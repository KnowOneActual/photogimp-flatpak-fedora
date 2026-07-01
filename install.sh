#!/usr/bin/env bash
set -euo pipefail

# photogimp-flatpak-fedora installer script
# Copies GIMP 3.0 PhotoGIMP configurations to GIMP 3.2 paths and installs assets.

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly DOWNLOADS_DIR="${HOME}/Downloads"
readonly PHOTOGIMP_EXTRACTED="${DOWNLOADS_DIR}/PhotoGIMP-linux"
readonly PHOTOGIMP_ZIP="${DOWNLOADS_DIR}/PhotoGIMP-linux.zip"
readonly ICON_DEST_DIR="${HOME}/Pictures/Assets/apps/PhotoGimp"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    log "ERROR: $*" >&2
    exit 1
}

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]
Options:
    -h, --help      Show this help message.
    -d, --dir PATH  Specify the path to the extracted PhotoGIMP-linux folder.
EOF
}

find_gimp_config_dir() {
    # Check ~/.config/GIMP first (Fedora Flatpak override/Native)
    local config_paths=(
        "${HOME}/.config/GIMP"
        "${HOME}/.var/app/org.gimp.GIMP/config/GIMP"
    )

    for path in "${config_paths[@]}"; do
        if [[ -d "$path" ]]; then
            echo "$path"
            return 0
        fi
    done

    # If neither exists but flatpak dir exists, use that
    if [[ -d "${HOME}/.var/app/org.gimp.GIMP" ]]; then
        mkdir -p "${HOME}/.var/app/org.gimp.GIMP/config/GIMP"
        echo "${HOME}/.var/app/org.gimp.GIMP/config/GIMP"
        return 0
    fi

    # Fallback to ~/.config/GIMP
    mkdir -p "${HOME}/.config/GIMP"
    echo "${HOME}/.config/GIMP"
}

main() {
    local photogimp_dir="$PHOTOGIMP_EXTRACTED"

    # Argument parsing
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -d|--dir)
                if [[ -z "${2:-}" ]]; then
                    error "Directory path required after -d/--dir"
                fi
                photogimp_dir="$2"
                shift 2
                ;;
            *)
                error "Unknown option: $1. Run with -h for usage."
                ;;
        esac
    done

    log "Starting PhotoGIMP configuration for GIMP 3.2..."

    # 1. Validate PhotoGIMP source directory
    if [[ ! -d "$photogimp_dir" ]]; then
        if [[ -f "$PHOTOGIMP_ZIP" ]]; then
            log "Extracted folder not found at ${photogimp_dir}, unzipping ${PHOTOGIMP_ZIP}..."
            unzip -q "$PHOTOGIMP_ZIP" -d "$DOWNLOADS_DIR"
        else
            error "PhotoGIMP source not found. Extract the ZIP to ${DOWNLOADS_DIR}/PhotoGIMP-linux or specify the path using the -d option."
        fi
    fi

    local source_config="${photogimp_dir}/.config/GIMP/3.0"
    if [[ ! -d "$source_config" ]]; then
        error "Source configuration directory not found at: ${source_config}"
    fi

    # 2. Locate destination GIMP config directory
    local dest_gimp_dir
    dest_gimp_dir=$(find_gimp_config_dir)
    local dest_32="${dest_gimp_dir}/3.2"
    local dest_30="${dest_gimp_dir}/3.0"

    log "Using GIMP configuration root: ${dest_gimp_dir}"

    # 3. Backup and clean up existing 3.2 configuration if present
    if [[ -d "$dest_32" ]]; then
        local backup_zip="${dest_gimp_dir}/3.2_old.zip"
        log "Existing 3.2 configuration folder found at ${dest_32}. Backing up to ${backup_zip}..."
        (cd "$dest_gimp_dir" && zip -r -q "3.2_old.zip" "3.2")
        log "Deleting existing 3.2 folder..."
        rm -rf "$dest_32"
    fi

    # 4. Remove any existing 3.0 configuration to prevent copy conflicts
    if [[ -d "$dest_30" ]]; then
        log "Removing existing 3.0 configuration folder at ${dest_30}..."
        rm -rf "$dest_30"
    fi

    # 5. Copy PhotoGIMP 3.0 configuration as 3.0 (GIMP 3.2 migrates it on startup)
    log "Copying PhotoGIMP configuration to ${dest_30}..."
    cp -r "$source_config" "$dest_30"

    # 6. Extract and copy application icon
    local source_icon="${photogimp_dir}/.local/share/icons/hicolor/photogimp.png"
    if [[ -f "$source_icon" ]]; then
        log "Creating assets directory: ${ICON_DEST_DIR}"
        mkdir -p "$ICON_DEST_DIR"
        log "Copying icon to: ${ICON_DEST_DIR}/photogimp.png"
        cp "$source_icon" "${ICON_DEST_DIR}/photogimp.png"
    else
        log "Warning: PhotoGIMP icon not found at ${source_icon}. Skipping icon copy."
    fi

    # 7. Copy custom splash screen if present in script assets
    local source_splash="${SCRIPT_DIR}/assets/splash-screen-brush-2026.png"
    if [[ -f "$source_splash" ]]; then
        local splash_dest_dir="${dest_30}/splashes"
        log "Creating splashes directory in 3.0 config: ${splash_dest_dir}"
        mkdir -p "$splash_dest_dir"
        log "Copying custom splash screen to: ${splash_dest_dir}/splash-screen-brush-2026.png"
        cp "$source_splash" "${splash_dest_dir}/splash-screen-brush-2026.png"
    fi

    log "PhotoGIMP configuration files applied."
    echo ""
    echo "=========================================================="
    echo "Manual post-installation steps required:"
    echo "=========================================================="
    echo "1. KDE Menu Icon Modification:"
    echo "   - Open KDE Menu Editor (via KRunner or right-click Application Launcher -> Edit Applications)"
    echo "   - Select 'GNU Image Manipulation Program' in the Graphics category"
    echo "   - Click the application icon button to change it"
    echo "   - Click 'Browse' in the bottom-left corner and select:"
    echo "     ${ICON_DEST_DIR}/photogimp.png"
    echo "   - Save changes"
    echo ""
    echo "2. Splash Screen Customization:"
    if [[ -f "$source_splash" ]]; then
        echo "   - The custom splash screen was copied to the 3.0 config directory."
        echo "     GIMP will automatically migrate this to ${dest_32}/splashes/ on startup."
    else
        echo "   - Create the splashes directory if it does not exist:"
        echo "     mkdir -p ${dest_30}/splashes"
        echo "   - Download a custom splash screen and place it inside that folder."
    fi
    echo "   - Note: GIMP must be launched to trigger the migration from 3.0 to 3.2 configuration."
    echo "=========================================================="
}

main "$@"
