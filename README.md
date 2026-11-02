# NEXUS — System Control Center

**A lightweight Windows system management tool built with PowerShell and WPF.**

NEXUS is a Windows desktop utility designed to provide a centralized interface for monitoring system information and managing common system maintenance tasks.

## Features

- **RAM Manager** — View memory usage and top memory-consuming processes.
- **Cache Cleaner** — Scan temporary files and clean supported cache locations.
- **Disk Manager** — View disk information and scan folder sizes.
- **Process Manager** — Monitor running processes and manage selected processes.
- **Startup Manager** — View startup applications and scheduled startup tasks.
- **Disk Optimization** — Analyze disk fragmentation and run supported optimization operations.
- **System Information** — Display CPU, motherboard, BIOS, RAM, GPU, Windows, and storage information.
- **Network Tools** — Check connectivity, ping hosts, perform DNS lookups, and flush DNS cache.
- **App Remover** — View and uninstall supported Windows applications.

## Screenshots

Screenshots will be added in a future update.

## Requirements

- Windows 10 or later
- PowerShell
- Administrator privileges may be required for certain operations
- NEXUS folder structure must remain intact when using the executable

## Installation

### Option 1: Download the executable

1. Open the [NEXUS GitHub repository](https://github.com/ilhamfandholi/NEXUS-System-Control-Center).
2. Download `NEXUS.exe` and the `Modules` folder.
3. Keep `NEXUS.exe` and `Modules` in the same directory.
4. Run `NEXUS.exe`.

### Option 2: Run from source

Clone the repository:

```powershell
git clone https://github.com/ilhamfandholi/NEXUS-System-Control-Center.git
```

Open the project directory:

```powershell
cd NEXUS-System-Control-Center
```

Run NEXUS:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\main.ps1"
```

## Project Structure

```text
NEXUS/
├── main.ps1
├── NEXUS.exe
├── README.md
├── .gitignore
└── Modules/
    ├── RAM.ps1
    ├── Cleaner.ps1
    ├── Disk.ps1
    ├── Process.ps1
    ├── Startup.ps1
    ├── Defrag.ps1
    ├── SystemInfo.ps1
    ├── Network.ps1
    └── AppRemover.ps1
```

## Technology Stack

- PowerShell
- Windows Presentation Foundation (WPF)
- XAML
- PS2EXE

## Disclaimer

NEXUS is provided as an open-source project for Windows system management and educational purposes.

Some operations may require administrator privileges. Review the operation before executing system-level changes.

Use this software at your own risk.

## Author

**Ilham Fandholi**

GitHub: [@ilhamfandholi](https://github.com/ilhamfandholi)

## License

License information has not yet been specified.
