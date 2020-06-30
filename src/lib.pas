{
  Program: Effectus - Action! language parser and cross-assembler to native code
           for Atari 8-bit home computers

  Authors : Bostjan Gorisek (Effectus), Tebe (Mad Assembler, Mad Pascal)

  Unit file  : lib.pas
  Description: Supporting routines

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
function ReplaceToken(code, operand, newOperand01, newOperand02 : string) : string;
procedure CheckOper(op, expr : string);
function ActionSCompare(params : string) : string;
procedure FuncInIfCond(procName, temp, params2 : string);
function Extract(offset : byte; str : string; delim : char) : string;
function ExtractText(Str : String; Ch1, Ch2 : Char) : String;
function Strip(Str : String; Ch : Char) : String;
function ExtractFilenameWithoutExt(AFileName: String) : String;
//function Split(const str: string; const separator: string): TStringArray;
//procedure SplitText(const aDelimiter, s: String; aList: TStringList);
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
 Description: Replace/substitute program defined tokens with true operators
 -----------------------------------------------------------------------------}
function ReplaceToken(code, operand, newOperand01, newOperand02 : string) : string;
begin
  if (System.Pos(operand, code) > 1) and (System.Pos('"', code) > 0)
     and (System.Pos(operand, code) > System.Pos('"', code)) then
  begin
  end
  else if System.Pos(operand, code) > 0 then begin
    if operand = newOperand01 then begin
      code := StringReplace(code, ' ' + operand, operand, [rfReplaceAll]);
      code := StringReplace(code, operand + ' ', newOperand01, [rfReplaceAll]);
      code := StringReplace(code, operand, newOperand02, [rfReplaceAll]);
    end
    else begin
      code := StringReplace(code, ' ' + operand + ' ', newOperand01, [rfReplaceAll]);
      code := StringReplace(code, operand + ' ', newOperand01, [rfReplaceAll]);
      code := StringReplace(code, ' ' + operand, newOperand02, [rfReplaceAll]);
    end;
  end;
  result := code;
end;

{------------------------------------------------------------------------------
 Description: Count operator occurrences in an expression
 -----------------------------------------------------------------------------}
procedure CheckOper(op, expr : string);
var
  x, y : integer;
begin
  y := 1;
  repeat
    x := nPos(op, expr, y);
    if x > 0 then begin
      oper.Add(op + '=' + IntToStr(x) + ';0')
    end;
    inc(y);
  until x = 0;
end;

function ActionSCompare(params : string) : string;
var
  paramsEx : TStringArray;
begin
  result := '-2';
  paramsEx := params.Split(',');
  //writeln('(2) scompare params2 = ', params2);

  if High(paramsEx) = 1 then begin
    paramsEx[0] := Trim(paramsEx[0]);
    paramsEx[1] := Trim(paramsEx[1]);
    if paramsEx[0] < paramsEx[1] then
      result := '-1'
    else if paramsEx[0] = paramsEx[1] then
      result := '0'
    else begin
      result := '1'
    end;
  end;
end;

procedure FuncInIfCond(procName, temp, params2 : string);  //; compare : string);
var
  //params : TStringArray;
  temp02 : string;
  list : TStringList;
  i : byte;
begin
  list := TStringlist.create;
  //writeln(procname, ' ', temp, ' ', params2, ' ', compare);
  for i := 0 to 4 do begin
    list.Clear;
    SplitStr(temp, _CMP_OPER[i], list);
    //params := temp.Split(compare);
    // High(params) = 1
    if list.Count = 2 then begin
      list[0] := Trim(list[0]);
      list[1] := Trim(list[1]);
      temp02 := Extract(1, list[0], '(');
      //writeln('temp02 = ', temp02, ' procname = ', procname);
      if funcs.IndexOfName(temp02) >= 0 then begin
        if procName = 'RAND' then
          temp02 := 'Random'
        else if procName = 'PEEK' then
          temp02 := 'Peek'
        else if procName = 'PEEKC' then
          temp02 := 'DPeek'
        else if procName = 'SCOMPARE' then begin
          temp02 := 'SCOMPARE';
          branchPtr.isFuncInIf := true;
          branchPtr.ifThenCode += ActionSCompare(params2) + ' ' + _CMP_OPER[i] + ' ' + list[1];
        end
        else begin
          temp02 := ''
        end;

        if (temp02 <> '') and (temp02 <> 'SCOMPARE') then begin
          branchPtr.isFuncInIf := true;
          branchPtr.ifThenCode += ' ' + temp02 + '(' + params2 + ') ' +
                                  _CMP_OPER[i] + ' ' + list[1] + ' ';
        end;
      end;
    end;
  end;
  list.Free;
end;

{------------------------------------------------------------------------------
Description: Extracts string between characters Ch1 and Ch2
Parameters
  Str - Input string
  Ch1 - First character as a wrapper of input string
  Ch2 - Last character as a wrapper of input string
Examples:
  Str := Between('ProcX(int a, byte b);', '(', ')');
  Str := Between('PrintE("test")', '"', '"');
 -----------------------------------------------------------------------------}
function ExtractText(Str : String; Ch1, Ch2 : Char) : String;
begin
  result := Copy(Str,
                 System.Pos(Ch1, Str) + 1,
                 RPos(Ch2, Str) - System.Pos(Ch1, Str) - 1);
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

// function Split(const str : string; const separator : string): TStringArray;
// var
//   i, n: integer;
//   strline, strfield: string;
// begin
//   n:= Occurs(str, separator);
//   SetLength(Result, n + 1);
//   i := 0;
//   strline:= str;
//   repeat
//     if Pos(separator, strline) > 0 then begin
//       strfield:= Copy(strline, 1, Pos(separator, strline) - 1);
//       strline:= Copy(strline, Pos(separator, strline) + 1,
//                      Length(strline) - pos(separator,strline));
//     end
//     else begin
//       strfield:= strline;
//       strline:= '';
//     end;
//     Result[i]:= strfield;
//     Inc(i);
//   until strline= '';
//   if Result[High(Result)] = '' then SetLength(Result, Length(Result) -1);
// end;

// procedure SplitText(const aDelimiter,s: String; aList: TStringList);
// begin
//   aList.LineBreak := aDelimiter;
//   aList.Text := s;
// end;

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
