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
begin  
  if vars.Count = 0 then Exit;
  
  for i := 0 to vars.Count - 1 do begin
    if isGlobal then begin
      if ExtractDelimited(5, vars.ValueFromIndex[i], [';']) <> '' then begin
        Continue;
      end;
    end
    else begin
      if prgPtr.strProcName <> ExtractDelimited(5, vars.ValueFromIndex[i], [';']) then begin
        Continue;
      end;
    end;

    if not isGlobal and (ExtractDelimited(2, vars.ValueFromIndex[i], [';']) = '7') then begin
      if not isType then begin
        isType := true;
        code.Add('type');
      end;
    end
    else if not isType then begin
      if not isVar then begin
        isVar := true;
        code.Add('var');
      end;
    end;

    varPtr.dataType := ExtractDelimited(1, vars.ValueFromIndex[i], [';']);

    if ExtractDelimited(2, vars.ValueFromIndex[i], [';']) = '0' then begin
      //isVarDecl := true;
      if isGlobal
         and (ExtractDelimited(3, vars.ValueFromIndex[i], [';']) <> '')
         and (ExtractDelimited(6, vars.ValueFromIndex[i], [';']) <> '') then
      begin
        isVarDecl := false;
      end
      else begin
        isVarDecl := true;
        varPtr.dataType := vars.Names[i] + ' : ' + varPtr.dataType + ';';
      end;

      // TYPE declarion ended
      if not isGlobal
         and (ExtractDelimited(3, vars.ValueFromIndex[i], [';']) = IntToStr(varPtr.typeRecVarCnt))
         and (ExtractDelimited(6, vars.ValueFromIndex[i], [';']) <> '') then
         //and (ExtractDelimited(6, vars.ValueFromIndex[i], [';']) = varPtr.typeDataTypeVar) then
      begin
        //isType := false;
        //varPtr.dataType := vars.Names[i] + ' : ' + varPtr.dataType + ';';
        varPtr.dataType += #13#10'  end;';
        //varPtr.isTypeDataType := false;
        //varPtr.typeDataTypeVar := '';
      end;
    end
    else if ExtractDelimited(2, vars.ValueFromIndex[i], [';']) = '6' then begin
      isVarDecl := true;
      varPtr.dataType := vars.Names[i] + ' : ' + varPtr.dataType + ' = ' +
                         ExtractDelimited(3, vars.ValueFromIndex[i], [';']) + ';';
                         //ExtractDelimited(3, tempList.ValueFromIndex[i], [';']);
    end
    else if ExtractDelimited(2, vars.ValueFromIndex[i], [';']) = '1' then begin
      isVarDecl := true;
      varPtr.dataType := vars.Names[i] + ' : ' + varPtr.dataType + ' absolute ' +
                         ExtractDelimited(3, vars.ValueFromIndex[i], [';']) + ';';
    end
    // String variable declaration 
    else if ExtractDelimited(2, vars.ValueFromIndex[i], [';']) = '2' then begin
      isVarDecl := true;
      buf := ExtractDelimited(3, vars.ValueFromIndex[i], [';']);
      len := ExtractDelimited(4, vars.ValueFromIndex[i], [';']);
      if buf = '0' then begin
        if len = '0' then
          varPtr.dataType := vars.Names[i] + ' : string;'
        else begin
          varPtr.dataType := vars.Names[i] + ' : string[' + len + '];'
        end;
      end
      else begin
        buf := QuotedStr(ExtractText(buf, '"', '"'));
        if len = '0' then
          varPtr.dataType := vars.Names[i] + ' : string = ' + buf + ';'
        else begin
          varPtr.dataType := vars.Names[i] + ' : string[' + len + '] = ' + buf + ';';
        end;
      end;
    end
    // BYTE ARRAY variable declaration 
    else if (ExtractDelimited(2, vars.ValueFromIndex[i], [';']) = '4')
            or (ExtractDelimited(2, vars.ValueFromIndex[i], [';']) = '5') then
    begin
      if ExtractDelimited(2, vars.ValueFromIndex[i], [';']) = '5' then begin
        dataType := 'word';
      end;    
      isVarDecl := true;
      buf := ExtractDelimited(3, vars.ValueFromIndex[i], [';']);
      len := ExtractDelimited(4, vars.ValueFromIndex[i], [';']);

      // f.e.: BYTE ARRAY values
      if (buf = '0') or (buf = '') then begin
        if len = '0' then
          varPtr.dataType := vars.Names[i] + ' : array[0..255] of ' + dataType + ';'
        else begin
          if len = '' then len := '255';
          varPtr.dataType := vars.Names[i] + ' : array[0..' + len + '] of ' + dataType + ';'
        end;
      end
      // f.e.: BYTE ARRAY BYTES=[10 20 30 40]
      // f.e.: CARD ARRAY BYTES=[1000 23504 30000 65221]
      else begin
        if System.Pos(',', buf) > 0 then begin 
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
          varPtr.dataType := vars.Names[i] + ' : array[0..' + IntToStr(High(params)) + ']' +
                             ' of ' + dataType + ' = (' + buf + ');';
        end
        else begin
          varPtr.dataType := vars.Names[i] + ' : array[0..255] of ' +
                             dataType + ' absolute ' + buf + ';'
        end;
      end;
    end 
    // TYPE variable declaration
    else if not isGlobal
            and (ExtractDelimited(2, vars.ValueFromIndex[i], [';']) = '7') then
    begin
      isVarDecl := true;
      isType := true;
      varPtr.dataType := vars.Names[i] + ' = record';
    end
    // Pointer variable declaration
    else if ExtractDelimited(2, vars.ValueFromIndex[i], [';']) = '3' then begin
      isVarDecl := true;
      //^byte, ^card, ^int
      varPtr.dataType := vars.Names[i] + ' : ^' + varPtr.dataType + ';';
    end;

    if isVarDecl then begin
      code.Add('  ' + varPtr.dataType);  // + IntToStr(i));
    end;
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

  // Convert possible DEFINE constants to real data
  if defineList.IndexOfName(param) >= 0 then begin
    param := ExtractDelimited(
      1, defineList.ValueFromIndex[defineList.IndexOfName(param)], [';']);
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
      param := Extract(1, param, ')', []);
    end;
    temp += param;
  end
  // BYTE
  else if paramType = '2' then begin
    if (offset > 0) and (offset < paramCnt) then temp += ', ';
    if offset = paramCnt - 1 then begin
      //params[i] := Extract(1, params[i], ')', []);  // ??
      param := ReplaceStr(param, '(', '[');
      param := ReplaceStr(param, ')', ']');
    end;
    temp += param;
  end
  // INT or CARD data type
  else if (paramType = '3') or (paramType = '4') then begin
    if (offset > 0) and (offset < paramCnt) then temp += ', ';
    if offset = paramCnt - 1 then begin
      //params[i] := Extract(1, params[i], ')', []);  // ??
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
  if (System.Pos('EOF(', UpperCase(stmt)) > 0) or (System.Pos('EOF[', UpperCase(stmt)) > 0) then
  begin
    //EOF(1)=0
    if System.Pos('=', UpperCase(stmt)) > 0 then begin
      temp := Extract(2, stmt, '=', []);
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
    stmt := ReplaceStr(stmt, '(', '[');
    stmt := ReplaceStr(stmt, ')', ']');
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
  if System.Pos('$', temp) > 0 then begin
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
      temp := IntToHex(StrToInt(temp), 4);
      temp := '$' + Copy(temp, 3, 2) + ' $' + Copy(temp, 1, 2);
    end;
    procML.strAsm += temp + ' ';
  end;
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
      if Length(op) = 1 then
        oper.Add(op + '=' + IntToStr(x) + ';0')
      else begin
        oper.Add('{' + op + '}=' + IntToStr(x) + ';0')
      end;
    end;
    inc(y);
  until x = 0;
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
  offset : word;
  temp, temp02, temp03, temp04, temp05 : string;
  procName : string;
  paramCnt : byte;
  params2 : string;
  params : TStringArray;
  paramsEx : TStringArray;
  funcVar : string;
  aList : TStringList;
  op : TStringList;
  cnt : byte = 0;
  
{------------------------------------------------------------------------------
 Description: Reset global variables
 -----------------------------------------------------------------------------}
procedure ResetVar;
begin
  varPtr.isVarStart := false;
  varPtr.isDataType := false;
  varPtr.isVarOver := false;
  varPtr.isVarEnd := false;
  varPtr.isArrayDataType := false;
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
end;

begin
  aList := TStringlist.create;
  op := TStringlist.create;
  oper.Clear;

  temp := Strip(line, ' ');

  // Check for Action! keywords
  offset := keywords.IndexOfName(temp);
  
  if (offset >= 0) and (offset < 65535) then begin
    if UpperCase(temp) = 'EXIT' then begin
      code.Add('  break;');
      Exit;
    end;

    k := StrToInt(ExtractDelimited(1, keywords.ValueFromIndex[offset], [';']));

    // The keyword is a branch
    if k = 1 then begin
      // IF branch
      if UpperCase(temp) = 'IF' then begin
        branchPtr.isIfThen := true;
        branchPtr.isIfThenInProgress := true;
        branchPtr.ifThenCode := '  if ';
        branchPtr.isIfThenNext := false;
        branchPtr.isEndIfNext := false;
        branchPtr.isElseNext := false;
        branchPtr.isElseIfNext := false;
        //prgPtr.ifTempCode := '';
      end
      else if (UpperCase(temp) = 'THEN') and branchPtr.isIfThenNext then begin
        branchPtr.ifThenCode += ' then begin';
        code.Add(branchPtr.ifThenCode);
        branchPtr.ifThenCode := '';
        //prgPtr.isIfThen := false;
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
        branchPtr.ifThenCode := '  end' + LineEnding +
                             '  else if ';
        branchPtr.isIfThenNext := false;
        branchPtr.isEndIfNext := false;
        branchPtr.isElseNext := false;
        branchPtr.isElseIfNext := false;
      end
      else if branchPtr.isEndIfNext and (UpperCase(temp) = 'FI') then begin
        code.Add('  end;');
        branchPtr.isIfThen := false;
        branchPtr.isIfThenNext := false;
        branchPtr.isEndIfNext := false;
        branchPtr.ifThenCode := '';
      end
      // FOR branch
      else if UpperCase(temp) = 'FOR' then begin
      //if keywords.Names[offset] = 'FOR' then begin
        branchPtr.isFor := true;
        branchPtr.forCode := '  for ';
        branchPtr.isForToNext := false;
        branchPtr.isForDoNext := false;
        branchPtr.isForOdNext := false;
      end
      else if (UpperCase(temp) = 'TO') and branchPtr.isForToNext then begin
        //prgPtr.forCode += ' to ';
        branchPtr.isForDoNext := true;
        //code.Add(prgPtr.forCode);
        //prgPtr.forCode := '';
      end
      else if (UpperCase(temp) = 'DO')
           and branchPtr.isForDoNext and not branchPtr.isForOdNext then
      begin
        branchPtr.forCode += ' do begin';
        branchPtr.isForOdNext := true;
        code.Add(branchPtr.forCode);
        branchPtr.forCode := '';
      end
      else if branchPtr.isForOdNext and (UpperCase(temp) = 'OD') then begin
        code.Add('  end;');
        branchPtr.isFor := false;
        branchPtr.isForToNext := false;
        branchPtr.isForDoNext := false;
        branchPtr.isForOdNext := false;
      end
      // WHILE branch
      else if UpperCase(temp) = 'WHILE' then begin
        branchPtr.isWhile := true;
        branchPtr.whileCode := '';
        branchPtr.isWhileDoNext := true;
        branchPtr.isWhileOdNext := false;
      end
//           if (temp <> 'DO') and prgPtr.isWhile and not prgPtr.isWhileDoNext then begin
//             prgPtr.whileCode += temp;
//             prgPtr.isWhileDoNext := true;
//           end;
      else if (UpperCase(temp) = 'DO') and branchPtr.isWhileDoNext then begin
        branchPtr.whileCode += ' do begin';
        branchPtr.isWhileOdNext := true;
        code.Add(branchPtr.whileCode);
        branchPtr.whileCode := '';
      end
      else if branchPtr.isWhileOdNext and (UpperCase(temp) = 'OD') then begin
        //prgPtr.whileCode += ' ' + temp;  // + ' // 4';
        code.Add('  end;');
        branchPtr.isWhile := false;
        branchPtr.isWhileDoNext := false;
        branchPtr.isWhileOdNext := false;
      end
      else if (UpperCase(temp) = 'DO') then
         //and not prgPtr.isFor and not prgPtr.isWhile then
      begin
        branchPtr.isDoOd := true;
        code.Add('  repeat');
      end
      else if (UpperCase(temp) = 'UNTIL') and branchPtr.isDoOd then
         //and not prgPtr.isFor and not prgPtr.isWhile then
      begin
        branchPtr.isDoOd := false;
        branchPtr.isUntil := true;
        branchPtr.untilCode := '';
      end
      else if (UpperCase(temp) = 'OD') and branchPtr.isDoOd then
         //and not prgPtr.isFor and not prgPtr.isWhile then
      begin
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
  else if (System.Pos('=', temp) > 0) //and not (System.Pos('(', temp) > 0)
          and not branchPtr.isIfThenInProgress then
          //and not varPtr.isFunc then  //and not prgPtr.isWhileDoNext then
  begin
    // Check if equal character (=) exists in comments (between string quotes "" in PROC or FUNC)
    if (System.Pos('=', temp) > 1) and (System.Pos('"', temp) > 0)
       and (System.Pos('=', temp) > System.Pos('"', temp)) then
    begin
      // Handle PROCedures with string parameters
      if System.Pos('(', temp) > 0 then begin
        // PROCedure name
        procName := UpperCase(Extract(1, temp, '(', []));
        // PROCedure parameters
        //params2 := Extract(2, line, '(', []);
        params2 := ExtractText(line, '(', ')');
        // Check if FUNCtion is assigned to some variable
        if (System.Pos('=', procName) > 0) then begin
          funcVar := Extract(1, procName, '=', []);
          procName := Extract(2, procName, '=', []);
        end;
      end;
    end
    // Pointer variable value assignment
    else if System.Pos('^=', temp) > 0 then begin
      temp02 := Extract(1, temp, '^', []);
      params2 := Extract(2, temp, '=', []);
      if ExtractDelimited(2, vars.ValueFromIndex[vars.IndexOfName(temp02)], [';']) = '3' then
      begin
        code.Add('  ' + temp02 + '^ := ' + params2 + ';');
      end;
    end
    // Double variable assignment
    else if System.Pos('==', temp) > 0 then begin
      SplitStr(temp, '==', aList);

      if System.Pos('{MOD}', aList[1]) > 0 then begin
        params2 := aList[0];
        SplitStr(temp, '{MOD}', aList);
        temp := StringReplace(aList[1], '{MOD}', '', [rfReplaceAll]);
        code.Add('  ' + params2 + ' := ' + params2 + ' MOD ' + temp + ';');
      end
      else if System.Pos('{AND}', aList[1]) > 0 then begin
        params2 := aList[0];
        SplitStr(temp, '{AND}', aList);
        temp := StringReplace(aList[1], '{AND}', '', [rfReplaceAll]);
        code.Add('  ' + params2 + ' := ' + params2 + ' AND ' + temp + ';');
      end
      else if System.Pos('{OR}', aList[1]) > 0 then begin
        params2 := aList[0];
        SplitStr(temp, '{OR}', aList);
        temp := StringReplace(aList[1], '{OR}', '', [rfReplaceAll]);
        code.Add('  ' + params2 + ' := ' + params2 + ' OR ' + temp + ';');
      end
      else if System.Pos('{XOR}', aList[1]) > 0 then begin
        params2 := aList[0];
        SplitStr(temp, '{XOR}', aList);
        temp := StringReplace(aList[1], '{XOR}', '', [rfReplaceAll]);
        code.Add('  ' + params2 + ' := ' + params2 + ' XOR ' + temp + ';');
      end
      else if System.Pos('{LSH}', aList[1]) > 0 then begin
        params2 := aList[0];
        SplitStr(temp, '{LSH}', aList);
        temp := StringReplace(aList[1], '{LSH}', '', [rfReplaceAll]);
        code.Add('  ' + params2 + ' := ' + params2 + ' SHL ' + temp + ';');
      end
      else if System.Pos('{RSH}', aList[1]) > 0 then begin
        params2 := aList[0];
        SplitStr(temp, '{RSH}', aList);
        temp := StringReplace(aList[1], '{RSH}', '', [rfReplaceAll]);
        code.Add('  ' + params2 + ' := ' + params2 + ' SHR ' + temp + ';');
      end
      else begin
        temp := aList[1][1];
        params2 := Extract(2, aList[1], aList[1][1], []);
        if vars.IndexOfName(aList[0]) >= 0 then begin
          // Pointer variable assigned to memory address
          if (ExtractDelimited(2, vars.ValueFromIndex[vars.IndexOfName(aList[0])], [';']) = '3')
             and (aList[1][1] = '@') then
          begin
            //prgPtr.isPointerAddress := true;
            //code.Add('  ' + aList[0] + ' := ' + aList[1] + ';');
          end
          else begin
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
                code.Add('  ' + aList[0] + ' := ' + aList[0] + ' ' + temp[1] + ' ' + params2 + ';');
              end;
            end;
          end;
        end;
      end
    end
    // Standard variable assignment
    else begin
      // Variable assignment
      //writeln('temp = ', temp);
      params := temp.Split('=');
      if High(params) > 0 then begin
        temp02 := Extract(1, params[0], '(', []);
        temp03 := Extract(1, params[1], '(', []);
        temp04 := Extract(1, params[0], '.', []);
        temp05 := Extract(2, params[0], '.', []);

        // FUNCtion assignment
        if funcs.IndexOfName(temp03) >= 0 then begin
          // FUNCtion name
          funcVar := temp02;
          procName := UpperCase(Extract(1, temp03, '(', []));
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
        else if (vars.IndexOfName(temp02) >= 0) or (vars.IndexOfName(temp04) >= 0) then
        begin
          params[0] := ReplaceStr(params[0], '(', '[');
          params[0] := ReplaceStr(params[0], ')', ']');
  
          // ENTRY=DATA+10
          // ENTRY.NUM1=30
          if (vars.IndexOfName(temp04) >= 0)
             and (ExtractDelimited(
                    2, vars.ValueFromIndex[vars.IndexOfName(temp04)], [';']) = '3') then
          begin
            //writeln('if .');
            //ENTRY.NUM1=30
            if (vars.IndexOfName(temp05) >= 0)
               and (ExtractDelimited(
                     6, vars.ValueFromIndex[vars.IndexOfName(temp05)], [';']) <> '') then
            begin
              //writeln('if . 2');
              params[0] := temp04 + '^.' + temp05;
            end
            //ENTRY := DATA+10;
            //ENTRY := pointer(word(@data));
            //Inc(entry, 5);
            else begin
              //writeln('if . 3');
              paramsEx := params[1].Split('+');
              if High(paramsEx) > 0 then begin
                //writeln('if . 4');
                params[0] := temp04 + ' := pointer(word(@' + paramsEx[0] + '));' + LineEnding +
                             'Inc(' + temp04 + ', ' + paramsEx[1] + ');';
                code.Add('  ' + params[0]);
                //ResetVar;
                aList.Free;
                op.Free;
                exit;
              end;
            end;
          end;

          // Check for FUNCtions
          temp03 := UpperCase(Extract(1, params[1], '(', []));
          if myFuncs.IndexOfName(temp03) >= 0 then begin
            temp04 := UpperCase(Extract(2, params[1], '(', []));
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
              CheckOper('/', params[1]);
              CheckOper('MOD', params[1]);
              CheckOper('AND', params[1]);
              CheckOper('OR', params[1]);
              CheckOper('XOR', params[1]);
              CheckOper('RSH', params[1]);
              CheckOper('LSH', params[1]);
              if oper.Count > 0 then begin
                for j := 0 to 255 do begin
                  for i := 0 to oper.Count - 1 do begin
                    if StrToInt(ExtractDelimited(1, oper.ValueFromIndex[i], [';'])) = j then begin
                      op.Add(oper.Names[i]);
                      temp04 += oper.Names[i];
                      break;
                    end; 
                  end;
                end;
              end;
              temp04 := '';
              for i := 0 to High(paramsEx) do begin
                if System.Pos('(', paramsEx[i]) > 0 then begin
                  temp03 := Extract(1, paramsEx[i], '(', []);
                  if (vars.IndexOfName(temp03) >= 0)
                     and ((ExtractDelimited(2, vars.ValueFromIndex[vars.IndexOfName(temp03)], [';']) = '4')
                          or (ExtractDelimited(2, vars.ValueFromIndex[vars.IndexOfName(temp03)], [';']) = '5')) then
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

          //videoPtr := pointer(DPeek(88));
          // Pointer variable assigned to memory address
          if (vars.IndexOfName(temp02) >= 0)
             and (ExtractDelimited(2, vars.ValueFromIndex[vars.IndexOfName(temp02)], [';']) = '3')
             and (params[1][1] = '@') then
          begin
            varPtr.isPointerAddress := true;
            code.Add('  ' + params[0] + ' := ' + params[1] + ';');
          end
          //n2 = n1 /// n2 := word(@n1);
          else if (vars.IndexOfName(temp02) >= 0) and (vars.IndexOfName(temp03) >= 0)
                  and (ExtractDelimited(2, vars.ValueFromIndex[vars.IndexOfName(temp02)], [';']) = '1')
                  and (ExtractDelimited(2, vars.ValueFromIndex[vars.IndexOfName(temp03)], [';']) = '4') then
                  //and not varPtr.isVarStart then
          begin
            code.Add('  ' + params[0] + ' := word(@' + params[1] + ');');
          end
          // PROCedure as the assignment
          else if (vars.IndexOfName(temp02) >= 0) and (myProcs.IndexOfName(temp03) >= 0)
                  and (ExtractDelimited(2, vars.ValueFromIndex[vars.IndexOfName(temp02)], [';']) = '1') then
                  //and (ExtractDelimited(2, vars.ValueFromIndex[vars.IndexOfName(temp03)], [';']) = '4') then
                  //and not varPtr.isVarStart then
          begin
            code.Add('  ' + params[0] + ' := word(@' + temp03 + 'Proc);');
          end
          // Standard assignment
          else begin
            if System.Pos('{MOD}', params[1]) > 0 then begin
              SplitStr(params[1], '{MOD}', aList);
              params[1] := aList[0] + ' MOD ' + aList[1];
            end
            else if System.Pos('{AND}', params[1]) > 0 then begin
              SplitStr(params[1], '{AND}', aList);
              params[1] := aList[0] + ' AND ' + aList[1];
            end
            else if System.Pos('{OR}', params[1]) > 0 then begin
              SplitStr(params[1], '{OR}', aList);
              params[1] := aList[0] + ' OR ' + aList[1];
            end
            else if System.Pos('{LSH}', params[1]) > 0 then begin
              SplitStr(params[1], '{LSH}', aList);
              params[1] := aList[0] + ' SHL ' + aList[1];
            end
            else if System.Pos('{RSH}', params[1]) > 0 then begin
              SplitStr(params[1], '{RSH}', aList);
              params[1] := aList[0] + ' SHR ' + aList[1];
            end
            else if System.Pos('{XOR}', params[1]) > 0 then begin
              SplitStr(params[1], '{XOR}', aList);
              params[1] := aList[0] + ' XOR ' + aList[1];
            end;
            
            if not varPtr.isVarStart then begin
              if params[1][1] = '''' then begin
                params[1] := IntToStr(Ord(params[1][2]));
              end;
              code.Add('  ' + params[0] + ' := ' + params[1] + ';');
            end;
          end;
        end;
      end;
    end;
  end
  // Start of inline machine language  
  else if (System.Pos('[', temp) > 0)
          and not procML.isAsm and not varPtr.isTypeDataType then
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
        if UpperCase(ExtractDelimited(5, vars.ValueFromIndex[i], [';'])) = UpperCase(prgPtr.strProcLocalName) then begin
          if asmOpcodeCnt > 2 then begin
            asmOpcodeCnt := 3;
            paramsAsm += '  ' + asmOpcode[asmOpcodeCnt] + ' ' + vars.Names[i] + ' $' + actionVar[asmcnt + 3] + LineEnding;
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
      temp02 := Extract(2, temp, '[', []);
      temp02 := ReplaceStr(temp02, ']', '');
      AsmBytes(temp02);
      if System.Pos(']', temp) > 0 then begin
        if prgPtr.isFuncAsm and varPtr.isFunc then begin
          procML.strAsm += LineEnding + '  mva #0 result';
          //  procML.strAsm += #13#10'  .by $60';
        end;
        procML.strAsm += LineEnding + '  };';
        code.Add(procML.strAsm);
        procML.isAsm := false;
        procML.strAsm := '';
        if prgPtr.isFuncAsm then begin
          code.Add('end;');
          ResetVar;
        end;
      end;
    end;
// [
//  $A9 $90 $3E $02C6 $0 $60
//]
    aList.Free;
    op.Free;
    Exit;
  end
  // End of inline machine language
  else if (System.Pos(']', temp) > 0) and procML.isAsm then begin
    // Machine language mnemonics on the same line 
    if Length(temp) > 1 then begin
      temp02 := Extract(1, temp, ']', []);
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
      code.Add('end;');
    end;

    ResetVar;
    aList.Free;
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
    aList.Free;
    Exit;
  end  
  // Check for PROCedure
  else if (System.Pos('(', temp) > 0) and not varPtr.isFunc then begin
    // PROCedure name
    procName := UpperCase(Extract(1, temp, '(', []));
    // PROCedure parameters
    params2 := ExtractText(line, '(', ')');
    // Check if FUNCtion is assigned to some variable
    if (System.Pos('=', procName) > 0) then begin
      funcVar := Extract(1, procName, '=', []);
      procName := Extract(2, procName, '=', []);
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
  else if varPtr.isFunc and (System.Pos('(', temp) > 0)
          and (System.Pos('RETURN', UpperCase(temp)) > 0) then
  begin
    params2 := ExtractText(line, '(', ')');
    Code.add('  result := ' + params2 + ';');
    Code.add('end;');
    ResetVar;
    aList.Free;
    op.Free;
    Exit;
  end;

  if branchPtr.isWhileDoNext and not branchPtr.isWhileOdNext then begin
    temp := CheckEOF(temp);
    branchPtr.whileCode += ' ' + temp;
  end;

  // End of PROCedure or FUNCtion
  if (UpperCase(Trim(line)) = 'RETURN') then
     //or (prgPtr.isFuncAsm and (System.Pos(']', line) > 0)) then
  begin
    code.Add('end;' + LineEnding);
    ResetVar;
    aList.Free;
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
  if (UpperCase(temp) <> 'THEN') and branchPtr.isIfThen and not branchPtr.isIfThenNext then begin
    //prgPtr.ifthenCode += temp;
    branchPtr.isIfThenNext := true;
    //prgPtr.isIfThen := false;
  end
  // Code in IF condition part
  else if branchPtr.isIfThenNext then begin
    // Replace () brackets with [] brackets
    
//     if System.Pos('(', temp) > 0 then begin
//       temp02 := Extract(1, temp, '=', []);
//     end;
   
    // Bracket '(' is not the first character in condition value 
    if temp[1] <> '(' then begin    
      temp := ReplaceStr(temp, '(', '[');
      temp := ReplaceStr(temp, ')', ']');
    end;

    if System.Pos('{AND}', temp) > 0 then begin
      temp := StringReplace(temp, '{AND}', ' AND ', [rfReplaceAll]);
    end;
    if System.Pos('{OR}', temp) > 0 then begin
      temp := StringReplace(temp, '{OR}', ' OR ', [rfReplaceAll]);
    end;
    if System.Pos('{XOR}', temp) > 0 then begin
      temp := StringReplace(temp, '{XOR}', ' XOR ', [rfReplaceAll]);
    end;
    if System.Pos('{LSH}', temp) > 0 then begin
      temp := StringReplace(temp, '{LSH}', ' SHL ', [rfReplaceAll]);
    end;
    if System.Pos('{RSH}', temp) > 0 then begin
      temp := StringReplace(temp, '{RSH}', ' SHR ', [rfReplaceAll]);
    end;
    if System.Pos('{MOD}', temp) > 0 then begin
      temp := StringReplace(temp, '{MOD}', ' MOD ', [rfReplaceAll]);
    end;

    // Check special character assignment, f.e. 'T
    if System.Pos('=', temp) > 0 then begin
      temp02 := Extract(1, temp, '=', []);
      temp03 := Extract(2, temp, '=', []);
      
      // Convert possible DEFINE constants to real data
      if defineList.IndexOfName(temp02) >= 0 then begin
        temp02 := ExtractDelimited(
          1, defineList.ValueFromIndex[defineList.IndexOfName(temp02)], [';']);
      end;

      if defineList.IndexOfName(temp03) >= 0 then begin
        temp03 := ExtractDelimited(
          1, defineList.ValueFromIndex[defineList.IndexOfName(temp03)], [';']);
      end;

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
      branchPtr.ifthenCode += temp;
    end
    else begin
      branchPtr.ifthenCode += branchPtr.ifTempCode;
    end;
  end
  else if (UpperCase(temp) <> 'TO') and branchPtr.isFor and not branchPtr.isForToNext then begin
    //temp := ReplaceStr(temp, '=', ':=');
    //prgPtr.forCode += '*2* ' + temp;
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
  aList.Free;
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
  //isDataType : boolean = false;
  isVar : boolean = false;
  dataTypeList, varList : TStringArray;
begin
  params := Extract(2, params, '(', []);
  paramTypes := '';
  dataTypeList := params.Split(' ');
  paramCntx := 0;
  cnt := High(dataTypeList);
  for i := 0 to cnt do begin
    // Check for data type declaration
    //varPtr.isVar := false;
    //varPtr.isParamVar := false;
    params := Extract(1, dataTypeList[i], ' ', []);
    found := dataTypes.IndexOfName(params);
    if found >= 0 then begin
      isVar := true;
      if UpperCase(params) = 'BYTE' then begin
        varPtr.dataType := 'byte';
        paramsx += ';2';
      end
      else if UpperCase(params) = 'CHAR' then begin
        varPtr.dataType := 'char';
        paramsx += ';2';
      end
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
        vars.Add(temp02 + '=' + varPtr.dataType + ';2;0;0;' + prgPtr.strProcLocalName);
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
  //offset : word;
  temp : string;
  //paramCnt : byte;
  //params2 : string;
  //paramsEx : TStringArray;
  //funcVar : string;
  //aList : TStringList;
  //cnt : byte = 0;
begin
  // PROCedure name is on the same line as parameters 
  if (Length(line) > 1) and (System.Pos('(', line) > 0) then begin
    procName := UpperCase(Extract(1, line, '(', []));
    params := UpperCase(Extract(2, line, '(', []));
    prgPtr.strAsmDecl := '';

    // PROC KBGET=$F302()
    // CARD FUNC MultiplyB=*(BYTE a,x)
    if System.Pos('=', line) > 0 then begin
      if System.Pos('*', line) > 0 then
        prgPtr.isFuncAsm := true
      else begin
        prgPtr.isProcAddr := true;
        prgPtr.strAsmDecl := ExtractText(line, '=', '(');
      end;
      procName := Extract(1, procName, '=', []);
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
  if System.Pos(')', line) > 0 then begin
    prgPtr.isProcParams := false;
    prgPtr.isProc := false;
    // PROCedure with no parameters
    if System.Pos('()', line) > 0 then begin
      varPtr.isVarOver := true;
      paramCntx := 0;
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
      else if prgPtr.isProcBegin then begin
        code.Add('begin');
        prgPtr.isBegin := true;
      end
      else if prgPtr.isProcAddr and (prgPtr.strAsmDecl <> '') then begin
        code.Add('begin');
        code.Add('  asm {');
        code.Add('    jsr ' + prgPtr.strAsmDecl);
        code.Add('    rts');
        code.Add('  };');
        code.Add('end;');
      end;
    end
    // PROCedure with parameters
    else begin 
      params := Extract(1, line, ')', []);
      prgPtr.procParams += ' ' + params;
      //procName := Extract(2, procName, '(', []);
      //code.Add('procedure ' + procName + '(' + prgPtr.procParams + ');');

      if prgPtr.isProcAddr or prgPtr.isFuncAsm then begin
        if System.Pos('=', prgPtr.procParams) > 0 then begin
          procName := Extract(1, prgPtr.procParams, '=', []);
          //prgPtr.strAsmDecl := ExtractText(line, '=', '(');
        end
      end
      else begin
        procName := Extract(1, prgPtr.procParams, '(', []);
      end;

      params := Extract(2, prgPtr.procParams, '(', []);
      //code.Add('procedure ' + prgPtr.procParams + ');');
      
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

      varPtr.isVarOver := true;

      if prgPtr.isFuncAsm then begin
        //code.Add('asm');
      end
      else if prgPtr.isProcBegin then begin
        code.Add('begin');
      end
      else if prgPtr.isProcAddr then begin
        code.Add('begin');
        code.Add('  asm {');
        code.Add('    jsr ' + prgPtr.strAsmDecl);
        // + ExtractDelimited(2, myProcs.ValueFromIndex[myProcs.IndexOfName(procName)], [';']));
        code.Add('    rts');
        code.Add('  };');
        code.Add('end;');
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
  if (System.Pos('[', line) > 0) then  //and (System.Pos(']', line) > 0) then
          //and not procML.isAsm and not varPtr.isTypeDataType then
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
        if UpperCase(ExtractDelimited(5, vars.ValueFromIndex[i], [';'])) = UpperCase(prgPtr.strProcLocalName) then begin
          if asmOpcodeCnt > 2 then begin
            asmOpcodeCnt := 3;
            paramsAsm += '  ' + asmOpcode[asmOpcodeCnt] + ' ' + vars.Names[i] + ' $' + actionVar[asmcnt + 3] + LineEnding;
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
      temp := Extract(2, line, '[', []);
      //temp := ReplaceStr(temp, ']', '');
      AsmBytes(temp);
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Variable declaration code block
 -----------------------------------------------------------------------------}
procedure VarDeclBlock(line : string);
var
  i : byte;
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

  if varPtr.isByteArray and (System.Pos(']', line) > 0) then begin
    // and not varPtr.isTypeDataType then begin
    varPtr.isByteArray := false;
    varPtr.isArrayDataType := false;
    vars.Add(varPtr.str01 + varPtr.byteArray + varPtr.str02 + ';' + prgPtr.strProcName);
  end
  else if varPtr.isCardArray and (System.Pos(']', line) > 0) then begin
    varPtr.isCardArray := false;
    varPtr.isArrayDataType := false;
    vars.Add(varPtr.str01 + varPtr.cardArray + varPtr.str02 + ';' + prgPtr.strProcName);
  end
  else if varPtr.isTypeDataType then begin
    if System.Pos('[', line) > 0 then begin
      line := ReplaceStr(line, '[', '');
    end
    else if System.Pos(']', line) > 0 then begin
      varPtr.isTypeDataType := false;
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
      varPtr.isVarOver := false;
    end;
    varPtr.isVar := true;
    varPtr.isArrayDataType := false;
    varPtr.isPointerDataType := false;

    if UpperCase(line) = 'BYTE' then begin
      //varPtr.isVar := true;
      varPtr.dataType := 'byte';
      varPtr.isDataType := true;
      //code.Add(c + dataType);
    end
    else if UpperCase(line) = 'CHAR' then begin
      //varPtr.isVar := true;
      varPtr.dataType := 'char';
      varPtr.isDataType := true;
      //code.Add(c + dataType);
    end
    else if UpperCase(line) = 'INT' then begin
      //varPtr.isVar := true;
      varPtr.dataType := 'integer';
      varPtr.isDataType := true;
    end    
    else if UpperCase(line) = 'CARD' then begin
      //varPtr.isVar := true;
      varPtr.dataType := 'word';
      varPtr.isDataType := true;
    end
    else if UpperCase(line) = 'SBYTE' then begin
      //varPtr.isVar := true;
      varPtr.dataType := 'string';
      varPtr.isDataType := true;
      //code.Add(c + dataType);
    end
    else if UpperCase(line) = 'ARRAY' then begin
      //varPtr.isVar := true;
      varPtr.arrayDataType := varPtr.dataType;
      varPtr.isArrayDataType := true;
      varPtr.isDataType := true;
    end
    else if UpperCase(line) = 'POINTER' then begin
      //varPtr.isVar := true;
      varPtr.pointerDataType := 'pointer';
      varPtr.isPointerDataType := true;
      varPtr.isDataType := true;
    end
    else if UpperCase(line) = 'TYPE' then begin
      //varPtr.isVar := true;
      varPtr.dataType := 'type';
      varPtr.isTypeDataType := true;
      varPtr.typeDataTypeVar := '';
      varPtr.isDataType := true;
      varPtr.typeRecVarCnt := 0;
      //varPtr.isPostTypeDataType := false;
    end
    else begin
      //varPtr.isVar := true;
      varPtr.dataType := line;
      varPtr.isDataType := true;
    end;
  end
  // Variable name declaration is expected
  else if varPtr.isVar then begin
    varDeclList := line.Split(',');  //, TStringSplitOptions.ExcludeEmpty);

    // Check variable declaration
    for i := 0 to High(varDeclList) do begin
      //varDeclList[i] := Trim(varDeclList[i]);
      // Scalar predeclared variable value or memory address assignment variable expected
      if (System.Pos('=', varDeclList[i]) > 0) and not varPtr.isArrayDataType then begin
        params := varDeclList[i].Split('=');
        // Scalar predeclared variable value expected
        if System.Pos('[', varDeclList[i]) > 0 then begin
          //temp := ExtractText(params[1], '[', ']');
          vars.Add(params[0] + '=' + varPtr.dataType + ';6;' + ExtractText(params[1], '[', ']') +
                   ';0;' + prgPtr.strProcName);
        end
        // TYPE declaration variable
        else if varPtr.isTypeDataType then begin
          varPtr.typeDataTypeVar := params[0];
          vars.Add(params[0] + '=' + varPtr.dataType + ';7;0;0;' + prgPtr.strProcName);
          dataTypes.Add(params[0] + '=5');
        end
        // Memory address assignment variable
        else begin
          vars.Add(params[0] + '=' + varPtr.dataType + ';1;' + params[1] +
                   ';0;' + prgPtr.strProcName);
        end;
      end
      // String variable declaration
      else if varPtr.isArrayDataType and (varPtr.arrayDataType = 'string') then begin
        // String variable constant declaration
        if System.Pos('=', varDeclList[i]) > 0 then begin
          params := varDeclList[i].Split('=');

          // Check string dimension and extract string variable
          temp := '0'; 
          if System.Pos('(', params[0]) > 0 then begin
            temp := ExtractText(params[0], '(', ')');
            params[0] := Extract(1, params[0], '(', []);
          end;
          vars.Add(params[0] + '=' + varPtr.dataType + ';2;' +
                   params[1] + ';' + temp + ';' + prgPtr.strProcName);
        end
        // String variable declaration
        else begin
          // Check string dimension and extract string variable
          temp := '0'; 
          if System.Pos('(', varDeclList[i]) > 0 then begin
            temp := ExtractText(varDeclList[i], '(', ')');
            varDeclList[i] := Extract(1, varDeclList[i], '(', []);
          end;
          vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';2;0;' +
                   temp + ';' + prgPtr.strProcName);
        end;
      end
      // BYTE ARRAY declaration
      else if varPtr.isArrayDataType and (varPtr.arrayDataType = 'byte') then begin
        temp02 := '';
        params := varDeclList[i].Split('=');
        // Check string dimension and extract string variable
        if System.Pos('(', varDeclList[i]) > 0 then begin
          temp := ExtractText(varDeclList[i], '(', ')');
          varDeclList[i] := Extract(1, varDeclList[i], '(', []);
        end
        // Predeclared value is expected
        else if System.Pos('[', params[1]) > 0 then begin
          temp := '0'; 
          varPtr.isByteArray := true;
          varPtr.byteArray := Extract(2, params[1], '[', []);
        end
        // BYTE ARRAY COL=708
        else if Length(params[1]) > 0 then begin
          temp02 := params[1];
        end;
        if not varPtr.isByteArray then begin
          vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';4;' +
                   temp02 + ';' + temp + ';' + prgPtr.strProcName);
        end
        // BYTE ARRAY predefined values
        else begin
          varPtr.str01 := params[0] + '=' + varPtr.dataType + ';4;';
          varPtr.str02 := ';0;' + prgPtr.strProcName;
        end;
      end
      // CARD ARRAY declaration
      else if varPtr.isArrayDataType and (varPtr.arrayDataType = 'word') then begin
        temp02 := '';
        params := varDeclList[i].Split('=');
        // Check string dimension and extract string variable
        if System.Pos('(', varDeclList[i]) > 0 then begin
          temp := ExtractText(varDeclList[i], '(', ')');
          varDeclList[i] := Extract(1, varDeclList[i], '(', []);
        end
        // Predeclared value is expected
        else if System.Pos('[', params[1]) > 0 then begin
          temp := '0'; 
          varPtr.isCardArray := true;
          varPtr.cardArray := Extract(2, params[1], '[', []);
        end
        // CARD ARRAY COL=52000
        else if Length(params[1]) > 0 then begin
          temp02 := params[1];
        end;
        // CARD ARRAY predefined values
        if not varPtr.isCardArray then begin
          vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';5;' +
                   temp02 + ';' + temp + ';' + prgPtr.strProcName);
        end
        else begin
          varPtr.str01 := params[0] + '=' + varPtr.dataType + ';5;';
          varPtr.str02 := ';0;' + prgPtr.strProcName;
          //vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';4;' + params[1] + ';' + temp);
        end;
      end
      // Pointer variable declaration
      else if varPtr.isPointerDataType then begin
        //^byte
        vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';3;0;0;' + prgPtr.strProcName);
      end
      // Standard or TYPE variable
      else begin
        //if varPtr.isTypeRecVarLast and not varPtr.isTypeDataType then begin
        if varPtr.isTypeDataType then begin
          Inc(varPtr.typeRecVarCnt);
          vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';0;' +
                   IntToStr(varPtr.typeRecVarCnt) + ';0;' + prgPtr.strProcName +
                   ';' + varPtr.typeDataTypeVar);
        end
        else begin
          vars.Add(varDeclList[i] + '=' + varPtr.dataType + ';0;0;0;' +
                   prgPtr.strProcName + ';');
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
    //varPtr.isFunc := true;
  end
  // No more declared variables for current data type
  else begin
    varPtr.isVar := false;
    varPtr.isVarEnd := true;
  end;
end;

{------------------------------------------------------------------------------
 Description: DEFINE declaration block
 -----------------------------------------------------------------------------}
procedure DefineBlock(A: TStringArray);
var
  defineName : string;
  defineValue : string;
  j : word;
begin
  for j := 0 to High(a) do begin
    if UpperCase(a[j]) = 'DEFINE' then begin
      varPtr.isDefine := true;
    end
    else if varPtr.isDefine then begin
      defineName := Extract(1, a[j], '=', []); 
      defineValue := ExtractText(a[j], '"', '"');
      defineList.Add(defineName + '=' + defineValue);
      varPtr.isDefine := false;
    end;
  end;
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
 Description: Main code block for generating Mad Pascal code from Action! code
 -----------------------------------------------------------------------------}
procedure GenerateCode;
var
  i : LongInt;
  j : byte;
  pasFile : string;
  temp, temp02, temp03 : string;
  A: TStringArray;
  strGraphics : string = '';
  strStick : string = '';
begin
  code.Add('// Effectus auto-generated Mad Pascal source code listing');
  code.Add('program ' + prgName + 'Prg;' + LineEnding);
  code.Add('uses');

  if devicePtr.isGraphics then begin
    strStick := ', Graph';
  end;
  
  if devicePtr.isStick then begin
    strStick := ', Joystick';
  end;

  code.Add('  SySutils, Crt' + strGraphics + strStick + ';' + LineEnding);

  if prgPtr.isByteBuffer or devicePtr.isDevice then begin
    code.Add(LineEnding + 'var');
  end;
  
  if prgPtr.isByteBuffer then begin
    code.Add('  intValue : integer;');
  end;

  if devicePtr.isDevice then begin
    code.Add('  f : file;');
    code.Add('  strBuffer : string;');
  end;

  // Data type declaration initialization 
  varPtr.isVar := false;
  varPtr.isVarStart := false;
  varPtr.isDataType := false;
  //varPtr.isVarOver := false;
  varPtr.isVarEnd := false;
  varPtr.isArrayDataType := false;
  varPtr.isTypeDataType := false;
  varPtr.typeDataTypeVar := '';
  varPtr.isTypeRecVarLast := false;
  varPtr.typeRecVarCnt := 0;
  varPtr.isPointerAddress := false;
  // PROCedure declaration initialization
  prgPtr.isProc := false;
  prgPtr.isProcBegin := false;
  varPtr.isByteArray := false;
  varPtr.isCardArray := false;
  procML.isAsm := false;
  procML.strAsm := '';
  prgPtr.isProcName := false;
  prgPtr.strProcName := '';
  prgPtr.isProcFirstBegin := false;
  prgPtr.isProcAddr := false;
  prgPtr.isFuncAsm := false;
  devicePtr.isOpen := false;
  varPtr.isDefine := false;
  branchPtr.isUntil := false;
  branchPtr.untilCode := '';
  varPtr.isFunc := false;
  //varPtr.isParamVar := false;
  prgPtr.isBegin := false;

  operators := TStringArray.Create(
    '+', '-', '/', '*', '{MOD}', '{AND}', '{OR}', '{XOR}', '{LSH}', '{RSH}');

  for i := 0 to effCode.Count - 1 do begin
    temp := Trim(effCode[i]);
    if temp = '' then continue;

    // Check comments
    if temp[1] = ';' then begin
      temp := Extract(2, temp, ';', []);
      code.Add('// ' + temp);
      continue;
    end;

    effCode[i] := StringReplace(effCode[i], '  ', ' ', [rfReplaceAll]);

    effCode[i] := StringReplace(effCode[i], '( ', '(', [rfReplaceAll]);
    effCode[i] := StringReplace(effCode[i], ' )', ')', [rfReplaceAll]);

    effCode[i] := StringReplace(effCode[i], ' =', '=', [rfReplaceAll]);
    effCode[i] := StringReplace(effCode[i], '= ', '=', [rfReplaceAll]);

    effCode[i] := StringReplace(effCode[i], ' +', '+', [rfReplaceAll]);
    effCode[i] := StringReplace(effCode[i], '+ ', '+', [rfReplaceAll]);

    effCode[i] := StringReplace(effCode[i], ' -', '-', [rfReplaceAll]);
    effCode[i] := StringReplace(effCode[i], '- ', '-', [rfReplaceAll]);

    effCode[i] := StringReplace(effCode[i], ' *', '*', [rfReplaceAll]);
    effCode[i] := StringReplace(effCode[i], '* ', '*', [rfReplaceAll]);

    effCode[i] := ReplaceToken(effCode[i], '&', '&', '{AND}');
    effCode[i] := ReplaceToken(effCode[i], '%', '%', '{OR}');
    effCode[i] := ReplaceToken(effCode[i], '!', '!', '{XOR}');
    effCode[i] := ReplaceToken(effCode[i], 'XOR', '{XOR}', '{XOR}');
    effCode[i] := ReplaceToken(effCode[i], 'LSH', '{LSH}', '{LSH}');
    effCode[i] := ReplaceToken(effCode[i], 'RSH', '{RSH}', '{RSH}');
    effCode[i] := ReplaceToken(effCode[i], 'MOD', '{MOD}', '{MOD}');
     
//     if (System.Pos('!', effCode[i]) > 1) and (System.Pos('"', effCode[i]) > 0)
//        and (System.Pos('!', effCode[i]) > System.Pos('"', effCode[i])) then
//     begin
//     end
//     else begin
//       effCode[i] := StringReplace(effCode[i], ' !', '!', [rfReplaceAll]);
//       effCode[i] := StringReplace(effCode[i], '! ', '!', [rfReplaceAll]);
//       effCode[i] := StringReplace(effCode[i], '!', '{XOR}', [rfReplaceAll]);
//     end;

//     if (System.Pos('LSH', effCode[i]) > 1) and (System.Pos('"', effCode[i]) > 0)
//        and (System.Pos('LSH', effCode[i]) > System.Pos('"', effCode[i])) then
//     begin
//     end
//     else begin
//       effCode[i] := StringReplace(effCode[i], ' LSH ', '{LSH}', [rfReplaceAll]);
//       effCode[i] := StringReplace(effCode[i], 'LSH ', '{LSH}', [rfReplaceAll]);
//       effCode[i] := StringReplace(effCode[i], ' LSH', '{LSH}', [rfReplaceAll]);
//     end;
// // 
//     if (System.Pos('MOD', effCode[i]) > 1) and (System.Pos('"', effCode[i]) > 0)
//        and (System.Pos('MOD', effCode[i]) > System.Pos('"', effCode[i])) then
//     begin
//     end
//     else begin
//       effCode[i] := StringReplace(effCode[i], ' MOD ', '{MOD}', [rfReplaceAll]);
//       effCode[i] := StringReplace(effCode[i], 'MOD ', '{MOD}', [rfReplaceAll]);
//       effCode[i] := StringReplace(effCode[i], ' MOD', '{MOD}', [rfReplaceAll]);
//     end;

    effCode[i] := ReplaceStr(effCode[i], ', ', ',');

//     // Check if == assignment is in string
//     if (System.Pos('==', effCode[i]) > 1) and (System.Pos('"', effCode[i]) > 0)
//        and (System.Pos('==', effCode[i]) > System.Pos('"', effCode[i])) then
//     begin
//       effCode[i] := StringReplace(effCode[i], '==', '=,=', [rfReplaceAll]);
//     end;

    // Check if comments character ";" is between string quotes ""
    if (System.Pos(';', temp) > 1) then begin
      if (System.Pos('"', temp) > 0)
         and (System.Pos(';', temp) > System.Pos('"', temp)) then
      begin
      end
      else begin
        effCode[i] := Extract(1, effCode[i], ';', []);
      end;
    end;

    effCode[i] := ReplaceStr(effCode[i], ', ', ',');

    // Split words separated by space
    A := effCode[i].Split(' ', '"', '"');

    // Parse each command or statement delimited by space
    if High(a) >= 0 then begin
      DefineBlock(a);

      for j := 0 to High(a) do begin
        // Still DEFINE block?
        if a[j] = 'DEFINE' then begin
          varPtr.isDefine := true;
          Continue;
        end
        else if varPtr.isDefine then begin
          varPtr.isDefine := false;
          Continue;
        end;

        a[j] := ReplaceStr(a[j], 'MODULE', '');

        temp03 := '';
        temp02 := Extract(1, a[j], '(', []);
        if System.Pos(')', a[j]) > 0 then begin
          temp03 := '(' + Extract(2, a[j], '(', []);
        end;

        if defineList.IndexOfName(temp02) >= 0 then begin
          a[j] := ExtractDelimited(1, defineList.ValueFromIndex[defineList.IndexOfName(temp02)], [';']);
          a[j] += temp03;
        end;

        // PROC statement is found, PROCedure name and parameters are expected
        if ((UpperCase(a[j]) = 'PROC') or (UpperCase(a[j]) = 'FUNC'))
           and not prgPtr.isProc then
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
                  if not varPtr.isByteArray and not varPtr.isCardArray and not varPtr.isTypeDataType
                  then begin
                    VarDecl(false);
                    if prgPtr.isProcName and not prgPtr.isBegin then begin
                      if not prgPtr.isFuncAsm then
                      code.Add('begin');
                    end;
                    prgPtr.isProcBegin := true;
                  end;
                  varPtr.isVarEnd := false;
                  varPtr.isVarStart := false;
                end;
              end
              else if not varPtr.isVarStart and varPtr.isVarOver then begin
                varPtr.isVarOver := false;
                if not prgPtr.isProcBegin then begin
                  if not prgPtr.isFuncAsm then 
                  code.Add('begin');
                end;
              end;
              // Source code listing body
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
  if devicePtr.isDevice then begin
    code.Add('  Close(f);');
  end;
  code.Add('end.');

  //FilenameSrc := ExtractFileName(actionFilename);
  //FilenameSrc := Copy(FilenameSrc, 1, RPos('.', FilenameSrc) - 1);
  //FilenameSrc += '.pas';

  FilenameSrc := ExtractFilePath(actionFilename);
  pasFile := ExtractFilenameWithoutExt(actionFilename) + '.pas';
  FilenameSrc += pasFile;
  
  //pasFile := GetCurrentDir + PathDelim + FilenameSrc;
  code.SaveToFile(FilenameSrc);
end;

end.
