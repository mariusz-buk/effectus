{
  Program: Effectus - Action! language parser and cross-assembler to native code
           for Atari 8-bit home computers

  Authors : Bostjan Gorisek (Effectus), Tebe (Mad Assembler, Mad Pascal)

  Unit file  : lib.pas
  Description: String supporting routines

  Effectus generates Mad Pascal and Mad Assembler source code listings to native binary code
  for 8-bit Atari home computers from Action! language source code listings.
  Program is compiled with Free Pascal 3.0.4.

  References:
  http://www.freepascal.org/
  http://gury.atari8.info/effectus/
  http://freeweb.siol.net/diomedes/effectus/
  https://github.com/mariusz-buk/effectus
  http://mads.atari8.info/mads.html

  This program is free software: you can redistribute it and/or modify it under the terms of
  the GNU General Public License as published by the Free Software Foundation, either version 3
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along with this program.
  If not, see <http://www.gnu.org/licenses/>.
}
unit Lib;
//{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

Uses
  SySUtils, Classes, StrUtils, decl;

function VarValue(valuePos, index : byte; compareValue : string) : boolean;
function GetVarValue(valuePos, index : byte) : string;
function Extract(offset : byte; str : string; delim : char) : string;
function ExtractText(Str : String; Ch1, Ch2 : Char) : String;
function Strip(Str : String; Ch : Char) : String;
function ExtractFilenameWithoutExt(AFileName: String) : String;
function Split(const str: string; const separator: string): TStringArray;
procedure SplitText(const aDelimiter, s: String; aList: TStringList);
function IsNumber(src : Char) : Boolean;
procedure SplitStr(const Source, Delimiter: String; var DelimitedList: TStringList);

implementation

function VarValue(valuePos, index : byte; compareValue : string) : boolean;
begin
  if ExtractDelimited(valuePos, vars.ValueFromIndex[index], [';']) = compareValue then
    result := true
  else
    result := false;
end;

function GetVarValue(valuePos, index : byte) : string;
begin
  result := ExtractDelimited(valuePos, vars.ValueFromIndex[index], [';']); 
end;

{------------------------------------------------------------------------------
 Description: Extracts string between characters Ch1 and Ch2
 Parameters : Str - Input string
              Ch1 - Starting character of examined string
              Ch2 - Last character of examined string
 Returns    : Returns string between characters Ch1 and Ch2
 Examples:
   Str := Between('ProcX(int a, byte b);', '(', ')');
   Str := Between('PrintE("test")', '"', '"');
 -----------------------------------------------------------------------------}
function ExtractText(Str : String; Ch1, Ch2 : Char) : String;
begin
  result := Copy(Str, System.Pos(Ch1, Str) + 1, RPos(Ch2, Str)-System.Pos(Ch1, Str) - 1);
  if Trim(result) = '' then begin
    result := str;
  end;
end;

function Extract(offset : byte; str : string; delim : char) : string;
var
  res : string;
begin
  res := ExtractDelimited(offset, str, [delim]);
  if (res = '') and (offset > 1) then begin
    res := ExtractDelimited(1, str, [delim]);
  end;

  //if sNoTrim in Flags then
  //  Result := res
  //else

  Result := Trim(res);
end;

function Replace(Str : String; Ch1, Ch2 : Char) : String;
var
  i : Integer;
begin
  i := System.Pos(Ch1, Str);
  Delete(Str, i, 1);
  Insert(Ch2, Str, i);
  Result := Str;
//  Result := StuffString(Str, System.Pos(Ch1, Str), 1, Ch2);
end;

{------------------------------------------------------------------------------
 Description: Deletes all occurences of a character in a string
 Parameters : Str - String value to be processed
              Ch - Character to be deleted from the string
 Returns    : New string value
 -----------------------------------------------------------------------------}
function Strip(Str : String; Ch : Char) : String;
begin
  Result := StringReplace(Str, Ch, '', [rfReplaceAll, rfIgnoreCase]);
end;

function ExtractFilenameWithoutExt(AFileName: String) : String;
begin
  Result := ChangeFileExt(ExtractFileName(AFileName), '');
end;

function Occurs(const str, separator : string) : integer;
var
  i, nSep : integer;
begin
  nSep:= 0;
  for i := 1 to Length(str) do begin
    if str[i] = separator then Inc(nSep);
  end;
  Result:= nSep;
end;

function Split(const str: string; const separator: string): TStringArray;
var
  i, n: integer;
  strline, strfield: string;
begin
  n:= Occurs(str, separator);
  SetLength(Result, n + 1);
  i := 0;
  strline:= str;
  repeat
    if Pos(separator, strline) > 0 then begin
      strfield:= Copy(strline, 1, Pos(separator, strline) - 1);
      strline:= Copy(strline, Pos(separator, strline) + 1,
                     Length(strline) - pos(separator,strline));
    end
    else begin
      strfield:= strline;
      strline:= '';
    end;
    Result[i]:= strfield;
    Inc(i);
  until strline= '';
  if Result[High(Result)] = '' then SetLength(Result, Length(Result) -1);
end;

procedure SplitText(const aDelimiter,s: String; aList: TStringList);
begin
  aList.LineBreak := aDelimiter;
  aList.Text := s;
end;

procedure SplitStr(const Source, Delimiter: String; var DelimitedList: TStringList);
var
  s: PChar;

  DelimiterIndex: Integer;
  Item: String;
begin
  s:=PChar(Source);
  DelimitedList.Clear;

  repeat
    DelimiterIndex:=Pos(Delimiter, s);
    if DelimiterIndex=0 then Break;

    Item:=Copy(s, 1, DelimiterIndex-1);
    DelimitedList.Add(Item);
    inc(s, DelimiterIndex + Length(Delimiter)-1);
  until DelimiterIndex = 0;
  DelimitedList.Add(s);
end;

function IsNumber(src : Char) : Boolean;
begin
  Result := (src in ['0'..'9']) or (src = '$');
  //Result := ((src > Chr(47)) and (src < Chr(58))) or (src = '$');
end;

function CountString(const astringtofind, totalstring: string): integer;
var
   p : integer;
begin
   Result := 0;
   p := 1;
   repeat
     p := PosEx(astringtofind, totalstring, p);
     if (p > 0) then begin
       Inc(Result);
       p := p+length(astringtofind);
     end;
   until p = 0;
end;

// procedure Debug(str : string; isShown : boolean);
// begin
//   if isShown then Writeln(str);
// end;

end.
