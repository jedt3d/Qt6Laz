# AGENTS.md — Qt6Laz

## Project Purpose

Qt6Laz is a standalone Free Pascal framework for building cross-platform desktop
applications using Qt6. No LCL dependency. Uses MVVM architecture with Qt6
Model/View.

## Architecture

- **bridge/** — Forked Qt6Pas C++ bridge (renamed Qt6Laz), built as a shared library
- **src/** — Pascal wrappers for Qt6 widgets (QApplication, QWidget, QMainWindow, etc.)
- **mvvm/** — Pure Pascal MVVM layer (ViewModel, DataSource, Binding)
- **bridge-pas/** — Pascal declarations for custom bridge extensions
- **demos/** — Example applications
- **tests/** — FPCUnit tests

## Platform Targets

All platforms are **ARM64 only**:

| Platform | Dev Environment | CI Runner |
|----------|----------------|-----------|
| macOS | macOS 26 (native Apple Silicon) | `macos-26` |
| Windows | Windows 11 ARM64 (Parallels Desktop VM) | `windows-11-arm` |
| Linux | Ubuntu 26.04 ARM64 (Parallels Desktop VM) | `ubuntu-24.04-arm` |

## Toolchain

- **FPC:** `/Users/worajedt/Lazarus/fpc/bin/fpc` (v3.3.1, aarch64-darwin)
- **Qt6:** `/opt/homebrew/opt/qt@6/` (v6.11.1)
- **qmake:** `/opt/homebrew/opt/qt@6/bin/qmake`

## Build Commands

### Build the C++ bridge (macOS)

```bash
cd bridge
/opt/homebrew/opt/qt@6/bin/qmake Qt6Laz.pro -o build/Makefile
make -C build -j$(sysctl -n hw.ncpu)
```

Output: `bridge/build/Qt6Laz.framework`

### Compile Pascal framework + demo (macOS)

```bash
FPC=/Users/worajedt/Lazarus/fpc/bin/fpc
SRC=src
BRIDGE=bridge/build
DEMO=demos/demo.minimal

$FPC -Mobjfpc -Sh \
  -Fu"$SRC" \
  -Ff"$BRIDGE" \
  -k-rpath -k/opt/homebrew/lib \
  -k-rpath -k"$BRIDGE" \
  -FE"$DEMO" \
  "$DEMO/demo.minimal.lpr"
```

### Run the demo

```bash
DYLD_FRAMEWORK_PATH="bridge/build" demos/demo.minimal/demo.minimal
```

## Key Technical Notes

- The bridge requires `initPWideStrings()` called before any WideString operations.
  This is done in `qt6laz.core.pas` initialization section.
- Floating point exceptions must be masked when interfacing with Qt6 C++ code.
  Done via `SetExceptionMask()` in `qt6laz.core.pas` initialization section.
- On macOS, the framework is linked via `{$LINKFRAMEWORK Qt6Laz}` with empty
  external library name. Framework search path is provided via `-Ff` compiler flag.
- At runtime, set `DYLD_FRAMEWORK_PATH` to the bridge build directory for testing.

## Bridge Origin

The `bridge/` directory is forked from Lazarus trunk:
`lcl/interfaces/qt6/cbindings/` (629 source files). Upstream is Qt6Pas by
Jan Van hijfte and Željan Rikalo, LGPL-2.1.
