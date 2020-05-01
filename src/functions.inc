
       if procName = 'RAND' then begin
         temp := '  ' + funcVar + ' := Random(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'PEEK' then begin
         if IsNumber(params2[1]) then
           temp := '  ' + funcVar + ' := Peek(' + params2 + ');'
         else begin
           temp := '  ' + funcVar + ' := ' + params2 + ';'
         end;
         code.Add(temp);
       end
       else if procName = 'PEEKC' then begin
         temp := '  ' + funcVar + ' := DPeek(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'VALB' then begin
         temp := '  ' + funcVar + ' := StrToInt(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'VALC' then begin
         temp := '  ' + funcVar + ' := StrToInt(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'VALI' then begin
         temp := '  ' + funcVar + ' := StrToInt(' + params2 + ');';
         code.Add(temp);
       end
       else if procName = 'STICK' then begin
         temp := '  ' + funcVar + ' := stick[' + params2 + '];';
         code.Add(temp);
       end
       else if procName = 'STRIG' then begin
         temp := '  ' + funcVar + ' := strig[' + params2 + '];';
         code.Add(temp);
       end
       else if procName = 'PADDLE' then begin
         temp := '  ' + funcVar + ' := paddl[' + params2 + '];';
         code.Add(temp);
       end
       else if procName = 'PTRIG' then begin
         temp := '  ' + funcVar + ' := ptrig[' + params2 + '];';
         code.Add(temp);
       end
       else if procName = 'GETD' then begin
         if params2 = '7' then
           temp := '  ' + funcVar + ' := ReadKey;'
         else begin
           temp := '  BlockRead(f, ' + funcVar + ', 1);';
         end;
         code.Add(temp);
       end
       else if procName = 'INPUTB' then begin
         temp := '  Readln(' + funcVar + ');';
         code.Add(temp);
       end
       else if procName = 'INPUTC' then begin
         temp := '  Readln(' + funcVar + ');';
         code.Add(temp);
       end
       else if procName = 'INPUTI' then begin
         temp := '  Readln(' + funcVar + ');';
         code.Add(temp);
       end
       else if procName = 'INPUTBD' then begin
         temp := '  BlockRead(f, ' + funcVar + ', 1);';
         code.Add(temp);
       end
       else if procName = 'INPUTCD' then begin
         temp := '  BlockRead(f, ' + funcVar + ', 1);';
         code.Add(temp);
       end
       else if procName = 'INPUTID' then begin
         temp := '  BlockRead(f, ' + funcVar + ', 1);';
         code.Add(temp);
       end
       else if procName = 'LOCATE' then begin
         if devicePtr.isGr0 then begin
           params := params2.Split(',');
           if High(params) > 0 then begin
             temp := '  ' + funcVar + ' := GetPixel(' + params[0] + ' + 1, ' + params[1] + ');';
           end;         
         end
         else begin
           temp := '  ' + funcVar + ' := GetPixel(' + params2 + ');';
         end;
         code.Add(temp);         
       end
       else if procName = 'SCOMPARE' then begin
         params := params2.Split(',');
         if High(params) = 1 then begin
           params[0] := Trim(params[0]);
           params[1] := Trim(params[1]);
           if params[0] < params[1] then
             params2 := '-1'
           else if params[0] = params[1] then
             params2 := '0'
           else begin
             params2 := '1'
           end;

           if branchPtr.isIfThenInProgress then begin
             if branchPtr.ifTempCode = '' then begin
               funcVar := '  intValue ';
               temp := '  ' + funcVar + ' := ' + params2 + ';';
               branchPtr.ifTempCode := ' ' + funcVar + '=' + params2 + ' ';
             end;
           end
           else begin 
             temp := '  ' + funcVar + ' := ' + params2 + ';';
           end;
           code.Add(temp);
         end;
       end;
