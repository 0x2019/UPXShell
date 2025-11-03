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
 { Compression unit                              }
 { Note that major difference from previous      }
 { version is that this is no more a separate    }
 { thread!                                       }
 {***********************************************}
unit Compression;

interface

uses
  Forms, Windows, Globals;

procedure CompressFile(const Params: string; Compress: TCompDecomp);

implementation

uses
  Shared, Translator, SysUtils, Math, Dialogs, Classes,
  MainFrm, SetupFrm;

{** Allocates console window and sets the cursor position to (0,0) **}
procedure AllocateConsole;
var
  CursorPos:    TCoord;
  ConsoleTitle: array[1..MAX_PATH] of char;
begin
  AllocConsole;
  if not Globals.Config.DebugMode then
  begin
    GetConsoleTitle(@ConsoleTitle, MAX_PATH);
    ShowWindow(FindWindow(nil, @ConsoleTitle), 0);
    Application.BringToFront;
  end;
  hStdOut     := GetStdHandle(STD_OUTPUT_HANDLE);
  CursorPos.X := high(TLine);
  CursorPos.Y := 50;
  SetConsoleScreenBufferSize(hStdOut, CursorPos);
  CursorPos.X := 0;
  CursorPos.Y := 0;
  SetConsoleCursorPosition(hStdOut, CursorPos);
end;

{** This procedure is used to hide the upx.exe console window **}
procedure FindWin;
var
  ConsoleTitle: array[1..MAX_PATH] of char;
begin
  // only hide when we're not in debug mode
  if not Globals.Config.DebugMode then
  begin
    GetConsoleTitle(@ConsoleTitle, MAX_PATH);
    ShowWindow(FindWindow(nil, @ConsoleTitle), 0);
    Application.BringToFront;
  end;
end;

{** The main part - reads the data from upx console and
    updates the progress bars **}
procedure GetProgress(ProcInfo: TProcessInformation; const IsMultiProgress: boolean);
var
  EC:           cardinal;
  BracketOffsetStart: integer;
  BracketOffsetEnd: integer;
  upxProgressBarStart: integer;
  upxProgressBarSize: integer;
  upxProgressBar: string;
  upxCurProgressBarPos: integer; //This is filled by the LastPos function located in Globals.
  upxTotalProgress: integer; //This will hold the total amount of * to be counted when in MultiProgress.
  upxCurrentProgress: integer;
  OldAppTitle:  string;

  ProgressValue: integer;
  CompressSize: string;
  MultiRepeat:  TStringList;
  MultiCurrentIndex: integer;
  MultiTotalCount: integer;
  CursorPos:    TCoord;
  CharsRead:    DWord;
  Line:         TLine;
begin
  GetExitCodeProcess(ProcInfo.hProcess, EC);
  OldAppTitle         := Application.Title;
  CursorPos.x         := 0;
  CursorPos.y         := 0;
  upxTotalProgress    := 0;
  MultiRepeat         := TStringList.Create;

  while True do //Let's find where the progress starts
  begin
    ReadConsoleOutputCharacter(hStdOut, Line, 80, CursorPos, CharsRead);
    BracketOffsetStart := Pos('[', Line) - 1;

    if BracketOffsetStart > -1 then
    begin
      BracketOffsetEnd    := Pos(']', Line) - 1;
      upxProgressBarStart := BracketOffsetStart + 1;
      upxProgressBarSize  := BracketOffsetEnd - upxProgressBarStart;
      Break;
    end
    else
    begin
      Inc(CursorPos.Y);
    end;
    if CursorPos.Y > 20 then
    begin //If we get here - something's wrong
      CursorPos.Y := 0;
      GetExitCodeProcess(ProcInfo.hProcess, EC);
      if EC <= 2 then
      begin
        Exit;
      end;
    end;
  end;

  //Here we go and check the progress of the compression
  while EC > 2 do //ec >= STILL_ACTIVE
  begin
    ReadConsoleOutputCharacter(hStdOut, Line, 80, CursorPos, CharsRead);
    if Line[BracketOffsetStart] = '[' then
    begin
      CompressSize         := '';
      upxProgressBar       := Copy(Line, upxProgressBarStart + 1, upxProgressBarSize);
      upxCurProgressBarPos := LastPos('*', upxProgressBar);

      if IsMultiProgress then
      begin
        Split('/', Trim(Copy(Line, BracketOffsetStart - 7, 6)), MultiRepeat);
        if (MultiRepeat.Count >= 2) and
          TryStrToInt(MultiRepeat[0], MultiCurrentIndex) and
          TryStrToInt(MultiRepeat[1], MultiTotalCount) then
        begin
          if upxTotalProgress = 0 then
          begin
            upxTotalProgress := (MultiTotalCount * upxProgressBarSize);
          end;
          upxCurrentProgress := (((MultiCurrentIndex - 1) * upxProgressBarSize) + upxCurProgressBarPos);
        end
        else
        begin
          if upxTotalProgress = 0 then
          begin
            upxTotalProgress := upxProgressBarSize;
          end;
          upxCurrentProgress := upxCurProgressBarPos;
        end;
      end
      //ELSE NO MULTIPROGRESS
      else
      begin
        if upxTotalProgress = 0 then
        begin
          upxTotalProgress := upxProgressBarSize;
        end;
        upxCurrentProgress := upxCurProgressBarPos;
      end;

      //Calculate the current progress to show to the user.
      ProgressValue := floor((upxCurrentProgress / upxTotalProgress) * 100);

      //The percentage of the compression on the file.
      CompressSize := Line[69] + Line[70] + Line[71] + Line[72];

      Application.Title         := OldAppTitle + ' - ' + IntToStr(ProgressValue) + '%';
      MainForm.prbSize.Progress := Round(StrToFloat(CompressSize));
      MainForm.prbCompress.Progress := ProgressValue;

      //Here we do some sleeping so we won't hogg the system.
      sleep(50);
      Application.ProcessMessages;
      if ProgressValue >= 100 then
      begin
        Exit;
      end;
    end;
    GetExitCodeProcess(ProcInfo.hProcess, EC);
  end;
  Application.Title := OldAppTitle;
end;


{** Gets compression ratio **}
function GetRatio: integer;
var
  Finalsz: integer;
  Size:    integer;
begin
  MainForm.prbCompress.Progress := 100;
  Finalsz := GetFileSize(GlobFileName);
  Size    := round((Finalsz / GlobFileSize) * 100);
  with MainForm do
  begin
    lblCSizeCap.Visible := True;
    lblCSize.Visible    := True;
    lblCSize.Caption    := ProcessSize(Finalsz);
    prbSize.Progress    := Size;
    bvlRatio.Visible    := True;
    lblRatioCap.Visible := True;
    lblRatio.Visible    := True;
    lblRatio.Caption    := IntToStr(Size) + ' %';
    if lblFSize.Width > lblCSize.Width then
    begin
      bvlRatio.Width := lblFSize.Width + 10;
      bvlRatio.Left  := lblFSize.Left - 5;
    end
    else
    begin
      bvlRatio.Width := lblCSize.Width + 10;
      bvlRatio.Left  := lblCSize.Left - 5;
    end;
  end;
  Result := Size;
end;

{** **}
procedure ResetVisuals;
begin
  with MainForm do
  begin
    prbSize.Progress     := 0;
    prbCompress.Progress := 0;
    sttDecomp.Width      := 0;
  end;
end;

{** Sets statusbar text **}
function SetStatus(EC: cardinal; Compress: TCompDecomp): TCompResult;

  procedure SetSuccess(var CompResult: TCompResult);
  begin
    if Compress = cdCompress then
    begin
      MainForm.stbMain.Panels[1].Text :=
        TranslateMsg('File successfully compressed');
    end
    else
    begin
      MainForm.stbMain.Panels[1].Text :=
        TranslateMsg('File successfully decompressed');
    end;
    CompResult := crSuccess;
  end;

  procedure SetWarning(var CompResult: TCompResult);
  begin
    if Compress = cdCompress then
    begin
      MainForm.stbMain.Panels[1].Text :=
        TranslateMsg('File compressed with warnings');
    end
    else
    begin
      MainForm.stbMain.Panels[1].Text :=
        TranslateMsg('File decompressed with warnings');
    end;
    CompResult := crWarning;
  end;

  procedure SetError(var CompResult: TCompResult);
  begin
    if Compress = cdCompress then
    begin
      MainForm.stbMain.Panels[1].Text :=
        TranslateMsg('Errors occurred. File not compressed');
    end
    else
    begin
      MainForm.stbMain.Panels[1].Text :=
        TranslateMsg('Errors occurred. File not decompressed');
    end;
    CompResult := crError;
  end;

  //Start main function code
var
  CompResult: TCompResult;
begin
  case EC of
    0:
    begin
      SetSuccess(CompResult);
    end; //Successful compression
    1:
    begin
      SetError(CompResult);
    end; //Errors encountered - unsuccessful compression
    2:
    begin
      SetWarning(CompResult);
    end; //Warnings encountered while compressing
    else
    begin
      SetWarning(CompResult);
    end
  end;
  Result := CompResult;
end;


{** Does exactly the same as above, except for that it sets test results **}
procedure SetStatusTest(EC: cardinal);
begin
  case EC of
    0:
    begin
      MainForm.stbMain.Panels[1].Text := MainForm.stbMain.Panels[1].Text +
        TranslateMsg(' & tested');
    end; //Successfull testing
    1:
    begin
      MainForm.stbMain.Panels[1].Text := MainForm.stbMain.Panels[1].Text +
        TranslateMsg(' & tested w/warnings');
    end; //Warnings encountered while testing
    2:
    begin
      MainForm.stbMain.Panels[1].Text := MainForm.stbMain.Panels[1].Text +
        TranslateMsg(' & test failed');
    end; //Errors encountered - unsuccessfull test
    else
    begin
      MainForm.stbMain.Panels[1].Text := MainForm.stbMain.Panels[1].Text +
        TranslateMsg(' & tested w/warnings');
    end;
  end;
end;


{** Reads error line (6) from upx console and shows the error message **}
procedure GetErrorText;

  function ReadErrorLine(I: integer): string;
  var
    TextLen:   DWord;
    CursorPos: TCoord;
    CharsRead: DWord;
  begin
    TextLen     := high(TLine);
    SetLength(Result, high(TLine));
    CursorPos.x := 0;
    CursorPos.y := I;
    CharsRead   := 0;
    ReadConsoleOutputCharacter(hStdOut, @Result[1], TextLen,
      CursorPos, CharsRead);
  end;

var
  ErrorMsg: string;
begin
  ErrorMsg := PChar(Trim(ReadErrorLine(6)));
  if ErrorMsg <> '' then
  begin
    beep;
    ErrorMsg := TranslateMsg('UPX returned following error:\n') + ErrorMsg;
    Application.MessageBox(PChar(ErrorMsg), PChar(TranslateMsg('Error')),
      MB_OK + MB_ICONERROR);
  end;
end;


{** **}
function TestFile: cardinal;
var
  StartInfo:  Tstartupinfo;
  ProcInfo:   TProcessInformation;
  Params:     string;
  lpExitCode: cardinal;
begin
  FillChar(StartInfo, SizeOf(StartInfo), 0);
  with StartInfo do
  begin
    cb          := SizeOf(StartInfo);
    dwFlags     := startf_UseShowWindow;
    wShowWindow := 2;
    StartInfo.lpTitle := PChar('UPX Shell 3.x - ' + GlobFileName);
  end;
  Params := WorkDir + 'upx.exe -t ' + GlobFileName;
  Createprocess(nil, PChar(Params), nil, nil, True, Create_default_error_mode,
    nil, PChar(WorkDir), StartInfo, ProcInfo);
  Waitforsingleobject(ProcInfo.hProcess, infinite);
  GetExitCodeProcess(ProcInfo.hProcess, lpExitCode);
  Result := lpExitCode;
end;


{** **}
procedure CompressFile(const Params: string; Compress: TCompDecomp);
var
  StartInfo:       Tstartupinfo;
  ProcInfo:        TProcessInformation;
  lpExitCode:      cardinal;
  CompResult:      TCompResult;
  IsMultiProgress: boolean;
begin
  ResetVisuals;
  CalcFileSize;
  AllocateConsole;
  FillChar(StartInfo, SizeOf(StartInfo), 0);
  with StartInfo do
  begin
    cb          := SizeOf(StartInfo);
    dwFlags     := STARTF_USESHOWWINDOW;
    wShowWindow := 2;
    lpTitle     := PChar('UPX Shell 3.x - ' + GlobFileName);
  end;
  ExtractUPX(edExtract);
  SetCurrentDir(WorkDir);

  //Check if UPX will do more then only 1 compression cycle.
  IsMultiProgress := False;
  if ((curUPXVersion = UPX2) or (curUPXVersion = UPX3)) and
    (SetupForm.chkBrute.Checked or SetupForm.chkFilters.Checked or SetupForm.chkMethods.Checked) then
  begin
    IsMultiProgress := True;
  end;

  //Now start upx.exe with specified parameters
  CreateProcess(nil, PChar(Params), nil, nil, True, Create_default_error_mode +
    GetPriority, nil, PChar(WorkDir), StartInfo, ProcInfo);
  FindWin; //Hide console window if it still shows
  if Compress = cdCompress then
  begin
    GetProgress(ProcInfo, IsMultiProgress);
  end;
  WaitForSingleObject(ProcInfo.hProcess, infinite);
  GetExitCodeProcess(ProcInfo.hProcess, lpExitCode);
  CompResult := SetStatus(lpExitCode, Compress);
  case CompResult of
    crSuccess:
    begin
      CompressionResult := True;
      if Compress = cdCompress then
      begin
        GetRatio;
      end
      else
      begin
        MainForm.sttDecomp.Width := round((MainForm.prbSize.Width / GetRatio) * 100) - 3;
			end;
    end;
    crWarning, crError:
    begin
      CompressionResult := False;
      GetErrorText; //Shows error message
    end;
  end;
  //Check whether to test the compressed file
  if (MainForm.chkTest.Checked) and (Compress = cdCompress) and
    (CompResult = crSuccess) then
  begin
    lpExitCode := TestFile;
    SetStatusTest(lpExitCode);
  end;
  ExtractUPX(edDelete);
  if AlreadyPacked then
    //This one checks if the file is compressed and sets checkbox
  begin
    MainForm.chkDecomp.Checked := True;
    sUPXVersion := GetUPXBuild(GlobFileName);
  end
  else
  begin
    sUPXVersion := '';
    MainForm.chkDecomp.Checked := False;
    MainForm.cmbUPX.ItemIndex := bStdUPXVersion;
  end;
end;

end.
