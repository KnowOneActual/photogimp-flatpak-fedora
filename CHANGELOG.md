# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Added `-i` / `--icon-dir` command-line option to [install.sh](file:///home/user/github/photogimp-flatpak-fedora/install.sh) to specify a custom application icon directory (defaults to `~/Pictures/Assets/apps/PhotoGimp`).
- Added a **Tips & Customizations** section to [README.md](file:///home/user/github/photogimp-flatpak-fedora/README.md) explaining the rationale behind the default asset directory and outlining the step-by-step process to selectively restore/merge personal GIMP settings from automated backups.
- Added a **Community & Feedback** section to [README.md](file:///home/user/github/photogimp-flatpak-fedora/README.md) thanking contributors and users for their feedback.

### Fixed
- Fixed rigid asset location requirement by supporting custom icon paths via the new `--icon-dir` option.

## [1.0.0] - 2026-07-04

### Added
- Created the initial version of the PhotoGIMP Linux installer script for GIMP 3.2.
- Added automatic validation of system dependencies (`zip`, `unzip`) and detection of GIMP installation.
- Added automatic GIMP configuration backups (`3.2_old.zip`) before config deployment.
- Added interactive splash screen style options: `brush`, `glassmorphic`, `classic`, `all` (random), or `none`.
- Added automatic GIMP desktop launcher icon overrides.
- Added comprehensive documentation on manual and automated installation steps in [README.md](file:///home/user/github/photogimp-flatpak-fedora/README.md).
