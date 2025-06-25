#!/bin/bash

# Remove Code Examples in Comments & Clean Trailing Comments
# Usage: ./organizer.sh -a -r -h
# Arguments: -a = all, -r = recursive, -h = with header comments

organize_go_file() {
    local file="$1"
    local add_header="$2"
    local create_backup="$3"
    local temp_file=$(mktemp)
    
    # Backup original (conditional)
    if [ "$create_backup" = "true" ]; then
        cp "$file" "${file}.backup"
    fi
    
    echo "🔧 Organizing: $file"
    if [ "$add_header" = "true" ]; then
        echo "📝 Adding license header..."
    fi
    
    # Python script with comment example removal AND trailing comment cleanup
    python3 - "$file" "$temp_file" "$add_header" << 'EOF'
import sys
import re

def get_license_header():
    return """/**
 * Nucleus Go - Schema-Driven Framework
 * 
 * Schema-driven architecture for rapid API development with automatic
 * REST & GraphQL endpoint generation, robust validation engine,
 * and seamless multi-database integration.
 * 
 * @package nucleus.geektech.id
 * @version 1.0.0
 * @author  GeekTech <https://geektech.id>
 * @license MIT
 */"""

def is_license_comment(content):
    content_lower = content.lower()
    keywords = ['license', 'copyright', 'author', '@package', 'nucleus']
    return any(keyword in content_lower for keyword in keywords)

def has_code_example(comment_content):
    """Check if comment contains code examples"""
    # Look for patterns that indicate code examples
    code_patterns = [
        r'func\s+\w+\s*\(',          # function definitions
        r'import\s+"',               # import statements
        r'package\s+\w+',            # package declarations
        r'\w+\.\w+\(',               # method calls like i18n.Init(
        r'var\s+\w+\s*=',            # variable declarations
        r'type\s+\w+\s+',            # type declarations
        r'if\s+.*\s*{',              # if statements
        r'for\s+.*\s*{',             # for loops
        r'^\s*//\s*\w+\.',           # commented method calls
    ]
    
    content = comment_content.lower()
    
    # Check for multiple code patterns
    pattern_count = 0
    for pattern in code_patterns:
        if re.search(pattern, content, re.MULTILINE):
            pattern_count += 1
    
    # If we find 2 or more code patterns, it's likely a code example
    return pattern_count >= 2

def clean_trailing_comments_and_whitespace(lines):
    """Remove trailing comments and excessive whitespace from end of file"""
    if not lines:
        return lines
    
    # Work backwards from the end to find the last meaningful content
    last_content_index = -1
    
    for i in range(len(lines) - 1, -1, -1):
        line = lines[i].strip()
        
        # Skip empty lines
        if not line:
            continue
            
        # Skip single-line comments at the end
        if line.startswith('//'):
            continue
            
        # Skip multi-line comment endings at the end
        if line == '*/' or line.endswith('*/'):
            continue
            
        # Found actual content - this is our cutoff point
        last_content_index = i
        break
    
    if last_content_index == -1:
        # No meaningful content found, return minimal structure
        return []
    
    # Keep content up to the last meaningful line, plus one empty line for clean ending
    result_lines = lines[:last_content_index + 1]
    
    # Ensure file ends with exactly one newline (clean ending)
    if result_lines and result_lines[-1].strip():
        result_lines.append('')
    
    return result_lines

def categorize_function(func_lines):
    if not func_lines:
        return "controller_public_methods"
    
    first_line = func_lines[0].strip()
    
    # Init and main functions (highest priority - placed right after types)
    if re.search(r'func init\(\)', first_line):
        return "init_and_main_functions"
    
    if re.search(r'func main\(\)', first_line):
        return "init_and_main_functions"
    
    # Controller constructors (NewXXXController)
    if re.search(r'func New\w*Controller\(', first_line):
        return "controller_constructors"
    
    # ControllerRegistry constructors
    if re.search(r'func New.*Registry\(', first_line):
        return "registry_constructors"
    
    # Method receivers
    if re.search(r'func \([^)]*\)', first_line):
        # ControllerRegistry methods
        if re.search(r'func \([^)]*\*?\w*Registry[^)]*\)', first_line):
            return "registry_methods"
        
        # Controller methods
        if re.search(r'func \([^)]*\*?\w*(Controller|Translator)[^)]*\)', first_line):
            # Public methods (start with capital letter)
            if re.search(r'func \([^)]*\) [A-Z]\w*\(', first_line):
                return "controller_public_methods"
            else:
                return "controller_private_methods"
        
        # Other methods
        if re.search(r'func \([^)]*\) [A-Z]\w*\(', first_line):
            return "controller_public_methods"
        else:
            return "controller_private_methods"
    
    # Other constructors
    if re.search(r'func New\w+\(', first_line):
        return "controller_constructors"
    
    # Standalone functions
    if re.search(r'func [a-z]\w*\(', first_line):
        return "controller_private_methods"
    
    return "controller_public_methods"

def organize_go_code(input_file, output_file, add_header):
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    lines = content.split('\n')
    
    # Sections with new init_and_main_functions category
    sections = {
        'license_header': [],
        'package': [],
        'imports': [],
        'constants': [],
        'variables': [],
        'types': [],
        'init_and_main_functions': [],       # New category - placed after types
        'controller_constructors': [],
        'registry_constructors': [],
        'registry_methods': [],
        'controller_public_methods': [],
        'controller_private_methods': [],
        'other_content': []
    }
    
    i = 0
    has_license = False
    
    while i < len(lines):
        line = lines[i].strip()
        original_line = lines[i]
        
        if not line:
            i += 1
            continue
        
        # Handle license header
        if not sections['package'] and (line.startswith('/**') or line.startswith('/*')):
            header_lines = [original_line]
            if '/**' in line and '*/' not in line:
                i += 1
                while i < len(lines) and '*/' not in lines[i]:
                    header_lines.append(lines[i])
                    i += 1
                if i < len(lines):
                    header_lines.append(lines[i])
            
            header_content = '\n'.join(header_lines)
            
            if is_license_comment(header_content):
                has_license = True
                sections['license_header'] = header_lines
                i += 1
                continue
        
        # Handle multi-line comments - CHECK FOR CODE EXAMPLES
        if (line.startswith('/*') and not line.startswith('/**')):
            comment_lines = [original_line]
            if '*/' not in line:
                i += 1
                while i < len(lines) and '*/' not in lines[i]:
                    comment_lines.append(lines[i])
                    i += 1
                if i < len(lines):
                    comment_lines.append(lines[i])
            
            comment_content = '\n'.join(comment_lines)
            
            # CHECK: Does this comment contain code examples?
            if has_code_example(comment_content):
                # SKIP this comment block entirely (remove it)
                print(f"🗑️ Removing code example comment block with {len(comment_lines)} lines")
                i += 1
                continue
            else:
                # Keep non-code comments
                sections['other_content'].extend(comment_lines)
                i += 1
                continue
        
        # Skip single-line comments before package
        if not sections['package'] and line.startswith('//'):
            i += 1
            continue
        
        # Package
        if line.startswith('package '):
            sections['package'].append(original_line)
            i += 1
            continue
        
        # Imports
        if line.startswith('import'):
            import_lines = [original_line]
            i += 1
            if '(' in original_line and ')' not in original_line:
                while i < len(lines) and ')' not in lines[i]:
                    import_lines.append(lines[i])
                    i += 1
                if i < len(lines):
                    import_lines.append(lines[i])
                    i += 1
            sections['imports'].extend(import_lines)
            continue
        
        # Constants
        if line.startswith('const'):
            const_lines = [original_line]
            i += 1
            
            # Check if this is a const block with parentheses
            if '(' in original_line and not ')' in original_line:
                # This is a const block like: const (
                # Count parentheses instead of braces
                paren_count = original_line.count('(') - original_line.count(')')
                while i < len(lines) and paren_count > 0:
                    const_lines.append(lines[i])
                    paren_count += lines[i].count('(') - lines[i].count(')')
                    i += 1
            # For simple const declarations like: const x = 5
            # No additional parsing needed, just the single line
            
            sections['constants'].append(const_lines)
            continue
        
        # Variables
        if line.startswith('var'):
            var_lines = [original_line]
            i += 1
            
            # Check if this is a var block with parentheses
            if '(' in original_line and not ')' in original_line:
                # This is a var block like: var (
                # Count parentheses instead of braces
                paren_count = original_line.count('(') - original_line.count(')')
                while i < len(lines) and paren_count > 0:
                    var_lines.append(lines[i])
                    paren_count += lines[i].count('(') - lines[i].count(')')
                    i += 1
            # For simple var declarations like: var x int
            # No additional parsing needed, just the single line
            
            sections['variables'].append(var_lines)
            continue
        
        # Types
        if line.startswith('type '):
            type_lines = [original_line]
            i += 1
            
            # Check if this is a type block with parentheses
            if '(' in original_line and original_line.strip().endswith('('):
                # This is a type block like: type (
                # Count parentheses instead of braces
                paren_count = 1  # We already have the opening paren
                while i < len(lines) and paren_count > 0:
                    type_lines.append(lines[i])
                    paren_count += lines[i].count('(') - lines[i].count(')')
                    i += 1
            elif '{' in original_line:
                # This is a type with struct/interface definition
                brace_count = original_line.count('{') - original_line.count('}')
                while i < len(lines) and brace_count > 0:
                    type_lines.append(lines[i])
                    brace_count += lines[i].count('{') - lines[i].count('}')
                    i += 1
            # For simple type aliases like: type MyInt int
            # No additional parsing needed, just the single line
            
            sections['types'].append(type_lines)
            continue
        
        # Single-line comments (keep these)
        if line.startswith('//'):
            sections['other_content'].append(original_line)
            i += 1
            continue
        
        # Functions - simple brace counting
        if line.startswith('func '):
            # Collect preceding comments
            comment_lines = []
            k = i - 1
            while k >= 0:
                prev_line = lines[k].strip()
                if prev_line.startswith('//'):
                    comment_lines.insert(0, lines[k])
                elif prev_line == '':
                    comment_lines.insert(0, lines[k])
                else:
                    break
                k -= 1
            
            # Get function with simple parsing
            func_lines = [original_line]
            i += 1
            brace_count = original_line.count('{') - original_line.count('}')
            
            if brace_count > 0:
                while i < len(lines) and brace_count > 0:
                    func_lines.append(lines[i])
                    brace_count += lines[i].count('{') - lines[i].count('}')
                    i += 1
            else:
                # Look for opening brace in next lines
                while i < len(lines):
                    func_lines.append(lines[i])
                    brace_count += lines[i].count('{') - lines[i].count('}')
                    if brace_count > 0:
                        i += 1
                        while i < len(lines) and brace_count > 0:
                            func_lines.append(lines[i])
                            brace_count += lines[i].count('{') - lines[i].count('}')
                            i += 1
                        break
                    i += 1
            
            # Categorize and store
            complete_function = comment_lines + func_lines
            category = categorize_function(func_lines)
            sections[category].append(complete_function)
            continue
        
        # Everything else
        sections['other_content'].append(original_line)
        i += 1
    
    # Prepare all content before cleaning trailing comments
    all_content_lines = []
    
    # License header
    if add_header == "true" and not has_license:
        all_content_lines.extend(get_license_header().split('\n'))
        all_content_lines.append('')
    elif sections['license_header']:
        all_content_lines.extend(sections['license_header'])
        all_content_lines.append('')
    
    # Package
    if sections['package']:
        all_content_lines.extend(sections['package'])
        all_content_lines.append('')
    
    # Imports
    if sections['imports']:
        all_content_lines.extend(sections['imports'])
        all_content_lines.append('')
    
    # Constants
    if sections['constants']:
        for const_block in sections['constants']:
            all_content_lines.extend(const_block)
            all_content_lines.append('')

    # Variables
    if sections['variables']:
        for var_block in sections['variables']:
            all_content_lines.extend(var_block)
            all_content_lines.append('')

    # Types
    if sections['types']:
        for type_block in sections['types']:
            all_content_lines.extend(type_block)
            all_content_lines.append('')
    
    # Functions in order
    for category in ['init_and_main_functions',           # First: init() and main()
                    'controller_constructors', 
                    'registry_constructors', 
                    'registry_methods', 
                    'controller_public_methods', 
                    'controller_private_methods']:
        if sections[category]:
            for func_block in sections[category]:
                all_content_lines.extend(func_block)
                all_content_lines.append('')
    
    # Other content (non-code comments, etc.)
    if sections['other_content']:
        all_content_lines.extend(sections['other_content'])
    
    # 🗑️ CLEAN TRAILING COMMENTS AND WHITESPACE
    cleaned_lines = clean_trailing_comments_and_whitespace(all_content_lines)
    
    # Write cleaned output
    with open(output_file, 'w', encoding='utf-8') as f:
        for line in cleaned_lines:
            f.write(line + '\n')

if __name__ == "__main__":
    organize_go_code(sys.argv[1], sys.argv[2], sys.argv[3])
EOF
    
    # Check if Python script succeeded
    if [ $? -eq 0 ]; then
        mv "$temp_file" "$file"
        
        # Format with gofmt
        if command -v gofmt >/dev/null 2>&1; then
            gofmt -w "$file"
            echo "✅ Organized, cleaned trailing comments, and formatted: $file"
        else
            echo "✅ Organized and cleaned trailing comments: $file"
        fi
        
        if [ "$create_backup" = "true" ]; then
            echo "📁 Backup saved as: ${file}.backup"
        else
            echo "⚡ No backup created"
        fi
    else
        echo "❌ Failed to organize $file"
        rm -f "$temp_file"
    fi
}

# Rest of the script... (keep all the existing functions and main logic)
ask_for_backup() {
    local file_count="$1"
    
    echo "🛡️  BACKUP OPTIONS:"
    echo ""
    echo "   You're about to organize $file_count Go files."
    echo "   This will modify your source code directly."
    echo ""
    echo "   Backup options:"
    echo "   [Y] Yes - Create .backup files (RECOMMENDED)"
    echo "   [N] No  - Skip backups (faster, but riskier)"
    echo "   [C] Cancel - Abort operation"
    echo ""
    
    while true; do
        read -p "Create backup files? (Y/n/c): " -n 1 -r
        echo
        
        case $REPLY in
            [Yy]|"")
                echo "✅ Will create backup files (.backup extension)"
                return 0
                ;;
            [Nn])
                echo "⚠️  Will NOT create backups!"
                read -p "Are you sure? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "⚡ Proceeding without backups"
                    return 1
                else
                    echo "👍 Smart choice! Will create backups"
                    return 0
                fi
                ;;
            [Cc])
                echo "❌ Operation cancelled"
                exit 0
                ;;
            *)
                echo "Please enter Y (yes), N (no), or C (cancel)"
                ;;
        esac
    done
}

find_go_files() {
    local search_dir="$1"
    local recursive="$2"
    
    if [ "$recursive" = "true" ]; then
        find "$search_dir" -name "*.go" -type f 2>/dev/null
    else
        find "$search_dir" -maxdepth 1 -name "*.go" -type f 2>/dev/null
    fi
}

# Main script
if [ $# -eq 0 ]; then
    echo "🚀 Nucleus Go Code Organizer"
    echo "Detects code examples and organize to meet Go coding standard."
    echo ""
    echo "Perfect Structure Order:"
    echo "  1. License Header"
    echo "  2. Package Declaration"
    echo "  3. Imports"
    echo "  4. Constants"
    echo "  5. Variables"
    echo "  6. Types"
    echo "  7. Init & Main Functions"
    echo "  8. Controller Constructors"
    echo "  9. ControllerRegistry Constructors"
    echo "  10. ControllerRegistry Methods"
    echo "  11. Controller Public Methods"
    echo "  12. Controller Private Methods"
    echo ""
    echo "Usage:"
    echo "  $0 <file.go> [file2.go ...]              # Organize specific files"
    echo "  $0 --all                                 # All .go files in current dir"
    echo "  $0 --recursive                           # All .go files recursively"
    echo "  $0 --dir <path>                          # All .go files in specific dir"
    echo "  $0 --recursive --dir <path>              # Recursive in specific dir"
    echo ""
    echo "Header options:"
    echo "  --with-header, -h                        # Add license header"
    echo ""
    echo "Backup options:"
    echo "  --backup                                 # Force create backups"
    echo "  --no-backup                              # Force skip backups"
    echo ""
    echo "🗑️ SMART FEATURES:"
    echo "✅ Detects code examples in /* */ comments"
    echo "✅ Removes comment blocks containing code"
    echo "✅ Cleans trailing comments at end of file"
    echo "✅ Preserves license headers and documentation"
    echo "✅ Perfect function organization"
    echo "✅ Clean, production-ready endings"
    echo "✅ Places init() and main() functions first"
    echo ""
    exit 1
fi

# Parse arguments (keep existing logic...)
add_header="false"
recursive="false"
process_all="false"
create_backup=""
search_dir="."
specific_files=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --with-header|-h)
            add_header="true"
            shift
            ;;
        --recursive|-r)
            recursive="true"
            process_all="true"
            shift
            ;;
        --all|-a)
            process_all="true"
            shift
            ;;
        --backup)
            create_backup="true"
            shift
            ;;
        --no-backup|--skip-backup)
            create_backup="false"
            shift
            ;;
        --dir|-d)
            search_dir="$2"
            process_all="true"
            shift 2
            ;;
        *.go)
            specific_files+=("$1")
            shift
            ;;
        *)
            echo "❌ Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check Python 3
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ Python 3 is required"
    exit 1
fi

# Determine files to process (keep existing logic...)
files_to_process=()

if [ "$process_all" = "true" ]; then
    if [ ! -d "$search_dir" ]; then
        echo "❌ Directory not found: $search_dir"
        exit 1
    fi
    
    echo "🔍 Searching for Go files in: $search_dir"
    if [ "$recursive" = "true" ]; then
        echo "🔄 Recursive mode enabled"
    fi
    
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            files_to_process+=("$file")
        fi
    done < <(find_go_files "$search_dir" "$recursive" | sort)
    
elif [ ${#specific_files[@]} -gt 0 ]; then
    for file in "${specific_files[@]}"; do
        if [ -f "$file" ]; then
            files_to_process+=("$file")
        else
            echo "⚠️  File not found: $file"
        fi
    done
else
    echo "❌ No files specified"
    exit 1
fi

# Check if any files found
if [ ${#files_to_process[@]} -eq 0 ]; then
    echo "❌ No Go files found to process"
    exit 1
fi

# Show initial summary
echo "🎯 Summary:"
echo "   Files to process: ${#files_to_process[@]}"
echo "   Add license header: $add_header"
echo "   Recursive: $recursive"
echo "   Search directory: $search_dir"
echo ""

# Interactive backup prompt (if not specified via flags)
if [ -z "$create_backup" ]; then
    ask_for_backup "${#files_to_process[@]}"
    if [ $? -eq 0 ]; then
        create_backup="true"
    else
        create_backup="false"
    fi
fi

# Process files
start_time=$(date +%s)
echo "🚀 Starting organization with code example + trailing comment removal..."
echo ""

for i in "${!files_to_process[@]}"; do
    file="${files_to_process[$i]}"
    current=$((i + 1))
    total=${#files_to_process[@]}
    
    echo "[$current/$total] Processing: $file"
    organize_go_file "$file" "$add_header" "$create_backup"
    echo "---"
done

end_time=$(date +%s)
duration=$((end_time - start_time))

echo ""
echo "🎉 Complete organization with trailing comment cleanup! 🗑️✨"
echo "📊 Processed ${#files_to_process[@]} files in ${duration}s"
echo ""
echo "🗑️ FEATURES APPLIED:"
echo "✅ Detected and removed code examples in comments"
echo "✅ Cleaned up trailing comments at end of files"
echo "✅ Perfect Nucleus Go structure organization"
echo "✅ Preserved license headers and documentation"
echo "✅ Clean, professional file endings"
echo "✅ Production-ready code"
echo "✅ Placed init() and main() functions first"
echo ""
echo "Ready for production! 🔥✨"