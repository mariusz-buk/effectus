
       if procName = 'PRINT' then begin
         temp := '  Write(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'PRINTE' then begin
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

         if devicePtr.isDevice then begin  
           temp := '  assign(f, ''S:''); rewrite(f, 1);' + LineEnding;
         end;

         devicePtr.isGr0 := params2 = '0';
//          if params2 = '0' then begin
//            devicePtr.isGr0 := true
//          end

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
         //temp := '  FloodFillH(' + params2 + ', ' + prgPtr.colorValue + ');';
         temp := '  FloodFill(' + params2 + ', ' + prgPtr.colorValue + ');';
         code.Add(temp);
       end
       else if procName = 'POSITION' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           //prgPtr.posX := params[0];
           //prgPtr.posY := params[1];
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
         temp := '  FillChar(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'MOVEBLOCK' then begin
         params := params2.Split(',');
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
         if params2[1] = '''' then begin
           temp := Extract(2, params2, '''');
           temp := '  Write(' + QuotedStr(temp) + ');  // test put';
         end
         else begin
           temp := '  Write(Chr(' + params2 + '));';
         end;
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
         //writeln('params2 = ', params2);
         
         // Process
         if System.Pos('%%', temp) > 0 then begin
           //SplitStr(temp, '%%', aList);
           temp := ReplaceStr(temp, '%%', '%{percentEff}');
         end;

         temp := ExtractText(temp, '"', '"');
         temp02 := QuotedStr(Extract(1, temp, '%'));
         //temp02 := QuotedStr(ReplaceStr(temp02, '"', '')) + ', ';

         // "line: %i%E",i
         // "line: %s%E",str
         paramsEx := temp.Split('%');
         for i := 1 to High(paramsEx) do begin
           if UpperCase(paramsEx[i][1]) = 'I' then begin
             Inc(cnt); 
             params[cnt] := ReplaceStr(params[cnt], '(', '[');
             params[cnt] := ReplaceStr(params[cnt], ')', ']');              
             //temp02 += params[i] + ', ' + QuotedStr(Extract(2, paramsEx[i], 'i', []));
             temp02 += ', ' + params[cnt] + ', ' + QuotedStr(Copy(paramsEx[i], 2, Length(paramsEx[i]) - 1));
           end
           else if UpperCase(paramsEx[i][1]) = 'U' then begin
             Inc(cnt);
             //writeln('params[cnt] = ', cnt, ' ', params[cnt]);
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
             //temp02 += params[i] + ', ' + QuotedStr(Extract(2, paramsEx[i], 'i', []));
             temp02 += ', Chr(' + params[cnt] + '), ' + QuotedStr(Copy(paramsEx[i], 2, Length(paramsEx[i]) - 1));
           end
           else if System.Pos('{percentEff}', paramsEx[i]) > 0 then begin
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
             //end;
           end;
         end;
         code.Add('  Write(' + temp02 + ');');
       end
       else if procName = 'OPEN' then begin
         devicePtr.isOpen := true;
         params := params2.Split(',');
         if High(params) > 0 then begin
           //assign(f, s);
           //reset(f, sizeof(cardinal));
           temp := '  Assign(f, ' + params[1] + ');' + LineEnding;

           if Trim(params[2]) = '4' then
             //temp += '  Reset(f, sizeOf(byteBuffer));'
             temp += '  Reset(f, 1);'
           else begin
             //temp += '  Rewrite(f, sizeOf(byteBuffer));';
             temp += '  Rewrite(f, 1);';
           end;
           code.Add(temp);
         end;
       end
       else if (procName = 'CLOSE') then begin
         if devicePtr.isOpen then begin
           devicePtr.isOpen := false;
           temp := '  Close(f);';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTD' then begin
         //params := params2.Split(',');
         //if High(params) > 0 then begin
           //Position(6,  'hi);  Blockwrite(f, atariage'[1], length(atariage'));
           //Blockwrite(f,  'hi atariage'[1], length( 'hi atariage'));
           temp03 := StringReplace(params2, ',', '{', []);
           temp03 := Extract(2, temp03, '{');
           temp := '  strBuffer := ' + temp03 + ';' + LineEnding;
           //temp := '  GotoXY(' + prgPtr.posX + ', ' + prgPtr.posY + ');' + LineEnding;
           temp += '  Blockwrite(f, strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         //end;
       end
       else if procName = 'PRINTDE' then begin
         //writeln('params2 = ', params2);
         //params := params2.Split(',');  //, '"', '"', 1);
         //if High(params) > 0 then begin
           //temp := '  strBuffer := Concat(' + params[1] + ', ' + QuotedStr('$9b') + ');' + LineEnding;
           temp03 := StringReplace(params2, ',', '{', []);
           temp03 := Extract(2, temp03, '{');
           temp := '  strBuffer := Concat(' + temp03 + ', #$9b);' + LineEnding;
           temp += '  Blockwrite(f, strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         //end;
       end
       else if procName = 'PRINTBD' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           //Position(6,  'hi);  Blockwrite(f, atariage'[1], length(atariage'));
           //Blockwrite(f,  'hi atariage'[1], length( 'hi atariage'));
           temp := '  strBuffer := IntToStr(' + params[1] + ');' + LineEnding;
           //temp := '  GotoXY(' + prgPtr.posX + ', ' + prgPtr.posY + ');' + LineEnding;
           temp += '  Blockwrite(f, strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTBDE' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           //Position(6,  'hi);  Blockwrite(f, atariage'[1], length(atariage'));
           //Blockwrite(f,  'hi atariage'[1], length( 'hi atariage'));
           temp := '  strBuffer := Concat(IntToStr(' + params[1] + '), #$9b);' + LineEnding;
           //temp := '  strBuffer := Concat(' + params[1] + ', #$9b);' + LineEnding;
           //temp := '  GotoXY(' + prgPtr.posX + ', ' + prgPtr.posY + ');' + LineEnding;
           temp += '  Blockwrite(f, strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTCD' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           //Position(6,  'hi);  Blockwrite(f, atariage'[1], length(atariage'));
           //Blockwrite(f,  'hi atariage'[1], length( 'hi atariage'));
           temp := '  strBuffer := IntToStr(' + params[1] + ');' + LineEnding;
           //temp := '  GotoXY(' + prgPtr.posX + ', ' + prgPtr.posY + ');' + LineEnding;
           temp += '  Blockwrite(f, strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTCDE' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           //Position(6,  'hi);  Blockwrite(f, atariage'[1], length(atariage'));
           //Blockwrite(f,  'hi atariage'[1], length( 'hi atariage'));
           temp := '  strBuffer := Concat(IntToStr(' + params[1] + '), #$9b);' + LineEnding;
           //temp := '  GotoXY(' + prgPtr.posX + ', ' + prgPtr.posY + ');' + LineEnding;
           temp += '  Blockwrite(f, strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTID' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           //Position(6,  'hi);  Blockwrite(f, atariage'[1], length(atariage'));
           //Blockwrite(f,  'hi atariage'[1], length( 'hi atariage'));
           temp := '  strBuffer := IntToStr(' + params[1] + ');' + LineEnding;
           //temp := '  GotoXY(' + prgPtr.posX + ', ' + prgPtr.posY + ');' + LineEnding;
           temp += '  Blockwrite(f, strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'PRINTIDE' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           //Position(6,  'hi);  Blockwrite(f, atariage'[1], length(atariage'));
           //Blockwrite(f,  'hi atariage'[1], length( 'hi atariage'));
           temp := '  strBuffer := Concat(IntToStr(' + params[1] + '), #$9b);' + LineEnding;
           //temp := '  GotoXY(' + prgPtr.posX + ', ' + prgPtr.posY + ');' + LineEnding;
           temp += '  Blockwrite(f, strBuffer[1], Length(strBuffer));';
           code.Add(temp);
         end;
       end
       else if procName = 'INPUTSD' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           temp := '  BlockRead(f, ' + params[1] + ', 255);';
           code.Add(temp);
         end;
       end
       else if procName = 'INPUTMD' then begin
         params := params2.Split(',');
         if High(params) > 0 then begin
           temp := '  BlockRead(f, ' + params[1] + ', ' + params[2] + ');';
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
