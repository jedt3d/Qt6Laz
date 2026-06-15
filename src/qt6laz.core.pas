unit qt6laz.core;

{$mode objfpc}{$H+}

interface

const
  { Library/framework name — conditional per platform.
    On macOS, {$LINKFRAMEWORK} handles linking; external name is empty. }
  {$ifdef mswindows}
  Qt6LazLib = 'Qt6Laz6.dll';
  {$endif}
  {$ifdef darwin}
  Qt6LazLib = '';
  {$LINKFRAMEWORK Qt6Laz}
  {$endif}
  {$ifdef linux}
  Qt6LazLib = 'libQt6Laz.so.6';
  {$endif}

  QT_VERSION = 6 shl 16 + 2 shl 8 + 1;
  ApplicationFlags = QT_VERSION or $1000000;

type
  { Opaque Qt6 handle types — type-safe pointers to C++ objects.
    Declared as empty class descendants following the upstream Qt6Pas pattern. }

  QObjectH = class(TObject) end;
  QCoreApplicationH = class(QObjectH) end;
  QGuiApplicationH = class(QCoreApplicationH) end;
  QApplicationH = class(QGuiApplicationH) end;

  QWidgetH = class(QObjectH) end;
  QMainWindowH = class(QWidgetH) end;
  QMenuBarH = class(QWidgetH) end;
  QStatusBarH = class(QWidgetH) end;
  QToolBarH = class(QWidgetH) end;

  QEventH = class(TObject) end;

  QtWindowFlags = Cardinal;

  { QCoreApplication }
function QCoreApplication_Create(argc: PInteger; argv: PPAnsiChar;
  AnonParam3: Integer): QCoreApplicationH;
  cdecl; external Qt6LazLib name 'QCoreApplication_Create';
function QCoreApplication_exec(): Integer;
  cdecl; external Qt6LazLib name 'QCoreApplication_exec';
procedure QCoreApplication_quit();
  cdecl; external Qt6LazLib name 'QCoreApplication_quit';
procedure QCoreApplication_exit(retcode: Integer);
  cdecl; external Qt6LazLib name 'QCoreApplication_exit';
procedure QCoreApplication_setAttribute(attribute: PtrUInt; _on: Boolean);
  cdecl; external Qt6LazLib name 'QCoreApplication_setAttribute';

  { QApplication }
function QApplication_Create(argc: PInteger; argv: PPAnsiChar;
  AnonParam3: Integer): QApplicationH;
  cdecl; external Qt6LazLib name 'QApplication_Create';
procedure QApplication_Destroy(handle: QApplicationH);
  cdecl; external Qt6LazLib name 'QApplication_Destroy';
function QApplication_exec(): Integer;
  cdecl; external Qt6LazLib name 'QApplication_exec';
procedure QApplication_quit();
  cdecl; external Qt6LazLib name 'QCoreApplication_quit';

  { QWidget basics }
procedure QWidget_show(handle: QWidgetH);
  cdecl; external Qt6LazLib name 'QWidget_show';
procedure QWidget_resize(handle: QWidgetH; w: Integer; h: Integer);
  cdecl; external Qt6LazLib name 'QWidget_resize';
procedure QWidget_setWindowTitle(handle: QWidgetH; title: PWideString);
  cdecl; external Qt6LazLib name 'QWidget_setWindowTitle';
function QWidget_close(handle: QWidgetH): Boolean;
  cdecl; external Qt6LazLib name 'QWidget_close';
function QWidget_width(handle: QWidgetH): Integer;
  cdecl; external Qt6LazLib name 'QWidget_width';
function QWidget_height(handle: QWidgetH): Integer;
  cdecl; external Qt6LazLib name 'QWidget_height';

  { QMainWindow }
function QMainWindow_Create(parent: QWidgetH; flags: QtWindowFlags): QMainWindowH;
  cdecl; external Qt6LazLib name 'QMainWindow_Create';
function QMainWindow_menuBar(handle: QMainWindowH): QMenuBarH;
  cdecl; external Qt6LazLib name 'QMainWindow_menuBar';
function QMainWindow_statusBar(handle: QMainWindowH): QStatusBarH;
  cdecl; external Qt6LazLib name 'QMainWindow_statusBar';
procedure QMainWindow_setCentralWidget(handle: QMainWindowH; widget: QWidgetH);
  cdecl; external Qt6LazLib name 'QMainWindow_setCentralWidget';

implementation

uses
  Math;

{ WideString bridge callbacks — required by pascalbind.cpp.
  These allow C++ bridge code to create/read/destroy Pascal WideStrings. }

procedure CopyUnicodeToPWideString(Unicode: PWideChar; var S: WideString;
  Len: Integer); cdecl; export;
begin
  SetString(S, Unicode, Len);
end;

function UnicodeOfPWideString(var S: WideString): PWideChar; cdecl; export;
const
  cEmptyStr: WideString = '';
begin
  if @S = nil then
    Result := PWideChar(cEmptyStr)
  else
    Result := PWideChar(Pointer(S));
end;

function LengthOfPWideString(var S: WideString): Integer; cdecl; export;
begin
  if @S <> nil then
    Result := Length(S)
  else
    Result := 0;
end;

procedure InitPWideStringCallback(var S: PWideString); cdecl; export;
begin
  New(S);
end;

procedure FinalPWideStringCallback(var S: PWideString); cdecl; export;
begin
  Dispose(S);
end;

{ Bridge initialization entry points }
procedure initPWideStrings(CUPS, UOPS, LOPS, IPS, FPS: Pointer); cdecl;
  external Qt6LazLib name 'initPWideStrings';

var
  BridgeInitialized: Boolean = False;

procedure EnsureBridgeInitialized;
begin
  if not BridgeInitialized then
  begin
    initPWideStrings(
      @CopyUnicodeToPWideString,
      @UnicodeOfPWideString,
      @LengthOfPWideString,
      @InitPWideStringCallback,
      @FinalPWideStringCallback);
    BridgeInitialized := True;
  end;
end;

initialization
  EnsureBridgeInitialized;
  SetExceptionMask([exDenormalized, exInvalidOp, exOverflow,
    exPrecision, exUnderflow, exZeroDivide]);

end.
