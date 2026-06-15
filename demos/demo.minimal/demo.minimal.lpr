program demo.minimal;

{$mode objfpc}{$H+}

uses
  {$ifdef unix}cthreads,{$endif}
  qt6laz.core,
  qt6laz.app,
  qt6laz.window;

var
  App: TQt6App;
  Win: TQt6Window;

begin
  App := TQt6App.Create;
  try
    App.Initialize;

    Win := TQt6Window.Create;
    try
      Win.Title := 'Qt6Laz Minimal Demo';
      Win.SetSize(800, 600);
      Win.Show;
    finally
      Win.Free;
    end;

    App.Run;
  finally
    App.Free;
  end;
end.
