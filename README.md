# PhotoGIMP on GIMP 3.2 (Flatpak/Linux)

This repository provides instructions and an automated script to configure PhotoGIMP on GIMP 3.2.4 (Flatpak or native package managers). This configuration was developed and tested on Fedora 44, but it is compatible with other Linux distributions.

The default configuration scripts in the Diolinux PhotoGIMP repository include launcher configurations that can crash modern Flatpak versions of GIMP. This project isolates the user interface modifications from the desktop integration files, preventing application crashes.

## Automated Installation

1. Install GIMP 3.2.4 using Flatpak or your package manager.
2. Launch GIMP once to initialize default configuration folders.
3. Download the PhotoGIMP Linux ZIP package from the [Diolinux PhotoGIMP repository](https://github.com/Diolinux/PhotoGIMP).
4. Run the installer script:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

The script backs up your existing `3.2` configuration folder to `3.2_old.zip`, copies the PhotoGIMP configuration to the target directory as `3.0` (which triggers GIMP's automatic configuration migration to `3.2` on startup), and copies the custom splash screen image (`assets/splash-screen-brush-2026.png`) to GIMP's splashes directory.

By default, the script looks for `~/Downloads/PhotoGIMP-linux` or `~/Downloads/PhotoGIMP-linux.zip`. You can specify a custom folder path using the `-d` or `--dir` option:
```bash
./install.sh --dir /path/to/extracted/PhotoGIMP-linux
```

## Manual Installation Steps

If you prefer to apply the configuration manually, follow these steps:

### 1. Back Up Your Config

GIMP configuration directories:
- **Flatpak**: `~/.var/app/org.gimp.GIMP/config/GIMP/` (or `~/.config/GIMP/` on Fedora 44)
- **Native**: `~/.config/GIMP/`

Backup your existing `3.2` directory:
```bash
cd ~/.config/GIMP  # Use your specific config directory path
zip -r 3.2_old.zip 3.2/
rm -rf 3.2/
```

### 2. Apply Config

Copy the `3.0` configuration folder from the extracted PhotoGIMP directory to your target GIMP configuration directory *without* renaming it. GIMP 3.2 must be started to trigger the automatic migration process, which reads the `3.0` folder and creates a new, populated `3.2` directory containing the PhotoGIMP layout.

### 3. Change the Application Icon

1. Copy the `photogimp.png` file to a stable directory:
   ```bash
   mkdir -p ~/Pictures/Assets/apps/PhotoGimp/
   cp /path/to/PhotoGIMP-linux/.local/share/icons/hicolor/photogimp.png ~/Pictures/Assets/apps/PhotoGimp/photogimp.png
   ```
2. Open KDE Menu Editor (available in KDE Plasma on Fedora, launchable via KRunner).
3. Find the **GNU Image Manipulation Program** entry under Graphics.
4. Click the icon, select **Browse**, and point it to:
   `~/Pictures/Assets/apps/PhotoGimp/photogimp.png`
5. Save changes.

### 4. Custom Splash Screen

To add the custom splash screen included in this repository:
1. Create the `splashes` directory:
   ```bash
   mkdir -p ~/.config/GIMP/3.2/splashes/  # Use your GIMP configuration path
   ```
2. Copy the splash image from the `assets` folder:
   ```bash
   cp assets/splash-screen-brush-2026.png ~/.config/GIMP/3.2/splashes/
   ```

GIMP reads the `splashes` directory on startup. If multiple images are present, GIMP rotates between them randomly. Remove any default splash images in that folder to force GIMP to show only your new splash screen.
