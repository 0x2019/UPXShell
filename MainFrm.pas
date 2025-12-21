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
 { Main UPX Shell unit                           }
 {***********************************************}
 { You may use and modify this unit and any other}
 { unit in this application and distribute it as }
 { you like, with the only condition that your   }
 { work must be stated as:                       }
 { 'Based on Michael Hardy source code'                }
 {***********************************************}
 { Copyrights by ION Trooper, Michael Hardy, 2000-2001 }
 {   --== Updated by BlackDex 2004-2007 ==--     }
 {***********************************************}
unit MainFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Gauges, {Translator,} Menus;

type
  TMainForm = class(TForm)
    btnAdvanced:  TButton;
    btnGo:        TButton;
    btnHelp:      TButton;
    btnMultiPck:  TButton;
    btnOpen:      TButton;
    btnRun:       TButton;
    bvlCompressor: TBevel;
    bvlOpenLeft:  TBevel;
    bvlRatio:     TBevel;
    chkAutoCompress: TCheckBox;
    chkBackup:    TCheckBox;
    chkExitDone:  TCheckBox;
    chkTest:      TCheckBox;
    ClearHistory: TMenuItem;
    cmbLanguage:  TComboBox;
    dlgOpen:      TOpenDialog;
    imgGradient:  TImage;
    imgHistory:   TImage;
    imgIONTek:    TImage;
    imgLogoGrad1: TImage;
    imgLogoGrad2: TImage;
    imgMail:      TImage;
    imgUPX:       TImage;
    imgWWW:       TImage;
    lblBetter:    TLabel;
    lblBuild:     TLabel;
    lblBuildCap:  TLabel;
    lblCompression: TLabel;
    lblCompressLevel: TLabel;
    lblCompressor: TLabel;
    lblCSize:     TLabel;
    lblCSizeCap:  TLabel;
    lblEMail:     TLabel;
    lblFaster:    TLabel;
    lblFName:     TLabel;
    lblFNameCap:  TLabel;
    lblFSize:     TLabel;
    lblFSizeCap:  TLabel;
    lblHistory:   TLabel;
    lblIns:       TLabel;
    lblInsCap:    TLabel;
    lblIONT:      TLabel;
    lblIONTmail:  TLabel;
    lblLanguage:  TLabel;
    lblOut:       TLabel;
    lblOutCap:    TLabel;
    lblProgress:  TLabel;
    lblProgressSize: TLabel;
    lblRatio:     TLabel;
    lblRatioCap:  TLabel;
    lblRelease:   TLabel;
    lblReleaseCap: TLabel;
    lblWWW:       TLabel;
		mnuHistory:   TPopupMenu;
    N1:           TMenuItem;
    pgcMain:      TPageControl;
    pnlAbout:     TPanel;
    pnlAll:       TPanel;
    pnlCompress:  TPanel;
    pnlFileInfo:  TPanel;
    pnlHelp:      TPanel;
    pnlOpen:      TPanel;
    pnlOpenLeft:  TPanel;
    pnlOptions:   TPanel;
    pnlProgress:  TPanel;
    pnlProgressSize: TPanel;
    pnlTop:       TPanel;
    prbCompress:  TGauge;
    prbSize:      TGauge;
    stbMain:      TStatusBar;
    sttDecomp:    TStaticText;
    tbsAbout:     TTabSheet;
    tbsCompress:  TTabSheet;
    tbsHelp:      TTabSheet;
    tbsOpen:      TTabSheet;
    tbsOptions:   TTabSheet;
    trbCompressLvl: TTrackBar;
    pnlAction:    TPanel;
    btnLocalizerMode: TButton;
    pnlLocalization: TPanel;
    btnSaveAs:    TButton;
    btnEditMessages: TButton;
    dlgSaveLanguageFile: TSaveDialog;
    lblIns2:      TLabel;
    cmbUPX:       TComboBox;
    chkDecomp:    TCheckBox;
    Label1: TLabel;
    procedure btnSaveAsClick(Sender: TObject);
    procedure btnEditMessagesClick(Sender: TObject);
    procedure btnLocalizerModeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ClearHistoryClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOpenClick(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure tbsOpenShow(Sender: TObject);
    procedure tbsCompressShow(Sender: TObject);
    procedure tbsOptionsShow(Sender: TObject);
    procedure tbsAboutShow(Sender: TObject);
    procedure tbsHelpShow(Sender: TObject);
    procedure trbCompressLvlChange(Sender: TObject);
    procedure btnAdvancedClick(Sender: TObject);
    procedure cmbLanguageChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure stbMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure btnHelpClick(Sender: TObject);
    procedure btnMultiPckClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure imgHistoryMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure FormShow(Sender: TObject);
    procedure HyperClick(Sender: TObject);
    procedure cmbUPXChange(Sender: TObject);
  private
    procedure HistoryPopUp(Sender: TObject); // Declaration of History popup handler
    procedure WMDropfiles(var Msg: Tmessage); message WM_DROPFILES;
    procedure ParseCommandLine;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses SysUtils, ShlObj, Wininet, ShellAPI,
  Globals, Translator, Compression, Shared, UPXScrambler,
  MultiFrm, SetupFrm, LocalizerFrm;

{$R *.dfm}

{*************************************************
 First list all the non-form procedures/functions
 This is because of dependencies
*************************************************}

{** This procedure loads application settings from the registry **}
procedure LoadSettings;
begin
  bStdUPXVersion := 0;

  {** Start reading settings from the registry ReadKey('History', ktString).Str; **}
  MainForm.chkAutoCompress.Checked := ReadKey('AutoCompress', ktBoolean).Bool;
  MainForm.chkExitDone.Checked     := ReadKey('ExitDone', ktBoolean).Bool;
  MainForm.chkBackup.Checked       := ReadKey('CreateBackup', ktBoolean).Bool;
  MainForm.chkTest.Checked         := ReadKey('TestFile', ktBoolean).Bool;
  MainForm.trbCompressLvl.Position := ReadKey('CompressionLevel', ktInteger).Int;

  WorkDir := ReadKey('InstallPath', ktString).Str;
  if WorkDir = '' then
  begin
    WorkDir := SysUtils.ExtractFileDir(ParamStr(0)) + '\';
  end;

  LangFile := ReadKey('LanguageFile', ktString).Str;
  if LangFile = '' then
  begin
		LangFile := 'English';
  end;

	bStdUPXVersion := ReadKey('StdUPXVersion', ktInteger).Int;
	curUPXVersion  := TUPXVersions(bStdUPXVersion);
end;

procedure FillUPXVersionsBox;
var
	I: TUPXVersions;
	ItemText: String;
begin
	MainForm.cmbUPX.Clear;
	for I := Low(aUPXVersions) to High(aUPXVersions) do
	begin
		ItemText := aUPXVersions[I];
		if (I = UPXC) then
		begin
			if (FileExists(WorkDir +'upx.exe')) then
			begin
				ItemText := TranslateMsg('Custom upx.exe');
			end
			else
			begin
				Continue;
			end;
		end;
		MainForm.cmbUPX.Items.Add(ItemText);
	end;
	if (bStdUPXVersion <= MainForm.cmbUPX.Items.Count - 1) then
	begin
		MainForm.cmbUPX.ItemIndex := bStdUPXVersion;
	end
	else
	begin
		MainForm.cmbUPX.ItemIndex := 1; //UPX2.0x
	end;
end;

{** This procedure saves the app settings to registry **}
procedure SaveSettings;
var
  RegValue: TRegValue;
begin
  {** The following code saves everything that should be saved of the MainForm **}
  RegValue.Bool := MainForm.chkAutoCompress.Checked;
  StoreKey('AutoCompress', RegValue, ktBoolean);

  RegValue.Bool := MainForm.chkExitDone.Checked;
  StoreKey('ExitDone', RegValue, ktBoolean);

  RegValue.Bool := MainForm.chkBackup.Checked;
  StoreKey('CreateBackup', RegValue, ktBoolean);

  RegValue.Bool := MainForm.chkTest.Checked;
  StoreKey('TestFile', RegValue, ktBoolean);

  RegValue.Int := MainForm.trbCompressLvl.Position;
  StoreKey('CompressionLevel', RegValue, ktInteger);

  RegValue.Str := MainForm.cmbLanguage.Text;
  StoreKey('LanguageFile', RegValue, ktString);

  RegValue.Int := MainForm.cmbUPX.ItemIndex;
  StoreKey('StdUPXVersion', RegValue, ktInteger);
end;

{** This one loads a list of previously opened files and adds'em to History menu **}
procedure LoadHistory;
var
  Strings:  TStrings;
  I:        integer;
  MenuItem: TMenuItem; // To add to the History menu
begin
  Strings := TStringList.Create;
  try
    Strings.CommaText := ReadKey('History', ktString).Str;
    // Load the file history
    for I := Strings.Count - 1 downto 0 do
    begin
      MenuItem         := TMenuItem.Create(MainForm);
      MenuItem.Caption := Strings.Strings[I];
      MenuItem.OnClick := MainForm.HistoryPopUp;
			MainForm.mnuHistory.Items.Add(MenuItem);
    end;
  finally
    FreeAndNil(Strings);
  end;
end;

{** Adds an item to the History menu and stores it to registry **}
procedure WriteHistory(const FileName: string);
var
  Strings: TStrings;
  Value:   TRegValue;

  { This nested procedure adds a new menu item to the History menu }
  procedure AddNewMenuItem;
  var
    MenuItem: TMenuItem; // To add to the History menu
  begin
    MenuItem         := TMenuItem.Create(MainForm);
    MenuItem.Caption := FileName;
    MenuItem.OnClick := MainForm.HistoryPopUp;
    MainForm.mnuHistory.Items.Add(MenuItem);
  end;

begin
  Strings := TStringList.Create;
  try
    Strings.CommaText := ReadKey('History', ktString).Str;
    // Load the file history
    if Strings.IndexOf(FileName) = -1 then // If item isn't already in the list
    begin
      Strings.Add(FileName);
      Value.Str := Strings.CommaText;
      StoreKey('History', Value, ktString);
      AddNewMenuItem;
    end;
  finally
    FreeAndNil(Strings);
  end;
end;

{** Start Compressing **}
procedure StartCompression; //initializes compression

  procedure SetCompressionVisuals(ControlEnabled: boolean);
  begin
    with MainForm do
    begin
      btnOpen.Enabled         := ControlEnabled;
      btnGo.Enabled           := ControlEnabled;
      imgHistory.Enabled      := ControlEnabled;
      chkDecomp.Enabled       := ControlEnabled;
      cmbUPX.Enabled          := ControlEnabled;
      btnRun.Enabled          := ControlEnabled;
      chkBackup.Enabled       := ControlEnabled;
      chkAutoCompress.Enabled := ControlEnabled;
      chkExitDone.Enabled     := ControlEnabled;
      chkTest.Enabled         := ControlEnabled;
      btnAdvanced.Enabled     := ControlEnabled;
      btnMultiPck.Enabled     := ControlEnabled;
      trbCompressLvl.Enabled  := ControlEnabled;

      if not ControlEnabled then
      begin
        sttDecomp.Width := 0;
      end;
    end;
	end;

	procedure TouchFile(const FileName: string);
	begin
		SHChangeNotify(SHCNE_UPDATEITEM, SHCNF_PATH, PChar(FileName), nil);
		SHChangeNotify(SHCNE_ATTRIBUTES, SHCNF_PATH, PChar(ExtractFileDir(FileName)), nil);
	end;

  //Main code
var
  StartTime: int64;
  OldCursor: TCursor;
  Compress:  TCompDecomp; //Holds whether to compress or decompress
begin
  Busy      := True;
  OldCursor := Screen.Cursor;
  try
    QueryTime(False, StartTime);
    DragAcceptFiles(MainForm.Handle, False);
    //Disable Drag&Drop while compressing
    SetCompressionVisuals(False);
    if not MainForm.chkDecomp.Checked then
    begin
      Compress := cdCompress;
    end
    else
    begin
      Compress := cdDecompress;
    end;
    //Start the compression now
    CompressFile(GetCompressParams, Compress);
    SetCompressionVisuals(True);
    MainForm.stbMain.Panels[1].Text := MainForm.stbMain.Panels[1].Text +
			TranslateMsg(' (in ') + QueryTime(True, StartTime) + TranslateMsg(' seconds)');
		if (Compress = cdCompress) and (SetupForm.chkScramble.Checked) then
    begin
      try
        Screen.Cursor := crHourGlass;
        ScrambleUPX;
      finally
        Screen.Cursor := OldCursor;
      end;
    end;
    TouchFile(GlobFileName);
    if (MainForm.chkExitDone.Checked) and (CompressionResult) then
    begin
      Application.Terminate;
    end;
  finally
    Busy := False;
    DragAcceptFiles(MainForm.Handle, True); // Re-enable Drag&Drop
  end;
end;

{** Opens the specified file for the further compression..
  Contains a lot of nested procedures **}
procedure LoadFile(const FileName: string);
//This function unsets the ReadOnly attribute of the file
  function SetFileAttrib: boolean;
  var
    Attrib: cardinal;
  begin
    Result := True;
    Attrib := GetFileAttributes(PChar(FileName));
    if (Attrib and FILE_ATTRIBUTE_READONLY) > 0 then
    begin
			if Application.MessageBox(PChar(TranslateMsg(
        'The file attribute is set to ReadOnly.' + #10#13 +
        'To proceed it must be unset. Continue?')),
        PChar(TranslateMsg('Confirmation')),
        MB_YESNO + MB_ICONQUESTION) = idYes then
      begin
        SetFileAttributes(PChar(FileName), Attrib - FILE_ATTRIBUTE_READONLY);
        Result := True;
      end
      else
      begin
        Result := False;
      end;
    end;
  end;

  //This one resets all visual controls to default state
  procedure ResetVisuals;
  begin
    MainForm.lblCSizeCap.Visible     := False;
    MainForm.lblCSize.Visible        := False;
    MainForm.bvlRatio.Visible        := False;
    MainForm.lblRatioCap.Visible     := False;
    MainForm.lblRatio.Visible        := False;
    MainForm.btnRun.Visible          := False;
    MainForm.pgcMain.ActivePageIndex := 1;
    MainForm.prbCompress.Progress    := 0;
    MainForm.prbSize.Progress        := 0;
    MainForm.sttDecomp.Width         := 0;
  end;

  //Extracts file name out of a path
  procedure ExtractName;
  var
    Temp: string;
  begin
    Temp := SysUtils.ExtractFileName(FileName);
    MainForm.lblFName.Caption := Temp;
    MainForm.stbMain.Panels[0].Text := Temp;
  end;

  //Start main procedure
begin
  if (FileName <> '') and (FileExists(FileName)) and (SetFileAttrib) then
    //Unsets read-only attribute of a file
  begin
    GlobFileName := FileName; //Assign a global filename variable
    ResetVisuals; //Resets visual controls
    if AlreadyPacked then
    begin
      //This one checks if the file is compressed and sets RadioButton
      MainForm.chkDecomp.Checked := True;
      sUPXVersion := GetUPXBuild(GlobFileName);
    end
    else
    begin
      MainForm.chkDecomp.Checked := False;
      sUPXVersion := '';
      MainForm.cmbUPX.ItemIndex := bStdUPXVersion;
    end;
    ExtractName;                     //Extracts a file name and puts it on a label & statusbar
    CalcFileSize;                   //Extracts file size and puts it on another label
    WriteHistory(FileName);         //Add item to History menu
    if MainForm.chkAutoCompress.Checked then
    begin
      StartCompression;
    end;
  end;
end;

{** This procedure is responsible for changing of the
    track bar label from digits to 'best' and vice versa:-) **}
procedure TrackBest;
begin
  if MainForm.trbCompressLvl.Position < 10 then
  begin
    MainForm.lblCompression.Caption :=
      IntToStr(MainForm.trbCompressLvl.Position);
  end
  else
  begin
    MainForm.lblCompression.Caption := TranslateMsg('Best');
  end;
end;

{** Loads visual settings, gets upx version... **}
procedure LoadVisualSettings;
var
  UPXOutStr: string;
begin
  //Checks if there is newer upx installed and sets it
  with MainForm do
  begin
    UPXOutStr := GetUPXBuild(WorkDir + 'upx.exe');
    if (UPXOutStr <> '') then
    begin
      lblIns2.Caption := '&& ' + UPXOutStr;
    end
    else
    begin
      lblIns2.Caption := '';
    end;

    //Checks UPX Shell release and buil numbers
    if BuildInfo.biNoBuild <> '' then
    begin
      lblRelease.Caption := BuildInfo.biNoBuild;
      lblBuild.Caption   := IntToStr(BuildInfo.biBuild);
    end
    else
    begin
      lblRelease.Caption := 'Unknown';
      lblBuild.Caption   := 'Unknown';
    end;
    lblOut.Caption     := BuildInfo.biCute;
  end;
end;

 {** Scans workdir for .lng files and adds them to cmbLanguage **}
procedure EnumerateLanguages;
 //Kill the final .lng extension to show in the cmbLanguage
  function KillExt(const FullPath: string): string;
  begin
    Result := ExtractFileName(FullPath);
    Result := copy(Result, 1, Pos('.', Result) - 1);
  end;

var
  SRec:  TSearchRec;
  LangF: string;
begin
  SetCurrentDir(WorkDir + LanguageSubdir);
  if FindFirst('*.lng', faAnyFile, SRec) = 0 then
  begin
    MainForm.cmbLanguage.Items.Add(KillExt(SRec.Name));
    while FindNext(SRec) = 0 do
    begin
      MainForm.cmbLanguage.Items.Add(KillExt(SRec.Name));
    end;
  end;
  FindClose(SRec);
  with MainForm.cmbLanguage do
  begin
    LangF := ReadKey('LanguageFile', ktString).Str;
    if LangF = '' then
    begin
      ItemIndex := Items.IndexOf('English');
      LangFile  := 'English';
    end
    else
    begin
      ItemIndex := Items.IndexOf(LangF);
      LangFile  := LangF;
    end;
  end;
  SetCurrentDir(WorkDir);
end;

{*************************************************
 Second list all the form procedures/functions
 Now the Non-Forum procedures/functions are all declared already
*************************************************}

{** **}
procedure TMainForm.ParseCommandLine;
var
  I: integer;
begin
  for I := 1 to ParamCount() do
  begin
    //Check if the setup calls to (Un)Register the extensions.
    if ParamStr(I) = '--SETUP-REGEXT' then
    begin
      LoadLanguage(MainForm);
      IntegrateContext([doSetup, extRegister]);
      Application.Terminate;
    end
    else
    if ParamStr(I) = '--SETUP-UNREGEXT' then
    begin
      LoadLanguage(MainForm);
      IntegrateContext([doSetup, extUnRegister]);
      Application.Terminate;
    end;
    //Check to start in the debug mode.
    if ParamStr(I) = '--debug' then
    begin
      Globals.Config.DebugMode := True;
    end;
  end;
end;

{** This procedure handles the History Menu **}
procedure TMainForm.HistoryPopUp(Sender: TObject);
begin
  LoadFile((Sender as TMenuItem).Caption);
end;

{** **}
procedure TMainForm.FormCreate(Sender: TObject);
begin
  //Set the Global DecimalSeparator so it will be used everywhere since we need it to be a '.'
  FormatSettings.DecimalSeparator := '.';

  GetBuild; // Get the build information
  DrawGradient(imgGradient.Canvas, 255, imgGradient.Height,
    imgGradient.Width, clSilver, GetSysColor(COLOR_BTNFACE));
  DragAcceptFiles(MainForm.Handle, True); // Enable Drag&Drop

	with Globals.Config do
	begin
	//ACTIVATING DEBUG
		DebugMode := False;
    LocalizerMode := False;
  end;
	LoadSettings;
  LoadHistory;
  //ParseCommandLine;
  Application.HintHidePause := 10000;
	Application.HelpFile      := WorkDir + 'Manual.chm';
	EnumerateLanguages;
	ParseCommandLine;
  // Scans for available language files and adds to cmbLanguage
  DrawGradient(imgLogoGrad1.Canvas, 50, imgLogoGrad1.Height,
    imgLogoGrad1.Width,
    clBtnFace, clSilver);
  DrawGradient(imgLogoGrad2.Canvas, 50, imgLogoGrad2.Height,
    imgLogoGrad2.Width,
    clSilver, clBtnFace);
end;

{** Clears the History menu **}
procedure TMainForm.ClearHistoryClick(Sender: TObject);
var
  Value: TRegValue;
  I:     integer;
begin
  Value.Str := '';
  StoreKey('History', Value, ktString);
  for I := mnuHistory.Items.Count - 1 downto 2 do
  begin
    mnuHistory.Items.Delete(I);
	end;
end;

{** **}
procedure TMainForm.imgHistoryMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
	mnuHistory.Popup(MainForm.Left + 90, MainForm.Top + 200);
end;

{** **}
procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveSettings;
end;

{** **}
procedure TMainForm.btnOpenClick(Sender: TObject);
var
  RegValue: TRegValue;
begin
  dlgOpen.FilterIndex := Extension;
  with ReadKey('LastFolder', ktString) do
  begin
    if Str <> '' then
    begin
      dlgOpen.InitialDir := Str;
    end;
  end;
  if dlgOpen.Execute then
  begin
    Extension    := dlgOpen.FilterIndex;
    RegValue.Str := ExtractFileDir(dlgOpen.FileName);
    StoreKey('LastFolder', RegValue, ktString);
    if dlgOpen.FileName <> '' then
    begin
      LoadFile(dlgOpen.filename);
    end;
  end;
end;

{** **}
procedure TMainForm.btnGoClick(Sender: TObject);
var
  CompDecomp: string;
begin
  if GlobFileName = '' then
  begin
    if chkDecomp.Checked then
    begin
      CompDecomp := TranslateMsg('decompress');
    end
    else
    begin
      CompDecomp := TranslateMsg('compress');
    end;
    beep;
    Application.MessageBox(PChar(TranslateMsg('There is nothing to ') +
      CompDecomp),
      PChar(TranslateMsg('Error')), MB_OK + MB_ICONERROR);
  end
  else
  begin
    StartCompression;
  end;
end;

{** Drag&Drop handler **}
procedure TMainForm.WMDropfiles(var Msg: Tmessage);
var
  hdrop:     integer; //THandle
  Buffer:    string;
  BufLength: integer;
begin
  hdrop     := Msg.WParam;
  BufLength := DragQueryFile(hdrop, 0, nil, 300) + 1;
  setlength(Buffer, BufLength);
  DragQueryFile(hdrop, 0, PChar(Buffer), BufLength);
  DragFinish(hdrop);
  LoadFile(trim(Buffer));
end;

{** **}
procedure TMainForm.tbsOpenShow(Sender: TObject);
begin
  if btnOpen.Enabled then
  begin
    btnOpen.SetFocus;
  end;
end;

{** **}
procedure TMainForm.tbsCompressShow(Sender: TObject);
begin
  if btnGo.Enabled then
  begin
    btnGo.SetFocus;
  end;
end;

{** **}
procedure TMainForm.tbsOptionsShow(Sender: TObject);
begin
  if chkBackup.Enabled then
  begin
    chkBackup.SetFocus;
  end;
end;

{** **}
procedure TMainForm.tbsAboutShow(Sender: TObject);
begin
  if pnlAbout.Enabled then
  begin
    pnlAbout.SetFocus;
  end;
end;

{** **}
procedure TMainForm.tbsHelpShow(Sender: TObject);
begin
  if btnHelp.Enabled then
  begin
    btnHelp.SetFocus;
  end;
end;

{** **}
procedure TMainForm.trbCompressLvlChange(Sender: TObject);
begin
  TrackBest;
end;

{** **}
procedure TMainForm.btnAdvancedClick(Sender: TObject);
begin
  SetupForm.ShowModal;
end;

{** **}
procedure TMainForm.cmbLanguageChange(Sender: TObject);
var
  RegValue: TRegValue;
begin
  RegValue.Str := Trim(TranslateMsg('Compress with UPX'));
  StoreKey('OldContext', RegValue, ktString);
  LangFile     := cmbLanguage.Text;
  LoadLanguage(MainForm);
  TrackBest;
  if SetupForm.chkIntegrate.Checked then
  begin
    IntegrateContext([extRegister]);
	end;
	FillUPXVersionsBox;
end;

{** **}
procedure TMainForm.FormActivate(Sender: TObject);
begin
	LoadLanguage(MainForm);
	FillUPXVersionsBox;
  TrackBest; //Checks the position of CompressionLevel TrackBar
  LoadVisualSettings;
end;

{** **}
procedure TMainForm.stbMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  if (stbMain.Panels[0].Text <> '') and (stbMain.Panels[1].Text = '') then
  begin
    stbMain.Hint := stbMain.Panels[0].Text;
  end
  else
  begin
    if (stbMain.Panels[0].Text <> '') and (stbMain.Panels[1].Text <> '') then
    begin
      stbMain.Hint := stbMain.Panels[0].Text + #13#10 + stbMain.Panels[1].Text;
    end;
  end;
end;

{** **}
procedure TMainForm.btnHelpClick(Sender: TObject);
begin
  if (Application.HelpFile <> '') and FileExists(Application.HelpFile) then
  begin
    ShellExecute(self.Handle, 'open', PChar(Application.HelpFile), nil, nil, SW_SHOWNORMAL);
  end
  else
  begin
    Application.MessageBox(PChar(TranslateMsg('Help file not found.')),
      PChar(TranslateMsg('Error')), MB_OK + MB_ICONERROR);
  end;
end;

{** **}
procedure TMainForm.btnMultiPckClick(Sender: TObject);
begin
  MultiForm := TMultiForm.Create(self);
  try
    // 1: Fix by KIRILL on 12.03.2003
    MainForm.Hide;
    MultiForm.ShowModal;
    MainForm.Show;
  finally
    MultiForm.Release
  end;
end;

{** **}
procedure TMainForm.btnRunClick(Sender: TObject);
begin
  ShellExecute(self.Handle, 'open', PChar(GlobFileName), nil, nil, SW_SHOWNORMAL);
end;

{** **}
procedure TMainForm.HyperClick(Sender: TObject);
var
  S: string;
begin
  // 1: Fix by KIRILL on 12.03.2003
  case (Sender as TLabel).Tag of
    1:
    begin
      S := 'http://www.hardyfoundation.com/upx/';
    end;
    2:
    begin
      S := 'http://upx.sf.net';
    end;
    3:
    begin
      S := 'mailto:Michael Hardy<hardycreations@gmail.com>?Subject=UPX_Shell_' +
        BuildInfo.biFull;
    end;
    4:
    begin
      S := 'mailto:BlackDex<black.dex.prg@gmail.com>?Subject=UPX_Shell_' +
        BuildInfo.biFull;
    end;
    5:
    begin
      S := 'mailto:Blaine<bsoutham@myrealbox.com>?Subject=UPX_Shell_' +
        BuildInfo.biFull;
    end;
  end;
  ShellExecute(0, 'open', PChar(S), nil, nil, SW_SHOWNORMAL);
end;

{** **}
procedure TMainForm.FormShow(Sender: TObject);
begin
  // I have no other choice, but to put this code in the
  // onShow event, since I must make sure that the form is
  // drawn...
  if lowercase(ParamStr(1)) <> '' then
  begin
    //Checks if there's a file passed through command line
    LoadFile(ParamStr(1));
  end;
  OnShow := nil;
end;

{** **}

procedure TMainForm.btnLocalizerModeClick(Sender: TObject);
begin
  // Toggle localization mode
  // In this mode every object capable of MouseUp event
  // detection get's a popup menu, which allows one to set
  // the object's caption and hint
  Globals.Config.LocalizerMode := not Globals.Config.LocalizerMode;
  pnlLocalization.Visible      := Globals.Config.LocalizerMode;

  LocalizerMode(self, Globals.Config.LocalizerMode);
  LocalizerMode(SetupForm, Globals.Config.LocalizerMode);

  // we need to do some special processing in order to show the otherwise
  // inaccessible MultiForm
  if Globals.Config.LocalizerMode then
  begin
    MultiForm      := TMultiForm.Create(Application);
    MultiForm.Show();
    MultiForm.Left := self.Left + self.Width + 20;
    LocalizerMode(MultiForm, Globals.Config.LocalizerMode);
  end
  else
  begin
    MultiForm.Release();
    SetupForm.Hide();
  end;
end;

procedure TMainForm.btnSaveAsClick(Sender: TObject);
begin
  dlgSaveLanguageFile.InitialDir := WorkDir + LanguageSubdir;
  if dlgSaveLanguageFile.Execute() then
  begin
    DumpLanguage(Self, dlgSaveLanguageFile.FileName, fmCreate);
    DumpLanguage(SetupForm, dlgSaveLanguageFile.FileName, fmOpenReadWrite);
    DumpLanguage(MultiForm, dlgSaveLanguageFile.FileName, fmOpenReadWrite, True);
  end;
end;

procedure TMainForm.btnEditMessagesClick(Sender: TObject);
var
  Localizer: TLocalizerForm;
begin
  Localizer := TLocalizerForm.Create(nil);
  try
    Localizer.FMode := lfmMessages;
    Localizer.ShowModal();
  finally
    Localizer.Release();
  end;
end;

procedure TMainForm.cmbUPXChange(Sender: TObject);
begin
	if (TUPXVersions(cmbUPX.ItemIndex) = UPXC) then
	begin
		if FileExists(WorkDir +'upx.exe') then
		begin
			//TODO Create a function which will only check for the external upx version.
			//TODO Also make it so that it will set the corrosponding curUPXVersion if it knows which version it is. This so it can have some of the extra features.
			LoadVisualSettings;
			bStdUPXVersion := cmbUPX.ItemIndex;
			curUPXVersion := TUPXVersions(bStdUPXVersion);
		end
		else
		begin
			curUPXVersion  := TUPXVersions(bStdUPXVersion);
			cmbUPX.ItemIndex := bStdUPXVersion;
		end;
	end
	else
	begin
		bStdUPXVersion := cmbUPX.ItemIndex;
		curUPXVersion  := TUPXVersions(bStdUPXVersion);
	end;
end;

end.
