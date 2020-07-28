{
  Program: Effectus - Action! language parser and cross-assembler to native binary code
           for Atari 8-bit home computers

  Authors : Bostjan Gorisek (Effectus)
            Tebe (Mad Assembler, Mad Pascal)
            zbyti, Mariusz Buk (Effectus support, new features, bug fixes and refactoring)

  Unit file  : extra.inc
  Description: Extra, non-standard directives

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

  //effCode.Add('  asm {' + tempxy.strings[i]);
  //effCode.Add(tempxy.strings[i]);
  
  temp := Strip(effCode[i], ' ');

  // Check for Mad Pascal code
  if Pos('PAS{', UpperCase(temp)) > 0 then begin
    isPas := true;
    continue;
  end
  else if isPas and (Pos('}', effCode[i]) > 0) then begin
    isPas := false;
    continue;
  end
  else if isPas then begin
    code.Add('  ' + effCode[i]);
    continue;
  end;

  // Check for Mad Assembler code
  if Pos('ASM{', UpperCase(temp)) > 0 then begin
    isAsm := true;
    code.Add('  asm {');
    continue;
  end
  else if isAsm and (Pos('}', effCode[i]) > 0) then begin
    isAsm := false;
    code.Add('  };');
    continue;
  end
  else if isAsm then begin
    code.Add('  ' + effCode[i]);
    continue;
  end;
