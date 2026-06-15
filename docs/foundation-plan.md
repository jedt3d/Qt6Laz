# Qt6Laz — Foundation Project Plan

> **Status:** Approved — Phase 0 ready to execute
> **Last Updated:** 2026-06-15
> **Repo:** `git@github.com:jedt3d/Qt6Laz.git` (public)
> **License:** LGPL-2.1 (matching Qt6Pas upstream)
> **CI:** Unlimited free minutes (public repo)

---

## 1. Overview

**Qt6Laz** is a standalone Free Pascal framework for building cross-platform
desktop applications using Qt6 as the UI backend — **no LCL dependency**. It uses
MVVM architecture with Qt6's Model/View/Delegate pattern for data-driven UIs.

The first dogfood application is a **code-centric IDE tool**: project browser,
code editor with syntax highlighting, output panel, and property inspector —
similar to Lazarus but modern.

### Platform Targets (Locked)

| Platform | Architecture | Dev OS Version | Min Deployment Target | Qt6 Channel |
|----------|-------------|----------------|-----------------------|-------------|
| **macOS** | **ARM64 / Apple Silicon** | macOS 26 (Tahoe) | macOS 14 (Sonoma) | Homebrew `qt@6` |
| **Windows** | **ARM64** | Windows 11 25H2 (Parallels VM) | Windows 11 ARM64 | `aqtinstall` or official Qt installer |
| **Linux** | **ARM64 (aarch64)** | Ubuntu 26.04 LTS (Parallels VM) | Ubuntu 24.04 LTS ARM64 | `aqtinstall` |

**All three platforms are ARM64.** No x86_64 or Intel builds are produced. This
unifies the architecture across all targets — the same CPU instruction set on
every platform, simplifying debugging and reducing build variants.

**Testing strategy:** All three platforms are tested locally on the developer's
Mac via **Parallels Desktop**:
- macOS 26 — native (no VM)
- Windows 11 ARM64 — Parallels Desktop VM
- Linux ARM64 (Ubuntu 26.04) — Parallels Desktop VM

GitHub CI provides automated build verification on all three platforms. Manual
GUI testing is done locally on the Paralleles VMs.

**Local dev machines vs CI runners:**

| | Local Dev Machine | GitHub CI Runner | CI Runner Label |
|--|--|--|--|
| macOS | macOS 26 Tahoe (Apple Silicon, native) | macOS 26, ARM64 | `macos-26` |
| Windows | Windows 11 25H2 ARM64 (Parallels VM) | Windows 11, ARM64 | `windows-11-arm` (public preview) |
| Linux | Ubuntu 26.04 LTS ARM64 (Parallels VM) | Ubuntu, ARM64 | `ubuntu-24.04-arm` |

---

## 2. Repository Structure

```
Qt6Laz/
├── README.md
├── LICENSE                         # LGPL-2.1
├── COPYING.LIB                     # LGPL-2.1 full text
├── .gitignore
├── Makefile                        # Top-level orchestrator
├── AGENTS.md                       # AI agent instructions
│
├── bridge/                         # Forked + modified Qt6Pas C++ bridge
│   ├── Qt6Laz.pro                  # qmake project (renamed from Qt6Pas.pro)
│   ├── README.BRIDGE.md            # What we changed from upstream
│   ├── src/
│   │   ├── chandles.h
│   │   ├── pascalbind.h / pascalbind.cpp
│   │   ├── flatfuncs.h / flatfuncs.cpp
│   │   ├── qobject_*.h / qobject_*.cpp          # (all upstream files)
│   │   ├── ...                                        # (all upstream Qt6Pas files)
│   │   │
│   │   │   # NEW FILES (added by us):
│   │   ├── qlclabstractitemmodel.h               # Pascal-callable QAbstractTableModel subclass
│   │   ├── qlclabstractitemmodel_c.h / _c.cpp     # Flat C wrappers
│   │   └── qlclabstractlistmodel.h               # (future) for QListView custom models
│   │
│   ├── build/                      # Build artifacts (gitignored)
│   │   ├── macos/                  # Qt6Laz.framework
│   │   ├── win64/                  # Qt6Laz.dll
│   │   └── linux/                  # Qt6Laz.so
│   └── Makefile.bridge             # Bridge build helper
│
├── src/                            # Pascal framework source (Qt6 wrappers)
│   ├── qt6laz.core.pas             # Qt6 type definitions, opaque handles, constants
│   ├── qt6laz.app.pas              # QApplication lifecycle, event loop
│   ├── qt6laz.widget.pas           # Base QWidget wrapper
│   ├── qt6laz.window.pas           # QMainWindow (menu, toolbar, dock, status, central)
│   ├── qt6laz.layout.pas           # Layout managers (HBox, VBox, Grid, Splitter)
│   ├── qt6laz.controls.basic.pas   # Label, Button, CheckBox, RadioButton, GroupBox
│   ├── qt6laz.controls.input.pas   # LineEdit, SpinBox, ComboBox, DateTimeEdit, Memo
│   ├── qt6laz.controls.container.pas # TabWidget, ScrollArea, StackedWidget
│   ├── qt6laz.controls.dialog.pas  # Dialog base, MessageBox, FileDialog, InputDialog
│   ├── qt6laz.treeview.pas         # QTreeView wrapper
│   ├── qt6laz.listview.pas         # QListView / QListWidget wrapper
│   ├── qt6laz.datagrid.pas         # QTableView + QSortFilterProxyModel
│   ├── qt6laz.dockwidget.pas       # QDockWidget wrapper
│   ├── qt6laz.actions.pas          # QAction, QShortcut
│   ├── qt6laz.menus.pas            # QMenuBar, QMenu, context menus
│   ├── qt6laz.toolbar.pas          # QToolBar
│   ├── qt6laz.statusbar.pas        # QStatusBar
│   ├── qt6laz.icon.pas             # QIcon, QPixmap, image loading
│   ├── qt6laz.theme.pas            # QStyle, themes, palette, font management
│   ├── qt6laz.clipboard.pas        # Clipboard read/write
│   └── qt6laz.print.pas            # QPrinter, print dialog, preview
│
├── mvvm/                           # MVVM layer (pure Pascal, no Qt6 dependency)
│   ├── qt6laz.viewmodel.base.pas   # TBaseViewModel (abstract)
│   ├── qt6laz.viewmodel.table.pas  # TTableViewModel (for QTableView)
│   ├── qt6laz.viewmodel.tree.pas   # TTreeViewModel (for QTreeView)
│   ├── qt6laz.viewmodel.list.pas   # TListViewModel (for QListView)
│   ├── qt6laz.model.datasource.pas # IDataSource interface
│   ├── qt6laz.model.sqlquery.pas   # TSQLQueryDataSource (SQLdb-backed)
│   ├── qt6laz.model.sqltable.pas   # TSQLTableDataSource (single table CRUD)
│   ├── qt6laz.model.json.pas       # TJSONDataSource (fpJSON-backed, for testing)
│   └── qt6laz.binding.pas          # Model→Qt bridge: connects ViewModel → Qt6 View
│
├── bridge-pas/                     # Pascal declarations for custom bridge extensions
│   └── qt6laz.bridge.model.pas     # QLCLAbstractItemModel Pascal types + cdecl externs
│
├── utils/                          # Build & development utilities
│   ├── build_bridge.sh             # Build Qt6Laz bridge (platform-aware)
│   ├── setup_qt6_macos.sh          # Install Qt6 on macOS (Homebrew)
│   ├── setup_qt6_windows.ps1       # Install Qt6 on Windows (aqtinstall)
│   ├── setup_qt6_linux.sh          # Install Qt6 on Linux (aqtinstall or apt)
│   └── test_bridge.sh              # Verify bridge loads correctly
│
├── tests/                          # FPCUnit tests (console runners)
│   ├── test_runner.lpr             # Main FPCUnit console runner
│   ├── test_runner.lpi
│   ├── tests.viewmodel.base.pas
│   ├── tests.viewmodel.table.pas
│   ├── tests.model.json.pas
│   └── tests.bridge.model.pas      # (needs Qt6 loaded — optional in CI)
│
├── demos/                          # Example applications
│   ├── demo.minimal.lpi / .lpr     # Empty window — proves build pipeline
│   ├── demo.controls.lpi / .lpr   # All basic controls in a scrollable form
│   ├── demo.datagrid.lpi / .lpr    # QTableView + TTableViewModel + TJSONDataSource
│   └── demo.ide.lpi / .lpr         # First IDE-like tool (dogfood target)
│
├── docs/
│   ├── foundation-plan.md          # THIS FILE
│   ├── architecture.md             # MVVM + Qt6 Model/View architecture
│   ├── getting-started.md          # Installation, first build, first app
│   ├── bridge-internals.md         # Qt6Laz bridge internals, how to add classes
│   ├── control-catalog.md          # Available controls, API, examples
│   ├── platform-matrix.md          # Platform-specific notes and gotchas
│   └── roadmap.md                  # Development phases and status
│
└── .github/
    └── workflows/
        ├── build-macos.yml         # macOS ARM64: bridge + framework + tests
        ├── build-windows.yml       # Windows ARM64: bridge + framework + tests
        └── build-linux.yml         # Linux ARM64: bridge + framework + tests
```

---

## 3. Build Pipeline Architecture

Each platform builds **natively** on its target OS and CPU. There is no
cross-compilation between platforms — the C++ bridge must be compiled on each
platform with that platform's Qt6 SDK and native C++ compiler.

```
┌──────────────────────────────────────────────────────────────┐
│  Phase 1: Qt6Laz Bridge (C++ → shared library / framework)    │
│                                                                │
│  Input:  Qt6 SDK (installed system-wide or via aqtinstall)     │
│  Tool:   qmake + make (C++17 compiler required)                │
│  Output:                                                       │
│    macOS   → Qt6Laz.framework  (ARM64)                         │
│    Windows → Qt6Laz.dll        (ARM64)                        │
│    Linux   → Qt6Laz.so         (ARM64)                        │
│                                                                │
│  Built natively on each platform — no cross-compile.           │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│  Phase 2: Pascal Framework (FPC → units .ppu/.o)              │
│                                                                │
│  Input:  Qt6Laz bridge (linked at runtime)                     │
│  Tool:   fpc 3.3.1 (local from /Users/worajedt/Lazarus/fpc/)   │
│  Output: .ppu/.o units + test runners                          │
│                                                                │
│  Pure Pascal — compiles on any platform FPC supports.          │
│  Links against bridge at runtime via dynamic loading.          │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│  Phase 3: Application (FPC → executable)                      │
│                                                                │
│  Input:  Framework units + application code                    │
│  Tool:   fpc or lazbuild                                       │
│  Output: Native executable                                      │
│                                                                │
│  Runtime: Requires Qt6Laz bridge + Qt6 runtime libraries.      │
│  Deploy: Ship bridge + Qt6 libs alongside executable.          │
└──────────────────────────────────────────────────────────────┘
```

### Runtime Dependency Chain

```
YourApp (Pascal executable)
  └→ Qt6Laz bridge (our forked C++ shared library)
       └→ Qt6Core, Qt6Gui, Qt6Widgets, Qt6PrintSupport
            └→ System Qt6 runtime libraries
```

---

## 4. Platform-Specific Details

### 4.1 macOS (ARM64 / Apple Silicon)

| Item | Value |
|------|-------|
| CPU | `aarch64` (Apple M1/M2/M3/M4) |
| Dev OS | macOS 26 (Tahoe) |
| Min deployment | macOS 14 (Sonoma) |
| Qt6 install | `brew install qt@6` → `/opt/homebrew/opt/qt@6/` |
| C++ compiler | Apple Clang (via Xcode Command Line Tools) |
| Bridge output | `Qt6Laz.framework` (macOS bundle) |
| FPC target | `fpc` for `aarch64-darwin` |
| Deploy shape | `.app` bundle with `Contents/Frameworks/Qt6Laz.framework` |

**Build bridge on macOS:**
```bash
brew install qt@6
cd bridge
/opt/homebrew/opt/qt@6/bin/qmake Qt6Laz.pro
make -j$(sysctl -n hw.ncpu)
# Output: build/macos/Qt6Laz.framework
```

### 4.2 Windows (ARM64)

| Item | Value |
|------|-------|
| CPU | `aarch64` (ARM64) |
| Dev OS | Windows 11 25H2 ARM64 (Parallels Desktop VM) |
| Min deployment | Windows 11 ARM64 |
| Qt6 install | Official Qt installer or `aqtinstall` (pip package) |
| C++ compiler | MinGW-w64 ARM64 or MSVC for ARM64 |
| Bridge output | `Qt6Laz.dll` |
| FPC target | `fpc` for `aarch64-win64` |
| Deploy shape | `.exe` + `Qt6Laz.dll` + Qt6 DLLs in same directory |

**Build bridge on Windows:**
```powershell
pip install aqtinstall
python -m aqt install-qt windows desktop 6.2.4 win64_mingw
cd bridge
C:\Qt\6.2.4\mingw_64\bin\qmake.exe Qt6Laz.pro
mingw32-make -j%NUMBER_OF_PROCESSORS%
# Output: build\win64\Qt6Laz.dll
```

> **Note:** Qt6 ARM64 Windows builds may require Qt 6.7+ (earlier versions had
> limited ARM64 Windows support). Check aqtinstall for available ARM64 packages.

### 4.3 Linux (ARM64)

| Item | Value |
|------|-------|
| CPU | `aarch64` (ARM64) |
| Dev OS | Ubuntu 26.04 LTS ARM64 (Parallels Desktop VM) |
| Min deployment | Ubuntu 24.04 LTS ARM64 |
| Qt6 install | `aqtinstall` or system package manager |
| C++ compiler | GCC 11+ ARM64 or Clang 14+ ARM64 |
| Bridge output | `Qt6Laz.so` (symlink: `libQt6Laz.so.6`) |
| FPC target | `fpc` for `aarch64-linux` |
| Deploy shape | Executable + `libQt6Laz.so.6` + Qt6 shared libs |

**Build bridge on Linux:**
```bash
pip install aqtinstall
python -m aqt install-qt linux desktop 6.2.4 linux_gcc_arm64
cd bridge
~/Qt/6.2.4/gcc_arm64/bin/qmake Qt6Laz.pro
make -j$(nproc)
# Output: build/linux/libQt6Laz.so.6.2.10
```

> **Note:** Qt6 Linux ARM64 packages are available via aqtinstall. Verify the
> exact architecture tag (`linux_gcc_arm64`) matches your system.

---

## 5. CI/CD Strategy (GitHub Actions)

### CI Matrix (Locked)

| Job | Runner | CPU | Matches Local Dev | Qt6 Source | Bridge Output | Purpose |
|-----|--------|-----|------------------|-----------|---------------|---------|
| `build-macos` | `macos-26` | ARM64 | macOS 26 (native Apple Silicon) | Homebrew `qt@6` | `Qt6Laz.framework` | Build + test |
| `build-windows` | `windows-11-arm` | ARM64 | Windows 11 25H2 (Parallels VM) | `aqtinstall` | `Qt6Laz.dll` | Build + test |
| `build-linux` | `ubuntu-24.04-arm` | ARM64 | Ubuntu 26.04 LTS (Parallels VM) | `aqtinstall` | `Qt6Laz.so` | Build + test |

All three jobs run **in parallel** on every push and pull request. Since the
repo is **public**, GitHub provides **unlimited free CI minutes** — there is no
cost concern regardless of how frequently we push.

Each job:

1. Checks out the repo
2. Installs Qt6 for its platform
3. Builds the C++ bridge natively
4. Installs FPC 3.3.1 (or snapshot)
5. Compiles the Pascal framework
6. Runs FPCUnit console tests
7. Builds the minimal demo app
8. (macOS only) Runs a GUI smoke test

### Why No Cross-Compilation

- The C++ bridge **must** be compiled on the target platform because Qt6's
  build system (`qmake`) produces platform-specific makefiles.
- FPC *can* cross-compile Pascal code (`--os=win64 --cpu=aarch64` from macOS),
  but it is simpler and more reliable to compile natively on each platform
  via CI runners.
- We avoid the complexity of cross-compiling C++ Qt6 code entirely.

### Workflow Template

All three workflow files share this structure (platform-specific values
substituted):

```yaml
name: Build <Platform>
on: [push, pull_request]

jobs:
  build:
    runs-on: <runner>  # macos-26 | windows-11-arm | ubuntu-24.04-arm
    steps:
      - uses: actions/checkout@v4

      - name: Install Qt6
        run: <platform-specific install command>

      - name: Setup Qt6 environment
        run: <set QT6_DIR, add to PATH>

      - name: Build Qt6Laz Bridge
        run: |
          mkdir -p bridge/build
          cd bridge
          <qmake-path>/qmake Qt6Laz.pro -o build/Makefile
          make -C build -j<n>

      - name: Setup FPC
        run: <download and install FPC 3.3.1 for platform>

      - name: Build Framework
        run: make framework

      - name: Run Tests
        run: make test

      - name: Build Demo
        run: make demo-minimal

      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: qt6laz-<platform>
          path: |
            bridge/build/
            demos/demo.minimal/demo.minimal<ext>
```

**Runner labels (as of June 2026):**

| Platform | Runner Label | Status | Notes |
|----------|-------------|--------|-------|
| macOS | `macos-26` | GA since Feb 2026 | ARM64 native Apple Silicon |
| Windows | `windows-11-arm` | Public preview | ARM64; free for public repos |
| Linux | `ubuntu-24.04-arm` | GA since Jan 2025 | ARM64; also `ubuntu-26.04-arm` in preview |

**All platforms are ARM64** — no x86_64 runners are used. This matches the
developer's local environment where all three OSes run on Apple Silicon (native
or via Parallels Desktop).

---

## 6. Qt6Pas Bridge Fork Strategy

### What We Fork

We copy the entire `cbindings/` directory from Lazarus trunk into our
`bridge/` directory:

```
Source: /Users/worajedt/Lazarus/lazarus/lcl/interfaces/qt6/cbindings/
Target: Qt6Laz/bridge/
```

### What We Change

| Change | Reason |
|--------|--------|
| Rename `Qt6Pas.pro` → `Qt6Laz.pro` | Our bridge is called Qt6Laz, not Qt6Pas |
| Rename `TARGET = Qt6Pas` → `TARGET = Qt6Laz` | Match our branding |
| Remove `attic/` directory | Contains Qt5-era web/network bindings we don't need |
| Remove unused Qt6Pas classes we don't use (optional, later) | Reduce binary size |
| **Add `qlclabstractitemmodel.h`** | **Core new feature: Pascal-callable custom model** |
| **Add `qlclabstractitemmodel_c.h` / `_c.cpp`** | Flat C wrappers for the new model class |
| Update `Qt6Laz.pro` HEADERS/SOURCES | Include the new files in the build |
| Rename Pascal `Qt6PasLib` constant → `Qt6LazLib` | Match new library name |

### What We Do NOT Change

- All existing `q*_c.cpp`, `q*_hook.h` files — kept as-is from upstream
- `chandles.h`, `pascalbind.h`, `flatfuncs.h` — unchanged
- The hook/callback architecture — unchanged
- We do **not** modify upstream Qt6Pas Pascal declarations (`qt62.pas`)

### How We Track Upstream

```
Upstream:  https://gitlab.com/freepascal.org/lazarus/lazarus.git
           Path: lcl/interfaces/qt6/cbindings/

Our fork:  Qt6Laz/bridge/
           Based on: Lazarus trunk @ <commit-hash>
           Last synced: <date>
```

We record the upstream commit hash in `bridge/README.BRIDGE.md` and periodically
merge upstream changes (infrequent — Qt6Pas targets Qt 6.2 LTS and changes rarely).

---

## 7. QLCLAbstractItemModel — Custom Model Bridge

### The Problem

Qt6's `QAbstractItemModel` (and `QAbstractTableModel`) are **abstract C++
classes** with pure virtual methods: `data()`, `rowCount()`, `columnCount()`,
`headerData()`, `flags()`, `setData()`. To create a custom model that Qt6 views
can display, you must **subclass in C++** and override these methods.

The existing Qt6Pas bridge only provides:
- **Flat C wrappers** (`QAbstractItemModel_rowCount(handle, parent)`) that call
  methods on an *existing* model object — you can't change the implementation.
- **Signal hooks** (`hook_dataChanged`, `hook_rowsInserted`, etc.) that notify
  Pascal when a model emits a signal — but can't change what the model *returns*.

There is no way to write a custom model in pure Pascal through the existing bridge.

### The Solution: QLCLAbstractItemModel

We add a new C++ class `QLCLAbstractItemModel` that:
1. Inherits from `QAbstractTableModel` (table models are simpler — no need to
   override `index()` / `parent()`)
2. Stores `QOverrideHook` function pointers for each virtual method
3. Each overridden virtual method checks if a Pascal callback is set; if so,
   calls it; if not, calls the base class implementation

This follows the **exact pattern** already used by `QLCLItemDelegate`,
`QLCLThread`, `QLCLOpenGLWidget`, `QLCLAbstractScrollArea`, and
`QLCLAbstractSpinBox` in the existing bridge.

### New C++ Files

**`bridge/src/qlclabstractitemmodel.h`:**
```cpp
#ifndef QLCLABSTRACTITEMMODEL_H
#define QLCLABSTRACTITEMMODEL_H

#include <QAbstractTableModel>
#include <QVariant>
#include "pascalbind.h"

class QLCLAbstractItemModel : public QAbstractTableModel {
public:
    QLCLAbstractItemModel(QObject *parent = 0) : QAbstractTableModel(parent) {
        rowCountOverride.func = NULL;
        columnCountOverride.func = NULL;
        dataOverride.func = NULL;
        headerDataOverride.func = NULL;
        flagsOverride.func = NULL;
        setDataOverride.func = NULL;
        insertRowsOverride.func = NULL;
        removeRowsOverride.func = NULL;
    }

    void override_rowCount(const QOverrideHook hook)      { rowCountOverride = hook; }
    void override_columnCount(const QOverrideHook hook)   { columnCountOverride = hook; }
    void override_data(const QOverrideHook hook)          { dataOverride = hook; }
    void override_headerData(const QOverrideHook hook)    { headerDataOverride = hook; }
    void override_flags(const QOverrideHook hook)         { flagsOverride = hook; }
    void override_setData(const QOverrideHook hook)       { setDataOverride = hook; }
    void override_insertRows(const QOverrideHook hook)    { insertRowsOverride = hook; }
    void override_removeRows(const QOverrideHook hook)    { removeRowsOverride = hook; }

    // Provide Pascal access to protected methods needed to emit signals
    void emit_dataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight,
                          const QVector<int> &roles = QVector<int>()) {
        emit dataChanged(topLeft, bottomRight, roles);
    }
    void emit_beginInsertRows(const QModelIndex &parent, int first, int last) {
        beginInsertRows(parent, first, last);
    }
    void emit_endInsertRows() { endInsertRows(); }
    void emit_beginRemoveRows(const QModelIndex &parent, int first, int last) {
        beginRemoveRows(parent, first, last);
    }
    void emit_endRemoveRows() { endRemoveRows(); }
    void emit_beginResetModel() { beginResetModel(); }
    void emit_endResetModel() { endResetModel(); }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override {
        if (rowCountOverride.func) {
            typedef int (*func_type)(void *data, const QModelIndexH parent);
            return (*(func_type)rowCountOverride.func)(
                rowCountOverride.data, (const QModelIndexH)&parent);
        }
        return 0;
    }

    int columnCount(const QModelIndex &parent = QModelIndex()) const override {
        if (columnCountOverride.func) {
            typedef int (*func_type)(void *data, const QModelIndexH parent);
            return (*(func_type)columnCountOverride.func)(
                columnCountOverride.data, (const QModelIndexH)&parent);
        }
        return 0;
    }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override {
        QVariant result;
        if (dataOverride.func) {
            typedef void (*func_type)(void *data, const QModelIndexH index,
                int role, QVariantH retval);
            (*(func_type)dataOverride.func)(
                dataOverride.data, (const QModelIndexH)&index, role, (QVariantH)&result);
        }
        return result;
    }

    QVariant headerData(int section, Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override {
        QVariant result;
        if (headerDataOverride.func) {
            typedef void (*func_type)(void *data, int section,
                int orientation, int role, QVariantH retval);
            (*(func_type)headerDataOverride.func)(
                headerDataOverride.data, section, (int)orientation, role, (QVariantH)&result);
        }
        return result;
    }

    Qt::ItemFlags flags(const QModelIndex &index) const override {
        if (flagsOverride.func) {
            typedef unsigned int (*func_type)(void *data, const QModelIndexH index);
            return (Qt::ItemFlags)(*(func_type)flagsOverride.func)(
                flagsOverride.data, (const QModelIndexH)&index);
        }
        return QAbstractTableModel::flags(index);
    }

    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::EditRole) override {
        if (setDataOverride.func) {
            typedef bool (*func_type)(void *data, const QModelIndexH index,
                const QVariantH value, int role);
            return (*(func_type)setDataOverride.func)(
                setDataOverride.data, (const QModelIndexH)&index,
                (const QVariantH)&value, role);
        }
        return false;
    }

    bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override {
        if (insertRowsOverride.func) {
            typedef bool (*func_type)(void *data, int row, int count,
                const QModelIndexH parent);
            return (*(func_type)insertRowsOverride.func)(
                insertRowsOverride.data, row, count, (const QModelIndexH)&parent);
        }
        return false;
    }

    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override {
        if (removeRowsOverride.func) {
            typedef bool (*func_type)(void *data, int row, int count,
                const QModelIndexH parent);
            return (*(func_type)removeRowsOverride.func)(
                removeRowsOverride.data, row, count, (const QModelIndexH)&parent);
        }
        return false;
    }

private:
    QOverrideHook rowCountOverride;
    QOverrideHook columnCountOverride;
    QOverrideHook dataOverride;
    QOverrideHook headerDataOverride;
    QOverrideHook flagsOverride;
    QOverrideHook setDataOverride;
    QOverrideHook insertRowsOverride;
    QOverrideHook removeRowsOverride;
};

#endif // QLCLABSTRACTITEMMODEL_H
```

**`bridge/src/qlclabstractitemmodel_c.h`:**
```cpp
#ifndef QLCLABSTRACTITEMMODEL_C_H
#define QLCLABSTRACTITEMMODEL_C_H

#include "chandles.h"

C_EXPORT QLCLAbstractItemModelH QLCLAbstractItemModel_Create(QObjectH parent);
C_EXPORT void QLCLAbstractItemModel_Destroy(QLCLAbstractItemModelH handle);
C_EXPORT void QLCLAbstractItemModel_override_rowCount(QLCLAbstractItemModelH handle, const QOverrideHook hook);
C_EXPORT void QLCLAbstractItemModel_override_columnCount(QLCLAbstractItemModelH handle, const QOverrideHook hook);
C_EXPORT void QLCLAbstractItemModel_override_data(QLCLAbstractItemModelH handle, const QOverrideHook hook);
C_EXPORT void QLCLAbstractItemModel_override_headerData(QLCLAbstractItemModelH handle, const QOverrideHook hook);
C_EXPORT void QLCLAbstractItemModel_override_flags(QLCLAbstractItemModelH handle, const QOverrideHook hook);
C_EXPORT void QLCLAbstractItemModel_override_setData(QLCLAbstractItemModelH handle, const QOverrideHook hook);
C_EXPORT void QLCLAbstractItemModel_override_insertRows(QLCLAbstractItemModelH handle, const QOverrideHook hook);
C_EXPORT void QLCLAbstractItemModel_override_removeRows(QLCLAbstractItemModelH handle, const QOverrideHook hook);
C_EXPORT void QLCLAbstractItemModel_emit_dataChanged(QLCLAbstractItemModelH handle, const QModelIndexH topLeft, const QModelIndexH bottomRight);
C_EXPORT void QLCLAbstractItemModel_emit_beginInsertRows(QLCLAbstractItemModelH handle, const QModelIndexH parent, int first, int last);
C_EXPORT void QLCLAbstractItemModel_emit_endInsertRows(QLCLAbstractItemModelH handle);
C_EXPORT void QLCLAbstractItemModel_emit_beginRemoveRows(QLCLAbstractItemModelH handle, const QModelIndexH parent, int first, int last);
C_EXPORT void QLCLAbstractItemModel_emit_endRemoveRows(QLCLAbstractItemModelH handle);
C_EXPORT void QLCLAbstractItemModel_emit_beginResetModel(QLCLAbstractItemModelH handle);
C_EXPORT void QLCLAbstractItemModel_emit_endResetModel(QLCLAbstractItemModelH handle);

#endif
```

**`bridge/src/qlclabstractitemmodel_c.cpp`:**
```cpp
#include "qlclabstractitemmodel.h"
#include "qlclabstractitemmodel_c.h"

C_EXPORT QLCLAbstractItemModelH QLCLAbstractItemModel_Create(QObjectH parent) {
    return (QLCLAbstractItemModelH) new QLCLAbstractItemModel((QObject*)parent);
}

C_EXPORT void QLCLAbstractItemModel_Destroy(QLCLAbstractItemModelH handle) {
    delete (QLCLAbstractItemModel*)handle;
}

C_EXPORT void QLCLAbstractItemModel_override_rowCount(QLCLAbstractItemModelH handle, const QOverrideHook hook) {
    ((QLCLAbstractItemModel*)handle)->override_rowCount(hook);
}
// ... (one per override method, same pattern)

C_EXPORT void QLCLAbstractItemModel_emit_beginResetModel(QLCLAbstractItemModelH handle) {
    ((QLCLAbstractItemModel*)handle)->emit_beginResetModel();
}
// ... (one per emit method)
```

### Pascal Bridge Declarations

**`bridge-pas/qt6laz.bridge.model.pas`:**
```pascal
unit qt6laz.bridge.model;

{$mode objfpc}{$H+}

interface

type
  { Opaque handle types }
  QLCLAbstractItemModelH = type QAbstractItemModelH;
  QModelIndexH = type Pointer;
  QVariantH = type Pointer;
  QObjectH = type Pointer;

  { Callback type declarations (must match C++ func_type signatures) }
  QLCLModel_rowCount_Callback = function(data: Pointer; parent: QModelIndexH): Integer; cdecl;
  QLCLModel_columnCount_Callback = function(data: Pointer; parent: QModelIndexH): Integer; cdecl;
  QLCLModel_data_Callback = procedure(data: Pointer; index: QModelIndexH;
    role: Integer; retval: QVariantH); cdecl;
  QLCLModel_headerData_Callback = procedure(data: Pointer; section: Integer;
    orientation: Integer; role: Integer; retval: QVariantH); cdecl;
  QLCLModel_flags_Callback = function(data: Pointer; index: QModelIndexH): Cardinal; cdecl;
  QLCLModel_setData_Callback = function(data: Pointer; index: QModelIndexH;
    value: QVariantH; role: Integer): Boolean; cdecl;
  QLCLModel_insertRows_Callback = function(data: Pointer; row: Integer;
    count: Integer; parent: QModelIndexH): Boolean; cdecl;
  QLCLModel_removeRows_Callback = function(data: Pointer; row: Integer;
    count: Integer; parent: QModelIndexH): Boolean; cdecl;

  { QOverrideHook record — must match C++ struct layout }
  QOverrideHook = packed record
    func: Pointer;  // Function pointer to Pascal callback
    data: Pointer;  // Instance pointer (Self)
  end;

{ C export declarations }
function QLCLAbstractItemModel_Create(parent: QObjectH = nil): QLCLAbstractItemModelH;
  cdecl; external Qt6LazLib;

procedure QLCLAbstractItemModel_Destroy(handle: QLCLAbstractItemModelH);
  cdecl; external Qt6LazLib;

procedure QLCLAbstractItemModel_override_rowCount(handle: QLCLAbstractItemModelH;
  hook: QOverrideHook); cdecl; external Qt6LazLib;
// ... (one per override)

procedure QLCLAbstractItemModel_emit_beginResetModel(handle: QLCLAbstractItemModelH);
  cdecl; external Qt6LazLib;
// ... (one per emit)

implementation

end.
```

### Qt6Laz.pro Changes

Add to HEADERS and SOURCES sections:
```qmake
HEADERS += qlclabstractitemmodel.h qlclabstractitemmodel_c.h
SOURCES += qlclabstractitemmodel_c.cpp
```

---

## 8. MVVM Architecture

### Layer Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    View Layer (Qt6)                      │
│                                                         │
│   QTableView    QTreeView    QListView    QLineEdit     │
│   QComboBox     QCheckBox    QLabel       QPushButton    │
│                                                         │
│   Delegates: rendering + editing (QStyledItemDelegate)  │
│   Proxy: QSortFilterProxyModel (sorting + filtering)    │
├─────────────────────────────────────────────────────────┤
│                 Binding Layer (Pascal)                   │
│                                                         │
│   qt6laz.binding.pas                                    │
│   Connects ViewModel → Qt6 View                         │
│   Creates QLCLAbstractItemModel, wires callbacks        │
│   Manages model lifecycle, signal forwarding             │
├─────────────────────────────────────────────────────────┤
│                ViewModel Layer (Pascal)                  │
│                                                         │
│   TBaseViewModel (abstract)                             │
│     ├── GetRowCount: Integer                            │
│     ├── GetColumnCount: Integer                         │
│     ├── GetField(row, col, role): Variant               │
│     ├── SetField(row, col, value, role): Boolean        │
│     ├── GetHeader(section, orient, role): Variant       │
│     └── OnDataChanged: TNotifyEvent                     │
│                                                         │
│   TTableViewModel    TTreeViewModel    TListViewModel   │
├─────────────────────────────────────────────────────────┤
│               Data Source Layer (Pascal)                │
│                                                         │
│   IDataSource (interface)                               │
│     ├── Count: Integer                                  │
│     ├── GetField(row, col): Variant                     │
│     ├── SetField(row, col, value): Boolean              │
│     ├── InsertRow / DeleteRow / UpdateRow               │
│     └── Refresh / Apply                                 │
│                                                         │
│   TSQLQueryDataSource   TSQLTableDataSource              │
│   TJSONDataSource       TMemoryDataSource                │
├─────────────────────────────────────────────────────────┤
│              Database / Storage Layer                   │
│                                                         │
│   SQLdb (SQLite, PostgreSQL, MySQL, ODBC)               │
│   JSON files    In-memory arrays                         │
└─────────────────────────────────────────────────────────┘
```

### Why MVVM Here

| Benefit | How |
|---------|-----|
| **Testability** | ViewModels are pure Pascal — unit-testable without any GUI running |
| **View-agnostic** | Same ViewModel can drive a table grid, tree, or custom view |
| **Data-source-agnostic** | Swap SQL for JSON for testing; no view code changes |
| **Qt6-native sorting/filtering** | QSortFilterProxyModel handles it — ViewModel just provides data |
| **Clean separation** | Business logic never touches Qt6 types; UI never touches SQL |

### Sort/Filter Strategy

We use **Qt6's QSortFilterProxyModel** for all sorting and filtering:

```
TTableViewModel                  QSortFilterProxyModel        QTableView
(our Pascal model)        →      (Qt6 built-in proxy)    →    (Qt6 view)
                                handles sort + filter
```

The ViewModel provides raw, unsorted data. The proxy model sits between the
ViewModel and the view, transparently handling column-click sorting and
text-filtering. This is zero Pascal code for sorting/filtering — Qt6 does it.

---

## 9. Essential Control Set (Scoped for MVP)

These are the controls needed for the first dogfood app (code-centric IDE tool).
Controls are grouped by implementation phase.

### Phase 0-1: Core Shell (Must Have First)

| Control | Qt6 Class | Purpose |
|---------|-----------|---------|
| Application | `QApplication` | Event loop, app lifecycle |
| Main window | `QMainWindow` | Window frame with dock areas |
| Central widget | `QWidget` | Central content area |
| Menu bar | `QMenuBar` | File, Edit, View menus |
| Menu | `QMenu` | Dropdown menu items |
| Toolbar | `QToolBar` | Action buttons bar |
| Status bar | `QStatusBar` | Bottom status line |
| Action | `QAction` | Menu/toolbar action items |
| Shortcut | `QShortcut` | Keyboard shortcuts |

### Phase 1: Layout + Basic Controls

| Control | Qt6 Class | Purpose |
|---------|-----------|---------|
| HBox layout | `QHBoxLayout` | Horizontal arrangement |
| VBox layout | `QVBoxLayout` | Vertical arrangement |
| Grid layout | `QGridLayout` | Grid arrangement |
| Splitter | `QSplitter` | Resizable divider panels |
| Label | `QLabel` | Static text |
| Push button | `QPushButton` | Action button |
| Check box | `QCheckBox` | Boolean toggle |
| Radio button | `QRadioButton` | Exclusive selection |
| Button group | `QButtonGroup` | Groups radio buttons |
| Group box | `QGroupBox` | Bordered container with title |
| Line edit | `QLineEdit` | Single-line text input |
| Plain text edit | `QPlainTextEdit` | Multi-line text (code editor base) |
| Spin box | `QSpinBox` | Integer input |
| Combo box | `QComboBox` | Dropdown selection |
| Progress bar | `QProgressBar` | Progress indicator |
| Tab widget | `QTabWidget` | Tabbed container |
| Scroll area | `QScrollArea` | Scrollable viewport |
| Dock widget | `QDockWidget` | IDE-style dockable panel |

### Phase 2-3: Data Controls

| Control | Qt6 Class | Purpose |
|---------|-----------|---------|
| Table view | `QTableView` | Editable data grid |
| Tree view | `QTreeView` | Hierarchical data (project browser) |
| List view | `QListView` | Flat list display |
| Header view | `QHeaderView` | Column headers |
| Sort filter proxy | `QSortFilterProxyModel` | Sorting + filtering |
| Standard item model | `QStandardItemModel` | Simple data model (fallback) |
| Custom item model | `QLCLAbstractItemModel` | Our Pascal-backed model |
| Item delegate | `QStyledItemDelegate` | Custom cell rendering |
| Completer | `QCompleter` | Auto-complete dropdown |

### Phase 5+: Extended Controls (Later)

| Control | Qt6 Class | Purpose |
|---------|-----------|---------|
| DateTime edit | `QDateTimeEdit` | Date/time input |
| Calendar widget | `QCalendarWidget` | Calendar popup |
| Font combo box | `QFontComboBox` | Font selection |
| Text browser | `QTextBrowser` | Rich text / HTML display |
| Text edit | `QTextEdit` | Rich text editor |
| Double spin box | `QDoubleSpinBox` | Floating-point input |
| Slider | `QSlider` | Range slider |
| LCD number | `QLCDNumber` | Digital display |
| Tool box | `QToolBox` | Accordion-style panels |
| Stacked widget | `QStackedWidget` | Page switcher |
| MDI area | `QMdiArea` | Multiple document interface |
| OpenGL widget | `QOpenGLWidget` | OpenGL canvas (via QLCLOpenGLWidget) |

### Dialogs (Phase 1+)

| Dialog | Qt6 Class | Purpose |
|--------|-----------|---------|
| Message box | `QMessageBox` | Info / warning / error / question |
| File dialog | `QFileDialog` | Open / save file browser |
| Input dialog | `QInputDialog` | Simple text input prompt |
| Color dialog | `QColorDialog` | Color picker |
| Font dialog | `QFontDialog` | Font picker |
| Progress dialog | `QProgressDialog` | Modal progress |
| Print dialog | `QPrintDialog` | Print setup |

---

## 10. Development Phases

### Phase 0: Project Bootstrap

**Goal:** Empty repo that builds a minimal `QMainWindow` on macOS ARM64.

| # | Task | Deliverable | Status |
|---|------|------------|--------|
| 0.1 | Create GitHub repo `jedt3d/Qt6Laz` | Empty repo | ☐ |
| 0.2 | Clone repo to `/Users/worajedt/Lazarus/projects/Qt6Laz/` | Local clone | ☐ |
| 0.3 | Create `.gitignore`, `LICENSE`, `COPYING.LIB`, `README.md`, `AGENTS.md` | Root files | ☐ |
| 0.4 | Fork Qt6Pas `cbindings/` into `bridge/`, rename project | `bridge/Qt6Laz.pro` | ☐ |
| 0.5 | Strip `bridge/attic/` (Qt5 web/network bindings) | Clean bridge | ☐ |
| 0.6 | Install Qt6 on macOS via Homebrew: `brew install qt@6` | Qt6 SDK | ☐ |
| 0.7 | Build bridge on macOS: `qmake Qt6Laz.pro && make` | `Qt6Laz.framework` | ☐ |
| 0.8 | Create `src/qt6laz.core.pas` — minimal Qt6 type definitions | Pascal types | ☐ |
| 0.9 | Create `src/qt6laz.app.pas` — QApplication init/run/quit | App lifecycle | ☐ |
| 0.10 | Create `src/qt6laz.window.pas` — QMainWindow wrapper | Window control | ☐ |
| 0.11 | Create `demos/demo.minimal.lpr` — show empty window | Proof of pipeline | ☐ |
| 0.12 | Create `Makefile` — orchestrates bridge + framework build | Build system | ☐ |
| 0.13 | Compile and run `demo.minimal` on macOS ARM64 | Window appears | ☐ |
| 0.14 | Initial commit + push | Git history starts | ☐ |

### Phase 1: Core Controls + Layout

**Goal:** All basic controls work; IDE shell is possible.

| # | Task | Deliverable | Status |
|---|------|------------|--------|
| 1.1 | `qt6laz.layout.pas` — HBox, VBox, Grid, Splitter | Layout system | ☐ |
| 1.2 | `qt6laz.controls.basic.pas` — Label, Button, CheckBox, RadioButton, GroupBox, ProgressBar | Basic controls | ☐ |
| 1.3 | `qt6laz.controls.input.pas` — LineEdit, SpinBox, ComboBox, PlainTextEdit | Input controls | ☐ |
| 1.4 | `qt6laz.controls.container.pas` — TabWidget, ScrollArea | Containers | ☐ |
| 1.5 | `qt6laz.menus.pas` — MenuBar, Menu, context menu | Menus | ☐ |
| 1.6 | `qt6laz.toolbar.pas` — QToolBar | Toolbar | ☐ |
| 1.7 | `qt6laz.statusbar.pas` — QStatusBar | Status bar | ☐ |
| 1.8 | `qt6laz.actions.pas` — QAction, QShortcut | Actions | ☐ |
| 1.9 | `qt6laz.dockwidget.pas` — QDockWidget | Dockable panels | ☐ |
| 1.10 | `qt6laz.icon.pas` — QIcon, QPixmap | Icons | ☐ |
| 1.11 | `demos/demo.controls` — all controls in a tabbed form | Control gallery | ☐ |
| 1.12 | `demos/demo.ide` skeleton — QMainWindow + dock panels + toolbar + menu + statusbar | IDE shell | ☐ |

### Phase 2: Custom Model Bridge + MVVM

**Goal:** Pascal ViewModels drive Qt6 table views with sorting/filtering.

| # | Task | Deliverable | Status |
|---|------|------------|--------|
| 2.1 | Write `qlclabstractitemmodel.h` (C++ subclass) | Custom model class | ☐ |
| 2.2 | Write `qlclabstractitemmodel_c.h` + `_c.cpp` (flat C wrappers) | C bridge | ☐ |
| 2.3 | Add new files to `Qt6Laz.pro` HEADERS + SOURCES | Updated build | ☐ |
| 2.4 | Rebuild bridge, verify it compiles + loads | Bridge updated | ☐ |
| 2.5 | Write `bridge-pas/qt6laz.bridge.model.pas` | Pascal declarations | ☐ |
| 2.6 | Write `mvvm/qt6laz.viewmodel.base.pas` — TBaseViewModel | Abstract VM | ☐ |
| 2.7 | Write `mvvm/qt6laz.viewmodel.table.pas` — TTableViewModel | Table VM | ☐ |
| 2.8 | Write `mvvm/qt6laz.model.json.pas` — TJSONDataSource | Test data source | ☐ |
| 2.9 | Write `mvvm/qt6laz.binding.pas` — connects VM ↔ Qt6 View | Binding layer | ☐ |
| 2.10 | Write `src/qt6laz.datagrid.pas` — QTableView + proxy | Data grid control | ☐ |
| 2.11 | `demos/demo.datagrid` — JSON-driven grid with sort/filter | Working grid | ☐ |
| 2.12 | FPCUnit tests for ViewModel + JSON data source + binding | Test coverage | ☐ |

### Phase 3: TreeView + SQL DataSource + IDE Demo v1

**Goal:** Functional IDE-like tool with project browser tree and code editor.

| # | Task | Deliverable | Status |
|---|------|------------|--------|
| 3.1 | `qt6laz.treeview.pas` — QTreeView wrapper | Tree control | ☐ |
| 3.2 | `mvvm/qt6laz.viewmodel.tree.pas` — TTreeViewModel | Tree VM | ☐ |
| 3.3 | `mvvm/qt6laz.model.sqlquery.pas` — TSQLQueryDataSource | SQL data source | ☐ |
| 3.4 | `mvvm/qt6laz.model.sqltable.pas` — TSQLTableDataSource | SQL table CRUD | ☐ |
| 3.5 | `demos/demo.ide` v1 — project tree + editor + output + properties | IDE demo | ☐ |
| 3.6 | FPCUnit tests for SQL data sources | Test coverage | ☐ |

### Phase 4: CI + Cross-Platform

**Goal:** Automated builds on all 3 platforms (macOS ARM64, Windows ARM64, Linux ARM64).

| # | Task | Deliverable | Status |
|---|------|------------|--------|
| 4.1 | Write `utils/setup_qt6_macos.sh` | Qt6 install script | ☐ |
| 4.2 | Write `utils/setup_qt6_windows.ps1` | Qt6 install script | ☐ |
| 4.3 | Write `utils/setup_qt6_linux.sh` | Qt6 install script | ☐ |
| 4.4 | Write `utils/build_bridge.sh` (platform-aware) | Bridge build script | ☐ |
| 4.5 | Write `.github/workflows/build-macos.yml` | macOS CI | ☐ |
| 4.6 | Write `.github/workflows/build-windows.yml` | Windows CI | ☐ |
| 4.7 | Write `.github/workflows/build-linux.yml` | Linux CI | ☐ |
| 4.8 | Fix cross-platform issues found in CI | Clean builds | ☐ |
| 4.9 | All 3 CI pipelines green | Verified | ☐ |

### Phase 5: Polish + Remaining Controls

**Goal:** Production-ready for LOB applications.

| # | Task | Deliverable | Status |
|---|------|------------|--------|
| 5.1 | DateTimeEdit, CalendarWidget, FontComboBox | Date/font controls | ☐ |
| 5.2 | Print support (QPrinter, QPrintPreviewDialog) | Printing | ☐ |
| 5.3 | System tray icon, clipboard | Desktop integration | ☐ |
| 5.4 | Keyboard shortcut management, menu accelerators | Productivity | ☐ |
| 5.5 | High-DPI / Retina scaling support | Cross-platform DPI | ☐ |
| 5.6 | Theme management, dark mode | Visual polish | ☐ |
| 5.7 | Documentation: getting-started, control-catalog, architecture | Docs | ☐ |
| 5.8 | API surface review — public vs internal units | Clean API | ☐ |

---

## 11. Key Architectural Decisions (Locked)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| LCL dependency | **None** | Standalone Qt6 via C bridge; no widgetset abstraction layer |
| Bridge source | **Forked Qt6Pas** | We need QLCLAbstractItemModel; must modify C++ bridge |
| Bridge name | **Qt6Laz** (renamed from Qt6Pas) | Our branding; avoids confusion with upstream |
| Bridge build tool | **qmake** | Qt6Pas already uses it; proven; no reason to switch to cmake |
| MVVM | **Yes** | ViewModel is pure Pascal, testable, view-agnostic |
| Sort/Filter | **Qt6 QSortFilterProxyModel** | Let Qt handle it; zero Pascal code for sorting |
| Custom models | **QLCLAbstractItemModel C++ subclass** | Follows QLCLItemDelegate pattern already in bridge |
| Pascal build tool | **fpc direct + Makefile** | No lazbuild needed; no .lpi for the framework library |
| Pascal dialect | **`{$mode objfpc}{$H+}`** | Standard modern FPC convention |
| macOS arch | **ARM64 only** | Apple Silicon; no Intel Mac support |
| Windows arch | **ARM64 only** | Windows on ARM; no x86_64 support |
| Linux arch | **ARM64 only** | aarch64; no x86_64 support |
| Local testing | **Parallels Desktop VMs** | Windows + Linux ARM64 VMs on the Mac |
| Cross-compilation | **None** | Each platform builds natively via CI |
| CI platform | **GitHub Actions** | 3-OS parallel matrix |
| License | **LGPL-2.1** | Matches Qt6Pas upstream; allows proprietary linking |
| Qt6 target version | **6.2 LTS (6.2.3+)** | What Qt6Pas is built against; long-term support |

---

## 12. Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Qt6 not installed on dev machine or CI | High | Document Homebrew (macOS) + aqtinstall (CI) in getting-started.md |
| `QLCLAbstractItemModel` `const` method callbacks crash | Medium | Follow `QLCLItemDelegate` pattern exactly; write bridge unit tests before using in demos |
| Qt6Pas bridge incompatible with newer Qt6 (7.x) | Medium | Pin Qt6 6.2 LTS in CI; document tested version; bridge targets 6.2.10 |
| Qt6 ARM64 Windows packages may be limited | Medium | Qt 6.7+ has better ARM64 Windows support; verify aqtinstall availability; may need official Qt installer |
| Qt6 ARM64 Linux packages may differ from x86_64 | Low | aqtinstall supports `linux_gcc_arm64`; verify Qt version coverage |
| Windows ARM64 CI runner is in public preview | Low | May be less stable than GA runners; fallback to local Parallels VM testing |
| macOS framework loading path issues | Medium | Set `@rpath` or `@executable_path` in qmake; document deployment shape |
| Windows DLL not found at runtime | Medium | Ship `Qt6Laz.dll` + Qt6 DLLs in same dir as `.exe`; document `windeployqt` |
| Signal/slot hook memory leaks | Low | Follow `TQtObject` lifecycle pattern (Create/Destroy with hook attach/detach) |
| FPC 3.3.1 is a development snapshot (not stable) | Low | Pin to a known-good snapshot; document exact version in CI |

---

## 13. Development Environment Setup

### macOS (Primary Dev Machine)

```bash
# 1. Install Xcode Command Line Tools (for C++ compiler)
xcode-select --install

# 2. Install Qt6 via Homebrew
brew install qt@6

# 3. Verify Qt6
/opt/homebrew/opt/qt@6/bin/qmake --version
# Expected: QMake version 3.1, using Qt version 6.x.x

# 4. Local FPC already at /Users/worajedt/Lazarus/fpc/bin/fpc

# 5. Clone repo
cd /Users/worajedt/Lazarus/projects
git clone git@github.com:jedt3d/Qt6Laz.git
cd Qt6Laz

# 6. Build bridge
cd bridge
/opt/homebrew/opt/qt@6/bin/qmake Qt6Laz.pro
make -j$(sysctl -n hw.ncpu)
cd ..

# 7. Build framework + demos
make all

# 8. Run minimal demo
./demos/demo.minimal/demo.minimal
```

### Windows ARM64 (Parallels Desktop VM)

```powershell
# 1. Install Qt6 via official installer or aqtinstall
# Note: ARM64 Windows requires Qt 6.7+ for full ARM64 support
pip install aqtinstall
python -m aqt install-qt windows desktop 6.8.1 win64_mingw
# Qt6 installs to C:\Qt\6.8.1\mingw_64\

# 2. Add Qt6 + MinGW to PATH
$env:PATH = "C:\Qt\6.8.1\mingw_64\bin;C:\Qt\Tools\mingw1310_64\bin;$env:PATH"

# 3. Install FPC 3.3.1 for Windows ARM64 (aarch64-win64)
# Check https://downloads.freepascal.org/ftpsrv/ for ARM64 Windows builds

# 4. Clone repo
git clone git@github.com:jedt3d/Qt6Laz.git
cd Qt6Laz

# 5. Build bridge
cd bridge
qmake Qt6Laz.pro
mingw32-make -j%NUMBER_OF_PROCESSORS%
cd ..

# 6. Build framework + demos
make all
```

### Linux ARM64 (Parallels Desktop VM)

```bash
# 1. Install build dependencies
sudo apt install build-essential gl1-mesa-dev

# 2. Install Qt6 via aqtinstall (ARM64 Linux)
pip install aqtinstall
python -m aqt install-qt linux desktop 6.8.1 linux_gcc_arm64
export PATH="$HOME/Qt/6.8.1/gcc_arm64/bin:$PATH"

# 3. Install FPC 3.3.1 for Linux ARM64 (aarch64-linux)
# Check https://downloads.freepascal.org/ftpsrv/ for ARM64 Linux builds

# 4. Clone repo
git clone git@github.com:jedt3d/Qt6Laz.git
cd Qt6Laz

# 5. Build bridge
cd bridge
qmake Qt6Laz.pro
make -j$(nproc)
cd ..

# 6. Build framework + demos
make all
```

---

## 14. Makefile Targets (Top-Level Orchestrator)

```makefile
# Makefile — top-level orchestrator for Qt6Laz

FPC ?= fpc
FPC_FLAGS = -Mobjfpc -Sh -CX -XX

# Platform detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Darwin)
    PLATFORM := macos
    QMAKE ?= /opt/homebrew/opt/qt@6/bin/qmake
    BRIDGE_OUT := bridge/build/Qt6Laz.framework
    LAZY_BUILD_JOBS := $(shell sysctl -n hw.ncpu)
else ifeq ($(OS), Windows_NT)
    PLATFORM := windows
    QMAKE ?= qmake
    BRIDGE_OUT := bridge/build/Qt6Laz.dll
    LAZY_BUILD_JOBS := $(NUMBER_OF_PROCESSORS)
else
    PLATFORM := linux
    QMAKE ?= qmake
    BRIDGE_OUT := bridge/build/libQt6Laz.so
    LAZY_BUILD_JOBS := $(shell nproc)
endif

.PHONY: all bridge framework test demos clean bridge-clean framework-clean

all: bridge framework demos

bridge:
	cd bridge && $(QMAKE) Qt6Laz.pro -o build/Makefile && $(MAKE) -C build -j$(LAZY_BUILD_JOBS)

framework:
	$(FPC) $(FPC_FLAGS) src/qt6laz.core.pas
	# ... compile all framework units

test: framework
	$(FPC) $(FPC_FLAGS) tests/test_runner.lpr
	./tests/test_runner --all --format=plain

demos: framework
	$(FPC) $(FPC_FLAGS) demos/demo.minimal/demo.minimal.lpr
	$(FPC) $(FPC_FLAGS) demos/demo.controls/demo.controls.lpr

clean: bridge-clean framework-clean

bridge-clean:
	rm -rf bridge/build/

framework-clean:
	find . -name '*.ppu' -delete
	find . -name '*.o' -delete
	find . -name '*.a' -delete
```

---

## 15. Glossary

| Term | Definition |
|------|-----------|
| **Qt6Pas** | The existing C++ bridge from Lazarus that exposes Qt6 to Pascal via flat C functions |
| **Qt6Laz** | Our fork of Qt6Pas, renamed and extended with QLCLAbstractItemModel |
| **QLCLAbstractItemModel** | Our new C++ class: a QAbstractTableModel subclass that forwards virtual method calls to Pascal callbacks |
| **QOverrideHook** | C struct `{ void *func; void *data; }` — a function pointer + instance pointer for virtual method override callbacks |
| **QHook** | C struct for signal notification hooks (different from QOverrideHook) |
| **MVVM** | Model-View-ViewModel pattern: ViewModel bridges data source and view |
| **ViewModel** | Pure Pascal class that provides view-friendly data access (row count, field values, headers) |
| **IDataSource** | Interface abstracting data access (SQL, JSON, memory) — ViewModel reads from this |
| **Binding** | The layer that creates a QLCLAbstractItemModel and wires its callbacks to a ViewModel |
| **QSortFilterProxyModel** | Qt6 built-in proxy model that provides sorting and filtering between source model and view |
| **FPCUnit** | Free Pascal unit testing framework (similar to DUnit/JUnit) |
| **aqtinstall** | Python tool for downloading and installing Qt SDK without the official installer GUI |
