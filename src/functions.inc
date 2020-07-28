{
  Program: Effectus - Action! language parser and cross-assembler to native binary code
           for Atari 8-bit home computers

  Authors : Bostjan Gorisek (Effectus)
            Tebe (Mad Assembler, Mad Pascal)
            zbyti, Mariusz Buk (Effectus support, new features, bug fixes and refactoring)

  Unit file  : functions.inc
  Description: Emulated Action! functions

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
       branchPtr.isFuncInIf := false;

       // Function is in IF condition block
       if (branchPtr.isIfThen and branchPtr.isIfThenInProgress) or
          branchPtr.isWhile or branchPtr.isUntil then
       begin
         FuncInIfCond(procName, temp, params2);
       end
       // Function is not in IF condition block
       else begin
         // doubled delimiter - to be sure ;)
         temp := ',' + procName + ',';

         // RAND, PEEK, PEEKC, VALB, VALC, VALI, GETD, INPUTBD, INPUTCD, INPUTID
         temp01 := '  ' + funcVar + ' := ' + _MARKER + '(' + params2 + ');';
         // INPUTB, INPUTC, INPUTI
         temp02 := '  ' + _MARKER + '(' + funcVar + ');';
         // STICK, STRIG, PADDLE, PTRIG
         temp03 := '  ' + funcVar + ' := ' + _MARKER + '[' + params2 + '];';
         // ReplaceKey function works on _REPLACEMENT array
         temp04 := ReplaceKey(_MARKER, procName);

         if Pos(temp, ',RAND,PEEK,PEEKC,VALB,VALC,VALI,GETD,INPUTBD,INPUTCD,INPUTID,') > 0 then
           temp01 := ReplaceStr(temp01, _MARKER, temp04)
         else if Pos(temp, ',INPUTB,INPUTC,INPUTI,') > 0 then
           temp02 := ReplaceStr(temp02, _MARKER, temp04)
         else if Pos(temp, ',STICK,STRIG,PADDLE,PTRIG,') > 0 then
           temp03 := ReplaceStr(temp03, _MARKER, temp04);

         if procName = 'GETD' then begin
           if params2 = '7' then temp01 += LineEnding + '  ReadKey;';
         end;

         if Pos(_MARKER, temp01) = 0 then code.Add(temp01)
         else if Pos(_MARKER, temp02) = 0 then code.Add(temp02)
         else if Pos(_MARKER, temp03) = 0 then code.Add(temp03);

         if procName = 'LOCATE' then begin
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
         end;

         if procName = 'SCOMPARE' then begin
           params := params2.Split(',');
           //writeln('scompare params2 = ', params2);
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
             temp := '  ' + funcVar + ' := ' + params2 + ';';
             code.Add(temp);
           end;
         end;
       end;
