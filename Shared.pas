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
 { Shared procedures unit                        }
 {***********************************************}
unit Shared;

interface

uses
  Windows, Forms, Classes, Graphics, Dialogs, Globals;

procedure Split(const Delimiter: char; const Input: string; const Strings: TStrings);
function GetPriority: cardinal; //Gets priority selected on the SetupForm
function AlreadyPacked: boolean;
function GetCompressParams: string;
procedure ExtractUPX(const Action: TExtractDelete);
procedure ScrambleUPX;
procedure DrawGradient(const DrawCanvas: TCanvas; const ColorCycles, Height, Width: integer; const StartColor, EndColor: TColor);
function ProcessSize(const Size: integer): string;
function GetFileSize(const FileName: string): integer;
procedure SetStringProperty(AComp: TComponent; const APropName: string; const AValue: string);
procedure CalcFileSize;

(*
//These functions/procedures arn't used (anymore), but kept here just in case

Function StrDiv(Const InStr: String): String;
Procedure DrawGradientVertical(Const DrawCanvas: TCanvas;
                               Const ColorCycles, Height, Width: Integer;
                               Const StartColor, EndColor: TColor);
function AnalyzeFileSize(Const FileName: String): String;
function TokenizeStr(Const InStr: String): TTokenStr;
*)
procedure WriteLog(Const InStr: String);
function GetComponentTree(Component: TComponent): string;
function GetStringProperty(Component: TComponent; const PropName: string): string;
function IsNumeric(const InStr: string): boolean;
function PropertyExists(Component: TComponent; const PropName: string): boolean;
function StringEncode(const InStr: string): string;
function StringDecode(const InStr: string): string;


implementation

uses
  SysUtils, TypInfo,
  UPXScrambler, Translator,
  MainFrm, SetupFrm;

procedure Split(const Delimiter: char; const Input: string; const Strings: TStrings);
begin
  Assert(Assigned(Strings));
  Strings.Clear;
  Strings.Delimiter     := Delimiter;
  Strings.DelimitedText := Input;
end;

//Extract resources from the upxmiracle.exe (upx.exe)
procedure ExtractRes(const ResType, ResName, ResNewName: string);
var
  Res: TResourceStream;
begin
  try
    Res := TResourceStream.Create(Hinstance, ResName, PChar(ResType));
    Res.SavetoFile(ResNewName);
  finally
    FreeAndNil(Res);
  end;
end;

//This one is used for getting the priority of the compression thread
{**
 * There are more Priorities when os is equal or higher then Windows 2000.
 * Idle						=		$00000040		=		IDLE_PRIORITY_CLASS
 * (Below Normal	=		$00004000		=		BELOW_NORMAL_PRIORITY_CLASS) 2k/xp/vista only
 * Normal					=		$00000020		=		NORMAL_PRIORITY_CLASS
 * (Above Normal	=		$00008000		=		ABOVE_NORMAL_PRIORITY_CLASS) 2k/xp/vista only
 * High						=		$00000080		=		HOGH_PRIORITY_CLASS
 * Realtime				=		$00000100		=		REALTIME_PRIORITY_CLASS
**}
function GetPriority: cardinal;
var
  Priority: integer;
begin
  Result   := NORMAL_PRIORITY_CLASS;
  Priority := SetupForm.cmbPriority.ItemIndex;
  case Priority of
    0:
    begin
			Result := IDLE_PRIORITY_CLASS;
    end;
    1:
    begin
      Result := NORMAL_PRIORITY_CLASS;
    end;
    2:
    begin
      Result := HIGH_PRIORITY_CLASS;
    end;
    3:
    begin
      Result := REALTIME_PRIORITY_CLASS;
    end;
  end;
end;

//Analyzes the file to check if it's already compressed
function AlreadyPacked: boolean;
var
  f:           TFileStream;
  GlobalChain: array[1..$3F0] of AnsiChar;
  BytesRead:   integer;
  Buffer:      AnsiString;
begin
  Result := False;
  BytesRead := 0;
  FillChar(GlobalChain, SizeOf(GlobalChain), 0);
  f := nil;
  try
    f          := TFileStream.Create(GlobFileName, fmOpenRead);
    f.Position := 0;
    try
      BytesRead := f.Read(GlobalChain, SizeOf(GlobalChain));
    except
      on E: Exception do
      begin
        Application.MessageBox(PChar(TranslateMsg(
          'Could not access file. It may be allready open!')),
          PChar(TranslateMsg('Error')), MB_ICONERROR or MB_OK);
      end;
    end;

    if BytesRead > 0 then
    begin
      SetString(Buffer, PAnsiChar(@GlobalChain[1]), BytesRead);
      Result := Pos('UPX', string(Buffer)) <> 0;
    end;
    // offset $34b... test the typical string in .EXE & .DLL 'This file is packed with the UPX'
    // offset $1F9... test string in .SCR 'This file is packed with the UPX'
    // offset $55... string 'UPX' in .COM
    // new offset in .EXE in UPX 1.08
    // another offset in .EXE in UPX 1.20
  finally
    FreeAndNil(f);
  end;
end;

//Gets compression parameters to be passed to upx
function GetCompressParams: string;
var
	upxExeFile: string;
begin
	with MainForm do
	begin
		if (curUPXVersion = UPXC) then
		begin
			upxExeFile := 'UPX.EXE';
		end
		else
		begin
			upxExeFile := 'UPXE.EXE';
		end;

		Result := WorkDir + upxExeFile +' "' + GlobFileName + '"';
    if not chkDecomp.Checked then
    begin
      if trbCompressLvl.Position < 10 then
      begin
        Result := Result + ' -' + IntToStr(trbCompressLvl.Position);
      end
      else
      begin
        Result := Result + ' --best';
      end;
      if SetupForm.chkCompression.Checked then
      begin
        Result := Result + ' --crp-ms=' +
          IntToStr(SetupForm.trbCompression.Position);
      end;
      if SetupForm.chkForce.Checked then
      begin
        Result := Result + ' --force';
      end;
      if SetupForm.chkResources.Checked then
      begin
        Result := Result + ' --compress-resources=1';
      end
      else
      begin
        Result := Result + ' --compress-resources=0';
      end;
      if SetupForm.chkRelocs.Checked then
      begin
        Result := Result + ' --strip-relocs=1';
      end
      else
      begin
        Result := Result + ' --strip-relocs=0';
      end;
      if chkBackup.Checked then
      begin
        Result := Result + ' -k';
      end;
      case SetupForm.cmbIcons.ItemIndex of
        0:
        begin
          Result := Result + ' --compress-icons=2';
        end;
        1:
        begin
          Result := Result + ' --compress-icons=1';
        end;
        2:
        begin
          Result := Result + ' --compress-icons=0';
        end;
      end;
      if SetupForm.chkExports.Checked then
      begin
        Result := Result + ' --compress-exports=1';
      end
      else
      begin
        Result := Result + ' --compress-exports=0';
      end;
      //UPX v1.9x till v2.0x (UPX2) OR UPX v2.9x till v3.x (UPX3)
			if (curUPXVersion = UPX2) or (curUPXVersion = UPX3) then
			begin
				//Check for the UPX2 and higher Brute, and -all-* checks
				if SetupForm.chkBrute.Checked then
				begin
					Result := Result + ' --brute';
				end
				else
				begin
					if SetupForm.chkMethods.Checked then
					begin
						Result := Result + ' --all-methods';
					end;
					if SetupForm.chkFilters.Checked then
					begin
						Result := Result + ' --all-filters';
					end;
				end;

				//Check for the new UPX3 LZMA compression check
				if (curUPXVersion = UPX3) then
				begin
					if SetupForm.chkLZMA.Checked then
					begin
						Result := Result + ' --lzma';
					end;
				end;
      end;
      Result := Result + ' ' + SetupForm.txtCommands.Text;
    end
    else
    begin
			Result := Result + ' -d';
		end;
		//MessageDlg('End Result: '+ Result, mtWarning, [mbOK], 0);
  end;
end;

procedure ExtractUPX(const Action: TExtractDelete);
begin
  SetCurrentDir(WorkDir);
  if not (curUPXVersion = UPXC) then
  begin
    if Action = edExtract then
    begin
      ExtractRes('EXEFILE', resUPXVersions[curUPXVersion], WorkDir + 'UPXE.EXE');
    end
    else
    begin
      DeleteFile(WorkDir + 'UPXE.EXE');
    end;
  end;
end;

{*****************************************
* This Function Scrambles the UPXed file *
*****************************************}
procedure ScrambleUPX;
var
  Scrambled: boolean;
begin
  if GlobFileName <> '' then
  begin
    if AlreadyPacked then
    begin
      Scrambled := fScrambleUPX(GlobFileName);
      if Scrambled then
      begin
        MainForm.chkDecomp.Checked      := False;
        MainForm.stbMain.Panels[1].Text :=
          MainForm.stbMain.Panels[1].Text + TranslateMsg(' & scrambled');
      end
      else
      begin
        MainForm.stbMain.Panels[1].Text :=
          MainForm.stbMain.Panels[1].Text + TranslateMsg(' & scrambled') +
          ' ' + TranslateMsg('Failed');
      end;
    end
    else
    begin
      if Application.MessageBox(PChar(TranslateMsg(
        'This file doesn''t seem to be packed. Run the Scrambler?')),
        PChar(TranslateMsg('Confirmation')), MB_YESNO + MB_ICONEXCLAMATION) =
        idYes then
      begin
        Scrambled := fScrambleUPX(GlobFileName);
        if Scrambled then
        begin
          MainForm.chkDecomp.Checked      := False;
          MainForm.stbMain.Panels[1].Text :=
            MainForm.stbMain.Panels[1].Text + TranslateMsg(' & scrambled');
        end
        else
        begin
          MainForm.stbMain.Panels[1].Text :=
            MainForm.stbMain.Panels[1].Text + TranslateMsg(' & scrambled') +
            ' ' + TranslateMsg('Failed');
        end;
      end;
    end;
  end;
end;

//These are the proceudres to draw that gradient near UPX logo
type
  TCustomColorArray = array[0..255] of TColor;

function CalculateColorTable(StartColor, EndColor: TColor; ColorCycles: integer): TCustomColorArray;
var
  BeginRGB:   array[0..2] of byte;
  DiffRGB:    array[0..2] of integer;
  R, G, B, I: byte;
begin
  BeginRGB[0] := GetRValue(ColorToRGB(StartColor));
  BeginRGB[1] := GetGValue(ColorToRGB(StartColor));
  BeginRGB[2] := GetBValue(ColorToRGB(StartColor));
  DiffRGB[0]  := GetRValue(ColorToRGB(EndColor)) - BeginRGB[0];
  DiffRGB[1]  := GetGValue(ColorToRGB(EndColor)) - BeginRGB[1];
  DiffRGB[2]  := GetBValue(ColorToRGB(EndColor)) - BeginRGB[2];
  for I := 0 to 255 do
  begin
    R         := BeginRGB[0] + MulDiv(I, DiffRGB[0], ColorCycles - 1);
    G         := BeginRGB[1] + MulDiv(I, DiffRGB[1], ColorCycles - 1);
    B         := BeginRGB[2] + MulDiv(I, DiffRGB[2], ColorCycles - 1);
    Result[I] := RGB(R, G, B);
  end;
end;

{** **}
procedure DrawGradient(const DrawCanvas: TCanvas; const ColorCycles, Height, Width: integer; const StartColor, EndColor: TColor);
var
  Rec:      TRect;
  I:        integer;
  Temp:     TBitmap;
  ColorArr: TCustomColorArray;
begin
  try
    ColorArr    := CalculateColorTable(StartColor, EndColor, ColorCycles);
    Temp        := TBitmap.Create;
    Temp.Width  := Width;
    Temp.Height := Height;
    Rec.Top     := 0;
    Rec.Bottom  := Height;
    with Temp do
    begin
      for I := 0 to ColorCycles do
      begin
        Rec.Left           := MulDiv(I, Width, ColorCycles);
        Rec.Right          := MulDiv(I + 1, Width, ColorCycles);
        Canvas.Brush.Color := ColorArr[I];
        Canvas.FillRect(Rec);
      end;
    end;
    DrawCanvas.Draw(0, 0, Temp);
  finally
    FreeAndNil(Temp);
  end;
end;

{** **}
function ProcessSize(const Size: integer): string;
begin
  Result := IntToStr(Size);
  case length(Result) of
    1..3:
    begin
      Result := IntToStr(Size) + ' B';
    end;
    4..6:
    begin
      Result := IntToStr(Size shr 10) + ' KB';
    end;
    7..9:
    begin
      Result := IntToStr(Size shr 20) + ' MB';
    end;
    10..12:
    begin
      Result := IntToStr(Size shr 30) + ' GB';
    end;
  end;
end;

{** **}
function GetFileSize(const FileName: string): integer;
var
  sr: TSearchRec;
begin
  if FindFirst(FileName, faAnyFile, sr) = 0 then
  begin
    Result := sr.Size;
  end
  else
  begin
    Result := -1;
  end;
  FindClose(sr);
end;

{** **}
procedure SetStringProperty(AComp: TComponent; const APropName: string; const AValue: string);
var
  PropInfo: PPropInfo;
  TK:       TTypeKind;
begin
  if AComp <> nil then
  begin
    PropInfo := GetPropInfo(AComp.ClassInfo, APropName);
    if PropInfo <> nil then
    begin
      TK := PropInfo^.PropType^.Kind;
      if (TK = tkString) or (TK = tkLString) or (TK = tkWString) then
      begin
        SetStrProp(AComp, PropInfo, AValue);
      end;
    end;
  end;
end;

{** Calculates file size **}
procedure CalcFileSize;
begin
  GlobFileSize := GetFileSize(GlobFileName);
  MainForm.lblFSize.Caption := ProcessSize(GlobFileSize);
end;

{***********************************************************
 These Procedures/Functions arn't used or replaced (anymore)
************************************************************}

{ Returns verson info from FileName in dotted decimal string format:
  Release.Major.Minor.Build (biFull)
  or Release.Major.Minor (biNoBuild)
  or Release.MajorMinor (biCute)
  or each one separately (biMajor, biMinor, biRelease, biBuild) }
(*
function GetBuild(const BuildInfo: TBuildInfo): string;
var
  dwI, dwJ: dword;
  VerInfo:  Pointer;
  VerValue: PVSFixedFileInfo;
begin
  Result := '';
  dwI    := GetFileVersionInfoSize(PChar(Application.ExeName), dwJ);
  if dwI > 0 then
  begin
    VerInfo := nil;
    try
      GetMem(VerInfo, dwI);
      GetFileVersionInfo(PChar(Application.ExeName), 0, dwI, VerInfo);
      VerQueryValue(VerInfo, '\', Pointer(VerValue), dwJ);
      case BuildInfo of
        biFull:
        begin
          with VerValue^ do
          begin
            Result := IntToStr(dwFileVersionMS shr 16) + '.';
            Result := Result + IntToStr(dwFileVersionMS and $FFFF) + '.';
            Result := Result + IntToStr(dwFileVersionLS shr 16) + '.';
            Result := Result + IntToStr(dwFileVersionLS and $FFFF);
          end;
        end;
        biNoBuild:
        begin
          with VerValue^ do
          begin
            Result := IntToStr(dwFileVersionMS shr 16) + '.';
            Result := Result + IntToStr(dwFileVersionMS and $FFFF) + '.';
            Result := Result + IntToStr(dwFileVersionLS shr 16);
          end;
        end;
        biCute:
        begin
          with VerValue^ do
          begin
            Result := IntToStr(dwFileVersionMS shr 16) + '.';
            Result := Result + IntToStr(dwFileVersionMS and $FFFF);
            Result := Result + IntToStr(dwFileVersionLS shr 16);
          end;
        end;
        biRelease:
        begin
          Result := IntToStr(VerValue^.dwFileVersionMS shr 16);
        end;
        biMajor:
        begin
          Result := IntToStr(VerValue^.dwFileVersionMS and $FFFF);
        end;
        biMinor:
        begin
          Result := IntToStr(VerValue^.dwFileVersionLS shr 16);
        end;
        biBuild:
        begin
          Result := IntToStr(VerValue^.dwFileVersionLS and $FFFF);
        end;
      end;
    finally
      FreeMem(VerInfo, dwI);
    end;
  end;
end;
*)


(*
//Puts a a space after every third character
Function StrDiv(Const InStr: String): String;
Var
  outstr: Array[1..255] Of Char;
  i, c, m, l: Integer;
Begin
  i := 0;
  c := 0;
  m := length(instr);
  l := m Div 3;
  fillchar(outstr, 255, #0);
  While i <= length(instr) + c Do
  Begin
    inc(i);
    If (i Mod 4 <> 0) Then
      outstr[m + l] := instr[m + c]
    Else
    Begin
      outstr[m + l] := ' ';
      inc(c);
    End;
    dec(m);
  End;
  Result := Trim(outstr);
End;
*)

(*
Procedure DrawGradientVertical(Const DrawCanvas: TCanvas;
  Const ColorCycles, Height, Width: Integer;
  Const StartColor, EndColor: TColor);
Var
  Rec: TRect;
  i: Integer;
  Temp: TBitmap;
  ColorArr: TCustomColorArray;
Begin
  ColorArr := CalculateColorTable(StartColor, EndColor, ColorCycles);
  Temp := TBitmap.Create;
  Try
    Temp.Width := Width;
    Temp.Height := Height;
    Rec.Left := 0;
    Rec.Right := Width;
    With Temp Do
      For I := 0 To ColorCycles Do
      Begin
        Rec.Top := MulDiv(I, Height, ColorCycles);
        Rec.Bottom := MulDiv(I + 1, Height, ColorCycles);
        Canvas.Brush.Color := ColorArr[i];
        Canvas.FillRect(Rec);
      End;
    DrawCanvas.Draw(0, 0, Temp);
  Finally
    FreeAndNil(Temp);
  End;
End;
*)

(*
Procedure DrawGradientPartial(DrawCanvas: TCanvas; ColorCycles, Height, Width: Integer;
  StartPos: Integer; StartColor, EndColor: TColor);
Var
  Rec: TRect;
  i: Integer;
  Temp: TBitmap;
  ColorArr: TCustomColorArray;
Begin
  Try
    ColorArr := CalculateColorTable(StartColor, EndColor, ColorCycles);
    Temp := TBitmap.Create;
    Temp.Width := Width;
    Temp.Height := Height;
    Rec.Top := 0;
    Rec.Bottom := Height;
    With Temp Do
      For I := 0 To ColorCycles Do
      Begin
        Rec.Left := MulDiv(I, Width, ColorCycles);
        Rec.Right := MulDiv(I + 1, Width, ColorCycles);
        Canvas.Brush.Color := ColorArr[i];
        Canvas.FillRect(Rec);
      End;
    DrawCanvas.Draw(StartPos, 0, Temp);
  Finally
    FreeAndNil(Temp);
  End;
End;
*)

(*
Function AnalyzeFileSize(Const FileName: String): String;
Var
  Size: Integer;
Begin
  If GetFileSize(FileName) <> 0 Then
  Begin
    Size := GetFileSize(FileName);
    Result := ProcessSize(Size);
  End
  Else
  Begin
    Result := 'I/O Error';
  End;
End;
*)

(*
Function TokenizeStr(Const InStr: String): TTokenStr;
Var
  i: Integer;
  GetVal: Boolean;
Begin
  If trim(InStr) <> '' Then
  Begin
    GetVal := False;
    SetLength(Result, length(Result) + 1);
    For i := 1 To Length(InStr) Do
    Begin
      If InStr[i] = ' ' Then
      Begin
        GetVal := False;
        SetLength(Result, length(Result) + 1);
      End
      Else
      Begin
        If GetVal Then
          Result[high(Result)].Value := Result[high(Result)].Value + InStr[i]
        Else
          If InStr[i] = '=' Then
            GetVal := True
          Else
            Result[high(Result)].Token := Result[high(Result)].Token + InStr[i];
      End;
    End;
  End;
End;
*)

procedure WriteLog(const InStr: string);
const
  CRLF       = #13#10;
  TimeFormat = 'dd/mm/yy||hh:nn:ss' + #09;
var
  fs:       TFileStream;
  filemode: word;
  date:     string;
begin
  if Globals.Config.DebugMode then
  begin
    if FileExists('log.txt') then
    begin
      filemode := fmOpenReadWrite;
    end
    else
    begin
      filemode := fmCreate;
    end;
    fs := TFileStream.Create('log.txt', filemode);
    try
      fs.Seek(0, soFromEnd);
      date := FormatDateTime(TimeFormat, now);
      fs.Write((@date[1])^, length(date));
      fs.Write((@InStr[1])^, length(InStr));
      fs.Write(CRLF, length(CRLF));
    finally
      FreeAndNil(fs);
    end;
  end;
end;

function GetStringProperty(Component: TComponent; const PropName: string): string;
var
  PropInfo: PPropInfo;
  TK:       TTypeKind;
begin
  Result   := '';
  PropInfo := GetPropInfo(Component.ClassInfo, PropName);
  if PropInfo <> nil then
  begin
    TK := PropInfo^.PropType^.Kind;
    if (TK = tkString) or (TK = tkLString) or (TK = tkWString) then
    begin
      Result := GetStrProp(Component, PropInfo);
    end;
  end;
end;

function GetComponentTree(Component: TComponent): string;
var
  Owner: TComponent;
begin
  Result := Component.Name;
  Owner  := Component.Owner;
  while Owner <> Application do
  begin
    Result := Owner.Name + '.' + Result;
    Owner  := Owner.Owner;
  end;
end;

function IsNumeric(const InStr: string): boolean;
var
  I: integer;
begin
  Result := True;
  for I := 1 to length(InStr) do
  begin
    if not CharInSet(InStr[I], ['0'..'9']) then
    begin
      Result := False;
      break;
    end;
  end;
end;

function PropertyExists(Component: TComponent; const PropName: string): boolean;
var
  PropInfo: PPropInfo;
  TK:       TTypeKind;
begin
  Result   := False;
  PropInfo := GetPropInfo(Component.ClassInfo, PropName);
  if PropInfo <> nil then
  begin
    TK := PropInfo^.PropType^.Kind;
    if (TK = tkString) or (TK = tkLString) or (TK = tkWString) then
    begin
      Result := True;
    end;
  end;
end;

 // converts a string, potentially containing newline
 // characters into a flatened string
function StringEncode(const InStr: string): string;
var
  I: integer;
begin
  Result := InStr;
  for I := 1 to length(Result) do
  begin
    if (Result[I] = #13) and (Result[I + 1] = #10) then
    begin
      Result[I]     := '\';
      Result[I + 1] := 'n';
    end;
  end;
end;

// converts a flat string into its original form
function StringDecode(const InStr: string): string;
var
  I: integer;
begin
  Result := InStr;
  for I := 1 to length(Result) do
  begin
    if (Result[I] = '\') and (Result[I + 1] = 'n') then
    begin
      Result[I]     := #13;
      Result[I + 1] := #10;
    end;
  end;
end;

end.
