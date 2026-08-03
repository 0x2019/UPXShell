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
  { CommandsFrm unit                              }
  {***********************************************}
unit CommandsFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TCommandsForm = class(TForm)
    pgcCommands: TPageControl;
    tbsUPX1:     TTabSheet;
    mmoUPX1:     TMemo;
    tbsUPX2:     TTabSheet;
    mmoUPX2:     TMemo;
		tbsUPX3:		 TTabSheet;
    mmoUPX3:		 TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CommandsForm: TCommandsForm;

implementation

uses
  Globals;

{$R *.dfm}

procedure LoadUPXHelp(const ResName: string; const Lines: TStrings);
var
  ResourceStream: TResourceStream;
begin
  ResourceStream := TResourceStream.Create(HInstance, ResName, PChar('TEXTFILE'));
  try
    Lines.LoadFromStream(ResourceStream, TEncoding.ASCII);
  finally
    ResourceStream.Free;
  end;
end;

procedure TCommandsForm.FormCreate(Sender: TObject);
begin
  tbsUPX1.Caption := aUPXVersions[UPX1];
  tbsUPX2.Caption := aUPXVersions[UPX2];
  tbsUPX3.Caption := aUPXVersions[UPX3];
  LoadUPXHelp('UPX1_HELP', mmoUPX1.Lines);
  LoadUPXHelp('UPX2_HELP', mmoUPX2.Lines);
  LoadUPXHelp('UPX3_HELP', mmoUPX3.Lines);
end;

end.
