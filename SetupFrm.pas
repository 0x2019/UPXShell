{*
    UPX Shell
    Copyright © 2000-2006, Michael Hardy

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*}

 {**************--===Michael Hardy===--****************}
 { SetupFrm unit                                 }
 {***********************************************}
unit SetupFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TSetupForm = class(TForm)
    pnlBottom:      TPanel;
    lblCommands:    TLabel;
    chkCommands:    TCheckBox;
    txtCommands:    TEdit;
    btnOk:          TButton;
    pnlTop:         TPanel;
    chkScramble:    TCheckBox;
    btnScramble:    TButton;
    chkIntegrate:   TCheckBox;
    pnlMiddle:      TPanel;
    lblAdvacedOpts: TLabel;
    lblPriority:    TLabel;
    lblIcons:       TLabel;
    chkForce:       TCheckBox;
    chkResources:   TCheckBox;
    chkRelocs:      TCheckBox;
		cmbPriority:    TComboBox;
    cmbIcons:       TComboBox;
    chkExports:     TCheckBox;
    trbCompression: TTrackBar;
    lblCompression: TLabel;
    chkCompression: TCheckBox;
    bvlCompressor:  TBevel;
    btnCommands:    TButton;
    pnlUpx2:        TPanel;
    chkBrute:       TCheckBox;
    chkMethods:     TCheckBox;
    lblCompOps: TLabel;
    chkFilters:     TCheckBox;
    chkLZMA: TCheckBox;
    chkUltraBrute: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure txtCommandsChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure chkIntegrateClick(Sender: TObject);
    procedure btnScrambleClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure trbCompressionChange(Sender: TObject);
    procedure chkCompressionClick(Sender: TObject);
    procedure btnCommandsClick(Sender: TObject);
		procedure chkBruteClick(Sender: TObject);
		procedure chkUltraBruteClick(Sender: TObject);
	private
    { Private declarations }
    procedure LoadAdvSettings;
  public
    { Public declarations }
  end;

var
  SetupForm: TSetupForm;

implementation

uses
  SysUtils,
  Shared, Translator, Globals,
  MainFrm, CommandsFrm;

{$R *.dfm}

{** This procedure loads advanced application settings from the registry **}
procedure TSetupForm.LoadAdvSettings;
begin
  // Now all the app settings will get loaded..
  chkScramble.Checked    := ReadKey('Scramble', ktBoolean).Bool;
  chkIntegrate.Checked   := ReadKey('ShellIntegrate', ktBoolean).Bool;
  chkResources.Checked   := ReadKey('CompressResources', ktBoolean).Bool;
  chkExports.Checked     := ReadKey('Compress exports', ktBoolean).Bool;
  chkRelocs.Checked      := ReadKey('StripRelocs', ktBoolean).Bool;
  chkForce.Checked       := ReadKey('ForceCompression', ktBoolean).Bool;
  chkCompression.Checked := ReadKey('AdvCompression', ktBoolean).Bool;
  txtCommands.Text       := ReadKey('Commands', ktString).Str;
  chkCommands.Checked    := ReadKey('SaveCommands', ktBoolean).Bool;
  chkBrute.Checked       := ReadKey('Brute', ktBoolean).Bool;
  chkMethods.Checked     := ReadKey('AllMethods', ktBoolean).Bool;
	chkFilters.Checked     := ReadKey('AllFilters', ktBoolean).Bool;
	chkLZMA.Checked        := ReadKey('LZMA', ktBoolean).Bool;
  chkUltraBrute.Checked  := ReadKey('UltraBrute', ktBoolean).Bool;

  if (ReadKey('Priority', ktInteger).Int <> -1) then
  begin
    cmbPriority.ItemIndex := ReadKey('Priority', ktInteger).Int;
  end
  else
  begin
    cmbPriority.ItemIndex := 1;
  end;

  if (ReadKey('Icons', ktInteger).Int <> -1) then
  begin
    cmbIcons.ItemIndex := ReadKey('Icons', ktInteger).Int;
  end
  else
  begin
    cmbIcons.ItemIndex := 2;
  end;

  if (ReadKey('AdvCompressionSeed', ktInteger).Int <> -1) then
  begin
    trbCompression.Position := ReadKey('AdvCompressionSeed', ktInteger).Int;
    lblCompression.Caption  := IntToStr(trbCompression.Position);
  end;
end;

{** **}
procedure TSetupForm.FormCreate(Sender: TObject);
var
  Save: longint;
begin
  //Removes the header from the form
  if BorderStyle = bsNone then
  begin
    Exit;
  end;
  Save := GetWindowLong(Handle, GWL_STYLE);
  if (Save and WS_CAPTION) = WS_CAPTION then
  begin
    case BorderStyle of
      bsSingle, bsSizeable:
      begin
        SetWindowLong(Handle, GWL_STYLE,
          Save and (not WS_CAPTION) or WS_BORDER);
      end;
      bsDialog:
      begin
        SetWindowLong(Handle, GWL_STYLE,
          Save and (not WS_CAPTION) or DS_MODALFRAME or WS_DLGFRAME);
      end;
    end;
    Height := Height - GetSystemMetrics(SM_CYCAPTION);
    Refresh;
  end;
  //Loads settings
  LoadAdvSettings;
end;

{** **}
procedure TSetupForm.txtCommandsChange(Sender: TObject);
begin
  if txtCommands.Text <> '' then
  begin
    chkCommands.Enabled := True;
  end
  else
  begin
    chkCommands.Enabled := False;
  end;
end;

{** **}
procedure TSetupForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  RegValue: TRegValue;
begin
  // Now all the app settings will get loaded..
  RegValue.Bool := chkScramble.Checked;
  StoreKey('Scramble', RegValue, ktBoolean);

  RegValue.Bool := chkIntegrate.Checked;
  StoreKey('ShellIntegrate', RegValue, ktBoolean);

  RegValue.Bool := chkResources.Checked;
  StoreKey('CompressResources', RegValue, ktBoolean);

  RegValue.Bool := chkExports.Checked;
  StoreKey('Compress exports', RegValue, ktBoolean);

  RegValue.Bool := chkRelocs.Checked;
  StoreKey('StripRelocs', RegValue, ktBoolean);

  RegValue.Bool := chkForce.Checked;
  StoreKey('ForceCompression', RegValue, ktBoolean);

  RegValue.Int := cmbPriority.ItemIndex;
  StoreKey('Priority', RegValue, ktInteger);

  RegValue.Int := cmbIcons.ItemIndex;
  StoreKey('Icons', RegValue, ktInteger);

	RegValue.Bool := chkBrute.Checked;
	StoreKey('Brute', RegValue, ktBoolean);

	RegValue.Bool := chkMethods.Checked;
	StoreKey('AllMethods', RegValue, ktBoolean);

	RegValue.Bool := chkFilters.Checked;
	StoreKey('AllFilters', RegValue, ktBoolean);

	RegValue.Bool := chkLZMA.Checked;
	StoreKey('LZMA', RegValue, ktBoolean);

  RegValue.Bool := chkUltraBrute.Checked;
	StoreKey('UltraBrute', RegValue, ktBoolean);

  RegValue.Bool := chkCompression.Checked;
  StoreKey('AdvCompression', RegValue, ktBoolean);

  RegValue.Int := trbCompression.Position;
  StoreKey('AdvCompressionSeed', RegValue, ktInteger);

  RegValue.Bool := chkCommands.Checked;
  StoreKey('SaveCommands', RegValue, ktBoolean);

  if chkCommands.Checked then
  begin
    RegValue.Str := txtCommands.Text;
  end
  else
  begin
    RegValue.Str := '';
  end;
  StoreKey('Commands', RegValue, ktString);
end;

{** **}
procedure TSetupForm.chkIntegrateClick(Sender: TObject);
begin
  if chkIntegrate.Checked then
  begin
    IntergrateContext([extRegister]);
  end
  else
  begin
    IntergrateContext([extUnRegister]);
  end;
end;

{** **}
procedure TSetupForm.btnScrambleClick(Sender: TObject);
begin
  ScrambleUPX;
  SetupForm.Close;
end;

{** **}
procedure TSetupForm.FormActivate(Sender: TObject);
begin
  LoadLanguage(SetupForm);
  LoadAdvSettings;
end;

{** **}
procedure TSetupForm.trbCompressionChange(Sender: TObject);
begin
  lblCompression.Caption := IntToStr(trbCompression.Position);
end;

{** **}
procedure TSetupForm.chkCompressionClick(Sender: TObject);
begin
  trbCompression.Enabled := chkCompression.Checked;
  lblCompression.Enabled := chkCompression.Checked;
end;

{** **}
procedure TSetupForm.btnCommandsClick(Sender: TObject);
begin
  CommandsForm := TCommandsForm.Create(self);
  try
    CommandsForm.ShowModal;
  finally
    CommandsForm.Release
  end;
end;

{** **}
procedure TSetupForm.chkBruteClick(Sender: TObject);
begin
	if chkBrute.Checked then
	begin
		chkFilters.Enabled := False;
		chkMethods.Enabled := False;
	end
	else
	begin
		chkFilters.Enabled := True;
		chkMethods.Enabled := True;
	end;
end;

{** **}
procedure TSetupForm.chkUltraBruteClick(Sender: TObject);
begin
	if chkUltraBrute.Checked then
	begin
		chkBrute.Enabled   := False;
		chkFilters.Enabled := False;
		chkMethods.Enabled := False;
	end
	else
	begin
		chkBrute.Enabled   := True;
		chkFilters.Enabled := True;
		chkMethods.Enabled := True;
	end;
end;

end.
