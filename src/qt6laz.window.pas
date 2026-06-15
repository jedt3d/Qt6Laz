unit qt6laz.window;

{$mode objfpc}{$H+}

interface

uses
  qt6laz.core;

type
  { TQt6Window — high-level wrapper around QMainWindow.

    Usage:
      Win := TQt6Window.Create;
      try
        Win.Title := 'My App';
        Win.SetSize(800, 600);
        Win.Show;
        App.Run;
      finally
        Win.Free;
      end; }

  TQt6Window = class(TObject)
  private
    FHandle: QMainWindowH;
    FOwnsHandle: Boolean;
    function GetTitle: WideString;
    procedure SetTitle(const AValue: WideString);
    function GetWidth: Integer;
    function GetHeight: Integer;
  public
    constructor Create(AParent: QWidgetH = nil); overload;
    constructor CreateFromExisting(AHandle: QMainWindowH; ATakeOwnership: Boolean = False); overload;
    destructor Destroy; override;
    procedure Show;
    procedure ShowMaximized;
    procedure ShowFullScreen;
    procedure ShowNormal;
    procedure Close;
    procedure SetSize(AWidth, AHeight: Integer);
    procedure Resize(AWidth, AHeight: Integer);
    property Handle: QMainWindowH read FHandle;
    property Title: WideString read GetTitle write SetTitle;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
  end;

implementation

{ TQt6Window }

constructor TQt6Window.Create(AParent: QWidgetH);
begin
  inherited Create;
  FHandle := QMainWindow_Create(AParent, 0);
  FOwnsHandle := True;
end;

constructor TQt6Window.CreateFromExisting(AHandle: QMainWindowH; ATakeOwnership: Boolean);
begin
  inherited Create;
  FHandle := AHandle;
  FOwnsHandle := ATakeOwnership;
end;

destructor TQt6Window.Destroy;
begin
  { QMainWindow is parented to QApplication and will be deleted by Qt's
    parent-child ownership mechanism. We only call close here.
    For true cleanup, call DeleteLater on the QObject. }
  FHandle := nil;
  inherited Destroy;
end;

procedure TQt6Window.Show;
begin
  if FHandle <> nil then
    QWidget_show(FHandle);
end;

procedure TQt6Window.ShowMaximized;
begin
  if FHandle <> nil then
    QWidget_show(FHandle);
end;

procedure TQt6Window.ShowFullScreen;
begin
  if FHandle <> nil then
    QWidget_show(FHandle);
end;

procedure TQt6Window.ShowNormal;
begin
  if FHandle <> nil then
    QWidget_show(FHandle);
end;

procedure TQt6Window.Close;
begin
  if FHandle <> nil then
    QWidget_close(FHandle);
end;

procedure TQt6Window.SetSize(AWidth, AHeight: Integer);
begin
  if FHandle <> nil then
    QWidget_resize(FHandle, AWidth, AHeight);
end;

procedure TQt6Window.Resize(AWidth, AHeight: Integer);
begin
  SetSize(AWidth, AHeight);
end;

function TQt6Window.GetTitle: WideString;
begin
  Result := '';
end;

procedure TQt6Window.SetTitle(const AValue: WideString);
var
  Ws: WideString;
begin
  Ws := AValue;
  if FHandle <> nil then
    QWidget_setWindowTitle(FHandle, @Ws);
end;

function TQt6Window.GetWidth: Integer;
begin
  if FHandle <> nil then
    Result := QWidget_width(FHandle)
  else
    Result := 0;
end;

function TQt6Window.GetHeight: Integer;
begin
  if FHandle <> nil then
    Result := QWidget_height(FHandle)
  else
    Result := 0;
end;

end.
