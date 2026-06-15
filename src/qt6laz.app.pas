unit qt6laz.app;

{$mode objfpc}{$H+}

interface

uses
  qt6laz.core;

type
  { TQt6App — thin wrapper around QApplication lifecycle.

    Usage:
      var App: TQt6App;
      App := TQt6App.Create;
      try
        App.Initialize;
        // ... create windows, show UI ...
        App.Run;
      finally
        App.Free;
      end; }

  TQt6App = class(TObject)
  private
    FHandle: QApplicationH;
    FArgc: Integer;
    FArgv: array of PAnsiChar;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Initialize;
    function Run: Integer;
    procedure Quit;
    property Handle: QApplicationH read FHandle;
  end;

implementation

{ TQt6App }

constructor TQt6App.Create;
begin
  inherited Create;
  FHandle := nil;
  FArgc := 0;
end;

destructor TQt6App.Destroy;
begin
  if FHandle <> nil then
    QApplication_Destroy(FHandle);
  inherited Destroy;
end;

procedure TQt6App.Initialize;
var
  I: Integer;
begin
  if FHandle <> nil then
    Exit;

  { Build argc/argv from Pascal command line params.
    Qt may modify argc (strip Qt-specific flags), so pass a real pointer. }
  FArgc := ParamCount + 1;
  SetLength(FArgv, FArgc);
  for I := 0 to ParamCount do
    FArgv[I] := PAnsiChar(ParamStr(I));

  FHandle := QApplication_Create(@FArgc, PPAnsiChar(@FArgv[0]), ApplicationFlags);
end;

function TQt6App.Run: Integer;
begin
  if FHandle <> nil then
    Result := QApplication_exec()
  else
    Result := 1;
end;

procedure TQt6App.Quit;
begin
  QApplication_quit();
end;

end.
