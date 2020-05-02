{
  Program: Effectus - Action! language parser and cross-assembler to native code
           for Atari 8-bit home computers

  Authors : Bostjan Gorisek (Effectus), Tebe (Mad Assembler, Mad Pascal)

  Unit file  : shell.pas
  Description: Shell command prompt routines

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
unit Shell;
//{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

Uses
  SySUtils, Classes, Process, StrUtils, Crt, Decl, Lib;

procedure ShellProc;
function Compile(filename : string) : boolean;
procedure ShellInfo;
procedure ReadSource(filename : string);

implementation

{------------------------------------------------------------------------------
 Description: Shell command prompt
 -----------------------------------------------------------------------------}
procedure ShellProc;
var
  i : Integer;
begin
  if ParamCount = 0 then begin
    TextColor(LightCyan);
{$ifdef DARWIN}
    WriteLn('Effectus ' + VERSION + ' (MacOS platform console version)');
{$else}
{$ifdef Unix}
    WriteLn('Effectus ' + VERSION + ' (Linux platform console version)');
{$else}
    //WriteLn('Effectus ' + VERSION + ' (x86-win32/x64 platform console version)');
    WriteLn('Effectus ' + VERSION + ' (x86 (32-bit) Windows platform console version)');
{$endif}
{$endif}
    WriteLn('Action! language parser and cross-assembler to native code for Atari 8-bit home computers');
    TextColor(White);
    WriteLn('Written by Bostjan Gorisek from Slovenia');
    WriteLn('Page URL: http://gury.atari8.info/effectus/');
    WriteLn('');
    TextColor(LightCyan);
    WriteLn('Mad Pascal and MAD Assembler (MADS) are products written by Tomasz Biela (Tebe) from Poland');
    TextColor(White);
    WriteLn('Page URL: http://mads.atari8.info/');
    WriteLn('');
    TextColor(LightGreen);
    WriteLn('Usage:');
    WriteLn('effectus <filename> <parameters>');
    WriteLn('');
    TextColor(White);
    WriteLn('Program options:');

    //TextColor(LightCyan); Write('-d:path');
    //TextColor(LightGray); Writeln('Output directory');

    TextColor(LightCyan); Write('-o:extension  ');
    TextColor(LightGray); Writeln('Binary file extension');

    TextColor(LightCyan); Write('-c            ');
    TextColor(LightGray); WriteLn('Clear summarized log file');

    TextColor(LightCyan); Write('-i            ');
    TextColor(LightGray); Writeln('Effectus variable usage list');
    
    TextColor(LightCyan); Write('-nc           ');
    TextColor(LightGray); Writeln('Effectus only translate source to Mad Pascal');    

    DestroyLists;
    Halt(0);
  end;
  
  optOutput := GetCurrentDir + PathDelim; 
  optBinExt := 'xex';
  
  for i := 1 to ParamCount do begin
    if ParamStr(i)[1] <> '-' then begin
      actionFilename := ParamStr(i);
      // Check for eff extension of Effectus source code listing file
      if System.Pos('.eff', LowerCase(actionFilename)) < 1 then begin
        actionFilename += '.eff';
      end;
      prgName := ExtractFilenameWithoutExt(actionFilename);
    end
    //else if LeftStr(ParamStr(i), 3) = '-d:' then
    //  optOutput := RightStr(ParamStr(i), Length(ParamStr(i)) - 3)
    else if LeftStr(ParamStr(i), 3) = '-o:' then begin
      optBinExt := RightStr(ParamStr(i), Length(ParamStr(i)) - 3);
    end
//     else if LeftStr(ParamStr(i), 3) = '-l:' then
//       meditMADS_log_dir := RightStr(ParamStr(i), Length(ParamStr(i)) - 3)
//     else if LeftStr(ParamStr(i), 3) = '-a:' then begin
//       if TryStrToInt(RightStr(ParamStr(i), Length(ParamStr(i)) - 3), num) then
//         meditAddr := num
//       else
//         Writeln('-a option could not be processed!');
//     end
    else if LeftStr(ParamStr(i), 2) = '-i' then
      isInfo := true
    else if LeftStr(ParamStr(i), 2) = '-c' then
       isClearLog := true
    else if LeftStr(ParamStr(i), 3) = '-nc' then      
    else
      Writeln(ParamStr(i) + ': Unknown parameter!')
  end;
end;

{------------------------------------------------------------------------------
 Description: Parse and compile Action! listing code to Mad Pascal and Mad Assembler code
 -----------------------------------------------------------------------------}
function Compile(filename : string) : boolean;
var
  AProcess : TProcess;
  AStringList : TStringList;
  isPasError : boolean = false;
  logFile : String; 
  logFileTotal : String; 
  filenamePart : string;
  filePath : string;
  i : word;
begin
  logFile := GetCurrentDir + PathDelim + 'efflog.txt';
  logFileTotal := GetCurrentDir + PathDelim + 'effectus.txt';

  AProcess := TProcess.Create(nil);  
  AProcess.Parameters.Clear;  
  AStringList := TStringList.Create;

  if isClearLog then begin
    AStringList.Clear;
    AStringList.SaveToFile(logFileTotal);
  end;

  //if isMadPascalUserLocation then
  //  AProcess.Executable := strMadPascalUserLocation + DirectorySeparator + 'mp'
  //else begin
    //AProcess.Executable := getDir + 'bin' + DirectorySeparator + 'mp' + DirectorySeparator + 'mp';
  //end;
  //writeln('1.) ', GetCurrentDir + PathDelim + 'mp ', 'mp filename = ', filename);
  AProcess.Executable := GetCurrentDir + PathDelim + 'mp';

  //  AProcess.Parameters.Add(AnsiQuotedStr(GetCurrentDir + '\bin\roto.pas', '"'));
  AProcess.Parameters.Add(AnsiQuotedStr(filename, '"'));

  //  if isMadPascal_o then AProcess.Parameters.Add('-o');
  //  if isMadPascal_d then AProcess.Parameters.Add('-d');
  //SetParams(AProcess, propMadPascal, propFlagMadPascal);

  AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes, poStdErrToOutPut];
  AProcess.Execute;
  
  //AStringList.LoadFromStream(AProcess.Stderr);
  // Save log output to file.
  //AStringList.SaveToFile('d:\atari\temp\test_err.log');
  AStringList.LoadFromStream(AProcess.Output);  
  
  // Check for errors created by Mad Pascal caused by Effectus source code listing  
  for i := 0 to AStringList.Count - 1 do begin
    //isPasError := AStringList.IndexOf('Error:') >= 0; 
    if System.Pos('Error:', AStringList[i]) > 0 then begin
      isPasError := true;
      break;
    end;
  end;  

  AStringList.Insert(0, 'Filename: ' + filename);
  AStringList.Insert(1, FormatDateTime('c', Now));
  AStringList.Add('--------------------------------------------------------------------------------');
  
  // Save the output to a file
  AStringList.SaveToFile(logFile);

  // Save the output to a file
//   if isPasError then begin
//     AStringList.SaveToFile('d:\atari\temp\error_log.txt');
//   end;

   AProcess.Parameters.Clear;

  // Redirect current output to the archive log
{$ifdef Unix}
  AProcess.Executable := '/bin/sh';
  AProcess.Parameters.Add('-c');
  AProcess.Parameters.Add('cat ' + logFile + ' >> effectus.txt');
{$else}
  AProcess.Executable := 'cmd.exe';
  AProcess.Parameters.Add('/c');
  AProcess.Parameters.Add('"type ' + logFile + ' >> ' + logFileTotal + '"');
{$endif}
  AProcess.Options := [poWaitOnExit, poUsePipes];
  AProcess.Execute();

//      if isMadPascalUserLocation then
//        AProcess.Executable := strMadsUserLocation + DirectorySeparator + 'mads'
//      else begin
//        AProcess.Executable := getDir + 'bin' + DirectorySeparator + 'mp' + DirectorySeparator + 'mads';
//      end;
     //writeln('2.) ', GetCurrentDir + PathDelim + 'mads ', ExtractFilenameWithoutExt(filename));

  AProcess.Executable := GetCurrentDir + PathDelim + 'mads';

  AProcess.Parameters.Clear;

//   fileTemp := filename;
//   filePath := ExtractFilePath(filename);
//   filenamePart := ExtractFilenameWithoutExt(filename);
    
  //FilenameSrc := ExtractFilePath(actionFilename);
  //pasFile := ExtractFilenameWithoutExt(actionFilename) + '.pas';
  //FilenameSrc += pasFile;
  
  filePath := ExtractFilePath(filename);
  filenamePart := ExtractFilenameWithoutExt(filename) + '.a65';
  
  //writeln('filePath + filenamePart = ', filePath + filenamePart);

  //AProcess.Parameters.Add(AnsiQuotedStr(ExtractFileNameWithoutExt(filename) + '.a65', '"'));
  AProcess.Parameters.Add(AnsiQuotedStr(filePath + filenamePart, '"'));
  //SetParams(AProcess, propMadsMP, propFlagMadsMP);
  
  //writeln(AnsiQuotedStr(ExtractFilenameWithoutExt(filename), '"'));

  filenamePart := ExtractFilenameWithoutExt(filename) + '.' + optBinExt;

//  AProcess.Parameters.Add('-o:' + AnsiQuotedStr(ExtractFilenameWithoutExt(filename) +
//                           '.' + optBinExt, '"'));
  AProcess.Parameters.Add('-o:' + AnsiQuotedStr(filePath + filenamePart, '"'));
  AProcess.Parameters.Add('-x');
  AProcess.Parameters.Add('-i:base');

  AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;

  AStringList.Free;
  AProcess.Free;
  
  result := isPasError;  
end;

{------------------------------------------------------------------------------
 Description: Shell info about Action!/Effectus source code listing
 -----------------------------------------------------------------------------}
procedure ShellInfo;
var
  i : byte;
  dataType, dataTypeExt : string;
  varItem, temp : string;
begin
  // Global and local variables
  if vars.Count > 0 then begin
    WriteLn(LineEnding + 'Variables' + LineEnding);
    WriteLn('Variable name        | Data type      | Description     | Owner (PROC/FUNC)');
    WriteLn('----------------------------------------------------------------------------' + LineEnding);
    for i := 0 to vars.Count - 1 do begin
      if ExtractDelimited(2, vars.ValueFromIndex[i], [';']) = '2' then begin
        continue;
      end;
      
      dataType := UpperCase(ExtractDelimited(1, vars.ValueFromIndex[i], [';']));
      dataTypeExt := ExtractDelimited(2, vars.ValueFromIndex[i], [';']);
      varItem := vars.Names[i];
      
      // TYPE variable
      temp := ExtractDelimited(6, vars.ValueFromIndex[i], [';']);
      if temp <> '' then begin
        varItem += ' (TYPE ' + temp + ')';
      end
      // Variable with default value
      else begin
        temp := ExtractDelimited(3, vars.ValueFromIndex[i], [';']);
        if (temp <> '0') and (dataTypeExt <> '4') and (dataTypeExt <> '5') then begin
          varItem += ' (' + temp + ')';
        end;
      end;

      // Data type information
      if LowerCase(dataType) = 'word' then
        dataType := 'CARD'
      else if LowerCase(dataType) = 'integer' then begin
        dataType := 'INT';
      end
      else if dataType = 'string' then begin
        dataType := 'SBYTE ARRAY';
      end;

      // Data type extra information
      if dataTypeExt = '1' then
        dataTypeExt := 'Memory address'
      else if dataTypeExt = '2' then begin
        dataTypeExt := 'String';
      end
      else if dataTypeExt = '3' then begin
        dataType += ' POINTER';
        dataTypeExt := 'Pointer';
      end
      else if dataTypeExt = '4' then begin
        dataType := 'BYTE ARRAY';
        dataTypeExt := 'Array';
      end
      else if dataTypeExt = '5' then begin
        dataType := 'CARD ARRAY';
        dataTypeExt := 'Array';
      end
      else if dataTypeExt = '7' then begin
        dataType := 'TYPE';
        dataTypeExt := 'Type';
      end
      else begin
        dataTypeExt := 'Scalar variable';
      end;

      Writeln(PadRight(varItem, 20),
        ' | ', PadRight(dataType, 14),
        ' | ', PadRight(dataTypeExt, 15),
        ' | ', PadRight(ExtractDelimited(5, vars.ValueFromIndex[i], [';']), 10));
    end;
  end;
  
  // PROCedures
  if myProcs.Count > 0 then begin
    WriteLn(LineEnding + 'PROCedures');
    //WriteLn('Name           | Parameters');
    WriteLn('-----------------' + LineEnding);
    for i := 0 to myProcs.Count - 1 do begin
      Writeln(PadRight(myProcs.Names[i], 14));
    end;
  end;

  // FUNCtions
  if myFuncs.Count > 0 then begin
    WriteLn(LineEnding + 'FUNCtions' + LineEnding);
    //WriteLn('Name           | Parameters');
    WriteLn('-----------------');
    for i := 0 to myFuncs.Count - 1 do begin
      Writeln(PadRight(myFuncs.Names[i], 14));
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Read Action!/Effectus source code listing
 -----------------------------------------------------------------------------}
procedure ReadSource(filename : string);
var
  i : LongInt;
  tempxy : TStringList;
begin
  //writeln('ReadSource filename = ', filename);

  tempxy := TStringlist.create;
  try
    try
      // Check if source file exists
      if not FileExists(filename) then begin
      //GetCurrentDir + PathDelim + 
        WriteLn('The source listing doesn''t exist!');
        DestroyLists;
        Halt(0);
      end;

      // Load source file to string list
      tempxy.loadfromfile(filename);
      //GetCurrentDir + PathDelim
      devicePtr.isDevice := false;
      devicePtr.isGraphics := false;
      devicePtr.isStick := false;
      prgPtr.isByteBuffer := false;
      for i := 0 to tempxy.Count - 1 do begin
        effCode.add(tempxy.strings[i]);

        if (System.Pos('GETD(7)', UpperCase(tempxy.strings[i])) > 0)
           and not devicePtr.isDevice then
        begin
        end
        else if (System.Pos('GETD', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('SCOMPARE', UpperCase(tempxy.strings[i])) > 0) then
        begin
          prgPtr.isByteBuffer := true;
        end
        else if (System.Pos('OPEN', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('CLOSE', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('PUTD', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('PRINTD', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('PRINTBD', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('PRINTCD', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('PRINTID', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('GETD', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('INPUTSD', UpperCase(tempxy.strings[i])) > 0) then
        begin
          devicePtr.isDevice := true;
        end
        else if (System.Pos('STICK', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('STRIG', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('PADDLE', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('PTRIG', UpperCase(tempxy.strings[i])) > 0) then
        begin
          devicePtr.isStick := true;
        end
        else if (System.Pos('GRAPHICS', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('PLOT', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('DRAWTO', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('COLOR', UpperCase(tempxy.strings[i])) > 0)
             or (System.Pos('FILL', UpperCase(tempxy.strings[i])) > 0) then
        begin
          devicePtr.isGraphics := true;
        end;
      end;
      except
        on E : Exception do writeln(E.Message);
        else begin
          WriteLn('An error occurred reading/processing the file ', filename);
          tempxy.Free;
          Halt(0);
        end;
    end;
  finally
    tempxy.Free;
  end;
end;

end.
