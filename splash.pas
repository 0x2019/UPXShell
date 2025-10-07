unit splash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg;

type
  TSplashScreen = class(TForm)
    tmrMainTimer: TTimer;
    Image1: TImage;
    procedure tmrMainTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SplashScreen: TSplashScreen;

implementation

{$R *.dfm}

procedure TSplashScreen.tmrMainTimerTimer(Sender: TObject);
begin
tmrMainTimer.Enabled := False;
end;

end.
