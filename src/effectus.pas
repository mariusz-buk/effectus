{
  Program: Effectus - Action! language parser and cross-assembler to native binary code
           for Atari 8-bit home computers

  Authors : Bostjan Gorisek (Effectus)
            Tebe (Mad Assembler, Mad Pascal)
            zbyti, Mariusz Buk (Effectus support, new features, bug fixes and refactoring)

  Unit file  : effectus.pas
  Description: Main project file

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
program Effectus;
{$APPTYPE CONSOLE}

uses
  Classes, SySutils, Decl, Shell, Core;

var
  i : Byte;
  isTranslation : boolean = false;

begin
  CreateLists;
  ShellProc;
  Init;
  Writeln('Reading Action! source file...', actionFilename);
  ReadSource(actionFilename);
  Writeln('Generating code...');

  GenerateCode;

  for i := 1 to ParamCount do begin
    if ParamStr(i) = '-t' then begin
      isTranslation := true;
      Writeln('Translation only...');
      break;
    end;
  end;
  if not isTranslation then begin
    Writeln('Compiling to native code...');
    if Compile(FilenameSrc) then begin
      Writeln('Compile error!');
    end
    else begin
      Writeln('Compilation is successful!');
    end;
    if isInfo then ShellInfo;
  end;

  DestroyLists;
end.
