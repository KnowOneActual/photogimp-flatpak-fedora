#!/usr/bin/env bash
set -euo pipefail

# photogimp-flatpak-fedora installer script
# Copies GIMP 3.0 PhotoGIMP configurations to GIMP 3.2 paths and installs assets.

SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_NAME
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_DIR
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
    -h, --help          Show this help message.
    -d, --dir PATH      Specify the path to the extracted PhotoGIMP-linux folder.
    -s, --splash STYLE  Specify the GIMP splash screen style to install.
                        Styles: brush, glassmorphic, classic, all, none.
                        (default: brush)
    --no-desktop-icon   Do not attempt to automatically create a desktop icon override.
EOF
}

check_dependencies() {
    local missing_deps=()
    for cmd in zip unzip; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}. Please install them (e.g., 'sudo dnf install zip unzip' on Fedora) and try again."
    fi
}

check_gimp_installation() {
    local gimp_found=false

    # Check if native gimp is in PATH
    if command -v gimp &>/dev/null || command -v gimp-3.2 &>/dev/null || command -v gimp-3.0 &>/dev/null; then
        gimp_found=true
    fi

    # Check if flatpak gimp is installed
    if ! "$gimp_found" && command -v flatpak &>/dev/null; then
        if flatpak info org.gimp.GIMP &>/dev/null; then
            gimp_found=true
        fi
    fi

    if ! "$gimp_found"; then
        log "Warning: GIMP 3.2 could not be detected on your system."
        log "         Make sure GIMP 3.2 is installed (Flatpak or Native) before running this script."
    fi
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

install_desktop_icon() {
    local icon_path="$1"
    local no_desktop_icon="$2"

    if [[ "$no_desktop_icon" = true ]]; then
        log "Skipping automatic desktop icon override (--no-desktop-icon specified)."
        return 1
    fi

    # List of candidate desktop files in order of preference
    local desktop_candidates=(
        "${HOME}/.local/share/flatpak/exports/share/applications/org.gimp.GIMP.desktop"
        "/var/lib/flatpak/exports/share/applications/org.gimp.GIMP.desktop"
        "/usr/share/applications/org.gimp.GIMP.desktop"
        "/usr/share/applications/gimp.desktop"
    )

    local source_desktop=""
    for candidate in "${desktop_candidates[@]}"; do
        if [[ -f "$candidate" ]]; then
            source_desktop="$candidate"
            break
        fi
    done

    # If not found, look for any desktop file containing 'gimp' in its name in system applications
    if [[ -z "$source_desktop" ]]; then
        local system_app_dir="/usr/share/applications"
        if [[ -d "$system_app_dir" ]]; then
            local found
            found=$(find "$system_app_dir" -maxdepth 1 -name "*gimp*.desktop" -print -quit 2>/dev/null)
            if [[ -n "$found" ]]; then
                source_desktop="$found"
            fi
        fi
    fi

    if [[ -n "$source_desktop" ]]; then
        local desktop_filename
        desktop_filename=$(basename "$source_desktop")
        local dest_dir="${HOME}/.local/share/applications"
        local dest_desktop="${dest_dir}/${desktop_filename}"

        log "Found GIMP desktop entry at: ${source_desktop}"
        log "Creating local applications directory: ${dest_dir}"
        mkdir -p "$dest_dir"

        log "Copying desktop entry to user directory: ${dest_desktop}"
        cp "$source_desktop" "$dest_desktop"

        log "Updating desktop entry icon to point to: ${icon_path}"
        sed -i "s|^Icon=.*|Icon=${icon_path}|" "$dest_desktop"

        log "Desktop icon override successfully installed. Your applications menu will update automatically."
        return 0
    else
        log "Warning: GIMP desktop entry file could not be automatically located. Skipping automatic icon override."
        return 1
    fi
}

main() {
    local photogimp_dir="$PHOTOGIMP_EXTRACTED"
    local splash_style=""
    local no_desktop_icon=false

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
            -s|--splash)
                if [[ -z "${2:-}" ]]; then
                    error "Splash style required after -s/--splash"
                fi
                splash_style="$2"
                shift 2
                ;;
            --no-desktop-icon)
                no_desktop_icon=true
                shift
                ;;
            *)
                error "Unknown option: $1. Run with -h for usage."
                ;;
        esac
    done

    # Check system dependencies
    check_dependencies

    # Check GIMP installation
    check_gimp_installation

    # If style is not specified, and the terminal is interactive, ask the user
    if [[ -z "$splash_style" ]]; then
        if [[ -t 0 && -t 1 ]]; then
            echo "Choose a custom GIMP splash screen style to install:"
            echo "  1) Brush (splash-screen-brush-2026.png) - Default"
            echo "  2) Glassmorphic Gradient (splash-screen-glassmorphic-gradient_v3.png)"
            echo "  3) Classic (splash-screen-2026-v3.png)"
            echo "  4) Random / Rotate All (installs all options)"
            echo "  5) None (do not install any custom splash screen)"
            read -rp "Enter choice [1-5, default: 1]: " choice
            case "$choice" in
                2) splash_style="glassmorphic" ;;
                3) splash_style="classic" ;;
                4) splash_style="all" ;;
                5) splash_style="none" ;;
                *) splash_style="brush" ;;
            esac
        else
            splash_style="brush"
        fi
    fi

    # Validate splash style
    case "$splash_style" in
        brush|glassmorphic|classic|all|none)
            ;;
        *)
            error "Invalid splash style: $splash_style. Choose from: brush, glassmorphic, classic, all, none."
            ;;
    esac

    log "Starting PhotoGIMP configuration for GIMP 3.2..."

    # 1. Validate PhotoGIMP source directory
    if [[ ! -d "$photogimp_dir" ]]; then
        if [[ -f "$PHOTOGIMP_ZIP" ]]; then
            log "Extracted folder not found at ${photogimp_dir}, unzipping ${PHOTOGIMP_ZIP}..."
            unzip -o -q "$PHOTOGIMP_ZIP" -d "$DOWNLOADS_DIR"
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
    if [[ ! -f "$source_icon" && -f "${SCRIPT_DIR}/assets/photogimp.png" ]]; then
        source_icon="${SCRIPT_DIR}/assets/photogimp.png"
    fi

    if [[ -f "$source_icon" ]]; then
        log "Creating assets directory: ${ICON_DEST_DIR}"
        mkdir -p "$ICON_DEST_DIR"
        log "Copying icon to: ${ICON_DEST_DIR}/photogimp.png"
        cp "$source_icon" "${ICON_DEST_DIR}/photogimp.png"
    else
        log "Warning: PhotoGIMP icon not found at ${source_icon} or in repository assets. Skipping icon copy."
    fi

    # Copy and modify desktop launcher icon override if applicable
    local desktop_override_status=1
    if [[ -f "${ICON_DEST_DIR}/photogimp.png" ]]; then
        if install_desktop_icon "${ICON_DEST_DIR}/photogimp.png" "$no_desktop_icon"; then
            desktop_override_status=0
        fi
    fi

    # 7. Copy custom splash screen(s) based on selected style
    if [[ "$splash_style" != "none" ]]; then
        local splash_dest_dir="${dest_30}/splashes"
        log "Creating splashes directory in 3.0 config: ${splash_dest_dir}"
        mkdir -p "$splash_dest_dir"

        local brush_src="${SCRIPT_DIR}/assets/splash-screen-brush-2026.png"
        local glass_src="${SCRIPT_DIR}/assets/splash-screen-glassmorphic-gradient_v3.png"
        local classic_src="${SCRIPT_DIR}/assets/splash-screen-2026-v3.png"

        case "$splash_style" in
            brush)
                if [[ -f "$brush_src" ]]; then
                    log "Copying Brush splash screen to: ${splash_dest_dir}/splash-screen-brush-2026.png"
                    cp "$brush_src" "${splash_dest_dir}/splash-screen-brush-2026.png"
                else
                    log "Warning: Brush splash screen not found at ${brush_src}."
                fi
                ;;
            glassmorphic)
                if [[ -f "$glass_src" ]]; then
                    log "Copying Glassmorphic Gradient splash screen to: ${splash_dest_dir}/splash-screen-glassmorphic-gradient_v3.png"
                    cp "$glass_src" "${splash_dest_dir}/splash-screen-glassmorphic-gradient_v3.png"
                else
                    log "Warning: Glassmorphic splash screen not found at ${glass_src}."
                fi
                ;;
            classic)
                if [[ -f "$classic_src" ]]; then
                    log "Copying Classic splash screen to: ${splash_dest_dir}/splash-screen-2026-v3.png"
                    cp "$classic_src" "${splash_dest_dir}/splash-screen-2026-v3.png"
                else
                    log "Warning: Classic splash screen not found at ${classic_src}."
                fi
                ;;
            all)
                log "Copying all available splash screens (GIMP will select one at random on startup)..."
                [[ -f "$brush_src" ]] && cp "$brush_src" "${splash_dest_dir}/splash-screen-brush-2026.png"
                [[ -f "$glass_src" ]] && cp "$glass_src" "${splash_dest_dir}/splash-screen-glassmorphic-gradient_v3.png"
                [[ -f "$classic_src" ]] && cp "$classic_src" "${splash_dest_dir}/splash-screen-2026-v3.png"
                ;;
        esac
    else
        log "Skipping splash screen installation (style set to none)."
    fi

    log "PhotoGIMP configuration files applied."
    echo ""
    echo "=========================================================="
    echo "Installation Summary & Next Steps:"
    echo "=========================================================="
    if [[ "$desktop_override_status" -eq 0 ]]; then
        echo "1. Desktop Icon Override: AUTOMATICALLY INSTALLED"
        echo "   - The application icon was successfully set to the PhotoGIMP icon."
        echo "   - If the icon doesn't update immediately, log out and back in."
    else
        echo "1. Desktop Icon Override: MANUAL STEP REQUIRED"
        echo "   - The GIMP desktop launcher file could not be modified automatically."
        echo "   - GNOME Users:"
        echo "     Copy GIMP's desktop file to ~/.local/share/applications/ and update the 'Icon=' line to:"
        echo "     ${ICON_DEST_DIR}/photogimp.png"
        echo "   - KDE Users:"
        echo "     Open KDE Menu Editor, find 'GNU Image Manipulation Program' under Graphics, and set its icon to:"
        echo "     ${ICON_DEST_DIR}/photogimp.png"
    fi
    echo ""
    echo "2. Splash Screen (Style: $splash_style):"
    if [[ "$splash_style" != "none" ]]; then
        echo "   - The selected splash screen image(s) were copied to the 3.0 config directory."
        echo "     GIMP will automatically migrate them to ${dest_32}/splashes/ on startup."
    else
        echo "   - No custom splash screen was installed."
    fi
    echo "   - Note: GIMP must be launched to trigger the migration from 3.0 to 3.2 configuration."
    echo ""
    echo "3. Post-Migration Cleanup (Recommended):"
    echo "   - Once GIMP has successfully launched and migrated the layout to 3.2, close GIMP."
    echo "   - Zip and delete the obsolete 3.0 directory to make GIMP load smoother."
    echo "   - Command (Optional backup & delete):"
    echo "     (cd \"${dest_gimp_dir}\" && zip -r 3.0_backup.zip 3.0 && rm -rf 3.0)"
    echo "=========================================================="
}

main "$@"
