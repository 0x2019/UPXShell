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
 { UPXScrambler unit                             }
 { Created by BlackDex                           }
 { This unit replaces the old scrambler.exe      }
 {***********************************************}
unit UPXScrambler;

interface

uses
  Classes, SysUtils;

{Functions/Procedures}
function fScrambleUPX(const FileName: string): boolean;

implementation

{** **}
function fScrambleUPX(const FileName: string): boolean;
var
  fsSource:    TFileStream;
  Buffer:      TBytes;
  BufferStr:   string;
  Modified:    Boolean;
  FileSize:    Int64;

  function BytesOf(const Text: string): TBytes;
  begin
    Result := TEncoding.ANSI.GetBytes(Text);
  end;

  function ZeroBytes(const Count: Integer): TBytes;
  begin
    SetLength(Result, Count);
    if Count > 0 then
    begin
      FillChar(Result[0], Count, 0);
    end;
  end;

  function ReplaceBytes(const Pattern: string; const Replacement: TBytes;
    const Offset: Integer = 0): Boolean;
  var
    Index: Integer;
    Start: Integer;
  begin
    Result := False;
    if Length(Replacement) = 0 then
    begin
      Exit;
    end;

    Index := Pos(Pattern, BufferStr);
    if Index = 0 then
    begin
      Exit;
    end;

    Start := Index - 1 + Offset;
    if (Start < 0) or (Start + Length(Replacement) > Length(Buffer)) then
    begin
      Exit;
    end;

    Move(Replacement[0], Buffer[Start], Length(Replacement));
    BufferStr := TEncoding.ANSI.GetString(Buffer);
    Modified := True;
    Result := True;
  end;

begin
  Result := False;
  fsSource := TFileStream.Create(FileName, fmOpenReadWrite);
  try
    FileSize := fsSource.Size;
    if (FileSize = 0) or (FileSize > High(Integer)) then
    begin
      Exit;
    end;

    SetLength(Buffer, Integer(FileSize));
    fsSource.Position := 0;
    fsSource.ReadBuffer(Buffer[0], Length(Buffer));
    BufferStr := TEncoding.ANSI.GetString(Buffer);
    Modified := False;

    // Scramble UPX0 -> code | UPX0 located in upx v0.6 until present
    ReplaceBytes('UPX0', BytesOf('CODE'));
    // Scramble UPX1 -> text | UPX1 located in upx v0.6 until present
    ReplaceBytes('UPX1', BytesOf('DATA'));
    // Scramble UPX2 -> data | UPX2 located in upx v0.6 until v1.0x
    ReplaceBytes('UPX2', BytesOf('BSS' + #0));
    // Scramble UPX3 -> data | UPX3 located in upx v0.7x i think.
    ReplaceBytes('UPX3', BytesOf('IDATA'));

    // Scramble OLD '$Id: UPXScrambler.pas,v 1.14 2007/01/23 21:43:50 dextra Exp $Id: UPX'
    if ReplaceBytes('$Id: UPX', ZeroBytes(13)) then
    begin
      ReplaceBytes('UPX!', ZeroBytes(6));
    end
    else
    begin
      // Scramble NEW UPX! -> nil | UPX! located in upx v1.08 until present
      ReplaceBytes('UPX!', ZeroBytes(11), -6);
    end;

    // Scramble anything that is left of something called UPX within the header
    ReplaceBytes('UPX', ZeroBytes(3));

    if Modified then
    begin
      fsSource.Position := 0;
      fsSource.WriteBuffer(Buffer[0], Length(Buffer));
      Result := True;
    end;
  finally
    FreeAndNil(fsSource);
  end;
end;

end.
