{
  Program: Effectus - Atari MADS cross-assembler/parser for Action! language
  Authors : Bostjan Gorisek (Effectus), Tebe (Mad Assembler)

  Unit file  : effectus.pas
  Description: Main project file

  Effectus generates MADS Assembler source code and native binary code for 8-bit
  Atari home computers from Action! language source code listings.
  Program is compiled with Free Pascal 3.0.4

  References:
  http://www.freepascal.org/
  http://gury.atari8.info/effectus/
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
  Classes, SySutils, StrUtils, Crt, Common, Decl, MADS_unit;

{------------------------------------------------------------------------------
 Description: Clean up before closing the program
 -----------------------------------------------------------------------------}
procedure CloseApp;
begin
  DestroyLists;
end;

{------------------------------------------------------------------------------
 Description: Main shell of the program
 -----------------------------------------------------------------------------}
procedure Shell;
var
  i : Integer;
  num : LongInt;
begin
  meditMADS_src_dir := GetCurrentDir + PathDelim;
  meditMADS_bin_dir := GetCurrentDir + PathDelim;
  if ParamCount = 0 then begin
    TextColor(LightCyan);
{$ifdef Unix}
    WriteLn('Effectus ' + VERSION + ' (Linux platform console version)');
{$else}
    WriteLn('Effectus ' + VERSION + ' (i386-win32 platform console version)');
    //WriteLn('Effectus ' + VERSION + ' (i386-win64 platform console version)');
{$endif}
    WriteLn('Atari MADS cross-assembler/parser for Action! language');
    TextColor(White);
    WriteLn('Written by Bostjan Gorisek (Slovenia)');
    WriteLn('Page URL: http://gury.atari8.info/effectus/');
    WriteLn('');
    TextColor(LightCyan);
    WriteLn('MAD Assembler (MADS) is a product written by Tebe (Poland)');
    TextColor(White);
    WriteLn('Page URL: http://mads.atari8.info/');
    WriteLn('');
    TextColor(LightGreen);
    WriteLn('Usage:');
    WriteLn('effectus <filename> <parameters>');
    WriteLn('');
    TextColor(White);
    WriteLn('Program options:');
//     TextColor(LightCyan);
//     Write('-md: ');
//     TextColor(LightGray);
//     Write('MADS cross-assembler directory');

    TextColor(LightCyan);
    Write('-a:address    ');
    TextColor(LightGray);
    Writeln('Program starting address');
    
//     TextColor(LightCyan);
//     Write('-s: ');
//     TextColor(LightGray);
//     Writeln('Output source directory');

//     TextColor(LightCyan);
//     Write('-b: ');
//     TextColor(LightGray);
//     Writeln('Output binary directory');

    TextColor(LightCyan);
    Write('-e:extension  ');
    TextColor(LightGray);
    Writeln('Source code extension');

    TextColor(LightCyan);
    Write('-o:extension  ');
    TextColor(LightGray);
    Writeln('Binary file extension');

    TextColor(LightCyan);
    Write('-r:path       ');
    TextColor(LightGray);
    Writeln('Effectus runtime library directory');

    TextColor(LightCyan);
    Write('-l:path       ');
    TextColor(LightGray);
    Writeln('Log filename (full pathname)');

    TextColor(LightCyan);
    Write('-m:address    ');
    TextColor(LightGray);
    WriteLn('Machine language starting address');

    TextColor(LightCyan);
    Write('-c            ');
    TextColor(LightGray);
    WriteLn('Clear log file');

    TextColor(LightCyan);
    Write('-i            ');
    TextColor(LightGray);
    Writeln('Effectus variable usage list');

    TextColor(LightCyan);
    Write('-n:value      ');
    TextColor(LightGray);
    Writeln('Maximum number of ARRAY elements');

    CloseApp;
    Halt(0);
  end;
  for i := 1 to ParamCount do begin
    if ParamStr(i)[1] <> '-' then begin
      meditEff_src_filename := ParamStr(i);
      // Check for eff extension of Effectus source code listing file
      if System.Pos('.eff', LowerCase(meditEff_src_filename)) < 1 then
        meditEff_src_filename := meditEff_src_filename + '.eff';
    end
//     else if LeftStr(ParamStr(i), 3) = '-s' then
//       meditMADS_src_dir := RightStr(ParamStr(i), Length(ParamStr(i)) - 4)
//     else if LeftStr(ParamStr(i), 3) = '-b' then
//       meditMADS_bin_dir := RightStr(ParamStr(i), Length(ParamStr(i)) - 4)
    else if LeftStr(ParamStr(i), 3) = '-e:' then
      meditMADS_src_ext := RightStr(ParamStr(i), Length(ParamStr(i)) - 3)
    else if LeftStr(ParamStr(i), 3) = '-o:' then begin
      meditMADS_bin_ext := RightStr(ParamStr(i), Length(ParamStr(i)) - 3);
    end
    else if LeftStr(ParamStr(i), 3) = '-r:' then
      meditMADS_rtl_dir := RightStr(ParamStr(i), Length(ParamStr(i)) - 3)
    else if LeftStr(ParamStr(i), 3) = '-l:' then
      meditMADS_log_dir := RightStr(ParamStr(i), Length(ParamStr(i)) - 3)
    else if LeftStr(ParamStr(i), 3) = '-a:' then begin
      if TryStrToInt(RightStr(ParamStr(i), Length(ParamStr(i)) - 3), num) then
        meditAddr := num
      else
        Writeln('-a option could not be processed!');
    end
    else if LeftStr(ParamStr(i), 3) = '-m:' then begin
      if TryStrToInt(RightStr(ParamStr(i), Length(ParamStr(i)) - 3), num) then
        meditMLAddr := num
      else
        Writeln('-m option could not be processed!');
    end
    else if LeftStr(ParamStr(i), 2) = '-n' then begin
      if TryStrToInt(RightStr(ParamStr(i), Length(ParamStr(i)) - 2), num) then
        meditArrMax := num
      else
        Writeln('-n option could not be processed!');
    end
    else if LeftStr(ParamStr(i), 2) = '-i' then
      isInfo := True
    else if LeftStr(ParamStr(i), 2) = '-c' then
      isDelLog := True
    else
      Writeln(ParamStr(i) + ': Unknown parameter!')
  end;
end;

{------------------------------------------------------------------------------
 Description: Check the configuration file
 -----------------------------------------------------------------------------}
// procedure CheckCfg;
// begin
//   if not FileExists(GetCurrentDir + PathDelim + 'config.ini') then begin
//     WriteLn('Configuration file is missing!');
//     CloseApp;
//     Halt(0)
//   end;
// end;

var
  i : byte;
  str : string;
begin  
  ReadCfg;
  CreateLists;
  Shell;
  Init;

  str := ExtractFileName(meditEff_src_filename);
  str := Copy(str, 1, RPos('.', str) - 1);
  isInclude := False;
  //isIncFlag := True;

  if Copy(meditEff_src_filename, 1, 1) = PathDelim then begin
    meditEff_src_filename := Copy(meditEff_src_filename, 2, Length(meditEff_src_filename) - 1);
  end;

  //writeln(meditEff_src_filename, '***');
  if not FileExists(meditEff_src_filename) then begin
  //if not ReadOrig then begin
    WriteLn('The source listing doesn''t exist!');
    CloseApp;
    //Exit;
    Halt(0);
  end;

  GetFuncs;
  //isIncFlag := False;
  GenerateCode;
  Write(mStatusLog);

  if isInfo then begin
    WriteLn('');
    WriteLn('Variable name | Type           | Size');
    WriteLn('-------------------------------------------');
    for i := 1 to GVarCnt do begin
      //writeln(GVar[i].VarType + ' * ' + GVar[i].ParentType + ' * ' + GVar[i].OrigType + ' * ' +
      //        GVar[i].VarName + ' * ' + GVar[i].Value + ' * ' + GVar[i].ML_type);
    
      if (System.Pos(GVar[i].VarName, 'var19750412') > 0)
         or (GVar[i].ParentType = 'T10')
         or ((GVar[i].ParentType = '') and (GVar[i].OrigType = '')) then
      begin
        Continue;
      end;

      if GVar[i].ML_type = 'byte' then begin
        write(PadRight(GVar[i].VarName, 13) + ' | ');
        Write(PadRight('BYTE/CHAR', 14) + ' | 1 ')
      end
      else if GVar[i].ML_type = 'word' then begin
        write(PadRight(GVar[i].VarName, 13) + ' | ');
        Write(PadRight('INT/CARD', 14) + ' | 2 ')
      end      
      else if GVar[i].ParentType = 'T9' then begin
        write(PadRight(GVar[i].VarType, 13) + ' | ');
        Write(PadRight('TYPE ' + GVar[i].OrigType, 14) + ' |')
      end;

      if GVar[i].Value <> '' then
        writeln('(Memory address)')
      else begin
        writeln('')
      end;
    end;

    if varList02.Count > 0 then begin
      for i := 0 to varList02.Count - 1 do begin
        var02.VarType := ExtractDelimited(1, varList02.ValueFromIndex[i], [';']);
        var02.OrigType := ExtractDelimited(2, varList02.ValueFromIndex[i], [';']);
        var02.ParentType := ExtractDelimited(3, varList02.ValueFromIndex[i], [';']);
        var02.Location := ExtractDelimited(4, varList02.ValueFromIndex[i], [';']);
        var02.Value := ExtractDelimited(5, varList02.ValueFromIndex[i], [';']);
        var02.Dim := StrToInt(ExtractDelimited(6, varList02.ValueFromIndex[i], [';']));
//        Writeln('');
//        WriteLn('Arrays/types/pointers:');
//        WriteLn('');
//        WriteLn('Name        | Type       | Size');
//        WriteLn('-------------------------------');
       //writeln(var02.VarType, ' * ', var02.OrigType, ' * ', var02.ParentType, ' * ',
       //        var02.Location, ' * ', var02.Value, ' * ', var02.Dim);
        Write(PadRight(varList02.Names[i], 13) + ' | ');
        if System.Pos(var02.VarType, 'T5T6') > 0 then begin
          Write(PadRight('BYTE array', 14));
          Writeln(' | ', var02.Dim);
        end
        else if System.Pos(var02.VarType, 'T7T8') > 0 then begin
          Write(PadRight('INT/CARD array', 14));
          Writeln(' | ', var02.Dim);
        end
        else if System.Pos(var02.VarType, 'T10') > 0 then begin
          Writeln(PadRight('POINTER', 14))
        end
        else if System.Pos(var02.VarType, 'T9') > 0 then begin
          Writeln(PadRight('TYPE decl.', 14))
        end;
      end;
    end;
    WriteLn('');
    WriteLn('PROCedure/FUNCtion | Parameters');
    WriteLn('-------------------------------------------');
    for i := 0 to ProcCount - 1 do begin
      //if Length(PrmBuf[i]) < 1 then begin
        //Writeln(RightStr(ProcBuf[i], Length(ProcBuf[i]) - 4), ' | ')
      //  Write(PadRight(RightStr(ProcBuf[i], Length(ProcBuf[i]) - 4), 18));
      //  Writeln(' | ');
      //end
      //else begin
        //Writeln(RightStr(ProcBuf[i], Length(ProcBuf[i]) - 4) + ' ==> Parameters: ' + PrmBuf[i]);
      if System.Pos('PROC ', UpperCase(PrmBuf[i])) > 0 then begin
        PrmBuf[i] := '';
      end;
      Writeln(PadRight(RightStr(ProcBuf[i], Length(ProcBuf[i]) - 4), 18), ' | ', PrmBuf[i]);
    end;
    WriteLn('');
  end;

  // Run Mad Assembler
  // meditMADS_src_dir -s
  // meditMADS_bin_dir -b
  // meditMADS_log_dir -l
  RunMADS(str, meditMADS_src_ext, meditMADS_bin_ext, meditMADS_log_dir);

  // Free variables and close application
  CloseApp;
end.