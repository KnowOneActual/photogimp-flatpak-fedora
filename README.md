# PhotoGIMP on GIMP 3.2 (Flatpak/Linux)

[![ShellCheck](https://github.com/KnowOneActual/photogimp-flatpak-fedora/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/KnowOneActual/photogimp-flatpak-fedora/actions/workflows/shellcheck.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/KnowOneActual/photogimp-flatpak-fedora/blob/main/CONTRIBUTING.md)

This repository provides instructions and an automated script to configure **PhotoGIMP** on **GIMP 3.2.4** (Flatpak or native package managers). Developed and tested on Fedora 44, but fully compatible with any modern Linux distribution.

### Why This Fork?
The default configuration scripts in the official [Diolinux PhotoGIMP repository](https://github.com/Diolinux/PhotoGIMP) include launcher/desktop integration files that can crash modern Flatpak versions of GIMP. This project isolates the user interface modifications from the desktop integration files, preventing application crashes while giving you the full Photoshop-like experience in GIMP 3.2.

---

## 📋 Requirements

Before running the installer, ensure you have the following installed on your system:
- **GIMP 3.2.4** (Flatpak or native)
- **Unzip** & **Zip** command-line utilities (for backup and extraction)
- **Bash** (v4.0 or newer)

---

## 🚀 Automated Installation

1. **Install GIMP 3.2.4** using Flatpak or your system package manager.
2. **Launch GIMP once** to initialize the default configuration folders, then close it.
3. **Download the PhotoGIMP Linux ZIP package** from the [Diolinux PhotoGIMP repository](https://github.com/Diolinux/PhotoGIMP).
4. **Run the installer script** from this repository:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

### ⚙️ Script Options
By default, the script looks for `~/Downloads/PhotoGIMP-linux` or `~/Downloads/PhotoGIMP-linux.zip`. If you downloaded it elsewhere or have extracted it to a custom path, use the `--dir` option:
```bash
./install.sh --dir /path/to/extracted/PhotoGIMP-linux
```

---

## 🛠️ How it Works under the Hood

1. **Backup**: It zips your existing `3.2/` GIMP configuration folder and saves it as `3.2_old.zip` in the GIMP configuration directory.
2. **Setup**: It copies the PhotoGIMP config folder as `3.0/` under GIMP's directory (instead of writing directly into `3.2/`).
3. **Migration**: On the next startup of GIMP 3.2, GIMP automatically detects the `3.0/` folder, migrates the layout safely, and correctly populates a new `3.2/` layout without conflicts.
4. **Assets**: It places the application icon in `~/Pictures/Assets/apps/PhotoGimp/` and copies the custom splash screen to the configuration directory.

---

## ↩️ Reverting / Restoring Your Settings

If you wish to remove PhotoGIMP and restore your previous GIMP configuration:

1. Locate your GIMP configuration root directory:
   - **Flatpak**: `~/.var/app/org.gimp.GIMP/config/GIMP/` (or `~/.config/GIMP/` on Fedora 44)
   - **Native**: `~/.config/GIMP/`
2. Run the following commands (replace the directory paths with your target GIMP path if necessary):
   ```bash
   cd ~/.config/GIMP
   rm -rf 3.2 3.0
   unzip -q 3.2_old.zip
   ```
This will restore your old GIMP 3.2 workspace configuration exactly as it was.

---

## 📝 Manual Installation Steps

If you prefer to apply the configuration manually, follow these steps:

### 1. Back Up Your Config
Backup your existing `3.2` directory:
```bash
cd ~/.config/GIMP  # Use your specific config directory path
zip -r 3.2_old.zip 3.2/
rm -rf 3.2/
```

### 2. Apply Config
Copy the `3.0` configuration folder from the extracted PhotoGIMP directory to your target GIMP configuration directory *without* renaming it. GIMP 3.2 must be started to trigger the automatic migration process, which reads the `3.0` folder and creates a new, populated `3.2` directory containing the PhotoGIMP layout.

### 3. Change the Application Icon
1. Copy the `photogimp.png` file from the repository `assets/` folder to a stable directory:
   ```bash
   mkdir -p ~/Pictures/Assets/apps/PhotoGimp/
   cp assets/photogimp.png ~/Pictures/Assets/apps/PhotoGimp/photogimp.png
   ```
2. Open **KDE Menu Editor** (available in KDE Plasma on Fedora, launchable via KRunner).
3. Find the **GNU Image Manipulation Program** entry under **Graphics**.
4. Click the icon, select **Browse**, and point it to:
   `~/Pictures/Assets/apps/PhotoGimp/photogimp.png`
5. Save changes.

### 4. Custom Splash Screen
1. Create the `splashes` directory if it does not exist:
   ```bash
   mkdir -p ~/.config/GIMP/3.2/splashes/  # Use your GIMP configuration path
   ```
2. Copy the splash image from the `assets` folder:
   ```bash
   cp assets/splash-screen-brush-2026.png ~/.config/GIMP/3.2/splashes/
   ```

GIMP reads the `splashes` directory on startup. If multiple images are present, GIMP rotates between them randomly. Remove any default splash images in that folder to force GIMP to show only your new splash screen.

---

## 📄 License

This repository is licensed under the [MIT License](LICENSE).
PhotoGIMP patches and assets are owned by [Diolinux](https://github.com/Diolinux/PhotoGIMP).
