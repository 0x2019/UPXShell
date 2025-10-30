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

program UPXMiracle;
{
                                 .___             __            _____
         _____________  ____   __| _/_ __   _____/  |_    _____/ ____\
         \____ \_  __ \/  _ \ / __ |  |  \_/ ___\   __\  /  _ \   __\
         |  |_> >  | \(  <_> ) /_/ |  |  /\  \___|  |   (  <_> )  |
         |   __/|__|   \____/\____ |____/  \___  >__|    \____/|__|
         |__|                     \/           \/
               .___________    _______    ___________     __
               |   \_____  \   \      \   \__    ___/___ |  | __
               |   |/   |   \  /   |   \    |    |_/ __ \|  |/ /
               |   /    |    \/    |    \   |    |\  ___/|    <
               |___\_______  /\____|__  /   |____| \___  >__|_ \
                           \/         \/               \/     \/

         UPDATED BY BLACKDEX 2004-2006
}

uses
  Forms,
  MainFrm in 'MainFrm.pas' {MainForm},
  SetupFrm in 'SetupFrm.pas' {SetupForm},
  MultiFrm in 'MultiFrm.pas' {MultiForm},
  CommandsFrm in 'CommandsFrm.pas' {CommandsForm},
  Globals in 'Globals.pas',
  Shared in 'Shared.pas',
  Translator in 'Translator.pas',
  Compression in 'Compression.pas',
  UPXScrambler in 'UPXScrambler.pas';

//LocalizerFrm in 'LocalizerFrm.pas' {LocalizerForm};

// we can now switch between using the native Delphi
// resource settings, or the more powerful external
// resource files
{$R *.res}
{$R 'Resources\resources.res'}

begin
  Application.Initialize;
  Application.Title := 'UPX Miracle';
  Application.HelpFile := '';
  Application.ShowMainForm := False;
	Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSetupForm, SetupForm);
  //Application.CreateForm(TLocalizerForm, LocalizerForm);
  Application.ShowMainForm := True;
	Application.Run;
end.

