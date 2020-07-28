{
  Program: Effectus - Action! language parser and cross-assembler to native binary code
           for Atari 8-bit home computers

  Authors : Bostjan Gorisek (Effectus)
            Tebe (Mad Assembler, Mad Pascal)
            zbyti, Mariusz Buk (Effectus support, new features, bug fixes and refactoring)

  Unit file  : branches.inc
  Description: Branch and condition logic

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
        //branchPtr.isElseNext := false;
        //branchPtr.isElseIfNext := false;
      end
      else if (UpperCase(temp) = 'THEN') and branchPtr.isIfThenNext then begin
        branchPtr.ifThenCode += ' then begin';
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
        //branchPtr.isElseNext := true;
      end
      else if UpperCase(temp) = 'ELSEIF' then begin
        branchPtr.isIfThen := true;
        branchPtr.isIfThenInProgress := true;
        branchPtr.ifThenCode := '  end' + LineEnding + '  else if ';
        branchPtr.isIfThenNext := false;
        branchPtr.isEndIfNext := false;
        //branchPtr.isElseNext := false;
        //branchPtr.isElseIfNext := false;
        //branchPtr.isElseNext := true;
      end
      else if UpperCase(Trim(temp)) = 'FI' then begin
        code.Add('  end;  // if');
        branchPtr.isIfThen := false;
        branchPtr.isIfThenNext := false;
        branchPtr.isEndIfNext := false;
        branchPtr.ifThenCode := '';
        //branchPtr.isElseNext := false;
      end
      // FOR branch
      else if UpperCase(temp) = 'FOR' then begin
        branchPtr.isUndefRepeat := false;
        branchList.Add('FOR');
        branchPtr.Count := branchList.Count;
        branchPtr.isFor := true;
        //writeln('FOR branch ', branchPtr.Count);
      end
      // WHILE branch
      else if UpperCase(temp) = 'WHILE' then begin
        branchPtr.isUndefRepeat := false;
        branchList.Add('WHILE');
        branchPtr.Count := branchList.Count;
        branchPtr.isWhile := true;
        //writeln('WHILE branch', branchPtr.Count);
      end
      // FOR branch DO
      else if branchPtr.isFor and (UpperCase(temp) = 'DO') then begin
        branchPtr.isFor := false;
        branchPtr.forCode += ' do begin';
        branchPtr.forCode := ReplaceStr(branchPtr.forCode, '=', ':=');
        code.Add(branchPtr.forCode);
        branchPtr.forCode := '';
      end
      // WHILE branch DO
      else if branchPtr.isWhile and (UpperCase(temp) = 'DO') then begin
        branchPtr.isWhile := false;

        //writeln('branchPtr.whileCode = ', branchPtr.whileCode);
        //temp01 := Extract(2, UpperCase(branchPtr.whileCode), 'WHILE ');
        SplitStr(UpperCase(branchPtr.whileCode), 'WHILE ', aList);
        //writeln('alist[0] = ', alist[0]);
        //writeln('alist[1] = ', alist[1]);

        if vars.IndexOfName(aList[1]) >= 0 then begin
          branchPtr.whileCode += ' > 0';
        end;
        branchPtr.whileCode += ' do begin';
        code.Add(branchPtr.whileCode);
        branchPtr.whileCode := '';
      end
      else if (UpperCase(temp) = 'UNTIL') then begin
        branchPtr.isUntil := true;
        branchPtr.untilCode := '';
      end
      //else if branchPtr.isForOdNext and (UpperCase(temp) = 'OD') then begin
      else if UpperCase(temp) = 'OD' then begin
        Dec(branchPtr.Count);
        temp02 := branchList[branchPtr.Count] + ' ' + IntToStr(branchPtr.Count); 
        if branchList[branchPtr.Count] = 'FOR' then
          code.Add('  end;')
        else if branchList[branchPtr.Count] = 'WHILE' then
          code.Add('  end;')
        else if (branchList[branchPtr.Count] = 'REPEAT') and
                branchPtr.isUntil then
        begin
          if branchPtr.untilCode <> '' then begin
            code.Add(branchPtr.untilCode + ';');
            branchPtr.untilCode := '';
          end;
          branchPtr.isUntil := false;
        end
        else begin
          if branchPtr.isUndefRepeat then
            code.Add('  until false;')
          else
            code.Add('  end;');
        end;
        branchPtr.isUndefRepeat := true;
      end
      else if (UpperCase(temp) = 'ODFOR') or (UpperCase(temp) = 'ODWHILE') then begin
        code.Add('  end;');
      end
      // DO OD branch (repeat ... until ...)
      else if (UpperCase(temp) = 'DO') then begin
        branchList.Add('REPEAT');
        branchPtr.Count := branchList.Count;
        code.Add('  repeat');
        //writeln('REPEAT branch', branchPtr.Count);
      end
    end
