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
 { MultiFrm unit                                 }
 {***********************************************}
unit MultiFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Gauges, ComCtrls;

type
  TFilesRec = record
    Skip:           boolean;
    FullName:       string;
    FileName:       string;
    FilePath:       string;
    FileSize:       integer;
    CompressedSize: integer;
    CompressionResult: boolean;
  end;

type
  TMultiForm = class(TForm)
    grpSearch:      TGroupBox;
    btnBrowse:      TButton;
    chkRecurse:     TCheckBox;
    lblDir:         TLabel;
    cmbType:        TComboBox;
    lvFiles:        TListView;
    pnlBottom:      TPanel;
    lblCurrent:     TLabel;
    lblOverall:     TLabel;
    lblTotalCap:    TLabel;
    lblSelectedCap: TLabel;
    lblTimeCap:     TLabel;
    lblTotal:       TLabel;
    lblSelected:    TLabel;
    lblTime:        TLabel;
    btnPack:        TButton;
    btnExit:        TButton;
    btnScan:        TButton;
    pnlCurrent:     TPanel;
    pgbCurrent:     TGauge;
    sttRatio:       TStaticText;
    pnlOverall:     TPanel;
    pgbOverall:     TGauge;
    procedure FormCreate(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnScanClick(Sender: TObject);
    procedure btnPackClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lvFilesKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure lvFilesMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
  private
    Active:        boolean;
    FDirName:      string;
    FGlobFileName: string;
    //backup GlobFileName variable to restore it afterwards
    FFileName:     string[5];
    //    FFileList: array [1..2] of TStringList;
    FFiles:        array of TFilesRec;
    procedure FindFiles(APath: string);
    function GetDirectoryName(const Dir: string): string;
    procedure FindFilesNR(APath: string);
    procedure PackFiles;
    function PackFile(FileName: string): boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MultiForm: TMultiForm;

implementation

uses
  FileCtrl, TypInfo, SysUtils, Math,
  Shared, Translator, Globals,
  MainFrm;

var
  hStdOut: THandle;

{$R *.dfm}

{** This function formats the directory name so that it is a valid
  directory containing the back-slash (\) as the last character. **}
function TMultiForm.GetDirectoryName(const Dir: string): string;
begin
  if Dir[Length(Dir)] <> '\' then
  begin
    Result := Dir + '\';
  end
  else
  begin
    Result := Dir;
  end;
end;

{** This is a procedure which is called recursively so that it finds the
  file with a specified mask through the current directory and its
  sub-directories. **}
procedure TMultiForm.FindFiles(APath: string);
var
  FSearchRec, DSearchRec: TSearchRec;
  FindResult: integer;

  function IsDirNotation(const ADirName: string): boolean;
  begin
    Result := (ADirName = '.') or (ADirName = '..');
  end;

begin
  APath      := GetDirectoryName(APath); // Obtain a valid directory name
  { Find the first occurrence of the specified file name }
  FindResult := FindFirst(APath + FFileName, faAnyFile {+faHidden+
                          faSysFile+faReadOnly}, FSearchRec);
  try
    { Continue to search for the files according to the specified
      mask. If found, add the files and their paths to the listbox.}
    while FindResult = 0 do
    begin
      SetLength(FFiles, length(FFiles) + 1);
      with FFiles[high(FFiles)] do
      begin
        Skip           := False;
        FullName       := APath + FSearchRec.Name;
        FileName       := ExtractFileName(APath + FSearchRec.Name);
        FilePath       := APath;
        FileSize       := GetFileSize(FullName);
        CompressedSize := -1;
        CompressionResult := False;
      end;
      FindResult := FindNext(FSearchRec);
    end;
    { Now search the sub-directories of this current directory. Do this
      by using FindFirst to loop through each subdirectory, then call
      FindFiles (this function) again. This recursive process will
      continue until all sub-directories have been searched. }
    FindResult := FindFirst(APath + '*.*', faDirectory, DSearchRec);
    while FindResult = 0 do
    begin
      if ((DSearchRec.Attr and faDirectory) = faDirectory) and not
        IsDirNotation(DSearchRec.Name) then
      begin
        FindFiles(APath + DSearchRec.Name);
      end; // Recursion here
      FindResult := FindNext(DSearchRec);
    end;
  finally
    FindClose(FSearchRec);
  end;
end;

{** This one is used to search files without directory
  recursion **}
procedure TMultiForm.FindFilesNR(APath: string);
var
  SearchRec:  TSearchRec;
  FindResult: integer;
begin
  APath      := GetDirectoryName(APath);
  FindResult := FindFirst(APath + FFileName, faAnyFile {+faHidden+
                          faSysFile+faReadOnly}, SearchRec);
  while FindResult = 0 do
  begin
    SetLength(FFiles, length(FFiles) + 1);
    with FFiles[high(FFiles)] do
    begin
      Skip           := False;
      FullName       := APath + SearchRec.Name;
      FileName       := ExtractFileName(APath + SearchRec.Name);
      FilePath       := APath;
      FileSize       := GetFileSize(FullName);
      CompressedSize := -1;
      CompressionResult := False;
    end;
    FindResult := FindNext(SearchRec);
  end;
end;

{** **}
procedure TMultiForm.FormCreate(Sender: TObject);
begin
  cmbType.ItemIndex := 1;
  Active        := False;
  FGlobFileName := GlobFileName;
end;

{** **}
procedure TMultiForm.btnBrowseClick(Sender: TObject);
var
  Dir: string;
begin
  if SelectDirectory(TranslateMsg('Select directory to compress:'), '', Dir) then
  begin
    FDirName       := Dir;
    lblDir.Caption := FDirName;
  end;
  {lblSelectedCap.Visible:= false;
  lblSelected.Visible:= false;
  lblTotalCap.Visible:= false;
  lblTotal.Visible:= false;
  lblTimeCap.Visible:= false;
  lblTime.Visible:= false;
  TreeViewForm := TTreeViewForm.Create(Self);
  try
    if TreeViewForm.ShowModal = mrOk then
      lblDir.Caption := FDirName;
  finally
    TreeViewForm.Release;
  end;}
end;

{** **}
procedure EnableButtons(Enable: boolean);
begin
  with MultiForm do
  begin
    Active          := Enable;
    btnBrowse.Enabled := Enable;
    cmbType.Enabled := Enable;
    chkRecurse.Enabled := Enable;
    btnScan.Enabled := Enable;
    btnPack.Enabled := Enable;
    btnExit.Enabled := Enable;
{    if Enable then
    begin
      lblTotalCap.Visible:= true;
      lblTotal.Visible:= true;
//      lblTotal.Caption:= inttostr(clbFiles.Items.Count);
    end;}
  end;
end;

{** **}
procedure FillView;
var
  lItem: TListItem;
  I:     integer;
begin
  with MultiForm do
  begin
    for I := low(FFiles) to high(FFiles) do
    begin
      lItem         := MultiForm.lvFiles.Items.Add;
      lItem.Caption := FFiles[I].FileName;
      lItem.SubItems.Add(FFiles[I].FilePath);
      lItem.SubItems.Add(ProcessSize(FFiles[I].FileSize));
      lItem.SubItems.Add('---');
      lItem.SubItems.Add('---');
    end;
  end;
end;

{** **}
procedure TMultiForm.btnScanClick(Sender: TObject);
begin
  if ((lblDir.Caption = TranslateMsg('N/A')) or (lblDir.Caption = '')) then
  begin
    ShowMessage(TranslateMsg('No directory selected'));
    Exit;
  end
  else
  begin
    Active := True;
    EnableButtons(False);
    lvFiles.Clear;
    SetLength(FFiles, 0);
    Screen.Cursor := crHourGlass;
    FFileName     := cmbType.Text;
    if chkRecurse.Checked then
    begin
      FindFiles(lblDir.Caption);
    end
    else
    begin
      FindFilesNR(lblDir.Caption);
    end;
    FillView;
    EnableButtons(True);
    Screen.Cursor := crDefault;
    Active        := False;
  end;
end;

{** **}
procedure GetProgress(ProcessInfo: TProcessInformation; Compress: boolean);

type
  TLine = array[0..79] of char;
var
  EC:          cardinal;
  C, Progress: integer;
  Offset:      integer;
  ConsoleText: array[0..79] of char;
  CursorPos:   TCoord;
  CharsRead:   DWord;
  Line:        TLine;
  MyString:    string;
begin
  GetExitCodeProcess(ProcessInfo.hProcess, EC);
  CursorPos.x := 0;
  CursorPos.y := 0;
  Progress    := 0;
  Offset      := 0;
  while True do
  begin
    ReadConsoleOutputCharacter(hStdOut, Line, 80, CursorPos, CharsRead);
    Offset := Pos('[', Line) - 1;
    if Offset > -1 then
    begin
      break;
    end
    else
    begin
      Inc(CursorPos.Y);
    end;
    if CursorPos.Y > 20 then
    begin //If we get here - something's wrong
      CursorPos.Y := 0;
      GetExitCodeProcess(ProcessInfo.hProcess, EC);
      if EC <= 2 then
      begin
        Exit;
      end;
    end;
  end;
  while EC > 2 do
  begin
    CharsRead := 0;
    ReadConsoleOutputCharacter(hStdOut, ConsoleText, 80, CursorPos, CharsRead);
    if Line[Offset] = '[' then
    begin
      for C := Offset + Progress + 1 to Offset + 66 do
      begin
        if Line[C] = '*' then
        begin
          Inc(Progress);
        end
        else
        begin
          Break;
        end;
      end;
      if Compress then
      begin
        MyString := Line[69] + Line[70] + Line[71] + Line[72];
        MultiForm.sttRatio.Width := round((MultiForm.pgbCurrent.Width / 100) * round(strtofloat(MyString))) - 3;
      end;
      MultiForm.pgbCurrent.Progress := floor((Progress / 64) * 100);
    end;
    if Progress = 64 then
    begin
      Exit;
    end;
    sleep(50);
    Application.ProcessMessages;
    GetExitCodeProcess(ProcessInfo.hProcess, EC);
  end;
end;

{** **}
procedure UnSetReadOnly(const FileName: string);
var
  Attrib: cardinal;
begin
  Attrib := GetFileAttributes(PChar(FileName));
  if (Attrib and FILE_ATTRIBUTE_READONLY) > 0 then
  begin
    SetFileAttributes(PChar(FileName), Attrib - FILE_ATTRIBUTE_READONLY);
  end;
end;

{** **}
function TMultiForm.PackFile(FileName: string): boolean;
var
  Si:         Tstartupinfo;
  p:          Tprocessinformation;
  lpExitCode: cardinal;
begin
  FillChar(Si, SizeOf(Si), 0);
  with Si do
  begin
    cb          := SizeOf(Si);
    dwFlags     := startf_UseShowWindow;
    wShowWindow := 2;
    Si.lpTitle  := PChar('UPX Shell - MultiPack Engine');
  end;
  GlobFileName := FileName;
  FileName     := GetCompressParams;
  SetCurrentDir(WorkDir);
  UnSetReadOnly(FileName);
  ShowWindow(findwindow(nil, PChar('UPX Shell - MultiPack Engine')), 0);
  Createprocess(nil, PChar(FileName), nil, nil, True,
    Create_default_error_mode + GetPriority, nil, PChar(WorkDir), Si, p);
  GetProgress(p, not MainForm.chkDecomp.Checked);
  WaitForSingleObject(p.hProcess, infinite);
  GetExitCodeProcess(p.hProcess, lpExitCode);
  if lpExitCode = 0 then
  begin
    Result := True;
  end
  else
  begin
    Result := False;
  end;
end;

{** **}
procedure TMultiForm.PackFiles;

  procedure SetPackedItem(Index: integer; Success: boolean = True);
  var
    lItem: TListItem;
  begin
    if Success then
    begin
      FFiles[Index].CompressionResult := True;
      FFiles[Index].CompressedSize := GetFileSize(FFiles[Index].FullName);
      lItem := lvFiles.FindCaption(0, FFiles[Index].FileName,
        False, True, True);
      if lItem <> nil then
      begin
        lItem.SubItems[2] := ProcessSize(FFiles[Index].CompressedSize);
        lItem.SubItems[3] := TranslateMsg('OK');
      end;
    end
    else
    begin
      FFiles[Index].CompressionResult := False;
      lItem := lvFiles.FindCaption(0, FFiles[Index].FileName,
        False, True, True);
      if lItem <> nil then
      begin
        lItem.SubItems[3] := TranslateMsg('Failed');
      end;
    end;
  end;

  procedure CreateConsole;
  var
    CursorPos:    TCoord;
    ConsoleTitle: array[1..MAX_PATH] of char;
  begin
    AllocConsole;
    GetConsoleTitle(@ConsoleTitle, MAX_PATH);
    ShowWindow(FindWindow(nil, @ConsoleTitle), 0);
    Application.BringToFront;
    hStdOut     := GetStdHandle(STD_OUTPUT_HANDLE);
    CursorPos.X := 500;
    CursorPos.Y := 50;
    SetConsoleScreenBufferSize(hStdOut, CursorPos);
    CursorPos.X := 0;
    CursorPos.Y := 0;
    SetConsoleCursorPosition(hStdOut, CursorPos);
    MultiForm.pgbCurrent.Progress := 0;
    MultiForm.pgbOverall.Progress := 0;
  end;

var
  I:         integer;
  C:         cardinal;
  CursorPos: TCoord;
  StartTime: int64;
begin
  CursorPos.X := 0;
  CursorPos.Y := 0;
  C           := 0;
  CreateConsole;
  QueryTime(False, StartTime);
  ExtractUPX(edExtract);
  for I := low(FFiles) to high(FFiles) do
  begin
    if not FFiles[I].Skip then
    begin
      if PackFile(FFiles[I].FullName) then
      begin
        SetPackedItem(I);
      end
      else
      begin
        SetPackedItem(I, False);
      end;
      MultiForm.pgbOverall.Progress := round((I + 1) / length(FFiles) * 100);
      MultiForm.sttRatio.Width      := 0;
      SetConsoleCursorPosition(hStdOut, CursorPos);
      FillConsoleOutputCharacter(hStdOut, #0, 1500, CursorPos, C);
    end;
  end;
  MultiForm.pgbCurrent.Progress := 100;
  MultiForm.pgbOverall.Progress := 100;
  ExtractUPX(edDelete);
  MultiForm.lblTimeCap.Visible  := True;
  MultiForm.lblTime.Visible     := True;
  MultiForm.lblTime.Caption     := QueryTime(True, StartTime); //Not to forget to re-
  //enable this code
  FreeConsole;
end;

{** **}
procedure TMultiForm.btnPackClick(Sender: TObject);
begin
  if ((lblDir.Caption = TranslateMsg('N/A')) or (lblDir.Caption = '')) or
    (length(FFiles) < 1) then
  begin
    ShowMessage(TranslateMsg('No directory selected'));
    Exit;
  end;
  Active := True;
  EnableButtons(False);
  PackFiles;
  EnableButtons(True);
  Active := False;
end;

{** **}
procedure TMultiForm.FormActivate(Sender: TObject);
begin
  TranslateForm(MultiForm);
  if GlobFileName <> '' then
  begin
    lblDir.Caption := ExtractFileDir(GlobFileName);
  end;
  cmbType.ItemIndex          := 0;
  lvFiles.Columns[0].Caption := TranslateMsg('File Name');
  lvFiles.Columns[1].Caption := TranslateMsg('Folder');
  lvFiles.Columns[2].Caption := TranslateMsg('Size');
  lvFiles.Columns[3].Caption := TranslateMsg('Packed');
  lvFiles.Columns[4].Caption := TranslateMsg('Result');
end;

{** **}
procedure TMultiForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GlobFileName := FGlobFileName;
end;

{** **}
procedure TMultiForm.lvFilesKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (not Active) and (lvFiles.Selected <> nil) then
  begin
    if lvFiles.Selected.SubItems[3] = TranslateMsg('Skip') then
    begin
      lvFiles.Selected.SubItems[3]        := '---';
      FFiles[lvFiles.Selected.Index].Skip := False;
    end
    else
    begin
      lvFiles.Selected.SubItems[3]        := TranslateMsg('Skip');
      FFiles[lvFiles.Selected.Index].Skip := True;
    end;
  end;
end;

{** **}
procedure TMultiForm.lvFilesMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  if (Button = mbRight) and (not Active) and (lvFiles.Selected <> nil) then
  begin
    if lvFiles.Selected.SubItems[3] = TranslateMsg('Skip') then
    begin
      lvFiles.Selected.SubItems[3]        := '---';
      FFiles[lvFiles.Selected.Index].Skip := False;
    end
    else
    begin
      lvFiles.Selected.SubItems[3]        := TranslateMsg('Skip');
      FFiles[lvFiles.Selected.Index].Skip := True;
    end;
  end;
end;

end.
