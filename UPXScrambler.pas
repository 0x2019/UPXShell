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

function fScrambleUPX(const FileName: string): boolean;
var
  fsSource: TFileStream;
  BufferStr: string;
  Modified: Boolean;
  FileSize: Int64;
  BufSize:  Integer;

  function FindStr(const Pattern: string): Integer;
  begin
    Result := Pos(Pattern, BufferStr);
  end;

  function ZeroString(const Count: Integer): string;
  var
    I: Integer;
  begin
    SetLength(Result, Count);
    for I := 1 to Count do
    begin
      Result[I] := #0;
    end;
  end;

  function ReplaceBytes(const Pattern: string; const Replacement: string;
    const Offset: Integer): Boolean;
  var
    Index: Integer;
    Start: Integer;
  begin
    Result := False;
    if Length(Replacement) = 0 then
    begin
      Exit;
    end;

    Index := FindStr(Pattern);
    if Index = 0 then
    begin
      Exit;
    end;

    Start := Index - 1 + Offset;
    if (Start < 0) or (Start + Length(Replacement) > BufSize) then
    begin
      Exit;
    end;

    Move(Replacement[1], BufferStr[Start + 1], Length(Replacement));
    Modified := True;
    Result   := True;
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

    BufSize := Integer(FileSize);
    SetLength(BufferStr, BufSize);
    fsSource.Position := 0;
    fsSource.ReadBuffer(BufferStr[1], BufSize);
    Modified := False;

    // Scramble UPX0 -> code | UPX0 located in upx v0.6 until present
    ReplaceBytes('UPX0', 'CODE', 0);
    // Scramble UPX1 -> text | UPX1 located in upx v0.6 until present
    ReplaceBytes('UPX1', 'DATA', 0);
    // Scramble UPX2 -> data | UPX2 located in upx v0.6 until v1.0x
    ReplaceBytes('UPX2', 'BSS' + #0, 0);
    // Scramble UPX3 -> data | UPX3 located in upx v0.7x i think.
    ReplaceBytes('UPX3', 'IDATA', 0);

    // Scramble OLD '$Id: UPX'
    if ReplaceBytes('$Id: UPX', ZeroString(13), 0) then
    begin
      ReplaceBytes('UPX!', ZeroString(6), 0);
    end
    else
    begin
      // Scramble NEW UPX! -> nil | UPX! located in upx v1.08 until present
      ReplaceBytes('UPX!', ZeroString(11), -6);
    end;

    // Scramble anything that is left of something called UPX within the header
    ReplaceBytes('UPX', ZeroString(3), 0);

    if Modified then
    begin
      fsSource.Position := 0;
      fsSource.WriteBuffer(BufferStr[1], BufSize);
      Result := True;
    end;
  finally
    FreeAndNil(fsSource);
  end;
end;

end.
