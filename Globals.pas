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
 { Global constants, variables and types unit    }
 {***********************************************}
unit Globals;

interface

const
  MsgCount = 44; //Contains original english messages
  EngMsgs: array[1..MsgCount] of string = (
    'Could not access file. It may be allready open',
    'The file attribute is set to ReadOnly. To proceed it must be unset. Continue?',
    'Best',
    'This file doesn''t seem to be packed. Run the Scrambler?',
    ' (in ',
    ' seconds)',
    'decompress',
    'compress',
    'There is nothing to ',
    'N/A',
    'No directory selected',
    '...update failed :-(',
    'Could not connect to update server!',
    'Updated version of product found!',
    'Parsing update file...',
    'Retrieving update information...',
    'File successfully compressed',
    'File successfully decompressed',
    'File compressed with warnings',
    'File decompressed with warnings',
    'Errors occured. File not compressed',
    'Errors occured. File not decompressed',
    ' & tested',
    ' & tested w/warnings',
    ' & test failed',
    'UPX returned following error:\n',
    ' & scrambled',
    '...update found',
    '...no updates found',
    'OK',
    'Failed',
    'Skip',
    'File Name',
    'Folder',
    'Size',
    'Packed',
    'Result',
    'Error',
    'Confirmation',
    'Select directory to compress:',
    'This file is now Scrambled!',
    'This file has NOT been scrambled!',
    'Compress with UPX',
    'Custom upx.exe');

type
  // The global configuration type
  TConfig = record
    DebugMode:     boolean;     // Are we in debug mode?
    LocalizerMode: boolean;     // Translation editor's mode
  end;

  //UPX Versions for the combobox etc..
type
  //UPXC means Custom.
  TUPXVersions = (UPX1, UPX2, UPX3, UPXC);

const
  resUPXVersions: array[TUPXVersions] of string = ('UPX1', 'UPX2', 'UPX3', 'UPXC');
  aUPXVersions: array[TUPXVersions] of string = ('UPX 1.25', 'UPX 2.03', 'UPX 2.92b', 'Custom');


type
  TKeyType = (ktString, ktInteger, ktBoolean); //Passed to ReadKey and StoreKey

  TRegValue = record //This one is returned by ReadKey and passed to StoreKey
    Str:  string;
    Int:  integer;
    Bool: boolean;
  end;

type
  TToken = record
    Token: ShortString;
    Value: ShortString;
  end;
  TTokenStr = array of TToken;

//The following is used to get UPX Shell build info
//OLD VERSION: TBuildInfo     = (biFull, biNoBuild, biMajor, biMinor, biRelease, biBuild, biCute);
type
  TBuildInfo = record
    biFull:    string;
    biNoBuild: string;
    biMajor:   integer;
    biMinor:   integer;
    biRelease: integer;
    biBuild:   integer;
    biCute:    string;
  end;

var
  BuildInfo: TBuildInfo;

type
  TLine          = array[0..500] of char;                   //Used in getting the DOS line
  TExtractDelete = (edExtract, edDelete); //Used for ExtractUPX()
  TCompDecomp    = (cdCompress, cdDecompress{, cdEmpty});
  //Passed to CompressFile() and holds
  // whether to compress or decompress the file
  TCompResult    = (crSuccess, crWarning, crError); //Passed to SetStatus()

  //Used for the IntergrateContext procedure to check what to do.
	TIntContext        = (doSetup, extRegister, extUnRegister);
  TIntContextOptions = set of TIntContext;

// This is all used when passing data for localization purposes
type
  TComponentProperty = record
    Name:  string;
    Value: string;
  end;

type
  TComponentProperties = record
	  Name:       string;
    Properties: array of TComponentProperty;
  end;

type
  TFormProperties = record
    Name:       string;
    Properties: array of TComponentProperties;
  end;

type
  TFormLocalizations = array of TFormProperties;
  TLocalizerFormMode = (lfmProperties, lfmMessages);

var
	Config:         TConfig;						// Holds the global application configuration
	GlobFileName:   string;							//Holds the opened file name
	WorkDir:        string;							//Holds the working directory of UPX Shell
	LanguageSubdir: string = 'Language';
	LangFile:       string;							//Holds the current language file name
	Extension:      integer = 1;				//Contains OpenDialog last selected extension
	GlobFileSize:   integer;						//Contains file size for ratio calculation
	Busy:           boolean = False;		//Set when compressing or scrambling files
	hStdOut:        THandle;						//Contains handle to standard console output
	CompressionResult: boolean = False;	// Result of the compress operation
	Messages:       array[1..MsgCount] of string; //Contains the translated messages
	sUPXVersion:    string;							//Contains the UPXVersion the file is compressed with
  bStdUPXVersion: byte;								//Contains the default UPXVersion selected, see TUPXVersions.
  curUPXVersion:  TUPXVersions;

{** Global Procedures **}
procedure IntergrateContext(const Options: TIntContextOptions);
function QueryTime(const GetTime: boolean; var StartTime: int64): string;
function ReadKey(const Name: string; KeyType: TKeyType): TRegValue;
procedure StoreKey(const Name: string; const Value: TRegValue; KeyType: TKeyType);
procedure GetBuild;
function GetUPXBuild(const FilePath: string): string;
function LastPos(const Substr: char; const S: string): integer;

implementation

uses
  Windows, SysUtils, Registry, Dialogs, Classes, Math,
  Translator,
  MainFrm;

const
  //** Array for filetypes
  RegExtensions: array[1..10] of string =
    ('.bpl', '.com', '.dll', '.dpl', '.exe', '.ocx', '.scr',
    '.sys', '.acm', '.ax');

{** **}
procedure RegisterExtensions(const Extensions: array of string; const OpenCommand: string; const ActionValue: string);
var
  Reg: TRegistry;
  I:   integer;
  Def: string;
begin
  Reg := TRegistry.Create();
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    for I := 0 to High(Extensions) do
    begin
      if Reg.OpenKey('\' + Extensions[I], True) then
      begin
        Def := Reg.ReadString('');
        if Def = '' then
        begin
          Def := copy(Extensions[I], 2, 3) + 'file';
          Reg.WriteString('', Def);
        end;
      end;
      Reg.CloseKey;

			if (Def <> '') then
			begin
				if Reg.CreateKey('\' + Def + '\shell\UPXMIRACLE\command') then
				begin
					if Reg.OpenKey('\' + Def + '\shell\UPXMIRACLE', True) then
					begin
						Reg.WriteString('', ActionValue);
					end;
					Reg.CloseKey;

					if Reg.OpenKey('\' + Def + '\shell\UPXMIRACLE\command', True) then
					begin
						Reg.WriteString('', OpenCommand);
					end;
					Reg.CloseKey;
				end;
				Reg.CloseKey;
			end;
    end;
  finally
    FreeAndNil(Reg);
  end;
end;

{** **}
procedure UnRegisterExtensions(const Extensions: array of string);
var
  Reg: TRegistry;
	I:   integer;
	Def: string;
begin
	Reg := TRegistry.Create;
	try
		Reg.RootKey := HKEY_CLASSES_ROOT;
		for I := Low(Extensions) to High(Extensions) do
		begin
			if Reg.OpenKey('\' + Extensions[I], False) then
			begin
				Def := Reg.ReadString('');
			end;
			Reg.CloseKey;

			if Def <> '' then
			begin
				Reg.DeleteKey('\' + Def + '\shell\UPXMIRACLE');
				Reg.CloseKey;
			end;
		end;
	finally
		FreeAndNil(Reg);
	end;
end;

 {** **}
procedure IntergrateContext(const Options: TIntContextOptions);
 {** (doSetup, extRegister, extUnRegister) **}
var
  Path:         string;
	ActionValue:  string;
  RegValue:     TRegValue;
begin
	Path				:= WorkDir + 'UPXMIRACLE.exe "%1" %*';
	ActionValue	:= Trim(TranslateMsg('Compress with Michael Hardy''s UPX-Miracle!'));

	if extRegister in Options then
	begin
		RegisterExtensions(RegExtensions, Path, ActionValue);
		// update the registry with new settings
		RegValue.Bool := True;
		StoreKey('ShellIntegrate', RegValue, ktBoolean);
	end
	else
	if extUnRegister in Options then
	begin
		UnRegisterExtensions(RegExtensions);
		RegValue.Bool := False;
		StoreKey('ShellIntegrate', RegValue, ktBoolean);
	end;

	//If this is called from the Setup then we need to close after finishing Integration.
	if doSetup in Options then
	begin
		exit;
	end;
end;

{** **}
function QueryTime(const GetTime: boolean; var StartTime: int64): string;
var
  Frequency, EndTime: int64;
  Time: string;
begin
  if GetTime then
  begin
    QueryPerformanceFrequency(Frequency);
    QueryPerformanceCounter(EndTime);
    Time   := FloatToStr((EndTime - StartTime) / Frequency, FormatSettings);
    Result := Time;
  end
  else
  begin
    QueryPerformanceCounter(StartTime);
    Result := '';
  end;
end;

{** Reads registry value from default UPX Shell folder and returns TRegResult **}
function ReadKey(const Name: string; KeyType: TKeyType): TRegValue;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Michael Hardy\UPX Shell\3.x', True) then
    begin
      if Reg.ValueExists(Name) then
      begin
        case KeyType of // Checks the type of key and retrieves it
          ktString:
          begin
            Result.Str := Reg.ReadString(Name);
          end;
          ktInteger:
          begin
            Result.Int := Reg.ReadInteger(Name);
          end;
          ktBoolean:
          begin
            Result.Bool := Reg.ReadBool(Name);
          end;
        end;
      end
      else
      begin
        case KeyType of // Checks the type of key and retrieves it
          ktString:
          begin
            Result.Str := '';
          end;
          ktInteger:
          begin
            Result.Int := -1;
          end;
          ktBoolean:
          begin
            Result.Bool := False;
          end;
        end;
      end;
		end;
    Reg.CloseKey;
  finally
    FreeAndNil(Reg);
  end;
end;

{** And this one saves a specified key to registry **}
procedure StoreKey(const Name: string; const Value: TRegValue; KeyType: TKeyType);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Michael Hardy\UPX Shell\3.x', True) then
    begin
      case KeyType of
        ktString:
        begin
          Reg.WriteString(Name, Value.Str);
        end;
        ktInteger:
        begin
          Reg.WriteInteger(Name, Value.Int);
        end;
        ktBoolean:
        begin
          Reg.WriteBool(Name, Value.Bool);
        end;
      end;
		end;
	  Reg.CloseKey;
  finally
    FreeAndNil(Reg);
  end;
end;

procedure GetBuild;
var
  pInfo:   PVSFixedFileInfo;
  dInfo:   cardinal;
  dSize:   cardinal;
  dTemp:   cardinal;
  pBuffer: PChar;
  pFile:   PChar;
begin
  FillChar(BuildInfo, SizeOf(BuildInfo), 0);

  pFile := PChar(ParamStr(0));
  dSize := GetFileVersionInfoSize(pFile, dTemp);

  if dSize <> 0 then
  begin
    GetMem(pBuffer, dSize);

    try
      if GetFileVersionInfo(pFile, dTemp, dSize, pBuffer) then
      begin
        if VerQueryValue(pBuffer, '\', Pointer(pInfo), dInfo) then
        begin
          with BuildInfo do
          begin
            biMajor   := HiWord(pInfo^.dwFileVersionMS);
            biMinor   := LoWord(pInfo^.dwFileVersionMS);
            biRelease := HiWord(pInfo^.dwFileVersionLS);
            biBuild   := LoWord(pInfo^.dwFileVersionLS);
            biFull    := Format('%d.%d.%d.%d', [biMajor, biMinor, biRelease, biBuild]);
            biNoBuild := Format('%d.%d.%d', [biMajor, biMinor, biRelease]);
            biCute    := Format('%d.%d%d', [biMajor, biMinor, biRelease]);
          end;
        end;
      end;
    finally
      FreeMem(pBuffer, dSize);
    end;
  end;
end;


{*****************************************
* This Function extracts the UPX Version *
*****************************************}
function GetUPXBuild(const FilePath: string): string;
const
  offsets: array[1..7] of int64 = ($1F0, $3DB, $39D, $320, $281, $259, $261);
var
  fStream:    TFileStream;
  chain:      array[1..4] of char; //This will contain something like '1.20'  begin
  I:          integer;
  upxVersion: single;
begin
  if FileExists(FilePath) then
  begin
    try
      fStream := TFileStream.Create(FilePath, fmOpenRead);
      for I := Low(offsets) to High(offsets) do
      begin
        fStream.Position := 1;
        fStream.Seek(offsets[I], soFromBeginning);
        fStream.ReadBuffer(chain, $4);
        if (TryStrToFloat(chain, upxVersion)) then
        begin
          Result := chain;
          Break;
        end;
      end;
    finally
      FreeAndNil(fStream);
    end;
  end
  else
  begin
    Result := '';
  end;
end;

{**
 * Method which will find the last position of a char of a given string.
 * ---
 * @param: Char    -  Substr  - The character which to look for.
 * @param: String  - S       - The String (Haystack) where to look for the Substr.
**}
function LastPos(const Substr: char; const S: string): integer;
begin
  for Result := Length(S) downto 1 do
  begin
    if S[Result] = Substr then
    begin
      Break;
    end;
  end;
end;

end.
