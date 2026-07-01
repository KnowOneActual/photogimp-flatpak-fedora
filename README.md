# PhotoGIMP on GIMP 3.2 (Flatpak/Linux)

[![ShellCheck](https://github.com/KnowOneActual/photogimp-flatpak-fedora/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/KnowOneActual/photogimp-flatpak-fedora/actions/workflows/shellcheck.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A simple script and setup to get PhotoGIMP working on GIMP 3.2 (Flatpak or native packages). 

This was put together and tested on Fedora 44. It should work on other Linux distros too, but hasn't been tested on them yet.

### What is this for?
The official Diolinux PhotoGIMP installer has desktop shortcuts that crash newer Flatpak versions of GIMP. This fork fixes that by copying only the UI configuration files and leaving the desktop files alone. You get the Photoshop-style layout without the app crashes.

---

## 📋 Requirements
Make sure you have these installed:
- **GIMP 3.2** (Flatpak or native)
- **unzip** and **zip** (for backups/extracting files)
- **bash**

---

## 🚀 Quick Install

1. Install GIMP 3.2 and open it once so it creates its config folders.
2. Download the PhotoGIMP Linux ZIP from the [Diolinux PhotoGIMP repo](https://github.com/Diolinux/PhotoGIMP).
3. Clone this repo and run the script:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

By default, the script looks for `~/Downloads/PhotoGIMP-linux` or `~/Downloads/PhotoGIMP-linux.zip`. If you put it somewhere else, point to it with:
```bash
./install.sh --dir /path/to/extracted/PhotoGIMP-linux
```

---

## 🛠️ How it works
1. **Backup**: It zips up your current GIMP `3.2` configuration folder and saves it as `3.2_old.zip` in your GIMP config directory.
2. **Copy**: It copies the PhotoGIMP layout to a `3.0` folder.
3. **Migrate**: The next time you open GIMP 3.2, it will notice the `3.0` directory and safely migrate the settings to `3.2` automatically.
4. **Assets**: It places the application icon in `~/Pictures/Assets/apps/PhotoGimp/` and copies the custom splash screen to GIMP's splashes directory.

---

## ↩️ How to undo it
If you want to remove PhotoGIMP and go back to your old GIMP settings:

1. Go to your GIMP config directory:
   - **Flatpak**: `~/.var/app/org.gimp.GIMP/config/GIMP/` (or `~/.config/GIMP/` on Fedora)
   - **Native**: `~/.config/GIMP/`
2. Delete the new configuration and restore the backup:
   ```bash
   rm -rf 3.2 3.0
   unzip -q 3.2_old.zip
   ```

---

## 📝 Doing it manually
If you don't want to run the script, here's how to do it yourself:

### 1. Back up your current settings
```bash
cd ~/.config/GIMP  # adjust path to your GIMP config
zip -r 3.2_old.zip 3.2/
rm -rf 3.2/
```

### 2. Copy the config
Copy the `3.0` folder from the extracted PhotoGIMP ZIP into your GIMP config directory. Keep the folder name as `3.0`. Start GIMP to let it migrate the settings to a new `3.2` folder.

### 3. Change the app icon
1. Copy the icon file:
   ```bash
   mkdir -p ~/Pictures/Assets/apps/PhotoGimp/
   cp assets/photogimp.png ~/Pictures/Assets/apps/PhotoGimp/photogimp.png
   ```
2. Open **KDE Menu Editor** (or your desktop launcher editor).
3. Find **GNU Image Manipulation Program** under **Graphics**.
4. Set the icon to: `~/Pictures/Assets/apps/PhotoGimp/photogimp.png` and save.

### 4. Custom splash screen
1. Create GIMP's splashes directory:
   ```bash
   mkdir -p ~/.config/GIMP/3.2/splashes/
   ```
2. Copy the splash screen image:
   ```bash
   cp assets/splash-screen-brush-2026.png ~/.config/GIMP/3.2/splashes/
   ```

---

## 📄 License
This repo is MIT licensed. The actual PhotoGIMP layout and assets belong to [Diolinux](https://github.com/Diolinux/PhotoGIMP).
