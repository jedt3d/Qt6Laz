# Qt6Laz Makefile — top-level orchestrator
# All platforms are ARM64.

FPC ?= fpc
FPC_FLAGS = -Mobjfpc -Sh

# Platform detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Darwin)
  PLATFORM := macos
  QMAKE ?= /opt/homebrew/opt/qt@6/bin/qmake
  BRIDGE_DIR := bridge/build
  BRIDGE_LIB := $(BRIDGE_DIR)/Qt6Laz.framework
  JOBS := $(shell sysctl -n hw.ncpu)
  RPATH_QT := -k-rpath -k/opt/homebrew/lib
else ifeq ($(OS), Windows_NT)
  PLATFORM := windows
  QMAKE ?= qmake
  BRIDGE_DIR := bridge/build
  BRIDGE_LIB := $(BRIDGE_DIR)/Qt6Laz.dll
  JOBS := $(NUMBER_OF_PROCESSORS)
  RPATH_QT :=
else
  PLATFORM := linux
  QMAKE ?= qmake
  BRIDGE_DIR := bridge/build
  BRIDGE_LIB := $(BRIDGE_DIR)/libQt6Laz.so
  JOBS := $(shell nproc)
  RPATH_QT :=
endif

SRC_DIR := src
DEMO_DIR := demos/demo.minimal

.PHONY: all bridge framework demo clean

all: bridge demo

bridge:
	@if [ ! -f "$(BRIDGE_DIR)/Makefile" ]; then \
		mkdir -p $(BRIDGE_DIR); \
		cd bridge && $(QMAKE) Qt6Laz.pro -o build/Makefile; \
	fi
	$(MAKE) -C $(BRIDGE_DIR) -j$(JOBS)

framework:
	$(FPC) $(FPC_FLAGS) -Fu$(SRC_DIR) -Ff$(BRIDGE_DIR) \
	  $(RPATH_QT) -k-rpath -k$(BRIDGE_DIR) \
	  -FE$(DEMO_DIR) $(SRC_DIR)/qt6laz.core.pas
	$(FPC) $(FPC_FLAGS) -Fu$(SRC_DIR) -Ff$(BRIDGE_DIR) \
	  -FE$(DEMO_DIR) $(SRC_DIR)/qt6laz.app.pas
	$(FPC) $(FPC_FLAGS) -Fu$(SRC_DIR) -Ff$(BRIDGE_DIR) \
	  -FE$(DEMO_DIR) $(SRC_DIR)/qt6laz.window.pas

demo: framework
	$(FPC) $(FPC_FLAGS) -Fu$(SRC_DIR) -Ff$(BRIDGE_DIR) \
	  $(RPATH_QT) -k-rpath -k$(BRIDGE_DIR) \
	  -FE$(DEMO_DIR) $(DEMO_DIR)/demo.minimal.lpr

run: demo
ifeq ($(PLATFORM), macos)
	DYLD_FRAMEWORK_PATH="$(BRIDGE_DIR)" $(DEMO_DIR)/demo.minimal
else
	$(DEMO_DIR)/demo.minimal
endif

clean:
	rm -rf $(BRIDGE_DIR)
	find . -name '*.ppu' -delete
	find . -name '*.o' -delete
	find . -name '*.a' -delete
	find demos -type f ! -name '*.lpr' ! -name '*.pas' -delete
