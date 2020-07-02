{
  Program: Effectus - Action! language parser and cross-assembler to native code
           for Atari 8-bit home computers

  Authors : Bostjan Gorisek (Effectus), Tebe (Mad Assembler, Mad Pascal)

  Unit file  : core.pas
  Description: Core routines for processing Action! source code listings

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
unit Core;
//{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

Uses
  SySUtils, Classes, StrUtils, Crt, Decl, Lib;

procedure GenerateCode;

implementation

{------------------------------------------------------------------------------
 Description: Write Mad Pascal variable declarations
 -----------------------------------------------------------------------------}
procedure VarDecl(isGlobal : boolean);
var
  i, j : byte;
  isVar : boolean = false;
  isVarDecl : boolean = false;
  buf, len : string;
  params : TStringArray;
  isType : boolean = false;
  dataType : string = 'byte';
  xyDataType : string;
begin
  if vars.Count = 0 then begin
    Exit;
  end;
  for i := 0 to vars.Count - 1 do begin
    if VarValue(7, i, '1') then begin
      varPtr.isVarXY := true;
      Inc(varCnt);
      continue;
    end;

    if isGlobal then begin
      if GetVarValue(5, i) <> '' then begin
        Continue;
      end;
    end
    else begin
      if prgPtr.strProcName <> GetVarValue(5, i) then begin
        Continue;
      end;
    end;

    if not isGlobal and VarValue(2, i, _VAR_TYPE_REC) then begin
      if not isType then begin
        isType := true;
        code.Add('type');
      end;
    end
    else if not isType then begin
      if not isVar then begin  //and not prgPtr.isVarArray then begin
        isVar := true;
        code.Add('var');
      end;
    end;

    xyDataType := GetVarValue(1, i);

    if VarValue(2, i, _VAR_SCALAR) then begin
      if UpperCase(xyDataType) = 'BYTE' then begin
        xyDataType := vars.Names[i] + ' : byte';
        if isVarFastMode or isByteFastMode then begin
          xyDataType += ' absolute $e0';
          if cntByteFastMode > 0 then begin
            xyDataType += ' + ' + IntToStr(cntByteFastMode);
          end;
          Inc(cntByteFastMode);
        end;
      end
      else if UpperCase(xyDataType) = 'WORD' then begin
        xyDataType := vars.Names[i] + ' : word';
        if isVarFastMode or isWordFastMode then begin
          xyDataType += ' absolute $e0';
          if cntByteFastMode > 0 then begin
            xyDataType += ' + ' + IntToStr(cntByteFastMode);
          end;
          Inc(cntByteFastMode, 2);
        end;
      end
      else begin
        xyDataType := vars.Names[i] + ' : ' + xyDataType;
      end;
      xyDataType += ';';
      isVarDecl := true;
    end
    else if VarValue(2, i, _VAR_SCALAR_DEFAULT) then begin
      isVarDecl := true;
      xyDataType := vars.Names[i] + ' : ' + xyDataType + ' = ' +
                         GetVarValue(3, i) + ';';
    end
    else if VarValue(2, i, _VAR_MEM_ADDR) then begin
      isVarDecl := true;
      xyDataType := vars.Names[i] + ' : ' + xyDataType + ' absolute ' +
                         GetVarValue(3, i) + ';';
    end
    // String variable declaration
    else if VarValue(2, i, _VAR_STRING) then begin
      isVarDecl := true;
      buf := GetVarValue(3, i);
      len := GetVarValue(4, i);
      if buf = '0' then begin
        if len = '0' then
          xyDataType := vars.Names[i] + ' : string;'
        else begin
          xyDataType := vars.Names[i] + ' : string[' + len + '];'
        end;
      end
      else begin
        buf := QuotedStr(ExtractText(buf, '"', '"'));
        if len = '0' then
          xyDataType := vars.Names[i] + ' : string = ' + buf + ';'
        else begin
          xyDataType := vars.Names[i] + ' : string[' + len + '] = ' + buf + ';';
        end;
      end;
    end
    // BYTE ARRAY variable declaration
    else if VarValue(2, i, _VAR_BYTE_ARRAY) or VarValue(2, i, _VAR_CARD_ARRAY) then begin
      if VarValue(2, i, _VAR_CARD_ARRAY) then begin
        dataType := 'word';
      end;
      isVarDecl := true;
      buf := GetVarValue(3, i);
      len := GetVarValue(4, i);
      //writeln('buf = ', buf, ' len = ', len);

      // f.e.: BYTE ARRAY values
      if (buf = '0') or (buf = '') then begin
        if len = '0' then
          xyDataType := vars.Names[i] + ' : array[0..255] of ' + dataType + ';'
        else begin
          if len = '' then begin
            xyDataType := vars.Names[i] + ' : PByte';
            if isPointerFastMode or isVarFastMode then begin
              xyDataType += ' absolute $e0';
              if cntByteFastMode > 0 then begin
                xyDataType += ' + ' + IntToStr(cntByteFastMode);
              end;
              Inc(cntByteFastMode);
            end;
          end
          else begin
            xyDataType := vars.Names[i] + ' : array[0..' + len + '] of ' + dataType;
          end;
          xyDataType += ';';
        end;
      end
      // f.e.: BYTE ARRAY BYTES=[10 20 30 40]
      // f.e.: CARD ARRAY BYTES=[1000 23504 30000 65221]
      else begin
        if (Pos(',', buf) > 0) or varPtr.isByteArrayNoSpace then begin
          //buf := QuotedStr(ExtractText(buf, '[', ']'));
          //buf := '1 2 3 4';
          params := buf.Split(',');
          if High(params) > 0 then begin
            buf := '';
            for j := 0 to High(params) do begin
              buf += params[j] + ',';
            end;
          end;
          buf := ReplaceStr(buf, '],', '');
          xyDataType := vars.Names[i] + ' : array[0..' + IntToStr(High(params)) + ']' +
                             ' of ' + dataType + ' = (' + buf + ');';
        end
        else begin
          if len = '' then len := '255';
          xyDataType := vars.Names[i] + ' : array[0..' + len + '] of ' +
                        dataType + ' absolute ' + buf + ';';
        end;
      end;
    end
    // TYPE variable declaration
    else if not isVar and VarValue(2, i, _VAR_TYPE_REC) then begin
      isVarDecl := true;
      isType := true;
      xyDataType := vars.Names[i] + ' = record';
    end
    // Pointer variable declaration
    else if VarValue(2, i, _VAR_POINTER) then begin
      isVarDecl := true;
      //^byte, ^card, ^int
      xyDataType := vars.Names[i] + ' : ^' + xyDataType + ';';
    end;

    if isType and VarValue(3, i, IntToStr(varPtr.typeRecVarCnt)) then begin
      code.Add('  ' + xyDataType);
      code.Add('  end;  // type');
      isType := false;
    end
    else if isVarDecl then begin
      code.Add('  ' + xyDataType);
    end;
    buf := vars[i];
    vars[i] := Copy(buf, 1, Length(buf) - 1) + '1';
  end;

  if (vars.Count > 0) and varPtr.isVarXY and
     not procML.isAsm and (prgPtr.strProcName <> '') then
  begin
    code.Add('begin  // 1');
    prgPtr.isStartBegin := true;
    prgPtr.isCheckVar := true;
    //prgPtr.strCheckProcName := prgPtr.strProcName;
    if (code.IndexOf('begin  // 2') >= 0) and (tempProc = prgPtr.strProcName) then begin
      code.Delete(code.IndexOf('begin  // 2'));
    end;
  end
  else if (vars.Count > 0) and not varPtr.isVarXY and prgPtr.isVarArray and
          not prgPtr.isStartBegin and (prgPtr.strProcName <> '') then
  begin
    code.Add('begin  // 2');
    prgPtr.isStartBegin := true;
    prgPtr.isCheckVar := true;
    tempProc := prgPtr.strProcName;
  end
  else if (prgPtr.strProcName <> '') and
          not procML.isAsm and not prgPtr.isStartBegin then
  begin
    code.Add('begin  // 3');
    prgPtr.isStartBegin := true;
  end;
end;

{------------------------------------------------------------------------------
 Description: Check Action! PROCedure/FUNCtion parameters
 -----------------------------------------------------------------------------}
function CheckParams(offset, paramCnt : byte; procName, param, temp : string) : string;
var
  paramType : string[1];
begin
  paramType := ExtractDelimited(
    offset + 2, procParams.ValueFromIndex[procParams.IndexOfName(procName)], [';']);
  param := Trim(param);

  if param[1] = '''' then begin
    //params[1] := Char(params[1][2]);
    param := IntToStr(Ord(param[2]));
  end;

  // Check parameter data type
  // string
  if paramType = '1' then begin
    if param[1] = '"' then begin
      param := '''' + ExtractText(param, '"', '"') + '''';
      if (offset > 0) and (offset < paramCnt) then temp += ', ';
    end
    else begin
      if (offset > 0) and (offset < paramCnt) then temp += ', ';
      param := Extract(1, param, ')');
    end;
    temp += param;
  end
  // BYTE
  else if paramType = '2' then begin
    if (offset > 0) and (offset < paramCnt) then temp += ', ';
    if offset = paramCnt - 1 then begin
      param := ReplaceStr(param, '(', '[');
      param := ReplaceStr(param, ')', ']');
    end;
    temp += param;
  end
  // INT or CARD data type
  else if (paramType = '3') or (paramType = '4') then begin
    if (offset > 0) and (offset < paramCnt) then temp += ', ';
    if offset = paramCnt - 1 then begin
      param := ReplaceStr(param, '(', '[');
      param := ReplaceStr(param, ')', ']');
    end;

    if varPtr.isPointerAddress then begin
      varPtr.isPointerAddress := false;
      param := 'word(' + param + ')'
    end;

    temp += param;
  end;

  result := temp;
end;

{------------------------------------------------------------------------------
 Description: Check EOF (end of line) statement
 -----------------------------------------------------------------------------}
function CheckEOF(stmt : string) : string;
var
  temp : string;
begin
  if (Pos('EOF(', UpperCase(stmt)) > 0) or
     (Pos('EOF[', UpperCase(stmt)) > 0) then
  begin
    //EOF(1)=0
    if Pos('=', UpperCase(stmt)) > 0 then begin
      temp := Extract(2, stmt, '=');
      if temp = '0' then begin
        stmt := 'not eof(f)';
      end
      else begin
        stmt := 'eof(f)';
      end;
    end
    else begin
      stmt := 'eof(f)';
    end;
  end
  else begin
    temp := Extract(1, stmt, '(');
    //writeln('temp EOF = ', temp);
    if ((vars.IndexOfName(temp) >= 0) and
        (VarValue(2, vars.IndexOfName(temp), _VAR_BYTE_ARRAY) or
         VarValue(2, vars.IndexOfName(temp), _VAR_CARD_ARRAY))) or
       (funcs.IndexOfName(temp) >= 0) then
    begin
      stmt := ReplaceStr(stmt, '(', '[');
      stmt := ReplaceStr(stmt, ')', ']');
    end;
  end;

  result := stmt;
end;

{------------------------------------------------------------------------------
 Description: Check machine language opcodes (1-byte and 2-byte pairs)
 -----------------------------------------------------------------------------}
procedure AsmBytes(temp : string);
var
  params : TStringArray;
  temp02 : string;
  j : byte;
begin
  if Pos('$', temp) > 0 then begin
    if Length(temp) > 3 then begin
      params := temp.Split('$');
      if High(params) > 0 then begin
        for j := 1 to High(params) do begin
          temp02 := '$' + params[j];
          if Length(params[j]) > 3 then begin
            temp02 := '$' + Copy(params[j], 3, 2) + ' $' + Copy(params[j], 1, 2);
          end;
          procML.strAsm += temp02 + ' ';
        end;
      end
      else begin
        temp := '$' + Copy(temp, 4, 2) + ' $' + Copy(temp, 2, 2);
        procML.strAsm := temp + ' ';
      end;
    end
    else begin
      procML.strAsm += temp + ' ';
    end;
  end
  else begin
    if Length(temp) < 3 then begin
      temp := '$' + IntToHex(StrToInt(temp), 2);
    end
    else begin
      if IsNumber(temp[1]) then begin
        temp := IntToHex(StrToInt(temp), 4);
        temp := '$' + Copy(temp, 3, 2) + ' $' + Copy(temp, 1, 2);
      end
      else begin
      end;
    end;
    procML.strAsm += temp + ' ';
  end;
end;

{------------------------------------------------------------------------------
 Description: Reset global variables
 -----------------------------------------------------------------------------}
procedure ResetVar;
begin
  varPtr.isVarStart := false;
  varPtr.isDataType := false;
  varPtr.isParamVarOver := false;
  varPtr.isVarEnd := false;
  varPtr.isArrayDataType := false;
  varPtr.isByteArrayNoSpace := false;
  varPtr.isTypeDataType := false;
  varPtr.typeDataTypeVar := '';
  varPtr.isTypeRecVarLast := false;
  varPtr.typeRecVarCnt := 0;
  varPtr.isPointerAddress := false;
  varPtr.isByteArray := false;
  varPtr.isCardArray := false;
  prgPtr.isProc := false;
  prgPtr.isProcBegin := false;
  prgPtr.isProcName := false;
  prgPtr.strProcName := '';
  prgPtr.isProcAddr := false;
  prgPtr.isFuncAsm := false;
  varPtr.isFunc := false;
  prgPtr.isBegin := false;
  prgPtr.isVarArray := true;
  varPtr.isVarXY := false;
  prgPtr.isCheckVar := false;
  branchPtr.forCnt := 0;
  branchPtr.whileCnt := 0;
  prgPtr.isStartBegin := false;
  varCnt := 0;
end;

{------------------------------------------------------------------------------
 Description: Handle/parse Action! line of source code listing
 -----------------------------------------------------------------------------}
procedure Src(line : string; lineNum : LongInt);
var
  asmOpcode : array[0..3] of string[10] =
    ('lda', 'ldx', 'ldy', 'mva');
  actionVar : array[3..15] of string[3] =
    ('a3', 'a4', 'a5', 'a6', 'a7', 'a8', 'a9', 'a10', 'a11', 'a12', 'a13', 'a14', 'a15');
  paramsAsm : string = '';
  asmOpcodeCnt : byte = 0;
  asmcnt : byte = 0;
  k, i, j : byte;
  offset : integer;
  temp, temp01, temp02, temp03, temp04, temp05, temp06 : string;
  procName : string;
  paramCnt : byte;
  params2 : string;
  params : TStringArray;
  paramsEx : TStringArray;
  funcVar : string;
  op : TStringList;
  cnt : byte = 0;
begin
  op := TStringlist.create;
  oper.Clear;

  temp := Strip(line, ' ');

  // Check for Action! keywords
  offset := keywords.IndexOfName(temp);
  if offset >= 0 then begin  //and (offset < 65535) then begin
    if UpperCase(temp) = 'EXIT' then begin
      code.Add('  break;');
      Exit;
    end;

    // The keyword is a branch
    k := StrToInt(ExtractDelimited(1, keywords.ValueFromIndex[offset], [';']));
    if k = 1 then begin
      // IF branch
      if (UpperCase(temp) = 'IF') then begin  //or (UpperCase(temp) = 'IF(') then begin
        branchPtr.isIfThen := true;
        branchPtr.isIfThenInProgress := true;
        branchPtr.ifThenCode := '  if ';
        branchPtr.isIfThenNext := false;
        branchPtr.isEndIfNext := false;
        branchPtr.isElseNext := false;
        branchPtr.isElseIfNext := false;
      end
      else if (UpperCase(temp) = 'THEN') and branchPtr.isIfThenNext then begin
        branchPtr.ifThenCode += ' then begin';  // (* 1 *)
        code.Add(branchPtr.ifThenCode);
        branchPtr.ifThenCode := '';
        branchPtr.isEndIfNext := true;
        branchPtr.isIfThenInProgress := false;
      end
      // ELSE branch
      else if (UpperCase(temp) = 'ELSE') then begin //and prgPtr.isElseNext then begin
        branchPtr.ifThenCode := '  else begin';
        code.Add('  end');
        code.Add(branchPtr.ifThenCode);
        branchPtr.ifThenCode := '';
        branchPtr.isEndIfNext := true;
      end
      else if UpperCase(temp) = 'ELSEIF' then begin
        branchPtr.isIfThen := true;
        branchPtr.isIfThenInProgress := true;
        branchPtr.ifThenCode := '  end' + LineEnding + '  else if ';
        branchPtr.isIfThenNext := false;
        branchPtr.isEndIfNext := false;
        branchPtr.isElseNext := false;
        branchPtr.isElseIfNext := false;
      end
      else if UpperCase(Trim(temp)) = 'FI' then begin
        code.Add('  end;  // if');
        branchPtr.isIfThen := false;
        branchPtr.isIfThenNext := false;
        branchPtr.isEndIfNext := false;
        branchPtr.ifThenCode := '';
      end
      // FOR branch
      else if UpperCase(temp) = 'FOR' then begin
        branchPtr.isFor := true;
        branchPtr.forCode := '  for ';
        branchPtr.isForToNext := false;
        branchPtr.isForDoNext := false;
        branchPtr.isForOdNext := false;
        Inc(branchPtr.forCnt);
      end
      else if (UpperCase(temp) = 'TO') and branchPtr.isForToNext then begin
        //prgPtr.forCode += ' to ';
        branchPtr.isForDoNext := true;
        //branchPtr.isForToNext := false;
        //code.Add(prgPtr.forCode);
        //prgPtr.forCode := '';
      end
      else if (UpperCase(temp) = 'DO') and
              branchPtr.isForDoNext and not branchPtr.isForOdNext then
      begin
        branchPtr.forCode += ' do begin';
        branchPtr.isForOdNext := true;
        code.Add(branchPtr.forCode);
        branchPtr.forCode := '';
      end
      else if branchPtr.isForOdNext and (UpperCase(temp) = 'OD') then begin
        code.Add('  end;  // for');
        Dec(branchPtr.forCnt);
        if branchPtr.forCnt = 0 then begin
          branchPtr.isFor := false;
          branchPtr.isForToNext := false;
          branchPtr.isForDoNext := false;
          branchPtr.isForOdNext := false;
        end;
      end
      // WHILE branch
      else if UpperCase(temp) = 'WHILE' then begin
        branchPtr.isWhile := true;
        branchPtr.whileCode := '';
        branchPtr.isWhileDoNext := true;
        branchPtr.isWhileOdNext := false;
        Inc(branchPtr.whileCnt);
      end
      else if (UpperCase(temp) = 'DO') and branchPtr.isWhileDoNext then begin
        branchPtr.whileCode += ' do begin';
        branchPtr.isWhileOdNext := true;
        code.Add(branchPtr.whileCode);
        branchPtr.whileCode := '';
      end
      else if branchPtr.isWhileOdNext and (UpperCase(temp) = 'OD') then begin
        code.Add('  end;  // while');
        Dec(branchPtr.whileCnt);
        if branchPtr.whileCnt = 0 then begin
          branchPtr.isWhile := false;
          branchPtr.isWhileDoNext := false;
          branchPtr.isWhileOdNext := false;
        end;
      end
      else if (UpperCase(temp) = 'DO') then begin
        branchPtr.isDoOd := true;
        code.Add('  repeat');
      end
      else if (UpperCase(temp) = 'UNTIL') and branchPtr.isDoOd then begin
        branchPtr.isDoOd := false;
        branchPtr.isUntil := true;
        branchPtr.untilCode := '';
      end
      else if (UpperCase(temp) = 'OD') and branchPtr.isDoOd then begin
        branchPtr.isDoOd := false;
        // Undefinite loop
        code.Add('  until 0 = 1;');
      end
      else if (UpperCase(temp) = 'OD') and branchPtr.isUntil then
      begin
        code.Add('  until ' + branchPtr.untilCode + ';');
      end
    end
  end
  // Check for variable assignment statement
  else if (Pos('=', temp) > 0) and
          not branchPtr.isIfThenInProgress then
  begin
    // Check if equal character (=) exists in comments (between string quotes "" in PROC or FUNC)
    if (Pos('=', temp) > 1) and
       (Pos('"', temp) > 0) and
       (Pos('=', temp) > Pos('"', temp)) then
    begin
      // Handle PROCedures with string parameters
      if Pos('(', temp) > 0 then begin
        // PROCedure name
        procName := UpperCase(Extract(1, temp, '('));
        // PROCedure parameters
        //params2 := Extract(2, line, '(', []);
        params2 := ExtractText(line, '(', ')');
        // Check if FUNCtion is assigned to some variable
        if (Pos('=', procName) > 0) then begin
          funcVar := Extract(1, procName, '=');
          procName := Extract(2, procName, '=');
        end;
      end;
    end
    // Pointer variable value assignment
    else if Pos('^=', temp) > 0 then begin
      temp02 := Extract(1, temp, '^');
      params2 := Extract(2, temp, '=');
      if VarValue(2, vars.IndexOfName(temp02), _VAR_POINTER) then begin
        code.Add('  ' + temp02 + '^ := ' + params2 + ';');
      end;
    end
    // Double variable assignment
    else if Pos('==', temp) > 0 then begin
      SplitStr(temp, '==', aList);

      if Pos('{MOD}', aList[1]) > 0 then begin
        params2 := aList[0];
        SplitStr(temp, '{MOD}', aList);
        temp := ReplaceStr(aList[1], '{MOD}', '');
        code.Add('  ' + params2 + ' := ' + params2 + ' MOD ' + temp + ';');
      end
      else if Pos('{AND}', aList[1]) > 0 then begin
        params2 := aList[0];
        SplitStr(temp, '{AND}', aList);
        temp := ReplaceStr(aList[1], '{AND}', '');
        code.Add('  ' + params2 + ' := ' + params2 + ' AND ' + temp + ';');
      end
      else if Pos('{OR}', aList[1]) > 0 then begin
        params2 := aList[0];
        SplitStr(temp, '{OR}', aList);
        temp := ReplaceStr(aList[1], '{OR}', '');
        code.Add('  ' + params2 + ' := ' + params2 + ' OR ' + temp + ';');
      end
      else if Pos('{XOR}', aList[1]) > 0 then begin
        params2 := aList[0];
        SplitStr(temp, '{XOR}', aList);
        temp := ReplaceStr(aList[1], '{XOR}', '');
        code.Add('  ' + params2 + ' := ' + params2 + ' XOR ' + temp + ';');
      end
      else if Pos('{LSH}', aList[1]) > 0 then begin
        params2 := aList[0];
        SplitStr(temp, '{LSH}', aList);
        temp := ReplaceStr(aList[1], '{LSH}', '');
        code.Add('  ' + params2 + ' := ' + params2 + ' SHL ' + temp + ';');
      end
      else if Pos('{RSH}', aList[1]) > 0 then begin
        params2 := aList[0];
        SplitStr(temp, '{RSH}', aList);
        temp := ReplaceStr(aList[1], '{RSH}', '');
        code.Add('  ' + params2 + ' := ' + params2 + ' SHR ' + temp + ';');
      end
      else begin
        temp := aList[1][1];
        params2 := Extract(2, aList[1], aList[1][1]);
        temp02 := '';
        // DL(4)==+1
        if Pos('(', aList[0]) > 0 then begin
          temp02 := aList[0];
          aList[0] := Extract(1, aList[0], '(');
        end;

        //writeln('temp = ', temp, ' params2 = ', params2,
        //        ' temp02 = ', temp02, ' alist[0] = ', aList[0]);

        if vars.IndexOfName(aList[0]) >= 0 then begin
          // Pointer variable assigned to memory address
          if VarValue(2, vars.IndexOfName(aList[0]), _VAR_POINTER) and (aList[1][1] = '@') then
          begin
            //prgPtr.isPointerAddress := true;
            //code.Add('  ' + aList[0] + ' := ' + aList[1] + ';');
          end
          else begin
            // SCREEN=SAVMSC
            // SCREEN := pointer(word(@SAVMSC));
            // SCREEN := pointer(SAVMSC);
            if VarValue(2, vars.IndexOfName(aList[0]), _VAR_BYTE_ARRAY) and (temp02 = '') then
            begin
              //code.Add('  ' + aList[0] + ' := pointer(word(@' + aList[0] + ') ' +
              //         temp[1] + ' ' + params2 + ');  // 1');
              if temp[1] = '+' then
                code.Add('  Inc(' + aList[0] + ', ' + params2 + ');')
              else if temp[1] = '-' then
                code.Add('  Dec(' + aList[0] + ', ' + params2 + ');')
            end
            else begin
              if temp02 <> '' then begin
                aList[0] := temp02;
                aList[0] := ReplaceStr(aList[0], '(', '[');
                aList[0] := ReplaceStr(aList[0], ')', ']');
              end;
              case temp[1] of
                '+' : begin
                  if params2 = '1' then
                    code.Add('  Inc(' + aList[0] + ');')
                  else begin
                    code.Add('  Inc(' + aList[0] + ', ' + params2 + ');');
                  end;
                end;
                '-' : begin
                  if params2 = '1' then
                    code.Add('  Dec(' + aList[0] + ');')
                  else begin
                    code.Add('  Dec(' + aList[0] + ', ' + params2 + ');');
                  end;
                end;
                else begin
                  code.Add('  ' + aList[0] + ' := ' + aList[0] + ' ' +
                           temp[1] + ' ' + params2 + ';');
                end;
              end;
            end;
          end;
        end;
      end
    end
    // Standard variable assignment
    else begin
      // Variable assignment
      params := temp.Split('=');
      if High(params) > 0 then begin
        temp02 := Extract(1, params[0], '(');
        temp03 := Extract(1, params[1], '(');
        temp04 := Extract(1, params[0], '.');
        temp05 := Extract(2, params[0], '.');

        // FUNCtion in assignment (right side)
        //temp06 := Extract(2, params[1], '(');
//        temp06 := params[1];

//        writeln('t = ', temp, ' / t02 = ', temp02, ' / t03 = ', temp03,
//                ' / t04 = ', temp04, ' / t05 = ', temp05, ' / t06 = ', temp06);

        // FUNCtion as an assignment
        if funcs.IndexOfName(temp03) >= 0 then begin
          // FUNCtion name
          funcVar := temp02;
          procName := UpperCase(Extract(1, temp03, '('));
            // PROCedure parameters
            //params2 := Extract(2, line, '(', []);
          params2 := ExtractText(line, '(', ')');
        end
        // Check Action! predeclared variables
        else if funcs.IndexOfName(temp02) >= 0 then begin
          if funcs.Names[funcs.IndexOfName(temp02)] = 'Color' then begin
            code.Add('  SetColor(' + temp03 + ');');
            prgPtr.colorValue := temp03;
          end
        end
        // Standard variable assignment
        else if (vars.IndexOfName(temp02) >= 0) or (vars.IndexOfName(temp04) >= 0) then begin
          params[0] := ReplaceStr(params[0], '(', '[');
          params[0] := ReplaceStr(params[0], ')', ']');
          // ENTRY=DATA+10
          // ENTRY.NUM1=30
          if (vars.IndexOfName(temp04) >= 0) and
             VarValue(2, vars.IndexOfName(temp04), _VAR_POINTER) then
          begin
            if (vars.IndexOfName(temp04) >= 0) and (Pos('.', temp02) > 0) then begin
              //ENTRY.NUM1=30
              if (vars.IndexOfName(temp05) >= 0) and (ExtractDelimited(
                    6, vars.ValueFromIndex[vars.IndexOfName(temp05)], [';']) <> '') then
              begin
                params[0] := temp04 + '^.' + temp05;
              end
              //ENTRY := DATA+10;
              //ENTRY := pointer(word(@data));
              //Inc(entry, 5);
            end
            else begin
              paramsEx := params[1].Split('+');
              if High(paramsEx) > 0 then begin
                params[0] := temp04 + ' := pointer(word(@' + paramsEx[0] + '));' + LineEnding +
                             '  Inc(' + temp04 + ', ' + paramsEx[1] + ');';
                code.Add('  ' + params[0]);
                op.Free;
                exit;
              end;
            end;
          end;

          // Check for FUNCtions
          temp03 := UpperCase(Extract(1, params[1], '('));
          if myFuncs.IndexOfName(temp03) >= 0 then begin
            temp04 := UpperCase(Extract(2, params[1], '('));
            params[1] := temp03 + 'Func(' + temp04;
          end
          // Other variables
          else begin
            // Split expression variables and values separated by operators
            params[1] += '+1';
            paramsEx := params[1].Split(operators);
            temp04 := '';
            if High(paramsEx) >= 0 then begin
              // Check operators in the operand
              CheckOper('+', params[1]);
              CheckOper('-', params[1]);
              CheckOper('*', params[1]);
              CheckOper('{DIV}', params[1]);  // Integer division, not float number division ('/')
              CheckOper('{MOD}', params[1]);
              CheckOper('{AND}', params[1]);
              CheckOper('{OR}', params[1]);
              CheckOper('{XOR}', params[1]);
              CheckOper('{RSH}', params[1]);
              CheckOper('{LSH}', params[1]);
              temp04 := '';
              if oper.Count > 0 then begin
                for j := 0 to 255 do begin
                  for i := 0 to oper.Count - 1 do begin
                    if StrToInt(ExtractDelimited(1, oper.ValueFromIndex[i], [';'])) = j then begin
                      op.Add(oper.Names[i]);
                      break;
                    end;
                  end;
                end;
              end;
              temp04 := '';
              for i := 0 to High(paramsEx) do begin
                if Pos('(', paramsEx[i]) > 0 then begin
                  // Assignment is ARRAY BYTE or ARRAY CARD variable
                  temp03 := Extract(1, paramsEx[i], '(');
                  if (vars.IndexOfName(temp03) >= 0) and
                     (VarValue(2, vars.IndexOfName(temp03), _VAR_BYTE_ARRAY) or
                      VarValue(2, vars.IndexOfName(temp03), _VAR_CARD_ARRAY)) then
                  begin
                    paramsEx[i] := ReplaceStr(paramsEx[i], '(', '[');
                    paramsEx[i] := ReplaceStr(paramsEx[i], ')', ']');
                  end;
                end;
                temp04 += paramsEx[i];
                if i < High(paramsEx) then begin
                  temp04 += op[i];
                end;
              end;
              params[1] := temp04;
            end;
          end;

          // videoPtr := pointer(DPeek(88));
          // Pointer variable assigned to memory address
          if (vars.IndexOfName(temp02) >= 0) and
             VarValue(2, vars.IndexOfName(temp02), _VAR_POINTER) and
             (params[1][1] = '@') then
          begin
            varPtr.isPointerAddress := true;
            code.Add('  ' + params[0] + ' := ' + params[1] + ';');
          end
          //n2 = n1 /// n2 := word(@n1);
          else if (vars.IndexOfName(temp02) >= 0) and
                  (vars.IndexOfName(temp03) >= 0) and
                  VarValue(2, vars.IndexOfName(temp02), _VAR_MEM_ADDR) and
                  VarValue(2, vars.IndexOfName(temp03), _VAR_BYTE_ARRAY) then
          begin
            code.Add('  ' + params[0] + ' := word(@' + params[1] + ');');
          end
          // PROCedure as the assignment
          else if (vars.IndexOfName(temp02) >= 0) and
                  (myProcs.IndexOfName(temp03) >= 0) and
                  VarValue(2, vars.IndexOfName(temp02), _VAR_MEM_ADDR) then
          begin
            code.Add('  ' + params[0] + ' := word(@' + temp03 + 'Proc);');
          end
          // BYTE ARRAY var = mem addr.
          // SCREEN := pointer(word(@SAVMSC));
          // SCREEN=SAVMSC
          else if (vars.IndexOfName(temp02) >= 0) and (vars.IndexOfName(temp03) >= 0) and
                  VarValue(2, vars.IndexOfName(temp02), _VAR_BYTE_ARRAY) and
                  VarValue(2, vars.IndexOfName(temp03), _VAR_MEM_ADDR) then
          begin
            //code.Add('  ' + temp02 + ' := pointer(word(@' + temp03 + '));
            code.Add('  ' + temp02 + ' := pointer(' + temp03 + ');');
          end
          // Standard assignment
          else begin
            params[1] := ReplaceStr(params[1],'{DIV}',' div ');
            params[1] := ReplaceStr(params[1],'{MOD}',' MOD ');
            params[1] := ReplaceStr(params[1],'{AND}',' AND ');
            params[1] := ReplaceStr(params[1],'{OR}',' OR ');
            params[1] := ReplaceStr(params[1],'{LSH}',' SHL ');
            params[1] := ReplaceStr(params[1],'{RSH}',' SHR ');
            params[1] := ReplaceStr(params[1],'{XOR}',' XOR ');
            if not varPtr.isVarStart and prgPtr.isStartBegin then begin
              // F.e. 'A
              if params[1][1] = '''' then begin
                params[1] := IntToStr(Ord(params[1][2]));
              end;
              if (branchPtr.isFor and branchPtr.isForToNext and not branchPtr.isForDoNext) then
              begin
              end
              else if branchPtr.isUntil and not branchPtr.isDoOd then begin
              end
              else begin
                if branchPtr.isWhile and branchPtr.isWhileDoNext and
                   not branchPtr.isWhileOdNext then
                begin
                end
                else begin
                  // Check if assignment is BYTE ARRAY or CARD ARRAY with FUNCtion as index element
                  // Action! dir = new_dir(Rand(8))
                  // MP!     dir := new_dir[Rand[8]];
                  temp01 := ExtractText(params[1], '[', ']');
                  temp02 := ExtractText(temp01, '[', ']');
                  temp01 := Extract(1, temp01, '[');
                  //writeln('extracted text = ', temp01);
                  if funcs.IndexOfName(temp01) >= 0 then begin
                    if UpperCase(temp01) = 'RAND' then
                      temp04 := 'Random'
                    else if UpperCase(temp01) = 'PEEK' then
                      temp04 := 'Peek'
                    else if UpperCase(temp01) = 'PEEKC' then
                      temp04 := 'DPeek'
                    else if UpperCase(temp01) = 'VALB' then
                      temp04 := 'StrToInt'
                    else if UpperCase(temp01) = 'VALC' then
                      temp04 := 'StrToInt'
                    else if UpperCase(temp01) = 'VALI' then begin
                      temp04 := 'StrToInt';
                    end;
                    temp03 := Extract(1, params[1], '[');
                    code.Add('  ' + params[0] + ' := ' + temp03 +
                             '[' + temp04 + '(' + temp02 + ')];');
                  end
                  // Normal assignment
                  else begin
                    code.Add('  ' + params[0] + ' := ' + params[1] + ';');  // ' + line + ' *** ' + inttostr(linenum));
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end
  // Start of inline machine language
  else if (Pos('[', temp) > 0) and
          not procML.isAsm and
          not varPtr.isTypeDataType then
  begin
    procML.isAsm := true;

    if prgPtr.isFuncAsm then begin
      //  lda a_reg
      //  ldx x_reg
      //  ldy y_reg
      //  mva a3_par $a3
      //  mva a4_par $a4
      //  mva a5_par $a5
      for i := 0 to vars.Count - 1 do begin
        if UpperCase(ExtractDelimited(
             5, vars.ValueFromIndex[i], [';'])) = UpperCase(prgPtr.strProcLocalName) then
        begin
          if asmOpcodeCnt > 2 then begin
            asmOpcodeCnt := 3;
            paramsAsm += '  ' + asmOpcode[asmOpcodeCnt] + ' ' + vars.Names[i] +
                         ' $' + actionVar[asmcnt + 3] + LineEnding;
            Inc(asmcnt);
          end
          else begin
            paramsAsm += '  ' + asmOpcode[asmOpcodeCnt] + ' ' + vars.Names[i] + LineEnding;
          end;
          Inc(asmOpcodeCnt);
        end;
      end;
      procML.strAsm := '  asm' + LineEnding +
                       '  {' + LineEnding +
                       paramsAsm +
                       '    .by ';
    end
    else begin
      procML.strAsm := '  asm' + LineEnding +
                       '  {' + LineEnding +
                       '    .by ';
    end;

    // Machine language mnemonics on the same line
    if Length(temp) > 1 then begin
      temp02 := Extract(2, temp, '[');
      temp02 := ReplaceStr(temp02, ']', '');
      AsmBytes(temp02);
      if Pos(']', temp) > 0 then begin
        if prgPtr.isFuncAsm and varPtr.isFunc then begin
          procML.strAsm += LineEnding + '  mva #0 result';
          //  procML.strAsm += #13#10'  .by $60';
        end;
        procML.strAsm += LineEnding + '  };';
        code.Add(procML.strAsm);
        procML.isAsm := false;
        procML.strAsm := '';
        if prgPtr.isFuncAsm then begin
          code.Add('end;  // 1');
          ResetVar;
        end;
      end;
    end;
// [
//  $A9 $90 $3E $02C6 $0 $60
//]
    op.Free;
    Exit;
  end
  // End of inline machine language
  else if (Pos(']', temp) > 0) and procML.isAsm then begin
    // Machine language mnemonics on the same line
    if Length(temp) > 1 then begin
      temp02 := Extract(1, temp, ']');
      AsmBytes(temp02);
    end;

    if prgPtr.isFuncAsm and varPtr.isFunc then begin
      procML.strAsm += LineEnding + '  mva #0 result';
      //  procML.strAsm += #13#10'  .by $60';
    end;

    procML.strAsm += LineEnding + '  };';
    code.Add(procML.strAsm);
    procML.isAsm := false;
    procML.strAsm := '';

    if prgPtr.isFuncAsm then begin
      //if varPtr.isFunc then code.Add('  result := 10;');
      code.Add('end;  // 2');
    end;

    prgPtr.isProc := false;
    prgPtr.isProcBegin := false;
    prgPtr.isFuncAsm := false;
    varPtr.isFunc := false;
    prgPtr.isBegin := false;
    branchPtr.forCnt := 0;
    branchPtr.whileCnt := 0;
    varCnt := 0;

    op.Free;
    Exit;
  end
  // Inline machine language
  else if procML.isAsm then begin
    AsmBytes(temp);
//    if Length(temp) > 3 then begin
//      temp := '$' + Copy(temp, 4, 2) + ' $' + Copy(temp, 2, 2);
//    end;
    //procML.strAsm += temp + ' ';
    Exit;
  end
  // Check for PROCedure
  else if (Pos('(', temp) > 0) and not varPtr.isFunc then begin
    // PROCedure name
    procName := UpperCase(Extract(1, temp, '('));
    // PROCedure parameters
    params2 := ExtractText(line, '(', ')');
    // Check if FUNCtion is assigned to some variable
    if (Pos('=', procName) > 0) then begin
      funcVar := Extract(1, procName, '=');
      procName := Extract(2, procName, '=');
      Code.add('func ' + temp);
    end
    // FUNC in IF condition
    else begin
      if branchPtr.isIfThenInProgress then begin
        branchPtr.ifTempCode := '';
        //prgPtr.ifThenCode += 'value (* test *) ';
      end;
    end;
  end
  else if varPtr.isFunc and
          (Pos('(', temp) > 0) and
          (Pos('RETURN', UpperCase(temp)) > 0) then
  begin
    params2 := ExtractText(line, '(', ')');
    Code.add('  result := ' + params2 + ';');
    Code.add('end;  // 3');
    ResetVar;
    op.Free;
    Exit;
  end;

  if branchPtr.isWhileDoNext and not branchPtr.isWhileOdNext then begin
    temp := CheckEOF(temp);
    // In case only one command exists in while condition then it must be checked automatically
    // if condition is true (f.e. i > 0)
    if vars.IndexOfName(temp) >= 0 then begin
      temp += ' > 0'
    end;
    branchPtr.whileCode += ' ' + temp;  // + ' (* w1 *) ';
  end;

  // End of PROCedure or FUNCtion
  if (UpperCase(Trim(line)) = 'RETURN') then
     //or (prgPtr.isFuncAsm and (Pos(']', line) > 0)) then
  begin
    if branchPtr.isIfThen then begin
      code.Add('exit;' + LineEnding);
      branchPtr.isIfThen := false;
      branchPtr.isIfThenNext := false;
      branchPtr.isEndIfNext := false;
      branchPtr.ifThenCode := '';
    end
    else begin
      code.Add('end;  // 4' + LineEnding);
    end;
    ResetVar;
    op.Free;
    Exit;
  end;

  // PROCedure is found, check the parameters
  if (procs.IndexOfName(procName) >= 0) or (myProcs.IndexOfName(procName) >= 0) then begin
    // Paramater count
    paramCnt := 0;
    if procParams.IndexOfName(procName) >= 0 then begin
      if UpperCase(procName) = 'PRINTF' then
        paramCnt := 255
      else begin
        paramCnt := StrToInt(ExtractDelimited(
          1, procParams.ValueFromIndex[procParams.IndexOfName(procName)], [';']));
      end;
    end;
    if (paramCnt > 0) and (paramCnt < 255) then begin
      params := params2.Split(',', '"', '"');
      params2 := '';
      // Iterate through parameters
      for i := 0 to paramCnt - 1 do begin
        //writeln('params[i] = ', params[i]);
        //params[i] := ReplaceStr(params[i], '(', '[');
        //params[i] := ReplaceStr(params[i], ')', ']');
        params2 := CheckParams(i, paramCnt, procName, params[i], params2);
      end;
    end
    // No parameters
    else if paramCnt = 0 then begin
      params2 := '';
    end;

    {$i procedures.inc}
  end
  // FUNCtion is found, check the parameters
  else if (funcs.IndexOfName(procName) >= 0) or (myFuncs.IndexOfName(procName) >= 0) then begin
    // Paramater count
    paramCnt := 0;
    if funcs.IndexOfName(procName) >= 0 then begin
//       paramCnt := StrToInt(ExtractDelimited(
//         2, funcs.ValueFromIndex[funcs.IndexOfName(procName)], [';']));
      paramCnt := StrToInt(ExtractDelimited(
        1, procParams.ValueFromIndex[procParams.IndexOfName(procName)], [';']));
    end;
//     else if myFuncs.IndexOfName(procName) >= 0 then begin
//       paramCnt := StrToInt(ExtractDelimited(
//         2, myFuncs.ValueFromIndex[myFuncs.IndexOfName(procName)], [';']));
//     end;

    if paramCnt > 0 then begin
      params := params2.Split(',', '"', '"');
      params2 := '';
      // Iterate through parameters
      for i := 0 to paramCnt - 1 do begin
        //params[i] := ReplaceStr(params[i], '(', '[');
        //params[i] := ReplaceStr(params[i], ')', ']');
        params2 := CheckParams(i, paramCnt, procName, params[i], params2);
      end;
    end
    // No parameters
    else begin
      params2 := '';
    end;

    {$i functions.inc}
  end;

  // Branch statements control
  if (UpperCase(temp) <> 'THEN') and
     branchPtr.isIfThen and
     not branchPtr.isIfThenNext then
  begin
    //prgPtr.ifthenCode += temp;
    branchPtr.isIfThenNext := true;
    //prgPtr.isIfThen := false;
  end
  // Code in IF condition part
  else if branchPtr.isIfThenNext then begin
    // Replace () brackets with [] brackets
    // Bracket '(' is not the first character in condition value
    if temp[1] <> '(' then begin
      temp := ReplaceStr(temp, '(', '[');
      temp := ReplaceStr(temp, ')', ']');
    end;

    temp := ReplaceStr(temp, '{AND}', ' AND ');
    temp := ReplaceStr(temp, '{OR}', ' OR ');
    temp := ReplaceStr(temp, '{XOR}', ' XOR ');
    temp := ReplaceStr(temp, '{LSH}', ' SHL ');
    temp := ReplaceStr(temp, '{RSH}', ' SHR ');
    temp := ReplaceStr(temp, '{MOD}', ' MOD ');
    temp := ReplaceStr(temp, '{DIV}', ' div ');

    // Check special character assignment, f.e. 'T
    if Pos('=', temp) > 0 then begin
      temp02 := Extract(1, temp, '=');
      temp03 := Extract(2, temp, '=');
      if temp03 <> '' then begin
        if temp03[1] = '''' then begin
          //params[1] := Char(params[1][2]);
          temp03 := IntToStr(Ord(temp03[2]));
        end;
        temp := temp02 + '=' + temp03;
      end;
    end;
    if branchPtr.ifTempCode = '' then begin
      temp := CheckEOF(temp);
      if not branchPtr.isFuncInIf then
        branchPtr.ifThenCode += temp;  // If 1 if 2
    end
    //else begin
    //  branchPtr.ifthenCode += branchPtr.ifTempCode + ' (* IF3 *) ';
    //end;
  end
  else if (UpperCase(temp) <> 'TO') and
          branchPtr.isFor and not branchPtr.isForToNext then
  begin
    branchPtr.isForToNext := true;
  end
  else if branchPtr.isForToNext then begin
    //temp := ReplaceStr(temp, 'TO', '');
    temp := ReplaceStr(temp, '=', ':=');
    branchPtr.forCode += ' ' + temp;
  end
  else if branchPtr.isUntil then begin
    temp := CheckEOF(temp);
    branchPtr.untilCode := ' ' + temp;
  end;
  op.Free;
end;

{------------------------------------------------------------------------------
 Description: Check PROCedure/FUNCtion parameters
 -----------------------------------------------------------------------------}
function ParamVarDecl(params : string) : string;
var
  i, j : byte;
  found : integer;
  temp : string = '';
  cnt, varCnt : byte;
  paramsx : string;
  temp02 : string;
  isVar : boolean = false;
  dataTypeList, varList : TStringArray;
begin
  params := Extract(2, params, '(');
  paramTypes := '';
  dataTypeList := params.Split(' ');
  paramCntx := 0;
  cnt := High(dataTypeList);
  for i := 0 to cnt do begin
    // Check for data type declaration
    //varPtr.isVar := false;
    //varPtr.isParamVar := false;
    params := Extract(1, dataTypeList[i], ' ');
    found := dataTypes.IndexOfName(params);
    if found >= 0 then begin
      isVar := true;
      if (UpperCase(params) = 'BYTE') or (UpperCase(params) = 'CHAR') then begin
        varPtr.dataType := 'byte';
        paramsx += ';2';
      end
//       else if UpperCase(params) = 'CHAR' then begin
//         varPtr.dataType := 'byte';
//         paramsx += ';2';
//       end
      else if UpperCase(params) = 'INT' then begin
        varPtr.dataType := 'integer';
        paramsx += ';3';
      end
      else if UpperCase(params) = 'CARD' then begin
        varPtr.dataType := 'word';
        paramsx += ';4';
      end
//       if UpperCase(params) = 'SBYTE' then begin
//         varPtr.isVar := true;
//         varPtr.dataType := 'string';
//       end
      else if UpperCase(params) = 'ARRAY' then begin
        varPtr.arrayDataType := 'string';
        varPtr.isArrayDataType := true;
        varPtr.isDataType := true;
        paramsx += ';5';
      end
      else if UpperCase(params) = 'POINTER' then begin
        varPtr.pointerDataType := 'pointer';
        varPtr.isPointerDataType := true;
        paramsx += ';1';
      end;
    end
    else if isVar then begin
      isVar := false;
      varList := params.Split(',');
      varCnt := High(varList);
      for j := 0 to varCnt do begin
        paramTypes += paramsx;
        temp02 := varList[j];  //Extract(2, varList[j], ' ', []);
        temp += temp02 + ' : ' + varPtr.dataType;
        vars.Add(temp02 + '=' + varPtr.dataType + ';2;0;0;' + prgPtr.strProcLocalName + ';0;0');
        temp += '; ';
      end;
      paramCntx += varCnt + 1;
    end;
  end;
  temp := Trim(temp);
  temp := Copy(temp, 0, length(temp) - 1);
  varPtr.isVar := false;
  result := temp;
end;

{------------------------------------------------------------------------------
 Description: Check the type of PROCedure/FUNCtion and its parameters
 -----------------------------------------------------------------------------}
procedure ProcBlock(line : string);
var
  procName : string;
  params : string;
  found : integer;
  asmOpcode : array[0..3] of string[10] =
    ('lda', 'ldx', 'ldy', 'mva');
  actionVar : array[3..15] of string[3] =
    ('a3', 'a4', 'a5', 'a6', 'a7', 'a8', 'a9', 'a10', 'a11', 'a12', 'a13', 'a14', 'a15');
  paramsAsm : string = '';
  asmOpcodeCnt : byte = 0;
  asmcnt : byte = 0;
  i : byte;
  temp : string;
begin
  // PROCedure name is on the same line as parameters
  if (Length(line) > 1) and (Pos('(', line) > 0) then begin
    procName := UpperCase(Extract(1, line, '('));
    params := UpperCase(Extract(2, line, '('));
    prgPtr.strAsmDecl := '';

    // PROC KBGET=$F302()
    // CARD FUNC MultiplyB=*(BYTE a,x)
    if Pos('=', line) > 0 then begin
      if Pos('*', line) > 0 then
        prgPtr.isFuncAsm := true
      else begin
        prgPtr.isProcAddr := true;
        prgPtr.strAsmDecl := ExtractText(line, '=', '(');
      end;
      procName := Extract(1, procName, '=');
      prgPtr.strProcLocalName := procName;
    end;

    if varPtr.isFunc then begin
      found := myFuncs.IndexOfName(procName);
      if found < 0 then begin
        prgPtr.isProcName := true;
        prgPtr.isProcParams := true;
        prgPtr.procParams := '';
        myFuncs.Add(procName + '=1;' + prgPtr.strAsmDecl);
      end;
    end
    else begin
      found := myProcs.IndexOfName(procName);
      if found < 0 then begin
        prgPtr.isProcName := true;
        prgPtr.isProcParams := true;
        prgPtr.procParams := '';
        myProcs.Add(procName + '=1;' + prgPtr.strAsmDecl);
      end;
    end;
  end;

  // PROCedure declaration statement is finished
  if Pos(')', line) > 0 then begin
    //prgPtr.isVarArray := false;
    prgPtr.isProcParams := false;
    prgPtr.isProc := false;
    // PROCedure with no parameters
    if Pos('()', line) > 0 then begin
      varPtr.isParamVarOver := true;
      paramCntx := 0;

      if prgPtr.isStartBegin then begin
        code.add('end;  // e1')
      end;

      if varPtr.isFunc then begin
        if prgPtr.isFuncAsm then
          code.Add('function ' + procName + 'Func : ' + varPtr.dataType + '; assembler;')
        else
          code.Add('function ' + procName + 'Func : ' + varPtr.dataType + ';');
      end
      else begin
        if prgPtr.isFuncAsm then
          code.Add('procedure ' + procName + 'Proc; assembler;')
        else
          code.Add('procedure ' + procName + 'Proc;');
      end;

      if prgPtr.isFuncAsm then begin
        //code.Add('asm');
        prgPtr.isBegin := true;
      end
      else if prgPtr.isProcBegin and not varPtr.isVarXY then begin
        code.Add('begin  // 4');
        prgPtr.isBegin := true;
        prgPtr.isStartBegin := true;
      end
      else if prgPtr.isProcAddr and (prgPtr.strAsmDecl <> '') then begin
        code.Add('begin');
        code.Add('  asm {');
        code.Add('    jsr ' + prgPtr.strAsmDecl);
        code.Add('    rts');
        code.Add('  };');
        code.Add('end;  // 5');
      end;
    end
    // PROCedure with parameters
    else begin
      params := Extract(1, line, ')');
      prgPtr.procParams += ' ' + params;
      //procName := Extract(2, procName, '(');
      //code.Add('procedure ' + procName + '(' + prgPtr.procParams + ');');

      if prgPtr.isProcAddr or prgPtr.isFuncAsm then begin
        if Pos('=', prgPtr.procParams) > 0 then begin
          procName := Extract(1, prgPtr.procParams, '=');
          //prgPtr.strAsmDecl := ExtractText(line, '=', '(');
        end
      end
      else begin
        procName := Extract(1, prgPtr.procParams, '(');
      end;

      params := Extract(2, prgPtr.procParams, '(');
      //code.Add('procedure ' + prgPtr.procParams + ');');

      if prgPtr.isStartBegin then begin
        code.add('end;  // e2')
      end;

      if varPtr.isFunc then begin
        if prgPtr.isFuncAsm then begin
          code.Add('function ' + procName + 'Func(' + ParamVarDecl(params) + ') : ' +
                   varPtr.dataType + '; assembler;');
        end
        else begin
          code.Add('function ' + procName + 'Func(' + ParamVarDecl(params) + ') : ' +
                   varPtr.dataType + ';');
        end;
      end
      else begin
        if prgPtr.isFuncAsm then begin
          code.Add('procedure ' + procName + 'Proc(' + ParamVarDecl(params) + '); assembler;');
        end
        else begin
          code.Add('procedure ' + procName + 'Proc(' + ParamVarDecl(params) + ');');
        end;
      end;

      varPtr.isParamVarOver := true;

//       if prgPtr.isFuncAsm then begin
//         //code.Add('asm');
//       end
      if prgPtr.isProcBegin and not prgPtr.isFuncAsm then begin
        code.Add('begin  // 5');
        prgPtr.isStartBegin := true;
      end
      else if prgPtr.isProcAddr then begin
        code.Add('begin');
        code.Add('  asm {');
        code.Add('    jsr ' + prgPtr.strAsmDecl);
        // + ExtractDelimited(2, myProcs.ValueFromIndex[myProcs.IndexOfName(procName)], [';']));
        code.Add('    rts');
        code.Add('  };');
        code.Add('end;  // 6');
      end;
    end;
    procParams.Add(procName + '=' + IntToStr(paramCntx) + paramTypes);
    prgPtr.strProcName := procName;
    //prgPtr.strProcLocalName := procName;
  end;
  if prgPtr.isProcName then begin
    prgPtr.procParams += ' ' + line;
  end;

  // Check for machine code opcode
  if (Pos('[', line) > 0) then begin
    procML.isAsm := true;

    if prgPtr.isFuncAsm then begin
      //  lda a_reg
      //  ldx x_reg
      //  ldy y_reg
      //  mva a3_par $a3
      //  mva a4_par $a4
      //  mva a5_par $a5
      for i := 0 to vars.Count - 1 do begin
        if UpperCase(ExtractDelimited(
             5, vars.ValueFromIndex[i], [';'])) = UpperCase(prgPtr.strProcLocalName) then
        begin
          //if VarValue(5, i, UpperCase(prgPtr.strProcLocalName)) then begin
          if asmOpcodeCnt > 2 then begin
            asmOpcodeCnt := 3;
            paramsAsm += '  ' + asmOpcode[asmOpcodeCnt] + ' ' + vars.Names[i] +
                         ' $' + actionVar[asmcnt + 3] + LineEnding;
            Inc(asmcnt);
          end
          else begin
            paramsAsm += '  ' + asmOpcode[asmOpcodeCnt] + ' ' + vars.Names[i] + LineEnding;
          end;
          Inc(asmOpcodeCnt);
        end;
      end;
      procML.strAsm := '  asm' + LineEnding +
                       '  {' + LineEnding +
//                        '  mva CURSOR $a3'#13#10 +
//                        '  mva BACK $a4'#13#10 +
//                        '  mva BORDER $a5'#13#10 +
//                        '  lda X'#13#10 +
//                        '  ldx Y'#13#10 +
//                        '  ldy UPDOWN'#13#10 +
                       paramsAsm +
                       '    .by ';
    end
    else begin
      procML.strAsm := '  asm' + LineEnding +
                       '  {' + LineEnding +
                       '    .by ';
    end;

    // Machine language mnemonics on the same line
    if Length(line) > 1 then begin
      temp := Extract(2, line, '[');
      temp := ReplaceStr(temp, ']', '');
      AsmBytes(temp);
      if Pos(']', line) > 0 then begin
        if prgPtr.isFuncAsm and varPtr.isFunc then begin
          procML.strAsm += LineEnding + '  mva #0 result';
          //  procML.strAsm += #13#10'  .by $60';
        end;
        procML.strAsm += LineEnding + '  };';
        code.Add(procML.strAsm);
        procML.isAsm := false;
        procML.strAsm := '';
        if prgPtr.isFuncAsm then begin
          code.Add('end;  // 7');
          ResetVar;
        end;
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Variable declaration code block
 -----------------------------------------------------------------------------}
procedure VarDeclBlock(line : string);
var
  i, j : byte;
  temp, temp02 : string;
  found : integer;
  params : TStringArray;
  varDeclList : TStringArray;
begin
  if varPtr.isByteArray then begin
    varPtr.byteArray += ', ' + line;
  end
  else if varPtr.isCardArray then begin
    varPtr.cardArray += ', ' + line;
  end;

  // End of predefined values for BYTE ARRAY declaration statement
  if varPtr.isByteArray and (Pos(']', line) > 0) then begin
    if (Pos('],', line) > 0) then begin
      varPtr.dataType := 'byte';
      varPtr.arrayDataType := varPtr.dataType;
      varPtr.isArrayDataType := true;
      varPtr.isDataType := true;
    end
    else begin
      varPtr.isByteArray := false;
      varPtr.isArrayDataType := false;
      prgPtr.isVarArray := false;
    end;

    if (Pos('=', varPtr.byteArray) > 0) then begin
      varPtr.str01 := Extract(1, varPtr.byteArray, '=');
      varPtr.byteArray := Extract(2, varPtr.byteArray, '[');
      varPtr.str01 := StringReplace(varPtr.str01, ', ', '', []);
      varPtr.str01 += '=' + varPtr.dataType + ';4;';
    end;
    vars.Add(varPtr.str01 + varPtr.byteArray + varPtr.str02 +
             ';' + prgPtr.strProcName + ';0;0');
    varPtr.byteArray := '';
    Exit;
  end
  // End of predefined values for CARD ARRAY declaration statement
  else if varPtr.isCardArray and (Pos(']', line) > 0) then begin
    if (Pos('],', line) > 0) then begin
      varPtr.dataType := 'word';
      varPtr.arrayDataType := varPtr.dataType;
      varPtr.isArrayDataType := true;
      varPtr.isDataType := true;
    end
    else begin
      varPtr.isCardArray := false;
      varPtr.isArrayDataType := false;
      prgPtr.isVarArray := false;
    end;

    if (Pos('=', varPtr.cardArray) > 0) then begin
      varPtr.str01 := Extract(1, varPtr.cardArray, '=');
      varPtr.cardArray := Extract(2, varPtr.cardArray, '[');
      varPtr.str01 := StringReplace(varPtr.str01, ', ', '', []);
      varPtr.str01 += '=' + varPtr.dataType + ';4;';
    end;
    vars.Add(varPtr.str01 + varPtr.cardArray + varPtr.str02 +
             ';' + prgPtr.strProcName + ';0;0');
    varPtr.cardArray := '';
    Exit;
  end
  else if varPtr.isTypeDataType then begin
    if Pos('[', line) > 0 then begin
      line := ReplaceStr(line, '[', '');
    end
    else if Pos(']', line) > 0 then begin
      varPtr.isTypeDataType := false;
      temp := vars[vars.IndexOfName(varPtr.typeDataTypeVar)];
      temp += ';1';
      vars[vars.IndexOfName(varPtr.typeDataTypeVar)] := temp;
      varPtr.typeDataTypeVar := '';
      line := ReplaceStr(line, ']', '');
    end;
  end;

  found := dataTypes.IndexOfName(line);
  if ((found >= 0) and not varPtr.isVar)
     or (UpperCase(line) = 'ARRAY') or (UpperCase(line) = 'POINTER') then
     //and not varPtr.isByteArray and not varPtr.isCardArray then
     //and not varPtr.isTypeDataType then
  begin
    if not varPtr.isVarStart then begin
      varPtr.isVarStart := true;
      varPtr.isParamVarOver := false;
    end;
    varPtr.isVar := true;
    varPtr.isArrayDataType := false;
    varPtr.isPointerDataType := false;

    if UpperCase(line) = 'BYTE' then begin
      varPtr.dataType := 'byte';
      varPtr.isDataType := true;
      //code.Add(c + dataType);
    end
    else if UpperCase(line) = 'CHAR' then begin
      varPtr.dataType := 'byte';  // char
      varPtr.isDataType := true;
      //code.Add(c + dataType);
    end
    else if UpperCase(line) = 'INT' then begin
      varPtr.dataType := 'integer';
      varPtr.isDataType := true;
    end
    else if UpperCase(line) = 'CARD' then begin
      varPtr.dataType := 'word';
      varPtr.isDataType := true;
    end
    else if UpperCase(line) = 'SBYTE' then begin
      varPtr.dataType := 'string';
      varPtr.isDataType := true;
      //code.Add(c + dataType);
    end
    else if UpperCase(line) = 'ARRAY' then begin
      varPtr.arrayDataType := varPtr.dataType;
      varPtr.isArrayDataType := true;
      varPtr.isDataType := true;
    end
    else if UpperCase(line) = 'POINTER' then begin
      varPtr.pointerDataType := 'pointer';
      varPtr.isPointerDataType := true;
      varPtr.isDataType := true;
    end
    else if UpperCase(line) = 'TYPE' then begin
      varPtr.dataType := 'type';
      varPtr.isTypeDataType := true;
      varPtr.typeDataTypeVar := '';
      varPtr.isDataType := true;
      varPtr.typeRecVarCnt := 0;
    end
    else begin
      varPtr.dataType := line;
      varPtr.isDataType := true;
    end;
  end
  // Variable name declaration is expected
  else if varPtr.isVar then begin
    varDeclList := line.Split(',');

    // Check variable declaration
    for i := 0 to High(varDeclList) do begin
      //varDeclList[i] := Trim(varDeclList[i]);
      // Scalar predeclared variable value or memory address assignment variable expected
      if (Pos('=', varDeclList[i]) > 0) and not varPtr.isArrayDataType then begin
        //and not varPtr.isByteArray then begin
        params := varDeclList[i].Split('=');
        // Scalar predeclared variable value expected
        if Pos('[', varDeclList[i]) > 0 then begin
          //temp := ExtractText(params[1], '[', ']');
          vars.Add(params[0] + '=' + varPtr.dataType + ';6;' + ExtractText(params[1], '[', ']') +
                   ';0;' + prgPtr.strProcName + ';0;0');
        end
        // TYPE declaration variable
        else if varPtr.isTypeDataType then begin
          varPtr.typeDataTypeVar := params[0];
          //varPtr.typeVarName := params[0];
          vars.Add(params[0] + '=' + varPtr.dataType + ';7;0;0;' + prgPtr.strProcName + ';0;0');
          dataTypes.Add(params[0] + '=5');
        end
        // Memory address assignment variable
        else begin
          vars.Add(params[0] + '=' + varPtr.dataType + ';1;' + params[1] +
                   ';0;' + prgPtr.strProcName + ';0;0');
        end;
      end
      // String variable declaration
      else if varPtr.isArrayDataType and (varPtr.arrayDataType = 'string') then begin
        // String variable constant declaration
        if Pos('=', varDeclList[i]) > 0 then begin
          params := varDeclList[i].Split('=');

          // Check string dimension and extract string variable
          temp := '0';
          if Pos('(', params[0]) > 0 then begin
            temp := ExtractText(params[0], '(', ')');
            params[0] := Extract(1, params[0], '(');
          end;
          vars.Add(params[0] + '=' + varPtr.dataType + ';2;' +
                   params[1] + ';' + temp + ';' + prgPtr.strProcName + ';0;0');
        end
        // String variable declaration
        else begin
          // Check string dimension and extract string variable
          temp := '0';
          if Pos('(', varDeclList[i]) > 0 then begin
            temp := ExtractText(varDeclList[i], '(', ')');
            varDeclList[i] := Extract(1, varDeclList[i], '(');
          end;
          vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';2;0;' +
                   temp + ';' + prgPtr.strProcName + ';0;0');
        end;
      end
      // BYTE ARRAY declaration
      else if varPtr.isArrayDataType and (varPtr.arrayDataType = 'byte') then begin
        temp02 := '';
        params := varDeclList[i].Split('=');
        // Check string dimension and extract string variable
        if Pos('(', varDeclList[i]) > 0 then begin
          temp := ExtractText(varDeclList[i], '(', ')');
          varDeclList[i] := Extract(1, varDeclList[i], '(');
        end
        // Predeclared value is expected
        else if Pos('[', params[1]) > 0 then begin
          temp := '0';
          varPtr.isByteArray := true;
          varPtr.byteArray := Extract(2, params[1], '[');
          // Predeclared values are not separated with space
          if Pos(']', params[1]) > 0 then begin
            varPtr.isByteArray := false;
            varPtr.isArrayDataType := false;
            varPtr.isByteArrayNoSpace := true;
            varPtr.str01 := params[0] + '=' + varPtr.dataType + ';4;';
            //varPtr.str02 := ';0;' + prgPtr.strProcName;
            varPtr.str02 := ';' + prgPtr.strProcName;

            params := varPtr.byteArray.Split('$');
            varPtr.byteArray := '';
            if High(params) > 0 then begin
              for j := 1 to High(params) do begin
                varPtr.byteArray += '$' + params[j];
                if j < High(params) then begin
                  varPtr.byteArray += ', ';
                end;
              end;
            end;
            vars.Add(varPtr.str01 + varPtr.byteArray + varPtr.str02 +
                     ';' + prgPtr.strProcName + ';0;0');
            varPtr.isVar := false;
            Exit;
          end;
        end;

        // BYTE ARRAY COL=708
        if Length(params[1]) > 0 then begin
          temp02 := params[1];
        end;

        if not varPtr.isByteArray then begin
          vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';4;' +
                   temp02 + ';' + temp + ';' + prgPtr.strProcName + ';0;0');
        end
        // BYTE ARRAY predefined values
        else begin
          varPtr.str01 := params[0] + '=' + varPtr.dataType + ';4;';
          //varPtr.str02 := ';0;' + prgPtr.strProcName;
          varPtr.str02 := ';' + prgPtr.strProcName;
        end;
      end
      // CARD ARRAY declaration
      else if varPtr.isArrayDataType and (varPtr.arrayDataType = 'word') then begin
        temp02 := '';
        params := varDeclList[i].Split('=');
        // Check string dimension and extract string variable
        if Pos('(', varDeclList[i]) > 0 then begin
          temp := ExtractText(varDeclList[i], '(', ')');
          varDeclList[i] := Extract(1, varDeclList[i], '(');
        end
        // Predeclared value is expected
        else if Pos('[', params[1]) > 0 then begin
          temp := '0';
          varPtr.isCardArray := true;
          varPtr.cardArray := Extract(2, params[1], '[');
        end
        // CARD ARRAY COL=52000
        else if Length(params[1]) > 0 then begin
          temp02 := params[1];
        end;
        // CARD ARRAY predefined values
        if not varPtr.isCardArray then begin
          vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';5;' +
                   temp02 + ';' + temp + ';' + prgPtr.strProcName + ';0;0');
        end
        else begin
          varPtr.str01 := params[0] + '=' + varPtr.dataType + ';5;';
          //varPtr.str02 := ';0;' + prgPtr.strProcName;
          varPtr.str02 := ';' + prgPtr.strProcName;
          //vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';4;' + params[1] + ';' + temp);
        end;
      end
      // Pointer variable declaration
      else if varPtr.isPointerDataType then begin
        //^byte
        vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';3;0;0;' + prgPtr.strProcName + ';0;0');
      end
      // Standard or TYPE variable
      else begin
        //if varPtr.isTypeRecVarLast and not varPtr.isTypeDataType then begin
        if varPtr.isTypeDataType then begin
          Inc(varPtr.typeRecVarCnt);
          vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';0;' +
                   IntToStr(varPtr.typeRecVarCnt) + ';0;' + prgPtr.strProcName +
                   ';' + varPtr.typeDataTypeVar + ';0');
        end
        else begin
          vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';0;0;0;' +
                   prgPtr.strProcName + ';0;0');
        end;
      end;
    end;
    if line[Length(line)] <> ',' then begin
      varPtr.isVar := false;
    end;
  end
  // It is a FUNCtion
  else if UpperCase(line) = 'FUNC' then begin
    varPtr.isVar := false;
  end
  // No more declared variables for current data type
  else begin
    varPtr.isVar := false;
    varPtr.isVarEnd := true;
  end;
end;

{------------------------------------------------------------------------------
 Description: Main code block for generating Mad Pascal code from Action! code
 -----------------------------------------------------------------------------}
procedure GenerateCode;
var
  i : LongInt;
  j : byte;
  pasFile : string;
  temp : string;
  A: TStringArray;
  strUnits : string = '';
begin
  code.Add('// Effectus auto-generated Mad Pascal source code listing');

  prgName := ReplaceStr(prgName, '-', '');
  code.Add('program ' + prgName + 'Prg;' + LineEnding);
  code.Add('uses');

  if devicePtr.isSySutils then begin
    strUnits += ', SySutils';
  end;

  if devicePtr.isGraphics then begin
    strUnits += ', Graph';
  end;

  if devicePtr.isDevice then begin
    strUnits += ', CIO';
  end;

  if devicePtr.isStick then begin
    strUnits += ', Joystick';
  end;

  code.Add('  Crt' + strUnits + ';' + LineEnding);

  //if prgPtr.isByteBuffer or devicePtr.isDevice or devicePtr.isDeviceOpen then begin
   if devicePtr.isDevice then begin
     code.Add(LineEnding + 'var');
   end;

//   if prgPtr.isByteBuffer then begin
//     code.Add('  intValue : integer;');
//   end;

//   if devicePtr.isDeviceOpen then begin
//     code.Add('  f : file;');
//   end;

   if devicePtr.isDevice then begin
     code.Add('  strBuffer : string;');
   end;

  // Data type declaration initialization
  varPtr.isVar := false;
  varPtr.isVarStart := false;
  varPtr.isDataType := false;
  varPtr.isVarEnd := false;
  varPtr.isArrayDataType := false;
  varPtr.isByteArrayNoSpace := false;
  varPtr.isTypeDataType := false;
  varPtr.typeDataTypeVar := '';
  varPtr.isTypeRecVarLast := false;
  varPtr.typeRecVarCnt := 0;
  varPtr.isPointerAddress := false;
  prgPtr.isVarArray := true;
  varPtr.isVarXY := false;
  prgPtr.isCheckVar := false;
  varPtr.isByteArray := false;
  varPtr.isCardArray := false;
  varCnt := 0;
  // PROCedure declaration initialization
  prgPtr.isProc := false;
  prgPtr.isProcBegin := false;
  procML.isAsm := false;
  procML.strAsm := '';
  prgPtr.isProcName := false;
  prgPtr.strProcName := '';
  prgPtr.isProcFirstBegin := false;
  prgPtr.isProcAddr := false;
  prgPtr.isFuncAsm := false;
  prgPtr.isStartBegin := false;
  //devicePtr.isOpen := false;
  varPtr.isFunc := false;
  prgPtr.isBegin := false;
  // Branch variables initialization
  branchPtr.forCnt := 0;
  branchPtr.whileCnt := 0;
  branchPtr.isUntil := false;
  branchPtr.untilCode := '';
  branchPtr.ifTempCode := '';

  operators := TStringArray.Create(
    '+', '-', '{DIV}', '*', '{MOD}', '{AND}', '{OR}', '{XOR}', '{LSH}', '{RSH}');

  for i := 0 to effCode.Count - 1 do begin
    temp := Trim(effCode[i]);
    if temp = '' then continue;

    // Check comments
    if temp[1] = ';' then begin
      temp := Extract(2, temp, ';');
      code.Add('// ' + temp);
      continue;
    end;

//     effCode[i] := StringReplace(effCode[i], '  ', ' ', [rfReplaceAll]);
    for j := 2 to 255 do begin
      effCode[i] := ReplaceStr(effCode[i], StringOfChar(' ', j), ' ');
    end;

    effCode[i] := ReplaceStr(effCode[i], ' (', '(');
    effCode[i] := ReplaceStr(effCode[i], '( ', '(');
    effCode[i] := ReplaceStr(effCode[i], ' )', ')');

    effCode[i] := ReplaceStr(effCode[i], ' [', '[');
    effCode[i] := ReplaceStr(effCode[i], '[ ', '[');
    effCode[i] := ReplaceStr(effCode[i], ' ]', ']');
    effCode[i] := ReplaceStr(effCode[i], ' ] ', ']');

    effCode[i] := ReplaceStr(effCode[i], ' =', '=');
    effCode[i] := ReplaceStr(effCode[i], '= ', '=');

    effCode[i] := ReplaceStr(effCode[i], ' +', '+');
    effCode[i] := ReplaceStr(effCode[i], '+ ', '+');

    effCode[i] := ReplaceStr(effCode[i], ' -', '-');
    effCode[i] := ReplaceStr(effCode[i], '- ', '-');

    effCode[i] := ReplaceStr(effCode[i], ' *', '*');
    effCode[i] := ReplaceStr(effCode[i], '* ', '*');

    effCode[i] := ReplaceStr(effCode[i], '#', '<>');

    effCode[i] := ReplaceToken(effCode[i], '/', '/', '{DIV}');
    effCode[i] := ReplaceToken(effCode[i], '&', '&', '{AND}');
    effCode[i] := ReplaceToken(effCode[i], '%', '%', '{OR}');
    effCode[i] := ReplaceToken(effCode[i], '!', '!', '{XOR}');
    effCode[i] := ReplaceToken(effCode[i], 'XOR', '{XOR}', '{XOR}');
    effCode[i] := ReplaceToken(effCode[i], 'LSH', '{LSH}', '{LSH}');
    effCode[i] := ReplaceToken(effCode[i], 'RSH', '{RSH}', '{RSH}');
    effCode[i] := ReplaceToken(effCode[i], 'MOD', '{MOD}', '{MOD}');

    effCode[i] := ReplaceStr(effCode[i], ', ', ',');
    effCode[i] := ReplaceStr(effCode[i], 'IF(', 'IF (');

    // Check if comments character ";" is between string quotes ""
    if (Pos(';', temp) > 1) then begin
      if (Pos('"', temp) > 0)
         and (Pos(';', temp) > Pos('"', temp)) then
      begin
      end
      else begin
        effCode[i] := Extract(1, effCode[i], ';');
      end;
    end;

    effCode[i] := ReplaceStr(effCode[i], ', ', ',');

    // Parse each command or any other statement delimited by space
    A := effCode[i].Split(' ', '"', '"');
    if High(a) >= 0 then begin
      for j := 0 to High(a) do begin
        //a[j] := ReplaceStr(a[j], 'MODULE', '');

        // PROC statement is found, PROCedure name and parameters are expected
        if ((UpperCase(a[j]) = 'PROC') or (UpperCase(a[j]) = 'FUNC')) and
           not prgPtr.isProc then
        begin
          prgPtr.isProc := true;

          if (UpperCase(a[j]) = 'FUNC') and not varPtr.isFunc then begin
            varPtr.isFunc := true;
          end;

          if not prgPtr.isProcFirstBegin then begin
            prgPtr.isProcFirstBegin := true;
            VarDecl(true);
            code.Add('');
          end;
        end
        else begin
          // PROC statement is processed
          if prgPtr.isProc then begin
            ProcBlock(a[j]);
          end
          // Other blocks of code are processed
          else begin
            if a[j] <> '' then begin
              // Variable declaration block
              VarDeclBlock(a[j]);
              if not varPtr.isVar and varPtr.isVarStart then begin
                if varPtr.isVarEnd then begin
                  // Write variable declarations
                  if not varPtr.isTypeDataType then begin
                    VarDecl(false);
                    prgPtr.isProcBegin := true;
                  end;
                  varPtr.isVarEnd := false;
                  varPtr.isVarStart := false;
                end;
              end
              // No variable declaration
              else if not varPtr.isVarStart and varPtr.isParamVarOver then begin
                varPtr.isParamVarOver := false;
                if not prgPtr.isFuncAsm then begin
                  if not prgPtr.isProcBegin or
                     (not prgPtr.isCheckVar and not prgPtr.isFuncAsm and
                      not prgPtr.isStartBegin) then
                  begin
                    code.Add('begin  // 6');
                    prgPtr.isStartBegin := true;
                  end;
                end;
              end;
              // Action! source code listing line
              Src(a[j], i);
            end;
          end;
        end;
      end;
    end;
  end;

  // Main program code block
  code.Add('begin');
  code.Add('  ' + myProcs.Names[myProcs.Count - 1] + 'Proc;');
  code.Add('end.');

  FilenameSrc := ExtractFilePath(actionFilename);
  pasFile := ExtractFilenameWithoutExt(actionFilename) + '.pas';
  FilenameSrc += pasFile;

  //pasFile := GetCurrentDir + PathDelim + FilenameSrc;
  code.SaveToFile(FilenameSrc);
end;

end.
