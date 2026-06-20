#!/bin/bash

# Target
TARGET_DIR="$HOME/Downloads"

# SAFETY CHECK: Set this to "true" to test, change to "false" to actually move files!
DRY_RUN=false

# Check if the directory actually exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR does not exist."
    exit 1
fi

if [ "$DRY_RUN" = true ]; then
    echo "=== RUNNING IN DRY-RUN MODE (No files will be moved) ==="
fi
echo "Target directory: $TARGET_DIR"
echo "----------------------------------------"

# Loop through every file in the target directory
for file in "$TARGET_DIR"/*; do
    
    # Skip if it's a directory instead of a file
    [ -d "$file" ] && continue
    
    # Extract the file extension and convert to lowercase
    ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    # Check if the file has no extension at all
    if [ "$file" = "$ext" ] || [ -z "$ext" ]; then
        SUBFOLDER="No_Extension"
    else
        # Determine the destination folder based on extension
        case "$ext" in
            jpg|jpeg|png|gif|bmp|svg|webp|tiff)   SUBFOLDER="Images" ;;
            pdf|doc|docx|txt|rtf|odt|pages)       SUBFOLDER="Documents" ;;
            xls|xlsx|csv|ods)                     SUBFOLDER="Spreadsheets" ;;
            ppt|pptx|key)                         SUBFOLDER="Presentations" ;;
            mp3|wav|wma|m4a|flac|aac)              SUBFOLDER="Audio" ;;
            mp4|mkv|mov|avi|wmv|flv|webm)         SUBFOLDER="Video" ;;
            zip|rar|7z|tar|gz|bz2)                SUBFOLDER="Archives" ;;
            sh|py|js|html|css|cpp|c|java|json)    SUBFOLDER="Code" ;;
            exe|msi|dmg|pkg|deb|rpm)              SUBFOLDER="Installers" ;;
            *)                                    SUBFOLDER="Miscellaneous" ;;
        esac
    fi
    
    DEST_DIR="$TARGET_DIR/$SUBFOLDER"
    
    # SAFETY LOGIC: If DRY_RUN is true, just print the action. If false, execute it.
    if [ "$DRY_RUN" = true ]; then
        echo "[WOULD MOVE] $(basename "$file") -> /$SUBFOLDER"
    else
        # Create folder if it doesn't exist
        if [ ! -d "$DEST_DIR" ]; then
            mkdir -p "$DEST_DIR"
        fi
        # Move the file
        mv "$file" "$DEST_DIR/"
        echo "Moved: $(basename "$file") -> /$SUBFOLDER"
    fi

done

echo "----------------------------------------"
echo "Process complete!"