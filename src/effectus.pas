{
  Program: Effectus - Action! language parser and cross-assembler to native code
           for Atari 8-bit home computers

  Authors : Bostjan Gorisek (Effectus), Tebe (Mad Assembler, Mad Pascal)

  Unit file  : effectus.pas
  Description: Main project file

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
program Effectus;
{$APPTYPE CONSOLE}

uses
  Classes, SySutils, Decl, Shell, Core;

var
  i : Byte;
  isCompileFalgSet : boolean = true;

begin
  CreateLists;
  ShellProc;
  Init; 
  Writeln('Reading Action! source file...', actionFilename);
  ReadSource(actionFilename);
  Writeln('Generating code...');
  GenerateCode;
  
  for i := 1 to ParamCount do begin
    if ParamStr(i) = '-nc' then begin
      isCompileFalgSet := false;
      WriteLn('Translation only...');
      break;
    end;
  end;
  if isCompileFalgSet then begin
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
