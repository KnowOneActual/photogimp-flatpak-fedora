# PhotoGIMP on GIMP 3.2 (Flatpak/Linux)

[![ShellCheck](https://github.com/KnowOneActual/photogimp-flatpak-fedora/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/KnowOneActual/photogimp-flatpak-fedora/actions/workflows/shellcheck.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A simple script and setup to get PhotoGIMP theme working on GNU Image Manipulation Program (GIMP 3.2) (Flatpak or native packages). 

I put this together and tested on Fedora 44. It should work on other Linux distros too, but hasn't been tested on them yet.

<p align="center">
  <img src="assets/demo/photogimp_demo_11.gif" alt="PhotoGIMP Linux Demo" width="800">
</p>

### What is this for?
The official [Diolinux PhotoGIMP](https://github.com/Diolinux/PhotoGIMP) installer has desktop shortcuts that crash newer Flatpak versions of GIMP. This fixes that by copying only the UI configuration files and leaving the desktop files alone. You get the Photoshop-style layout without the app crashes.

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
3. Clone this repository and run the installer script:
   ```bash
   git clone https://github.com/KnowOneActual/photogimp-flatpak-fedora.git
   cd photogimp-flatpak-fedora
   chmod +x install.sh
   ./install.sh
   ```
4. **Clean up configuration (Recommended)**:
   - Launch GIMP 3.2 to trigger the automatic settings migration.
   - Once GIMP is running with the new theme, close GIMP.
   - Navigate to your GIMP configuration directory, back up the `3.0` folder to a zip file (optional), and delete the `3.0` directory to ensure GIMP loads smoother:
     ```bash
     cd ~/.config/GIMP  # Or ~/.var/app/org.gimp.GIMP/config/GIMP/ for Flatpak
     zip -r 3.0_backup.zip 3.0/  # optional backup
     rm -rf 3.0/
     ```

### Command Options:
- `-d, --dir PATH`: Specify path to the extracted `PhotoGIMP-linux` folder.
  ```bash
  ./install.sh --dir /path/to/extracted/PhotoGIMP-linux
  ```
- `-s, --splash STYLE`: Choose GIMP splash screen style. Options:
  - `brush`: Brush effect style (`splash-screen-brush-2026.png`, default)
  - `glassmorphic`: Glassmorphic gradient style (`splash-screen-glassmorphic-gradient_v3.png`)
  - `classic`: Clean / classic style (`splash-screen-2026-v3.png`)
  - `all`: Copy all of them (GIMP will select one at random on startup!)
  - `none`: Do not install any custom splash screen.
  
  *If run in an interactive terminal and no style is specified, the script will prompt you.*
- `-i, --icon-dir PATH`: Specify the directory path where the PhotoGIMP app icon will be saved (default: `~/Pictures/Assets/apps/PhotoGimp`).
  ```bash
  ./install.sh --icon-dir ~/.local/share/icons/PhotoGimp
  ```
- `--no-desktop-icon`: Disable automatic desktop icon override.

---

## 🛠️ How it works
1. **Validation**: It checks for required dependencies (`zip`, `unzip`) and warns if GIMP 3.2 is not detected.
2. **Backup**: It zips up your current GIMP `3.2` configuration folder and saves it as `3.2_old.zip` in your GIMP config directory.
3. **Copy**: It copies the PhotoGIMP layout to a `3.0` folder.
4. **Migrate**: The next time you open GIMP 3.2, it will notice the `3.0` directory and safely migrate the settings to `3.2` automatically.
5. **Cleanup (Post-Launch)**: Once migration is complete, the `3.0` folder is no longer needed. Zipping and deleting it helps GIMP load smoother and avoids redundancy.
6. **Assets & Icon Override**: It copies the application icon to `~/Pictures/Assets/apps/PhotoGimp/` and automatically attempts to set it in your local desktop launcher (`~/.local/share/applications/org.gimp.GIMP.desktop` or native equivalent).
7. **Splash Screen**: It copies the selected custom splash screen style(s) into GIMP's splashes directory. The splash image that is included with Diolinux was a little to busy for my liking.

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

## 💡 Tips & Customizations

### Why is the app icon saved in `~/Pictures/Assets/apps/PhotoGimp` by default?
Saving assets in a dedicated folder like `~/Pictures/Assets/` is a convenient way to organize custom assets so they are easily backed up, syncable across devices, and preserved for future system redeployments. 

However, if you prefer not to use this location, you can customize the icon destination path when running the script using the `-i` or `--icon-dir` option:
```bash
./install.sh --icon-dir ~/.local/share/icons/PhotoGimp
```

### How do I restore my custom settings (shortcuts, brushes, plugins, etc.)?
When the installer runs, it automatically backs up your existing GIMP configuration folder into a file called `3.2_old.zip` located in GIMP's config directory.

If you want to restore specific custom settings without completely overwriting the PhotoGIMP layout, you can selectively copy files from that backup:

1. **Locate your backup file**:
   - **Flatpak**: `~/.var/app/org.gimp.GIMP/config/GIMP/3.2_old.zip` (or `~/.config/GIMP/3.2_old.zip` on Fedora)
   - **Native**: `~/.config/GIMP/3.2_old.zip`
2. **Extract the backup to a temporary folder**:
   ```bash
   mkdir -p /tmp/gimp_old
   unzip ~/.config/GIMP/3.2_old.zip -d /tmp/gimp_old/  # adjust zip path if using Flatpak
   ```
3. **Copy the desired settings back to your new GIMP 3.2 configuration**:
   - **Custom Brushes**:
     ```bash
     cp -r /tmp/gimp_old/3.2/brushes/* ~/.config/GIMP/3.2/brushes/
     ```
   - **Keyboard Shortcuts / Menu entries**:
     ```bash
     cp /tmp/gimp_old/3.2/menurc ~/.config/GIMP/3.2/menurc
     ```
   - **Custom Plug-ins**:
     ```bash
     cp -r /tmp/gimp_old/3.2/plug-ins/* ~/.config/GIMP/3.2/plug-ins/
     ```
   - **Custom Scripts**:
     ```bash
     cp -r /tmp/gimp_old/3.2/scripts/* ~/.config/GIMP/3.2/scripts/
     ```
   - **Custom Window Layout / Session settings**:
     ```bash
     cp /tmp/gimp_old/3.2/sessionrc ~/.config/GIMP/3.2/sessionrc
     ```
4. **Restart GIMP** for the restored settings to take effect.
5. **Clean up**:
   ```bash
   rm -rf /tmp/gimp_old
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

### 2. Copy and Migrate the config
1. Copy the `3.0` folder from the extracted PhotoGIMP ZIP into your GIMP config directory. Keep the folder name as `3.0`.
2. Start GIMP to let it automatically migrate the settings to a new `3.2` folder.
3. Once migration is complete and GIMP is running with the new theme, close GIMP.
4. Clean up by zipping (optional) and deleting the obsolete `3.0` folder to help GIMP load smoother:
   ```bash
   zip -r 3.0_backup.zip 3.0/  # optional backup
   rm -rf 3.0/
   ```

### 3. Change the app icon
1. Copy the icon file:
   ```bash
   mkdir -p ~/Pictures/Assets/apps/PhotoGimp/
   cp assets/photogimp.png ~/Pictures/Assets/apps/PhotoGimp/photogimp.png
   ```
2. **Automatic**: The script will try to automatically duplicate and update the desktop entry to point to this path.
3. **Manual**: If using a custom desktop setup, you can manually override GIMP's icon:
   - **GNOME / general override file**: Copy GIMP's `.desktop` file to `~/.local/share/applications/` and edit the `Icon=` line:
     ```text
     Icon=/home/YOUR_USERNAME/Pictures/Assets/apps/PhotoGimp/photogimp.png
     ```
   - **KDE Menu Editor**: Open KDE Menu Editor, select "GNU Image Manipulation Program" in Graphics, and choose the path above as the application icon.

### 4. Custom splash screen
1. Create GIMP's splashes directory:
   ```bash
   mkdir -p ~/.config/GIMP/3.2/splashes/
   ```
2. Copy your desired splash screen image(s) (e.g. `splash-screen-glassmorphic-gradient_v3.png`):
   ```bash
   cp assets/splash-screen-glassmorphic-gradient_v3.png ~/.config/GIMP/3.2/splashes/
   ```

## ❤️ Community & Feedback

A huge thank you to everyone who has submitted issues, asked questions, and provided valuable feedback! Your input has helped improve this installer, making it more robust and flexible for everyone. If you have suggestions or encounter any issues, please feel free to open an issue or submit a pull request!

---

## 📄 License
This repo is MIT licensed. The actual PhotoGIMP layout and assets belong to [Diolinux](https://github.com/Diolinux/PhotoGIMP).
