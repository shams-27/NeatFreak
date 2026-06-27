# NeatFreak

A Bash script that organizes your `Downloads` folder by sorting files into category subfolders — Images, Documents, Code, and more — with a live terminal UI, progress tracking, and conflict handling.

## Features

- Sorts files into `Images`, `Documents`, `Spreadsheets`, `Presentations`, `Audio`, `Video`, `Archives`, `Code`, `Installers`, `Fonts`, `Miscellaneous`, and `No_Extension`
- Case-insensitive extension matching
- Live progress bar with percentage, file counter, and ETA
- Per-file ticker with category icons (requires Nerd Font — auto-installed on first run)
- Conflict resolution — duplicate filenames are auto-renamed with a timestamp instead of overwritten
- Dry-run mode — preview all moves without touching any files
- Timestamped log at `$HOME/Downloads/.neatfreak.log`
- Skips dotfiles and subdirectories

## Requirements

- macOS or Linux
- Bash 4+
- `curl` (for Nerd Font auto-install, optional)

## Installation

```bash
git clone https://github.com/shams-27/NeatFreak.git
cd NeatFreak
chmod +x NeatFreak.sh
```

## Usage

```bash
./NeatFreak.sh            # organize Downloads
./NeatFreak.sh --dry-run  # preview only, no files moved
```

On first run, NeatFreak checks for a Nerd Font and offers to install JetBrainsMono Nerd Font automatically if none is found. After installing, set it as your terminal font and rerun.

## Output structure

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
├── Fonts/
├── Miscellaneous/
├── No_Extension/
└── .neatfreak.log
```

## Configuration

Edit the variables at the top of `NeatFreak.sh`:

| Variable      | Description                        | Default           |
|---------------|------------------------------------|-------------------|
| `TARGET_DIR`  | Directory to organize              | `$HOME/Downloads` |
| `VERSION`     | Script version string              | `2.0`             |

Dry-run is controlled via the `--dry-run` flag at runtime, not a hardcoded variable.

## File category mapping

| Category      | Extensions                                              |
|---------------|---------------------------------------------------------|
| Images        | jpg, jpeg, png, gif, bmp, svg, webp, tiff, ico, heic   |
| Documents     | pdf, doc, docx, txt, rtf, odt, pages, md, epub         |
| Spreadsheets  | xls, xlsx, csv, ods, numbers                           |
| Presentations | ppt, pptx, key, odp                                    |
| Audio         | mp3, wav, wma, m4a, flac, aac, ogg, opus               |
| Video         | mp4, mkv, mov, avi, wmv, flv, webm, m4v                |
| Archives      | zip, rar, 7z, tar, gz, bz2, xz, zst                   |
| Code          | sh, py, js, ts, html, css, cpp, c, h, java, json, yaml, yml, toml, xml, rb, go, rs, php, sql, kt, swift |
| Installers    | exe, msi, dmg, pkg, deb, rpm, appimage                 |
| Fonts         | ttf, otf, woff, woff2                                  |
| No_Extension  | files with no extension                                |
| Miscellaneous | anything else                                          |

To add a category, extend the `case` block in the main loop and add a matching entry to `folder_meta()` and `folder_color()`.

## Automating with cron

```bash
crontab -e
```

```
0 18 * * * /path/to/NeatFreak.sh >> /dev/null 2>&1
```

The script writes its own log to `.neatfreak.log` inside the target directory.

## Safety notes

- Files are **moved**, not copied. Run with `--dry-run` first if unsure.
- Conflicts are **never overwritten** — duplicates are renamed `filename_<timestamp>.ext` automatically.
- Only top-level files are processed; existing subfolders are left untouched.

## License

MIT