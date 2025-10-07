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
 { Translator engine unit                        }
 {***********************************************}
unit Translator;

interface

uses
  Forms, Windows, Classes, TypInfo, StdCtrls, ComCtrls, ExtCtrls,
  Controls, Menus, Dialogs;

function TranslateMsg(const Msg: string): string;
procedure LoadLanguage(FormInstance: TForm);
procedure TranslateForm(FormInstance: TForm);
procedure DumpLanguage(FormInstance: TForm; const FileName: string; WriteMode: word; DumpMessages: boolean = False);
procedure LocalizerMode(FormInstance: TForm; Enable: boolean);

implementation

uses
  SysUtils,
  Globals, Shared,
  MainFrm,
  LocalizerFrm;

type
  TTokenKind = (tkScoper, tkProperty, tkData);

  TToken = record
    Data: string;
    Kind: TTokenKind;
  end;
  TTokens = array of TToken;

type
	// This is a dummy container used to handle popup forms in
  // localization mode
  TDummyContainer = class
	public
		{FFormProperties: TFormProperties;}
		procedure LocalizationMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
  end;


//======================================================================================
{** Does the translation of predefined messages (declared as
    msg[xxx]=??? in .lng file) **}
function TranslateMsg(const Msg: string): string;
var
  I: integer;
begin
	Result := StringDecode(Msg);
	for I := 1 to High(EngMsgs) do
	begin
//		if (Msg = EngMsgs[I]) and (Messages[I] <> '') then
		if (Msg = EngMsgs[I]) then
    begin
      Result := StringDecode(Messages[I]);
      break;
    end;
  end;
end;
 //======================================================================================

 //======================================================================================
procedure AddMessage(Msg: string);

  function RemoveQuotes(const InStr: string): string;
  begin
    //Commented out the '''' single quote detection. This has been requested.
    if (InStr <> '') and (InStr[1] in ['"'{, ''''}]) then
    begin
      Result := copy(InStr, 2, length(InStr) - 2);
    end
    else
    begin
      Result := InStr;
    end;
  end;

var
  posit, cut: integer;
begin
  posit := Pos('[', Msg) + 1;
  posit := StrToInt(Copy(Msg, posit, 3));
  cut   := Pos('=', Msg);
  Delete(Msg, 1, cut);
  Messages[posit] := RemoveQuotes(StringDecode(Msg));
end;
 //======================================================================================

 //======================================================================================
procedure SetProperty(const Tokens: TTokens);
var
  I:       integer;
  trComp:  TComponent;
  trProp:  string;
  trValue: string;
begin
  trComp := Application.FindComponent(Tokens[0].Data);
  if trComp <> nil then
  begin
    for I := 1 to high(Tokens) do
    begin
      case Tokens[I].Kind of
        tkScoper:
        begin
          if trComp <> nil then
          begin
            trComp := trComp.FindComponent(Tokens[I].Data);
          end;
        end;
        tkProperty:
        begin
          trProp := Tokens[I].Data;
        end;
        tkData:
        begin
          trValue := Tokens[I].Data;
        end;
      end;
    end;
  end;
  if (trComp <> nil) and (trComp is TComboBox) then
  begin
    if lowercase(trProp) = 'hint' then
    begin
      TComboBox(trComp).Hint := trValue;
    end
    else
    begin
      TComboBox(trComp).Items[StrToInt(trProp)] := trValue;
    end;
  end
  else
  begin
    if Pos('mnuHistory', Tokens[1].Data) <> 0 then
    begin
      MainForm.mnuHistory.Items[0].Caption := trValue;
    end;
  end;
  //** This will allow multiline hints. This was a requested feature.
  if (trComp <> nil) and (lowercase(trProp) = 'hint') then
  begin
    trValue := StringReplace(trValue, '\n', #13#10, [rfReplaceAll, rfIgnoreCase]);
    SetStringProperty(trComp, trProp, trValue);
  end
  else
  begin
    SetStringProperty(trComp, trProp, trValue);
  end;
end;
 //======================================================================================

 //======================================================================================
procedure ParseLine(const Line: string);

  function Tokenize(const InStr: string): TTokens;
  var
    I:     integer;
    level: integer;
    tKind: TTokenKind;
  begin
    level := 0;
    SetLength(Result, 1);
    tKind := tkScoper;
    for I := 1 to length(InStr) do
    begin
      if (tKind = tkScoper) and (InStr[I] = '.') then
      begin
        Inc(level);
        SetLength(Result, level + 1);
        Result[level].Kind := tKind;
      end
      else
      begin
        if (tKind = tkScoper) and (InStr[I] = '=') then
        begin
          Inc(level);
          SetLength(Result, level + 1);
          tKind := tkData;
          Result[level].Kind := tKind;
          Result[level - 1].Kind := tkProperty;
        end
        else
        begin
          //Commented out the '''' single quote detection. This has been requested.
          if (tKind = tkData) and (InStr[I] in ['"'{, ''''}]) then
          begin
            //Do Nothing
          end
          else
          begin
            Result[level].Data := Result[level].Data + InStr[I];
          end;
        end;
      end;
    end;
  end;

var
  tmp: TTokens;
begin
  tmp := Tokenize(Line);
  SetProperty(tmp);
end;
 //======================================================================================

 //======================================================================================
 // Loads the file and scans strings one by one
procedure LoadFile(const FileName: string; FormInstance: TForm);
type
  TTokenKind = (tkUnknown, tkComment, tkMessage, tkTranslation);

  function GetTokenKind(Str: string): TTokenKind;
  begin
    Result := tkUnknown;
    Str    := trim(Str);
    if Str <> '' then
    begin
      if (copy(Str, 1, 2) = '//') or (Str[1] = ';') then
      begin
        Result := tkComment;
      end
      else
      begin
        if copy(Str, 1, 4) = 'msg[' then
        begin
          Result := tkMessage;
        end
        else
        begin
          if Pos('=', Str) <> 0 then
          begin
            Result := tkTranslation;
          end;
        end;
      end;
    end;
  end;

var
  f:        textfile;
  FormName: string;
  Temp:     string;
begin
  FormName := FormInstance.Name;
  if FileExists(FileName) then
  begin
    assignfile(f, FileName);
    reset(f);
    while not EOF(f) do
    begin
      readln(f, Temp);
      case GetTokenKind(Temp) of
        tkTranslation:
        begin
          if Pos(FormName, Temp) <> 0 then
          begin
            ParseLine(Temp);
          end;
        end;
        tkMessage:
        begin
          AddMessage(Temp);
        end;
      end;
    end;
    closefile(f);
  end;
end;
 //======================================================================================

 //======================================================================================
procedure LoadLanguage(FormInstance: TForm);
begin
  SetCurrentDir(WorkDir + LanguageSubdir);
  LoadFile(LangFile + '.lng', FormInstance); //Load .lng file for processing
  SetCurrentDir(WorkDir);
end;
 //======================================================================================

 //======================================================================================
procedure TranslateForm(FormInstance: TForm);
 //Parses a text file
  procedure ParseLine(InStr: string; out Form, Component, Prop, Value: string);
  var
    posit: integer;
  begin
    posit     := Pos('.', InStr);
    Form      := lowercase(trim(copy(InStr, 1, posit - 1)));
    Delete(InStr, 1, posit);
    posit     := Pos('.', InStr);
    Component := lowercase(trim(copy(InStr, 1, posit - 1)));
    Delete(InStr, 1, posit);
    posit     := Pos('=', InStr);
    Prop      := lowercase(trim(copy(InStr, 1, posit - 1)));
    Delete(InStr, 1, posit);
    posit     := Pos('=', InStr);
    Delete(InStr, posit, 1);
    Value     := StringDecode(Trim(InStr));
  end;

var
  f:     textfile;
  Line:  string;
  Form, Component, Prop, Value: string;
  CompC: TComponent;
begin
  assignfile(f, WorkDir + 'Language\' + LangFile + '.lng');
  reset(f);
  while not EOF(f) do
  begin
    readln(f, Line);
    if StrLiComp(PChar(FormInstance.Name), PChar(Line),
      Length(FormInstance.Name)) = 0 then
    begin
      ParseLine(Line, Form, Component, Prop, Value);
      if not (FormInstance = nil) then
      begin
        CompC := FormInstance.FindComponent(Component);
        if CompC <> nil then
        begin
          if CompC is TComboBox then
          begin
            if Prop = 'hint' then
            begin
              TComboBox(CompC).Hint := Value;
            end
            else
            begin
              TComboBox(CompC).Items[StrToInt(Prop)] := Value;
            end;
          end
          else
          begin
            SetStringProperty(CompC, Prop, Value);
          end;
        end
        else
        if ((Prop = 'caption') and (lowercase(FormInstance.Name) = Form) and
          (Component = '')) then
        begin
          FormInstance.Caption := Value;
        end;
      end;
    end;
  end;
  closefile(f);
end;
 //======================================================================================

 //======================================================================================
 // Dumps all form component's captions and hints into a language file
procedure DumpLanguage(FormInstance: TForm; const FileName: string; WriteMode: word; DumpMessages: boolean = False);

  procedure DumpComponent(Component: TComponent; const Properties: array of string; var fs: TFileStream);
  var
    I:   integer;
    Str: string;
    tmp: string;
  begin
    // let's see if we are dealing with a menu and save its items

    // note: we only save those menu items, whose Tag *is* set to -1
    // this is to avoid saving items like those in the recent-files menu
    if Component is TMenuItem then
    begin
      if Component.Tag = -1 then
      begin
        Str := #13#10 + GetComponentTree(Component) + '.' + 'Caption' + '=' + StringEncode(TMenuItem(Component).Caption);
        fs.WriteBuffer(Str[1], length(Str));
      end;
    end
    else
      // perform the generic save
    begin
      // save only if the Tag is *not* -1
      if Component.Tag <> -1 then
      begin
        for I := 0 to high(Properties) do
        begin
          Str := GetComponentTree(Component);
          tmp := GetStringProperty(Component, Properties[I]);
          if tmp <> '' then
          begin
            tmp[1] := UpperCase(tmp[1])[1];
            Str    := #13#10 + Str + '.' + Properties[I] + '=' + StringEncode(tmp);
            fs.WriteBuffer(Str[1], length(Str));
          end;
        end;
      end;
    end;

    // let's see if we are dealing with a combo box and save its items
    // note: we do this separately from the processing above since we
    // need to save *both* the stuff above and the following

    // note: we only save those combos, whose Tag is *not* set to -2
    // this is to avoid saving combos like the cmbLanguage one
    if (Component is TComboBox) and (Component.Tag <> -2) then
    begin
      for I := 0 to TComboBox(Component).Items.Count - 1 do
      begin
        Str := #13#10 + GetComponentTree(Component) + '.' + IntToStr(I) + '=' + StringEncode(TComboBox(Component).Items[I]);
        fs.WriteBuffer(Str[1], length(Str));
      end;
    end;
  end;

var
  fs:      TFileStream;
  I:       integer;
  Comment: string;
  Msg:     string;
  Quote:   string;
begin
  fs := TFileStream.Create(FileName, WriteMode);
  try
    fs.Seek(0, soFromEnd);

    // if we're staring a new file then output a generic header
    if fs.Position = 0 then
    begin
      Comment := '; Automatic Language Dump generated at ' + DateTimeToStr(now) + #13#10 + '; Based on: ' + LangFile;
      fs.WriteBuffer(Comment[1], length(Comment));
    end;

    // output a comment specifying which form the following data belongs to
    // to ease navigating through the language file
    Comment := #13#10 + chr(VK_TAB) + '// ' + FormInstance.Name + ' Form';
    fs.WriteBuffer(Comment[1], length(Comment));

    for I := 0 to FormInstance.ComponentCount - 1 do
    begin
      // again output a comment for tab sheets
      if FormInstance.Components[I] is TTabSheet then
      begin
        Comment := #13#10 + chr(VK_TAB) + chr(VK_TAB) + '// ' + TTabSheet(FormInstance.Components[I]).Caption + ' Tab';
        fs.WriteBuffer(Comment[1], length(Comment));
      end;
      DumpComponent(FormInstance.Components[I], ['Caption', 'Hint'], fs);
    end;

    if DumpMessages then
    begin
      Comment := #13#10 + '; Messages';
      fs.WriteBuffer(Comment[1], length(Comment));

      for I := 1 to high(Messages) do
      begin
        // if the message ends in a space character then we have to quote it
        if Messages[I][length(Messages[I])] = ' ' then
        begin
          Quote := '"';
        end
        else
        begin
          Quote := '';
        end;

        Msg := #13#10 + 'msg[' + Format('%.3d', [I]) + ']=' + Quote + StringEncode(Messages[I]) + Quote;
        fs.WriteBuffer(Msg[1], length(Msg));
      end;
    end;
  finally
    FreeAndNil(fs);
  end;
end;
 //======================================================================================

 //======================================================================================

type
  TControlFriend = class(TControl);
 // When we go to localizer mode we create a context menu
 //======================================================================================
procedure LocalizerMode(FormInstance: TForm; Enable: boolean);

  procedure SetComponentPopup(Component: TComponent; Dummy: TDummyContainer);
  begin
    // first let's see if the component has a caption or a hint properties
    if PropertyExists(Component, 'caption') or
      PropertyExists(Component, 'hint') then
    begin
      // now let's see if our component is a TControl descendant and actually
      // has an OnMouseUp event sink
      if Component is TControl then
      begin
        TControlFriend(Component).OnMouseUp := Dummy.LocalizationMouseUp;
        //Set the Component to visible, else they can't translate the control.
        TControlFriend(Component).Visible   := True;
      end;
    end;
  end;

  // remove those popups set by previous routine
	procedure RemoveComponentPopup(Component: TComponent{; Dummy: TDummyContainer});
  begin
    if Component is TControl then
    begin
      TControlFriend(Component).OnMouseUp := nil;
    end;
  end;

var
  I:     integer;
  Dummy: TDummyContainer;
begin
  if Enable then
  begin
    // this dummy will leak memory, since it will never be released.
    // maybe add a global stack of dummies if this poses a real problem
    // which it should not since the localizer mode isn't used real often
    Dummy := TDummyContainer.Create();

    for I := 0 to FormInstance.ComponentCount - 1 do
    begin
      if (FormInstance.Components[I].Tag <> -1) and (FormInstance.Components[I].Tag <> -2) then
      begin
        SetComponentPopup(FormInstance.Components[I], Dummy);
      end;
    end;
  end
  else
  begin
    for I := 0 to FormInstance.ComponentCount - 1 do
    begin
      RemoveComponentPopup(FormInstance.Components[I]{, nil});
    end;
  end;
end;
 //======================================================================================

 { TDummyContainer }
 //======================================================================================
procedure TDummyContainer.LocalizationMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);

  function GetControlProps(Control: TControl): TComponentProperties;
  var
    I: integer;
  begin
    Result.Name := GetComponentTree(Control);
    if Control is TComboBox then
    begin
      // a combobox needs special treatment
      // we only localize comboboxes, whose Tag is *not* -1
      if Control.Tag <> -1 then
      begin
        I := TComboBox(Control).Items.Count;
        SetLength(Result.Properties, I + 1);
        Result.Properties[I].Name := 'Hint';
        Result.Properties[I].Value := GetStringProperty(Control, 'Hint');
        for I := 0 to I - 1 do
        begin
          Result.Properties[I].Name  := IntToStr(I);
          Result.Properties[I].Value := TComboBox(Control).Items[I];
        end;
      end
      else
      begin
        SetLength(Result.Properties, 1);
        Result.Properties[0].Name  := 'Hint';
        Result.Properties[0].Value := GetStringProperty(Control, 'Hint');
      end;
    end
    else
    begin
      if (Control is TPanel) and (TPanel(Control).Parent is TTabSheet) and
        (TPanel(Control).Align = alClient) then
      begin
        // if the control is a panel and has a TabSheet parent and an
        // alClient alignment, then we redirect it's click to the parent sheet
        SetLength(Result.Properties, 2);
        Result.Properties[0].Name  := 'Caption';
        Result.Properties[0].Value :=
          GetStringProperty(Control.Parent, 'Caption');
        Result.Properties[1].Name  := 'Hint';
        Result.Properties[1].Value :=
          GetStringProperty(Control.Parent, 'Hint');
      end
      else
      begin
        // as for the rest of controls, we are only allowing to edit their
        // captions and hints
        I := 0;
        if PropertyExists(Control, 'Caption') then
        begin
          Inc(I);
          SetLength(Result.Properties, I);
          Result.Properties[I - 1].Name  := 'Caption';
          Result.Properties[I - 1].Value :=
            GetStringProperty(Control, 'Caption');
        end;
        if PropertyExists(Control, 'Hint') then
        begin
          Inc(I);
          SetLength(Result.Properties, I);
          Result.Properties[I - 1].Name  := 'Hint';
          Result.Properties[I - 1].Value := GetStringProperty(Control, 'Hint');
        end;
      end;
    end;
  end;

  procedure SetControlProps(Control: TControl; const Props: TComponentProperties);
  var
    I: integer;
  begin
    if Control is TComboBox then
    begin
      for I := 0 to high(Props.Properties) do
      begin
        if IsNumeric(Props.Properties[I].Name) then
        begin
          TComboBox(Control).Items[StrToInt(Props.Properties[I].Name)] :=
            Props.Properties[I].Value;
        end
        else
        begin
          SetStringProperty(Control, Props.Properties[I].Name,
            Props.Properties[I].Value);
        end;
      end;
    end
    else
    begin
      if (Control is TPanel) and (TPanel(Control).Parent is TTabSheet) and
        (TPanel(Control).Align = alClient) then
      begin
        for I := 0 to high(Props.Properties) do
        begin
          SetStringProperty(Control.Parent, Props.Properties[I].Name,
            Props.Properties[I].Value);
        end;
      end
      else
      begin
        for I := 0 to high(Props.Properties) do
        begin
          SetStringProperty(Control, Props.Properties[I].Name,
            Props.Properties[I].Value);
        end;
      end;
    end;
  end;

var
  Localizer: TLocalizerForm;
begin
  if Button = mbRight then
  begin
    Localizer := TLocalizerForm.Create(nil);
    try
      Localizer.FMode := lfmProperties;
      Localizer.FControl := GetControlProps(TControl(Sender));
      Localizer.ShowModal();
      SetControlProps(TControl(Sender), Localizer.FControl);
    finally
      Localizer.Release()
    end;
  end;
end;
//======================================================================================

end.
