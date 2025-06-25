# Go Code Organizer - Documentation

## Overview

Go Code Organizer adalah script bash yang powerful untuk menata ulang struktur file Go sesuai dengan standar coding yang optimal. Script ini tidak hanya mengorganisir kode, tetapi juga membersihkan code examples dalam komentar dan trailing comments yang tidak perlu.

## ✨ Key Features

### 🗑️ Smart Comment Cleaning
- **Code Example Detection**: Otomatis mendeteksi dan menghapus blok komentar yang berisi contoh kode
- **Trailing Comment Cleanup**: Membersihkan komentar dan whitespace berlebih di akhir file
- **License Header Preservation**: Mempertahankan header lisensi dan dokumentasi penting

### 📋 Perfect Code Organization
Script mengorganisir kode Go dalam urutan yang optimal:
1. **License Header** - Header lisensi atau copyright
2. **Package Declaration** - Deklarasi package
3. **Imports** - Import statements
4. **Constants** - Konstanta
5. **Variables** - Variabel global
6. **Types** - Type definitions (struct, interface, dll)
7. **Init & Main Functions** - Functions init() dan main()
8. **Controller Constructors** - Constructor functions untuk controller
9. **ControllerRegistry Constructors** - Constructor untuk registry
10. **ControllerRegistry Methods** - Method untuk registry
11. **Controller Public Methods** - Method public controller
12. **Controller Private Methods** - Method private controller

### 🛡️ Safety Features
- **Backup System**: Opsi untuk membuat backup otomatis
- **Interactive Prompts**: Konfirmasi sebelum melakukan perubahan
- **Error Handling**: Penanganan error yang robust

## 🚀 Installation

1. Download script `organizer.sh`
2. Berikan permission execute:
   ```bash
   chmod +x organizer.sh
   ```
3. Pastikan Python 3 terinstall (diperlukan untuk parsing kode)

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

Jika dijalankan tanpa parameter, script akan menampilkan help:

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

Script menggunakan algoritma cerdas untuk mendeteksi code examples dalam komentar:

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

Membersihkan akhir file dari:
- Komentar yang tidak perlu di akhir file
- Whitespace berlebihan
- Multi-line comment endings yang menggantung

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

Otomatis mendeteksi dan mempertahankan license headers yang ada, atau menambahkan header Nucleus Go jika diminta:

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
Saat menjalankan script, Anda akan ditanya tentang backup:

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
Jika backup diaktifkan, file asli akan disimpan dengan ekstensi `.backup`:
- `main.go` → `main.go.backup`
- `controller.go` → `controller.go.backup`

## 🔧 Technical Requirements

- **Bash**: Unix/Linux shell environment
- **Python 3**: Untuk parsing dan analisis kode Go
- **gofmt** (optional): Untuk formatting otomatis setelah reorganisasi

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

## 🔮 Future Enhancements

- Support for custom organization rules
- Integration with popular Go linters
- Configuration file support
- IDE plugin compatibility
- More granular comment filtering options

---

**Made with ❤️ for Go developers who love clean, organized code!**
