# Go Code Organizer

**Professional Go code organization tool with smart comment cleanup**

[![Made by GeekTech](https://img.shields.io/badge/Made%20by-GeekTech-blue?style=flat-square)](https://geektech.id)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Go](https://img.shields.io/badge/Go-1.18+-00ADD8?style=flat-square&logo=go)](https://golang.org)

---

## Overview

Go Code Organizer is a powerful bash script designed to restructure Go files according to optimal coding standards. Beyond simple organization, it intelligently detects and removes code examples from comments while cleaning up unnecessary trailing comments, resulting in production-ready, clean code.

**Developed by [GeekTech](https://geektech.id) - Empowering developers with professional tools.**

## ✨ Key Features

### 🗑️ Smart Comment Cleaning
- **Code Example Detection**: Automatically detects and removes comment blocks containing code snippets
- **Trailing Comment Cleanup**: Removes unnecessary comments and excessive whitespace at file endings
- **License Header Preservation**: Maintains important license headers and documentation

### 📋 Perfect Code Organization
The script organizes Go code in optimal order:
1. **License Header** - Copyright and license information
2. **Package Declaration** - Package statement
3. **Imports** - Import statements
4. **Constants** - Constant declarations
5. **Variables** - Global variables
6. **Types** - Type definitions (struct, interface, etc.)
7. **Init & Main Functions** - init() and main() functions
8. **Controller Constructors** - Constructor functions for controllers
9. **ControllerRegistry Constructors** - Registry constructors
10. **ControllerRegistry Methods** - Registry methods
11. **Controller Public Methods** - Public controller methods
12. **Controller Private Methods** - Private controller methods

### 🛡️ Safety Features
- **Backup System**: Optional automatic backup creation
- **Interactive Prompts**: Confirmation before making changes
- **Error Handling**: Robust error handling and validation

## 🚀 Installation

1. Download the `organizer.sh` script
2. Make it executable:
   ```bash
   chmod +x organizer.sh
   ```
3. Ensure Python 3 is installed (required for code parsing)

## 📖 Usage

### Basic Usage

```bash
# Organize specific files
./organizer.sh file1.go file2.go file3.go

# Organize all .go files in current directory
./organizer.sh --all

# Organize all .go files recursively
./organizer.sh --recursive

# Organize files in specific directory
./organizer.sh --dir /path/to/project

# Recursive mode in specific directory
./organizer.sh --recursive --dir /path/to/project
```

### Advanced Options

```bash
# Add license header to files
./organizer.sh --with-header file.go
./organizer.sh -h --all

# Backup options
./organizer.sh --backup --all          # Force create backups
./organizer.sh --no-backup --all       # Skip backups

# Combined usage
./organizer.sh --recursive --with-header --backup --dir ./src
```

### Interactive Mode

Run without parameters to see help:

```bash
./organizer.sh
```

## ⚙️ Command Line Options

| Option | Short | Description |
|--------|-------|-------------|
| `--all` | `-a` | Process all .go files in current directory |
| `--recursive` | `-r` | Process files recursively |
| `--dir <path>` | `-d <path>` | Specify directory to process |
| `--with-header` | `-h` | Add license header to files |
| `--backup` | | Force create backup files |
| `--no-backup` | | Skip backup creation |

## 🧠 Smart Features Explained

### Code Example Detection

The script uses intelligent algorithms to detect code examples in comments:

```go
/*
Example usage:
func main() {
    i18n.Init()
    controller := NewUserController()
    // This entire comment block will be REMOVED
}
*/
```

**Detection Patterns:**
- Function definitions (`func name()`)
- Import statements (`import "package"`)
- Package declarations (`package main`)
- Method calls (`object.method()`)
- Variable declarations (`var x = value`)
- Type declarations (`type Name struct`)
- Control structures (`if`, `for`)

### Trailing Comment Cleanup

Cleans file endings from:
- Unnecessary comments at end of files
- Excessive whitespace
- Hanging multi-line comment endings

**Before:**
```go
func main() {
    fmt.Println("Hello")
}

// Some trailing comment
// Another comment

/*
More comments at the end
*/


```

**After:**
```go
func main() {
    fmt.Println("Hello")
}
```

### License Header Management

Automatically detects and preserves existing license headers, or adds Nucleus Go header when requested:

```go
/**
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
 */
```

## 📂 File Organization Examples

### Before Organization
```go
// Random comments

func (c *UserController) GetUser() {
    // implementation
}

var globalVar = "something"

func NewUserController() *UserController {
    return &UserController{}
}

const API_VERSION = "v1"

package main

import "fmt"

func init() {
    // initialization
}

type UserController struct {
    // fields
}
```

### After Organization
```go
package main

import "fmt"

const API_VERSION = "v1"

var globalVar = "something"

type UserController struct {
    // fields
}

func init() {
    // initialization
}

func NewUserController() *UserController {
    return &UserController{}
}

func (c *UserController) GetUser() {
    // implementation
}
```

## 🛡️ Backup System

### Interactive Backup Prompt
When running the script, you'll be prompted about backups:

```
🛡️  BACKUP OPTIONS:

   You're about to organize 5 Go files.
   This will modify your source code directly.

   Backup options:
   [Y] Yes - Create .backup files (RECOMMENDED)
   [N] No  - Skip backups (faster, but riskier)
   [C] Cancel - Abort operation

Create backup files? (Y/n/c):
```

### Backup Files
When backups are enabled, original files are saved with `.backup` extension:
- `main.go` → `main.go.backup`
- `controller.go` → `controller.go.backup`

## 🔧 Technical Requirements

- **Bash**: Unix/Linux shell environment
- **Python 3**: For code parsing and analysis
- **gofmt** (optional): For automatic formatting after reorganization

## 📊 Performance & Results

### Sample Output
```
🚀 Starting organization with code example + trailing comment removal...

[1/3] Processing: ./main.go
🔧 Organizing: ./main.go
🗑️ Removing code example comment block with 8 lines
✅ Organized, cleaned trailing comments, and formatted: ./main.go
---

[2/3] Processing: ./controller.go
🔧 Organizing: ./controller.go
✅ Organized, cleaned trailing comments, and formatted: ./controller.go
---

🎉 Complete organization with trailing comment cleanup! 🗑️✨
📊 Processed 3 files in 2s

🗑️ FEATURES APPLIED:
✅ Detected and removed code examples in comments
✅ Cleaned up trailing comments at end of files
✅ Perfect Nucleus Go structure organization
✅ Preserved license headers and documentation
✅ Clean, professional file endings
✅ Production-ready code
✅ Placed init() and main() functions first

Ready for production! 🔥✨
```

## 🚨 Important Notes

### What Gets Removed
- **Code example comments**: Multi-line comments containing code snippets
- **Trailing comments**: Comments at the end of files
- **Excessive whitespace**: Multiple empty lines at file end

### What Gets Preserved
- **License headers**: Detected by keywords like 'license', 'copyright', 'author'
- **Documentation comments**: Important documentation that's not code examples
- **Inline comments**: Comments within code blocks
- **Function documentation**: Comments directly above functions

### Safety Considerations
- Always use backup option for important code
- Test on a small subset first
- Review changes before committing to version control
- The script modifies files in-place

## 🎯 Best Practices

1. **Always backup** important code before running
2. **Test on sample files** first to understand behavior
3. **Use version control** as additional safety net
4. **Review changes** after organization
5. **Run gofmt** if not automatically applied
6. **Check build status** after reorganization

## 🐛 Troubleshooting

### Common Issues

**Error: "Python 3 is required"**
```bash
# Install Python 3
sudo apt update && sudo apt install python3  # Ubuntu/Debian
brew install python3                         # macOS
```

**Error: "Permission denied"**
```bash
# Make script executable
chmod +x organizer.sh
```

**No files found**
```bash
# Check if .go files exist in specified directory
ls *.go
# Or check with find
find . -name "*.go"
```

### Getting Help

Run script without arguments to see help:
```bash
./organizer.sh
```

## 🤝 Contributing

We welcome contributions! Please feel free to submit issues, feature requests, or pull requests.

Visit [GeekTech](https://geektech.id) for more professional development tools and resources.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔮 Future Enhancements

- Support for custom organization rules
- Integration with popular Go linters
- Configuration file support
- IDE plugin compatibility
- More granular comment filtering options

---

**Created with ❤️ by [GeekTech](https://geektech.id) - Empowering developers worldwide with professional tools and solutions.**

*For more awesome developer tools and resources, visit [geektech.id](https://geektech.id)*
