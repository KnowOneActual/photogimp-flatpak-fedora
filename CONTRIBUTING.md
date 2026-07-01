# Contributing to photogimp-flatpak-fedora

Thank you for your interest in contributing to this project! Contributions are welcome and highly appreciated.

## Getting Started

1. Fork the repository on GitHub.
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/photogimp-flatpak-fedora.git
   cd photogimp-flatpak-fedora
   ```
3. Create a branch for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Guidelines

### Code Quality & Linting
We use ShellCheck to ensure our installer script is robust, safe, and free from common bash bugs.

- Make sure you install ShellCheck locally.
- Run ShellCheck before committing:
  ```bash
  shellcheck install.sh
  ```
- No warnings or errors should be present.

### Testing
Test the script locally to make sure it handles files and directories correctly:
- Run it without arguments to test the default downloads path.
- Run it specifying a custom directory with `-d` / `--dir`.
- Check that GIMP's settings and assets are correctly backed up and replaced without breaking any active GIMP instances.

## Submitting a Pull Request

1. Commit your changes:
   ```bash
   git commit -m "Add some feature"
   ```
2. Push to your branch:
   ```bash
   git push origin feature/your-feature-name
   ```
3. Open a Pull Request on the main repository. Describe your changes clearly and explain why they are needed.
