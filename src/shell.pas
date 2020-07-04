{
  Program: Effectus - Action! language parser and cross-assembler to native binary code
           for Atari 8-bit home computers

  Authors : Bostjan Gorisek (Effectus)
            Tebe (Mad Assembler, Mad Pascal)
            zbyti, Mariusz Buk (Effectus support, new features, bug fixes and refactoring)

  Unit file  : shell.pas
  Description: Shell command prompt routines

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
    WriteLn('Effectus ' + VERSION + ' (x86_64-win64 64-bit Windows platform console version)');
    //WriteLn('Effectus ' + VERSION + ' (i386-win32 32-bit Windows platform console version)');
{$endif}
{$endif}
    WriteLn('Action! language parser to native binary code for Atari 8-bit home computers');
    WriteLn('written by Bostjan Gorisek from Slovenia');
    TextColor(White);
    WriteLn('References:');
    WriteLn('  https://github.com/mariusz-buk/effectus');
    WriteLn('  http://freeweb.siol.net/diomedes/effectus/');
    //WriteLn('  http://gury.atari8.info/effectus/');
    WriteLn('');
    TextColor(LightCyan);
    WriteLn('Mad Pascal and MAD Assembler (MADS) are products written by Tomasz Biela (Tebe) from Poland');
    TextColor(White);
    WriteLn('References:');
    WriteLn('  http://mads.atari8.info/');
    WriteLn('  https://github.com/tebe6502/Mad-Assembler');
    WriteLn('  https://github.com/tebe6502/Mad-Pascal');
    //WriteLn('https://atariage.com/forums/topic/291426-effectus-action-cross-compiler-using-mad-assembler-mads/');
    WriteLn('');
    TextColor(LightGreen);
    WriteLn('Usage:');
    WriteLn('effectus <filename> <parameters>');
    WriteLn('');
    TextColor(White);
    WriteLn('Program options:');

    TextColor(LightCyan); Write('-o:extension  ');
    TextColor(LightGray); Writeln('Binary file extension');

    TextColor(LightCyan); Write('-c            ');
    TextColor(LightGray); WriteLn('Clear summarized log file');

    TextColor(LightCyan); Write('-i            ');
    TextColor(LightGray); Writeln('Effectus variable usage list');

    TextColor(LightCyan); Write('-t            ');
    TextColor(LightGray); Writeln('Effectus only translate source to Mad Pascal');

    TextColor(LightCyan); Write('-z            ');
    TextColor(LightGray); Writeln('Variable zero page address');

    TextColor(LightCyan); Write('-zb           ');
    TextColor(LightGray); Writeln('BYTE variable zero page address');

    TextColor(LightCyan); Write('-zw           ');
    TextColor(LightGray); Writeln('CARD (word) variable zero page address');

    TextColor(LightCyan); Write('-zp           ');
    TextColor(LightGray); Writeln('Pointer (PByte) zero page address');

    DestroyLists;
    Halt(0);
  end;

  optOutput := GetCurrentDir + PathDelim;
  optBinExt := 'xex';

  for i := 1 to ParamCount do begin
    if ParamStr(i)[1] <> '-' then begin
      actionFilename := ParamStr(i);
      // Check for eff extension of Effectus source code listing file
      if Pos('.eff', LowerCase(actionFilename)) < 1 then begin
        actionFilename += '.eff';
      end;
      prgName := ExtractFilenameWithoutExt(actionFilename);
    end
    else if LeftStr(ParamStr(i), 3) = '-o:' then begin
      optBinExt := RightStr(ParamStr(i), Length(ParamStr(i)) - 3);
    end
    else if LeftStr(ParamStr(i), 2) = '-i' then
      isInfo := true
    else if LeftStr(ParamStr(i), 2) = '-c' then
       isClearLog := true
    else if LeftStr(ParamStr(i), 3) = '-t' then
    else if LeftStr(ParamStr(i), 3) = '-z' then
       isVarFastMode := true
    else if LeftStr(ParamStr(i), 3) = '-zb' then
       isByteFastMode := true
    else if LeftStr(ParamStr(i), 3) = '-zw' then
       isWordFastMode := true
    else if LeftStr(ParamStr(i), 3) = '-zp' then
       isPointerFastMode := true
    else begin
      Writeln(ParamStr(i) + ': Unknown parameter!');
    end;
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
//  filePath : string;
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

  AProcess.Executable := GetCurrentDir + PathDelim + 'mp';

  //  AProcess.Parameters.Add(AnsiQuotedStr(GetCurrentDir + '\bin\roto.pas', '"'));
  AProcess.Parameters.Add(AnsiQuotedStr(filename, '"'));

  AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes, poStdErrToOutPut];
  AProcess.Execute;

  //AStringList.LoadFromStream(AProcess.Stderr);
  // Save log output to file.
  //AStringList.SaveToFile('d:\atari\temp\test_err.log');
  AStringList.LoadFromStream(AProcess.Output);

  // Check for errors created by Mad Pascal caused by Effectus source code listing
  for i := 0 to AStringList.Count - 1 do begin
    //isPasError := AStringList.IndexOf('Error:') >= 0;
    if Pos('Error:', AStringList[i]) > 0 then begin
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

  AProcess.Executable := GetCurrentDir + PathDelim + 'mads';

  AProcess.Parameters.Clear;

  //filePath := ExtractFilePath(filename);
  filenamePart := ExtractFilenameWithoutExt(filename) + '.a65';
  AProcess.Parameters.Add(AnsiQuotedStr(filePath + filenamePart, '"'));

  filenamePart := ExtractFilenameWithoutExt(filename) + '.' + optBinExt;
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
    WriteLn('------------------------------------------------------------------------------');
    for i := 0 to vars.Count - 1 do begin
      if ExtractDelimited(2, vars.ValueFromIndex[i], [';']) = '2' then begin
        continue;
      end;

      dataType := UpperCase(ExtractDelimited(1, vars.ValueFromIndex[i], [';']));
      dataTypeExt := ExtractDelimited(2, vars.ValueFromIndex[i], [';']);
      varItem := vars.Names[i];

      // TYPE variable
      temp := ExtractDelimited(6, vars.ValueFromIndex[i], [';']);
      if temp <> '0' then begin
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
    WriteLn('-----------------');
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

  // DEFINE constants
  if defineList.Count > 0 then begin
    WriteLn(LineEnding + 'DEFINE constants' + LineEnding);
    WriteLn('Constant         | Value');
    WriteLn('------------------------------------------------------------------------------');
    for i := 0 to defineList.Count - 1 do begin
      temp := ExtractDelimited(1, defineList.ValueFromIndex[i], [';']);
      temp := ReplaceStr(temp, '{', '=');
      Writeln(PadRight(defineList.Names[i], 16), ' | ', temp);
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: DEFINE declaration block
 -----------------------------------------------------------------------------}
procedure CheckDefine;
var
  defineName : string;
  defineValue : string;
  i, j : word;
  temp : string;
  A: TStringArray;
begin
  if not varPtr.isDefine then Exit;
  varPtr.isDefine := false;

  //Write('2. pass...');
  for i := 0 to effCode.Count - 1 do begin
    temp := Trim(effCode[i]);
    temp := ReplaceStr(temp, ' = ', '=');
    if temp = '' then continue;

    // Check comments
    if temp[1] = ';' then begin
      continue;
    end;
    // Find DEFINE constants as substitutes for real statement values
    // Parse each command or statement delimited by space ignoring words inside "" pair
    A := temp.Split(' ', '"', '"');
    if High(a) >= 0 then begin
      for j := 0 to High(a) do begin
        //writeln('a[j] = ', a[j]);
        if UpperCase(a[j]) = 'DEFINE' then begin
          varPtr.isDefine := true;
        end
        else if varPtr.isDefine then begin
          a[j] := StringReplace(a[j], '=', '{', []);
          defineName := Extract(1, a[j], '{');
          defineValue := Extract(2, a[j], '{');
          defineValue := ExtractText(defineValue, '"', '"');
          defineValue := ReplaceStr(defineValue, '=', '{');
          defineList.Add(defineName + '=' + defineValue);
          //writeln('DEFINE ', defineName, ' = ', defineValue);
          if a[j][Length(a[j])] = ',' then begin
            varPtr.isDefine := true;
            //writeln('a[j] , ', a[j]);
          end else begin
            varPtr.isDefine := false;
          end;
        end;
      end;
    end;
  end;

  // Convert DEFINE constants to real statement values
  for i := 0 to effCode.Count - 1 do begin
    if (Pos('DEFINE ', UpperCase(effCode[i])) > 0)
       or (UpperCase(effCode[i]) = 'DEFINE') then
    begin
      if (Pos('"', UpperCase(effCode[i])) > 0)
         and (Pos('"', UpperCase(effCode[i])) < Pos('DEFINE ', UpperCase(effCode[i]))) then
      begin
      end
      else begin
        effCode[i] := '';
        continue;
      end;
    end;

    // Convert possible DEFINE constants to real data
    for j := 0 to defineList.Count - 1 do begin
      //writeln('defineList.Names[j] = ', defineList.Names[j]);
      temp := effCode[i];
      if Pos(UpperCase(defineList.Names[j]), UpperCase(temp)) > 0 then begin
        if (Pos('"', UpperCase(temp)) > 0) and (Pos('"', UpperCase(temp))
             < Pos(UpperCase(defineList.Names[j]), UpperCase(temp))) then
        begin
        end
        else begin
          //if defineList.IndexOfName(j) >= 0 then begin
          temp:= ExtractDelimited(1, defineList.ValueFromIndex[j], [';']);
          temp := ReplaceStr(temp, '{', '=');
          effCode[i] := StringReplace(
            effCode[i], defineList.Names[j], temp, [rfReplaceAll, rfIgnoreCase]);
        end;
      end;
    end;
  end;

  for i := 0 to effCode.Count - 1 do begin
    // Convert possible DEFINE constants to real data
    for j := 0 to defineList.Count - 1 do begin
      temp := effCode[i];
      if Pos(UpperCase(defineList.Names[j]), UpperCase(temp)) > 0 then begin
        if (Pos('"', UpperCase(temp)) > 0) and (Pos('"', UpperCase(temp))
             < Pos(UpperCase(defineList.Names[j]), UpperCase(temp))) then
        begin
        end
        else begin
          //if defineList.IndexOfName(j) >= 0 then begin
          temp:= ExtractDelimited(1, defineList.ValueFromIndex[j], [';']);
          temp := ReplaceStr(temp, '{', '=');
          effCode[i] := StringReplace(
            effCode[i], defineList.Names[j], temp, [rfReplaceAll, rfIgnoreCase]);
        end;
      end;
    end;
  end;
  //Writeln(' Done!');
end;

{------------------------------------------------------------------------------
 Description: Read Action!/Effectus source code listing
 -----------------------------------------------------------------------------}
procedure ReadSource(filename : string);
var
  i, j : LongInt;
  tempxy : TStringList;
  includeFile : TStringList;
  A : TStringArray;
begin
  tempxy := TStringlist.create;
  includeFile := TStringlist.create;
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
      filePath := ExtractFilePath(filename);
      
      //GetCurrentDir + PathDelim
      devicePtr.isDevice := false;
      //devicePtr.isDeviceOpen := false;
      devicePtr.isGraphics := false;
      devicePtr.isStick := false;
      devicePtr.isSySutils := false;
      prgPtr.isByteBuffer := false;
      varPtr.isDefine := false;
      //Write('1. pass... ');
      for i := 0 to tempxy.Count - 1 do begin
        tempxy.strings[i] := Trim(tempxy.strings[i]);
        tempxy.strings[i] := ReplaceStr(tempxy.strings[i], 'MODULE', '');

        // Remove character with Ascii code 9 from Action! listing lines
        tempxy.strings[i] := ReplaceStr(tempxy.strings[i], Chr(9), '');

        // Check for INCLUDE file
        if Pos('INCLUDE ', UpperCase(tempxy.strings[i])) = 1 then begin
          A := tempxy.strings[i].Split(' ');
          if High(a) = 1 then begin
            a[1] := ExtractText(a[1], '"', '"');
            a[1] := Extract(2, a[1], ':');
          
            //writeln(GetCurrentDir + a[1]);
            writeln('INCLUDE file is processed: ', filePath + a[1]);
            
            if FileExists(filePath + a[1]) then begin
              //includeFile.loadfromfile(GetCurrentDir + PathDelim + a[1]);
              includeFile.loadfromfile(filePath + a[1]);
              for j := 0 to includeFile.Count - 1 do begin
                includeFile.strings[j] := Trim(includeFile.strings[j]);
  
                // Check DEFINE statement
                if Pos('DEFINE ', UpperCase(includeFile.strings[j])) = 1 then begin
                //if tempxy.strings[i] = 'DEFINE' then begin
                  varPtr.isDefine := true;
                end;
  
                if IsArrayElementInString(_MP_DEVICE_SYSUTILS, includeFile.strings[j]) then begin
                  devicePtr.isDevice := true;
                  devicePtr.isSySutils := true;
                end;
                if IsArrayElementInString(_MP_STICK, includeFile.strings[j]) then
                     devicePtr.isStick := true;
                if IsArrayElementInString(_MP_GRAPHICS, includeFile.strings[j]) then
                     devicePtr.isGraphics := true;
                if IsArrayElementInString(_MP_SYSUTILS, includeFile.strings[j]) then
                     devicePtr.isSySutils := true;
                     
                // Add Action! listing line
                effCode.add(includeFile.strings[j]);
              end;
            end
            else begin
              writeln('INCLUDE file ' + filePath + a[1] + ' not found!');
              //PathDelim
            end;
          end;
        end
        else begin
          // Push Action! listing line to the list
          effCode.add(tempxy.strings[i]);
          
          // Check DEFINE statement
          if Pos('DEFINE ', UpperCase(tempxy.strings[i])) = 1 then begin
          //if tempxy.strings[i] = 'DEFINE' then begin
            varPtr.isDefine := true;
          end;
  
          if IsArrayElementInString(_MP_DEVICE_SYSUTILS, tempxy.strings[i]) then begin
            devicePtr.isDevice := true;
            devicePtr.isSySutils := true;
          end;
          if IsArrayElementInString(_MP_STICK, tempxy.strings[i]) then
               devicePtr.isStick := true;
          if IsArrayElementInString(_MP_GRAPHICS, tempxy.strings[i]) then
               devicePtr.isGraphics := true;
          if IsArrayElementInString(_MP_SYSUTILS, tempxy.strings[i]) then
               devicePtr.isSySutils := true;          
        end;
      end;
      //WriteLn(' Done!');
      CheckDefine;

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
    includeFile.Free;
  end;
end;

end.
