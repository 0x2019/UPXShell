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
    btnClose:    TButton;
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

{$R *.dfm}

procedure TCommandsForm.FormCreate(Sender: TObject);
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
end;

end.
