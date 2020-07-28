{
  Program: Effectus - Action! language parser and cross-assembler to native binary code
           for Atari 8-bit home computers

  Authors : Bostjan Gorisek (Effectus)
            Tebe (Mad Assembler, Mad Pascal)
            zbyti, Mariusz Buk (Effectus support, new features, bug fixes and refactoring)

  Unit file  : procedures.inc
  Description: Emulated Action! procedures

  Effectus parses Action! language source code listings and generates native binary code
  for 8-bit Atari home computers by using excellent Mad Pascal and Mad Assembler languages.

  Effectus is compiled with Free Pascal 3.0.4.

  References:
    https://github.com/mariusz-buk/effectus
    http://freeweb.siol.net/diomedes/effectus/
    http://mads.atari8.info/

  This program is free software: you can redistribute it and/or modify it under the terms of
  the GNU General Public License as published by the Free Software Foundation, either version 3
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along with this program.
  If not, see <http://www.gnu.org/licenses/>.
}

       //writeln('procName = ', procName);

       if procName = 'PRINT' then begin
         temp := '  Write(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'PRINTE' then begin
         if (params[0] = '""') or (UpperCase(params[0]) = 'PRINTE()') then
              params2 := QuotedStr('');

         temp := '  Writeln(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'PRINTB' then begin
         temp := '  Write(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'PRINTBE' then begin
         temp := '  Writeln(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'PRINTI' then begin
         temp := '  Write(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'PRINTIE' then begin
         temp := '  Writeln(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'PRINTC' then begin
         temp := '  Write(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'PRINTCE' then begin
         temp := '  Writeln(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'PUTE' then begin
         temp := '  Writeln(' + QuotedStr(params2) + ');';
         code.Add(temp);
       end
       else if procName = 'GRAPHICS' then begin
         temp := '';
         devicePtr.isGr0 := params2 = '0';
         temp += '  InitGraph(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'PLOT' then begin
         temp := '  PutPixel(' + params2 + ');' + LineEnding;
         temp += '  MoveTo(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'DRAWTO' then begin
         temp := '  LineTo(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'FILL' then begin
         temp := '  FloodFill(' + params2 + ', ' + prgPtr.colorValue + ');';
         code.Add(temp);
       end
       else if procName = 'POSITION' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           temp := '  GotoXY(' + params[0] + ' + 1, ' + params[1] + ' + 1);';
         end;
         code.Add(temp);
       end
       else if procName = 'POKE' then begin
         temp := '  Poke(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'POKEC' then begin
         temp := '  DPoke(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'ZERO' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           params2 := '';
           for j := 0 to High(params) do begin
             if j = 0 then begin
               if vars.IndexOfName(params[j]) >= 0 then begin
                 if VarValue(2, vars.IndexOfName(params[j]), _VAR_BYTE_ARRAY)
                    or VarValue(2, vars.IndexOfName(params[j]), _VAR_CARD_ARRAY) then
                 begin
                   params[j] := '@' + params[j];
                 end;
               end;
               params2 += 'pointer(' + params[j] + '),';
             end
             else begin
               params2 += params[j];
             end;
           end;
         end;
         temp := '  FillChar(' + params2 + ', 0);';
         code.Add(temp);
       end
       else if procName = 'SETBLOCK' then begin
         params := params2.Split(',');
         params[0] := Trim(params[0]);
         if vars.IndexOfName(params[0]) >= 0 then begin
           if VarValue(2, vars.IndexOfName(params[0]), _VAR_BYTE_ARRAY) or
              VarValue(2, vars.IndexOfName(params[0]), _VAR_CARD_ARRAY) then
           begin
             //params[j] := '@' + params[j];
             //params[0] := 'pointer(' + params[0] + ')';
           end
           else begin
             params[0] := 'pointer(' + params[0] + ')';
           end;
         end
         else begin
           params[0] := 'pointer(' + params[0] + ')';
         end;
         params[1] := Trim(params[1]);
         params[2] := Trim(params[2]);
         params2 := params[0] + ', ' + params[1] + ', ' + params[2];
         temp := '  FillChar(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'MOVEBLOCK' then begin
         params := params2.Split(',');
         params[0] := Trim(params[0]);
         params[1] := Trim(params[1]);
         if IsNumber(params[1][1]) then
              params[1] := 'pointer(' + Trim(params[1]) + ')';

         params2 := Trim(params[1]) + ', pointer(' + Trim(params[0]) + '), ' + params[2];
         temp := '  Move(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'SOUND' then begin
         temp := '  Sound(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'SNDRST' then begin
         temp := '  Sound(0, 0, 0, 0);' + LineEnding +
                 '  Sound(1, 0, 0, 0);' + LineEnding +
                 '  Sound(2, 0, 0, 0);' + LineEnding +
                 '  Sound(3, 0, 0, 0);';
         code.Add(temp);
       end
       else if procName = 'PUT' then begin
         temp := '  Write(Chr(' + params2 + '));';
         code.Add(temp);
       end
       else if procName = 'STRB' then begin
         temp := '  ' + params[1] + ' := IntToStr(' + params[0] + ');';
         code.Add(temp);
       end
       else if procName = 'STRC' then begin
         temp := '  ' + params[1] + ' := IntToStr(' + params[0] + ');';
         code.Add(temp);
       end
       else if procName = 'STRI' then begin
         temp := '  ' + params[1] + ' := IntToStr(' + params[0] + ');';
         code.Add(temp);
       end
       else if procName = 'SCOPY' then begin
         params := params2.Split(',');
         temp := '  ' + params[0] + ' := ' + params[1] + ';';
         code.Add(temp);
       end
       else if procName = 'SCOPYS' then begin
         params := params2.Split(',');
         temp := '  ' + params[0] + ' := ' +
                 'Copy(' + params[1] + ',' + params[2] + ', ' + params[3] + ' - ' + params[2] + ' + 1);';
         code.Add(temp);
       end
       else if procName = 'SASSIGN' then begin
         // SASSIGN(STR01,"ATARI",7,11)
         params := params2.Split(',');
//         temp := '  ' + params[0] + ' := ' +
//                 'Insert(' + params[1] + ',' + params[0] + ',' + params[2] + ');' + LineEnding;
         //temp := '  ' + params[0] + ' := AddCharR(  C: Char; var S: string; N: Byte)
//         temp += '  ' + params[0] + ' := ' +
//                 'Copy(' + params[0] + ', 1, ' + params[3] +  ');';
                 //'Copy(' + params[0] + ', ' + params[3] + ', ' + 'Length(' + params[0] + ')' +
                 //' - (' + params[3] + ' - ' + params[2] + '));';
         //str01 := Copy(str01, 1, 7) + str02 + Copy(str01, 11, Length(str01));
         temp := '  ' + params[0] + ' := Concat(Concat(Copy(' + params[0] + ', 1, ' + params[2] + ' - 1), ' +
                 params[1] + '), Copy(' + params[0] + ', ' + params[3] + ' + 1, Length(' + params[0] + ')));';
         code.Add(temp);
       end
       else if procName = 'SETCOLOR' then begin
         params := params2.Split(',');
         temp := '  Poke(708 + ' + params[0] + ', ' + params[1] + '*16 + ' + params[2] + ');';
         code.Add(temp);
       end
       else if procName = 'INPUTS' then begin
         temp := '  Readln(' + params2 + ');';
         code.Add(temp);
       end
       (*
       format char	description for Action!:
       %I	INT
       %U	CARD (the U stands for Unsigned) and BYTE
       %C	print as a character
       %H	Hexadecimal number
       %E	the RETURN character
       %%	output the percent sign
       %S	output as a string

       Some examples:
         PrintF("%EA%EB%E")
         PrintF("%EThe sum of %U and %U is %U%E",a,b,a+b
         PrintF("The letter %C.%E",65)
         PrintF("Score %U: %U",player,score(player))
       *)
       else if procName = 'PRINTF' then begin
         // Format string definition
         params := params2.Split(',', '"', '"');
         temp := params[0];
         if Pos('%%', temp) > 0 then
              temp := ReplaceStr(temp, '%%', '%{percentEff}');

         temp := ExtractText(temp, '"', '"');
         temp02 := QuotedStr(Extract(1, temp, '%'));

         // "line: %i%E",i
         // "line: %s%E",str
         paramsEx := temp.Split('%');
         for i := 1 to High(paramsEx) do begin
           if UpperCase(paramsEx[i][1]) = 'I' then begin
             Inc(cnt);
             params[cnt] := ReplaceStr(params[cnt], '(', '[');
             params[cnt] := ReplaceStr(params[cnt], ')', ']');
             temp02 += ', ' + params[cnt] + ', ' + QuotedStr(Copy(paramsEx[i], 2, Length(paramsEx[i]) - 1));
           end
           else if UpperCase(paramsEx[i][1]) = 'U' then begin
             Inc(cnt);
             params[cnt] := ReplaceStr(params[cnt], '(', '[');
             params[cnt] := ReplaceStr(params[cnt], ')', ']');
             temp02 += ', ' + params[cnt] + ', ' + QuotedStr(Copy(paramsEx[i], 2, Length(paramsEx[i]) - 1));
           end
           else if UpperCase(paramsEx[i][1]) = 'S' then begin
             Inc(cnt);
             params[cnt] := ReplaceStr(params[cnt], '(', '[');
             params[cnt] := ReplaceStr(params[cnt], ')', ']');
             temp02 += ', ' + params[cnt] + ', ' + QuotedStr(Copy(paramsEx[i], 2, Length(paramsEx[i]) - 1));
           end
           else if UpperCase(paramsEx[i][1]) = 'H' then begin
             Inc(cnt);
             params[cnt] := ReplaceStr(params[cnt], '(', '[');
             params[cnt] := ReplaceStr(params[cnt], ')', ']');
             temp02 += ', ' + QuotedStr('$') + ', HexStr(' + params[cnt] + ', 4), ' + QuotedStr(Copy(paramsEx[i], 2, Length(paramsEx[i]) - 1));
           end
           else if UpperCase(paramsEx[i][1]) = 'C' then begin
             Inc(cnt);
             temp02 += ', Chr(' + params[cnt] + '), ' + QuotedStr(Copy(paramsEx[i], 2, Length(paramsEx[i]) - 1));
           end
           else if Pos('{percentEff}', paramsEx[i]) > 0 then begin
             SplitStr(paramsEx[i], '{percentEff}', aList);
             if aList.Count = 1 then begin
               temp02 += ', ' + QuotedStr('%');
             end
             else if aList.Count > 1 then begin
               temp02 += ', ' + QuotedStr('%' + aList[1]);
             end;
             //temp02 := QuotedStr(Extract(1, temp, '%', []));
             //temp02 += ', ' + QuotedStr('%') + QuotedStr(Copy(paramsEx[i], 1, 11));
           end
           else if UpperCase(paramsEx[i][1]) = 'E' then begin
             temp03 := Extract(2, paramsEx[i], 'E');
             //temp02 += 'eol, ' + QuotedStr(Extract(2, paramsEx[i], 'E', []));
//              if temp03 = '"' then
//                temp02 += ', eol'
//              else begin
             temp02 += ', eol, ' + QuotedStr(Copy(paramsEx[i], 2, Length(paramsEx[i]) - 1));
           end;
         end;
         code.Add('  Write(' + temp02 + ');');
       end
       else if procName = 'OPEN' then begin
//          //devicePtr.isOpen := true;
//          params := params2.Split(',');
//          if High(params) > 0 then begin
//            temp := '  Assign(f, ' + params[1] + ');' + LineEnding;
//            if Trim(params[2]) = '4' then
//              //temp += '  Reset(f, sizeOf(byteBuffer));'
//              temp += '  Reset(f, 1);'
//            else begin
//              //temp += '  Rewrite(f, sizeOf(byteBuffer));';
//              temp += '  Rewrite(f, 1);';
//            end;
//            code.Add(temp);
//          end;
          params := params2.Split(',');
          if High(params) > 0 then begin
            // procedure Opn(chn, ax1, ax2: byte; device: PByte); assembler;
            temp := '  Opn(' + params[0] + ', ' + Trim(params[2]) + ', 0, ' + Trim(params[1]) + ');';
            code.Add(temp);
          end;
       end
       else if (procName = 'CLOSE') then begin
         //procedure Cls(chn: byte); assembler;
         temp := '  Cls(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'PUTD' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           // Put(6, ord('A'*));
           temp := '  Put(' + params[0] + ', ' + params[1] + ');';
           code.Add(temp);
         end;
       end
       else if procName = 'PUTDE' then begin
         //temp := '  strBuffer := Concat(#$9b, ' + QuotedStr('') + ');' + LineEnding;
         //temp += '  Blockwrite(f, strBuffer[1], Length(strBuffer));';
         temp := '  Put(' + params2 + ', $9b);';
         code.Add(temp);
       end
       else if procName = 'PRINTD' then begin
         temp03 := StringReplace(params2, ',', '{', []);
         params := temp03.Split('{');
         if High(params) > 0 then begin
           temp := '  strBuffer := ' + params[1] + ';' + LineEnding;
           //temp := '  GotoXY(' + prgPtr.posX + ', ' + prgPtr.posY + ');' + LineEnding;
           temp += '  BPut(' + params[0] + ', @strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTDE' then begin
         temp03 := StringReplace(params2, ',', '{', []);
         params := temp03.Split('{');
         if High(params) > 0 then begin
           //temp03 := StringReplace(params2, ',', '{', []);
           //temp03 := Extract(2, temp03, '{');
           //temp := '  strBuffer := Concat(' + temp03 + ', #$9b);' + LineEnding;
           temp := '  strBuffer := Concat(' + Trim(params[1]) + ', #$9b);' + LineEnding;
           //temp += '  Blockwrite(f, strBuffer[1], Length(strBuffer));';
           temp += '  BPut(' + params[0] + ', @strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTBD' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           temp := '  strBuffer := IntToStr(' + params[1] + ');' + LineEnding;
           temp += '  BPut(' + params[0] + ', @strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTBDE' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           temp := '  strBuffer := Concat(IntToStr(' + params[1] + '), #$9b);' + LineEnding;
           temp += '  BPut(' + params[0] + ', @strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTCD' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           temp := '  strBuffer := IntToStr(' + params[1] + ');' + LineEnding;
           temp += '  BPut(' + params[0] + ', @strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTCDE' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           temp := '  strBuffer := Concat(IntToStr(' + params[1] + '), #$9b);' + LineEnding;
           temp += '  BPut(' + params[0] + ', @strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTID' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           temp := '  strBuffer := IntToStr(' + params[1] + ');' + LineEnding;
           temp += '  BPut(' + params[0] + ', @strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTIDE' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           temp := '  strBuffer := Concat(IntToStr(' + params[1] + '), #$9b);' + LineEnding;
           //temp += '  Blockwrite(f, strBuffer[1], Length(strBuffer));';
           temp += '  BPut(' + params[0] + ', @strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'INPUTSD' then begin
         //procedure BGet(chn: byte; buf: PByte; cnt: word); assembler; register;
         params := params2.Split(',');
         if High(params) > 0 then begin
           //temp := '  BlockRead(f, ' + params[1] + ', 255);';
           //temp := '  strBuffer := ' + params[1] + ';' + LineEnding;
           //temp := '  BGet(' + params[0] + ', @strBuffer[1], Length(strBuffer));';
           temp := '  BGet(' + params[0] + ', ' + params[1] + ', SizeOf(' + params[1] + '));';
           code.Add(temp);
         end;
       end
       else if procName = 'INPUTMD' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           //temp := '  BlockRead(f, ' + params[1] + ', ' + params[2] + ');';
           //temp := '  strBuffer := ' + params[1] + ';' + LineEnding;
           temp := '  BGet(' + params[0] + ', ' + params[1] + ', ' + params[2] + ');';
           code.Add(temp);
         end;
       end
       else if procName = 'XIO' then begin
         //procedure XIO(cmd, chn, ax1, ax2: byte; device: PByte); assembler;
         (*
         @param: cmd - command
         @param: chn - channel 0..7
         @param: ax1 - parameter
         @param: ax2 - parameter
         @param: device - name of device, example "S2:"
         PROC XIO(BYTE chan,0,cmd,auxl,aux2,<filestring))
         *)
         params := params2.Split(',');
         if High(params) > 0 then begin
           temp := '  XIO(' + params[2] + ', ' + params[0] + ', ' + params[3] + ', ' +
                              params[4] + ', ' + params[5] + ');' + LineEnding;
           code.Add(temp);
         end;
       end
       else begin
         if params2 = '' then
           code.Add('  ' + procName + 'Proc;')
         else begin
           code.Add('  ' + procName + 'Proc(' + params2 + ');');
         end;
       end;
