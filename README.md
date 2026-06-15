# Qt6Laz

Standalone Free Pascal framework for building cross-platform desktop applications using **Qt6** — no LCL dependency, MVVM architecture.

## Overview

Qt6Laz provides a pure Free Pascal API over Qt6, enabling modern, native-looking desktop applications without the Lazarus LCL widgetset layer. It uses:

- **Qt6** for the UI backend (widgets, painting, model/view, printing)
- **Free Pascal** (FPC 3.3.1+) as the implementation language
- **MVVM** (Model-View-ViewModel) pattern for data-driven UIs
- **Qt6 Model/View** with `QSortFilterProxyModel` for sorting and filtering

### Platform Support

| Platform | Architecture | Status |
|----------|-------------|--------|
| macOS 14+ | ARM64 (Apple Silicon) | Primary dev |
| Windows 10 21H2+ | x86_64 | Supported |
| Ubuntu 24.04 LTS+ | x86_64 | Supported |

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    View Layer (Qt6)                      │
│   QTableView, QTreeView, QLineEdit, QPushButton, etc.    │
├──────────────────────────────────────────────────────────┤
│                 Binding Layer (Pascal)                   │
│  Connects ViewModel → Qt6 View via QLCLAbstractItemModel │
├──────────────────────────────────────────────────────────┤
│                ViewModel Layer (Pascal)                  │
│   TBaseViewModel, TTableViewModel, TTreeViewModel        │
├──────────────────────────────────────────────────────────┤
│               Data Source Layer (Pascal)                 │
│          IDataSource: SQLdb, JSON, in-memory             │
└──────────────────────────────────────────────────────────┘
```

## Quick Start

### Prerequisites

- **Qt6** (6.2+ recommended, tested against 6.11.1)
  - macOS: `brew install qt@6`
  - Windows/Linux: [aqtinstall](https://github.com/miurahr/aqtinstall) or official installer
- **Free Pascal** 3.3.1+ ([fpc-lang.org](https://www.freepascal.org/))
- **C++ compiler** (for building the bridge)
  - macOS: Xcode Command Line Tools
  - Windows: MinGW-w64 (included with Qt)
  - Linux: GCC 11+

### Build

```bash
# 1. Build the Qt6Laz C++ bridge
cd bridge
qmake Qt6Laz.pro
make -j$(nproc)
cd ..

# 2. Build the Pascal framework
make framework

# 3. Build and run the minimal demo
make demo-minimal
./demos/demo.minimal/demo.minimal
```

## Project Structure

```
Qt6Laz/
├── bridge/          # Forked Qt6Pas C++ bridge (renamed Qt6Laz)
├── src/             # Pascal framework (Qt6 widget wrappers)
├── mvvm/            # MVVM layer (ViewModel + DataSource + Binding)
├── bridge-pas/      # Pascal declarations for bridge extensions
├── tests/           # FPCUnit tests
├── demos/           # Example applications
└── docs/            # Documentation
```

## License

LGPL-2.1 — same as the upstream Qt6Pas bridge. See [COPYING.LIB](COPYING.LIB).

The Qt6Laz bridge is derived from [Qt6Pas](http://wiki.freepascal.org/Qt6_binding) by Jan Van hijfte and Željan Rikalo, distributed under LGPL-2.1.
