# NeatFreak 

A lightweight Bash script that automatically organizes your `Downloads` folder by sorting files into category-based subfolders — Images, Documents, Spreadsheets, Code, and more.

No more digging through hundreds of mismatched files. Run it once, and NeatFreak tidies everything up based on file extension.

## Features

- **Automatic categorization** — sorts files into folders like `Images`, `Documents`, `Spreadsheets`, `Presentations`, `Audio`, `Video`, `Archives`, `Code`, `Installers`, and `Miscellaneous`
- **Case-insensitive extension matching** — `.JPG` and `.jpg` are treated the same
- **Handles extensionless files** — routed to a `No_Extension` folder instead of being skipped
- **Built-in dry-run mode** — preview exactly what will happen before any files are moved
- **Skips subdirectories** — only top-level files in the target directory are processed
- **Zero dependencies** — pure Bash, no external tools required

## Requirements

- macOS or Linux (or WSL on Windows)
- Bash (pre-installed on most systems)

## Installation

1. Clone this repository or download `NeatFreak.sh` directly.

   ```bash
   git clone https://github.com/shams-27/NeatFreak.git
   cd NeatFreak
   ```

2. Make the script executable:

   ```bash
   chmod +x NeatFreak.sh
   ```

## Usage

Run the script directly:

```bash
./NeatFreak.sh
```

By default, it targets `$HOME/Downloads`. Once run, your Downloads folder will look something like this:

```
Downloads/
├── Images/
├── Documents/
├── Spreadsheets/
├── Presentations/
├── Audio/
├── Video/
├── Archives/
├── Code/
├── Installers/
├── Miscellaneous/
└── No_Extension/
```

### Dry-run mode (recommended for first use)

Before letting NeatFreak move anything, test it in dry-run mode to preview what it *would* do — without touching a single file.

Open `NeatFreak.sh` and set:

```bash
DRY_RUN=true
```

Then run the script. You'll see output like:

```
=== RUNNING IN DRY-RUN MODE (No files will be moved) ===
Target directory: /Users/you/Downloads
----------------------------------------
[WOULD MOVE] resume.pdf -> /Documents
[WOULD MOVE] vacation.jpg -> /Images
[WOULD MOVE] script.py -> /Code
----------------------------------------
Process complete!
```

Once you're happy with the preview, set `DRY_RUN=false` and run it again to actually organize your files.

## Configuration

| Variable      | Description                                  | Default            |
|---------------|-----------------------------------------------|---------------------|
| `TARGET_DIR`  | The directory NeatFreak will organize         | `$HOME/Downloads`   |
| `DRY_RUN`     | If `true`, only previews actions (no moves)   | `false`             |

To organize a different folder, edit the `TARGET_DIR` variable at the top of the script:

```bash
TARGET_DIR="$HOME/Desktop"
```

### File category mapping

| Category        | Extensions |
|------------------|------------|
| Images           | jpg, jpeg, png, gif, bmp, svg, webp, tiff |
| Documents        | pdf, doc, docx, txt, rtf, odt, pages |
| Spreadsheets     | xls, xlsx, csv, ods |
| Presentations    | ppt, pptx, key |
| Audio            | mp3, wav, wma, m4a, flac, aac |
| Video            | mp4, mkv, mov, avi, wmv, flv, webm |
| Archives         | zip, rar, 7z, tar, gz, bz2 |
| Code             | sh, py, js, html, css, cpp, c, java, json |
| Installers       | exe, msi, dmg, pkg, deb, rpm |
| No_Extension     | files with no extension |
| Miscellaneous    | anything else not listed above |

Want to add or change a category? Just edit the `case` statement inside the script — each line maps one or more extensions to a folder name.

## Automating it (optional)

To run NeatFreak automatically on a schedule, add it to your crontab. For example, to run it every day at 6 PM:

```bash
crontab -e
```

Then add:

```
0 18 * * * /path/to/NeatFreak.sh >> /path/to/neatfreak.log 2>&1
```

## ⚠️ Safety notes

- This script **moves files**, it does not copy them. Always test with `DRY_RUN=true` first if you're unsure.
- Files with the same name as an existing file in the destination folder will be overwritten by `mv`. Back up anything important before running this on an unfamiliar directory.
- Only top-level files are processed; files inside subfolders of the target directory are left untouched.

## Contributing

Issues and pull requests are welcome! If you'd like to add support for more file types or features (e.g. conflict handling, logging, undo), feel free to open a PR.

## License

This project is licensed under the [MIT License](LICENSE).
