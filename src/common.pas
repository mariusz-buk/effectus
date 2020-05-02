{
  Program: Effectus - Atari MADS cross-assembler/parser for Action! language
  Authors : Bostjan Gorisek (Effectus), Tebe (Mad Assembler)

  Unit file  : common.pas
  Description: Common library

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
unit Common;
//{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
  sysutils, Classes, INIfiles, strutils, Decl, Core;

procedure GetFuncs;
procedure CheckLibProc;
procedure DeviceCheck;
procedure ReadSource(filename : string; isIncluded : boolean);
procedure sc_Lib(RtlDir : String);
function VarDeclCheck(StrBuf : String) : Boolean;
function ExprCheck(StrBuf : String) : Boolean;
procedure ReadCfg;
procedure ReadInclude;
procedure GenerateCode;
procedure MathExpr(VarStr, Str1, Str2 : String; Flag, Index : Byte);
function AsmStrNum(Str : String) : String;
function mvwa(src : String) : String;
function IsNumber(src : Char) : Boolean;
procedure Split(Str, Delimiter : String; Flags : TFlags);
procedure SplitEx2(Str : String; Delim1, Delim2, Delim3, Delim4 : Char);
function Replace(Str : String; Ch1, Ch2 : Char): String;
function Strip(Str : String; Ch : Char) : String;
function ExtractText(Str : String; Ch1, Ch2 : Char) : String;
function ExtractEx(Str, Delimiter : String; Index : Integer; Flags : TFlags) : String;
function Extract(offset : byte; str : string; delim : char; Flags : TFlags) : string;
function Checkvar02(str, startStr, endStr : string) : boolean;
function CheckExtraVarType(types : string) : boolean;
function Checkvar02Equal(str, addStr : string) : boolean;
procedure WatchVar(spot : string; index : byte);

implementation

{------------------------------------------------------------------------------
 Description: List of Action! functions
 -----------------------------------------------------------------------------}
procedure GetFuncs;
begin
  FuncList.Add('Peek');
  FuncList.Add('Stick');
  FuncList.Add('Strig');
  FuncList.Add('Paddle');
  FuncList.Add('Ptrig');
  FuncList.Add('Rand');
  FuncList.Add('PeekC');
  FuncList.Add('GetD');
  FuncList.Add('Locate');
  FuncList.Add('ValB');
  FuncList.Add('ValI');
  FuncList.Add('ValC');
//  FuncList.Add('SCompare');
end;

{------------------------------------------------------------------------------
 Description: Check supporting libraries
 -----------------------------------------------------------------------------}
procedure CheckLibProc;
var
  i : Byte;
begin
  for i := 0 to GrProcs.Count - 1 do begin 
    if (System.Pos(UpperCase(GrProcs[i]) + '(', UpperCase(Strip(TextBuf[CR_LF], ' '))) > 0) or
       (System.Pos(UpperCase(GrProcs[i]) + '=', UpperCase(Strip(TextBuf[CR_LF], ' '))) > 0) then
      isGraphics := True;
  end;
  for i := 0 to SoundProcs.Count - 1 do begin
    if System.Pos(UpperCase(SoundProcs[i]) + '(', UpperCase(Strip(TextBuf[CR_LF], ' '))) > 0 then
      isSound := True;
  end;
  for i := 0 to PrintFProcs.Count - 1 do begin
    if System.Pos(UpperCase(PrintFProcs[i]) + '(', UpperCase(Strip(TextBuf[CR_LF], ' '))) > 0 then
      isPrintF := True;
  end;
  for i := 0 to IOProcs.Count - 1 do begin
    if System.Pos(UpperCase(IOProcs[i]) + '(', UpperCase(Strip(TextBuf[CR_LF], ' '))) > 0 then
      isIO := True;
  end;
  for i := 0 to PrintFDProcs.Count - 1 do begin
    if System.Pos(UpperCase(PrintFDProcs[i]) + '(', UpperCase(Strip(TextBuf[CR_LF], ' '))) > 0 then
      isPrintFD := True;
  end;
  for i := 0 to ControllerProcs.Count - 1 do begin
    if System.Pos(UpperCase(ControllerProcs[i]) + '(', UpperCase(Strip(TextBuf[CR_LF], ' '))) > 0 then
      isControllers := True;
  end;
end;

{------------------------------------------------------------------------------
 Description: Close channels
 -----------------------------------------------------------------------------}
procedure DeviceCheck;
var
  i : Byte;
begin
  for i := 0 to 7 do begin
    if isIOerror[i] then begin
//       WriteLn(fASM, '');
//       WriteLn(fASM, 'stop', i);
//       WriteLn(fASM, ' close #$', i, '0');
//       WriteLn(fASM, '');
      code.Add('');
      code.Add('stop' + IntToStr(i));
      code.Add(' close #$' + IntToStr(i) + '0');
      code.Add('');
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Read Effectus source code listing
 -----------------------------------------------------------------------------}
procedure ReadSource(filename : string; isIncluded : boolean);
var
  i : LongInt;
  buffer : String;
  tempxy : TStringList;
begin
  //filename := GetCurrentDir + PathDelim + meditEff_src_filename;
//   if not FileExists(filename) then begin
//     WriteLn('The source listing doesn''t exist!');
//     Halt(0);
//   end;

  tempxy := TStringlist.create;
  CR_LF := 0;
  TextBuf.Clear;
  
  if not isIncluded then begin
    TextBuf.Add('CARD var19750412');
  end
  else begin
    TextBuf.Add('');
  end;
  try
    try
//    writeln(GetCurrentDir + PathDelim + meditEff_src_filename);
    tempxy.loadfromfile(filename);
    //writeln('filename = ', filename, ' *** count = ', tempxy.Count);
    for i := 0 to tempxy.Count - 1 do begin
      CR_LF := i + 1;
      TextBuf.Add(tempxy[i]);
      //WriteLn(tempxy.Strings[i]);

      // Check for ELSEIF statement
      if System.Pos('ELSEIF ', UpperCase(TextBuf[CR_LF])) > 0 then begin
        flags2 += [sElseIf];
      end;

      {
      // Check to see if FOR statement was found in the listing
      if System.Pos('FOR ', UpperCase(TextBuf[CR_LF])) > 0 then begin
        flags := flags + [sFor];
      end;
      }
      // Check for WHILE statement
      if System.Pos('WHILE ', UpperCase(TextBuf[CR_LF])) > 0 then begin
        flags += [sWhile];
      end;

      // Check for UNTIL statement
      if System.Pos('UNTIL ', UpperCase(TextBuf[CR_LF])) > 0 then begin
        flags2 += [sUntilFlag];
      end;
      
      {
      // Check to see if EXIT command was found in the listing
      if System.Pos('EXIT', UpperCase(TextBuf[CR_LF])) > 0 then begin
        flags2 := flags2 + [sExitFlag];
      end;
      }

      // Check for libraries
      CheckLibProc;

      // Retrieve all procedures and functions (PROC, FUNC)
      if ((System.Pos('PROC ', UpperCase(TextBuf[CR_LF])) > 0)
          or (System.Pos('FUNC ', UpperCase(TextBuf[CR_LF])) > 0))
         and (System.Pos('"', TextBuf[CR_LF]) < 1) then
      begin
        Inc(ProcCount);
        //if isIncFlag then Inc(ProcCount2);
        if (System.Pos('PROC ', UpperCase(TextBuf[CR_LF])) > 0) then begin
          buffer := ExtractEx(TextBuf[CR_LF], 'PROC ', 2, []);
          if System.Pos('=', TextBuf[CR_LF]) > 0 then
            buffer := ExtractEx(buffer, '=', 1, [])
            //buffer := Extract(1, Buffer, '=', [])
          // Bug found by Spaced Cowboy from AtariAge
          //else if System.Pos('=*', TextBuf[CR_LF]) > 0 then
          //  buffer := ExtractEx(Buffer, '=*', 1, [])
          else begin
            buffer := ExtractEx(buffer, '(', 1, []);
            //buffer := Extract(1, buffer, '(', []);
          end;
          ProcBuf.Add('PROC' + buffer);
        end
        else begin
          buffer := ExtractEx(TextBuf[CR_LF], ' FUNC ', 2, []);
          if System.Pos('=*', TextBuf[CR_LF]) > 0 then
            buffer := ExtractEx(Buffer, '=*', 1, [])
          else begin
            buffer := ExtractEx(Buffer, '(', 1, []);
            //buffer := Extract(1, buffer, '(', []);
          end;
          ProcBuf.Add('FUNC' + buffer);
        end;
        PrmBuf.Add(ExtractText(TextBuf[CR_LF], '(', ')'));
      end;
    end;
    except
      WriteLn('An error occurred reading/processing the file ', filename);
      tempxy.Free;
      Halt(0);
    end;
  finally
    tempxy.Free;
  end;
end;

{------------------------------------------------------------------------------
 Description: Links all necessary libraries
 Parameters : RtlDir - runtime library directory
 -----------------------------------------------------------------------------}
procedure sc_Lib(RtlDir : String);
begin
  if isGraphics then
    //WriteLn(fASM, ' .link ' + AnsiQuotedStr(RtlDir + 'graphics.obx', ''''));
    code.Add(' .link ' + AnsiQuotedStr(RtlDir + 'graphics.obx', ''''));
  if isSound then
    //WriteLn(fASM, ' .link ' + AnsiQuotedStr(RtlDir + 'sound.obx', ''''));
    code.Add(' .link ' + AnsiQuotedStr(RtlDir + 'sound.obx', ''''));
  if isPrintF or isGr then
    //WriteLn(fASM, ' .link ' + AnsiQuotedStr(RtlDir + 'printf.obx', ''''));
    code.Add(' .link ' + AnsiQuotedStr(RtlDir + 'printf.obx', ''''));
  if isIO then
    //WriteLn(fASM, ' .link ' + AnsiQuotedStr(RtlDir + 'io.obx', ''''));
    code.Add(' .link ' + AnsiQuotedStr(RtlDir + 'io.obx', ''''));
  if isPrintFD then
    //WriteLn(fASM, ' .link ' + AnsiQuotedStr(RtlDir + 'printfd.obx', ''''));
    code.Add(' .link ' + AnsiQuotedStr(RtlDir + 'printfd.obx', ''''));
  if isMath then
    //WriteLn(fASM, ' .link ' + AnsiQuotedStr(RtlDir + 'math.obx', ''''));
    code.Add(' .link ' + AnsiQuotedStr(RtlDir + 'math.obx', ''''));
  if isControllers then
    //WriteLn(fASM, ' .link ' + AnsiQuotedStr(RtlDir + 'controllers.obx', ''''));
    code.Add(' .link ' + AnsiQuotedStr(RtlDir + 'controllers.obx', ''''));
end;
(*
//   Procedure name: RunMads
//   Description   : Executes Mads cross-compiler on Win32 platform
//   Parameters    : MADS_dir - Runtime library directory
//                   MADS_src_dir
//                   MADS_bin_dir
//                   MADS_log_dir
procedure RunMads(MADS_dir, MADS_src_dir, MADS_bin_dir, MADS_output_dir : String);
var
  i : LongInt;
  logFile : String;
  AProcess : TProcess;
  AStringList : TStringList;
begin
  logFile := GetCurrentDir + PathDelim + 'efflog.txt';

  // Create the TProcess object
  AProcess := TProcess.Create(nil);

  // Create the TStringList object.
  AStringList := TStringList.Create;
  AProcess.Parameters.Clear;

  // Tell the new AProcess what the command to execute is.
{$ifdef Unix}
  AProcess.Executable := MADS_dir + 'mads';
  AProcess.Parameters.Add(FilenameOrig);
  AProcess.Parameters.Add('-o:' + FilenameBin);  // Generate Atari native executable code
{$else}
  AProcess.Executable := MADS_dir + 'mads.exe';
  AProcess.Parameters.Add(AnsiQuotedStr(MADS_src_dir + FilenameOrig, '"'));
  AProcess.Parameters.Add('-o:' + AnsiQuotedStr(MADS_bin_dir + FilenameBin, '"'));  // Generate Atari native executable code
{$endif}

  AProcess.Parameters.Add('-x');  // Exclude unreferenced procedures
  AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;

  // Now read the output of the program we just ran into the TStringList.
  AStringList.LoadFromStream(AProcess.Output);
  //ErrList.LoadFromStream(AProcess.Stderr);
  //AStringList.Add(FormatDateTime('c', Now));
  //AStringList.Add('-----------------------------------------');

  // Check resulted compile status
  //mStatusLog := '';  //FormatDateTime('c', Now) + LineEnding;
  mStatus := '';
  for i := 0 to AStringList.Count - 1 do begin
    mStatusLog := mStatusLog + AStringList[i] + LineEnding;
    //if System.Pos('ERROR:', UpperCase(AStringList[i])) > 0 then begin
    //  mStatus := AStringList[i] + LineEnding;
      //lError := True;
    //end;

    //lWarnings := System.Pos('WARNING:', UpperCase(AStringList[i])) > 0;
    // else if System.Pos('WARNING:', UpperCase(AStringList[i])) > 0 then begin
    //  lWarnings := True;
    //end;
  end;

  //if lWarnings then
  //  mStatus := mStatus + 'There were some warnings found!' + LineEnding;
  //if not lError then
  //  mStatus := mStatus + 'Compiling was successful!' + LineEnding;
  AStringList.Add(FormatDateTime('c', Now));
  AStringList.Add('----------------------------------------');
  AStringList.Insert(0, 'Filename: ' + FilenameOrig);
  {
  if AStringList.Count < 0 then begin
    AStringList.Add('----------------------------------------');
    AStringList.Add('Filename: ' + FilenameOrig);
    AStringList.Add('Error at compile time!!!');
    AStringList.Add('----------------------------------------');
  end;
  }

  // Save the output to a file.
  AStringList.SaveToFile(logFile);

  AProcess.Parameters.Clear;

  // Redirect current output to the archive log
{$ifdef Unix}
  AProcess.Executable := '/bin/sh';
  AProcess.Parameters.Add('-c');
  AProcess.Parameters.Add('cat ' + logFile + ' >> effectus.log');
{$else}
  AProcess.Executable := 'cmd.exe';
  AProcess.Parameters.Add('/c');
  AProcess.Parameters.Add('"type ' + logFile + ' >> ' + MADS_output_dir + '"');
{$endif}
  AProcess.Options := [poWaitOnExit, poUsePipes];
  AProcess.Execute();
  AStringList.Free;
  AProcess.Free;
end;
*)
{------------------------------------------------------------------------------
 Description: Checks for reserved words in variable declarations
 Parameters : StrBuf - String value to search for
 -----------------------------------------------------------------------------}
function VarDeclCheck(StrBuf : String) : Boolean;
var
  i : byte;
begin
  Result := True;
  // Check for comments
  if System.Pos(';', StrBuf) > 0 then begin
    StrBuf := ExtractEx(StrBuf, ';', 1, []);
    //StrBuf := Extract(1, StrBuf, ';', []);
  end;
  // Checks for reserved words in variable declarations
  for i := 1 to 4 do begin
    if System.Pos(NotVarDecl[i], UpperCase(StrBuf)) > 0 then begin
      Result := False;
      Break;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Checks for reserved words in expression declarations
 Parameters : StrBuf - String value to search for
 -----------------------------------------------------------------------------}
function ExprCheck(StrBuf : String) : Boolean;
var
  i : ShortInt;
begin
  Result := True;

  // Check for comments
  if System.Pos(';', StrBuf) > 0 then begin
    StrBuf := ExtractEx(StrBuf, ';', 1, []);
    //StrBuf := Extract(1, StrBuf, ';', []);
  end;
    
  for i := 1 to 9 do begin
    if System.Pos(NotExpr[i], StrBuf) > 0 then begin
      Result := False;
      Break;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Reads configuration file
 -----------------------------------------------------------------------------}
procedure ReadCfg;
var
  IniFile : TIniFile;
begin
  // Default settings
  meditAddr := 2200;
  meditMADS_src_ext := 'asm';
  meditMADS_bin_ext := 'xex';
  meditMADS_rtl_dir := GetCurrentDir + PathDelim + 'lib' + PathDelim;
  meditMADS_log_dir := GetCurrentDir + PathDelim + 'log.txt';
  meditMLAddr := 8000;
  meditArrMax := 2200;

  // Read config file
  IniFile := TIniFile.Create( 'config.ini' );
  if FileExists(GetCurrentDir + PathDelim + 'config.ini') then begin
    IniFile.ReadIniFile;
    meditAddr := IniFile.ReadInteger( 'SETUP', 'ORG', meditAddr);
    meditMADS_src_ext := IniFile.ReadString('SETUP', 'MADS_SRC_EXT', meditMADS_src_ext);
    meditMADS_bin_ext := IniFile.ReadString('SETUP', 'MADS_BIN_EXT', meditMADS_bin_ext);
    {$ifdef Unix}
    meditMADS_rtl_dir := IniFile.ReadString('SETUP', 'MADS_RTL_DIR', './lib/');
    {$else}
    //'c:\atari\effectus\lib\'
    meditMADS_rtl_dir := IniFile.ReadString('SETUP', 'MADS_RTL_DIR', meditMADS_rtl_dir);
    meditMADS_log_dir := IniFile.ReadString('SETUP', 'MADS_LOG_DIR', meditMADS_log_dir);
    {$endif}
    meditMLAddr := IniFile.ReadInteger( 'SETUP', 'ML_ORG', meditMLAddr);
    meditArrMax := IniFile.ReadInteger( 'SETUP', 'ARRAY_MAX', meditArrMax);
  end;
  IniFile.Destroy;
end;

{------------------------------------------------------------------------------
 Description: Opens and reads Effectus source code file
 Returns    : Boolean True if reading the file was successful, otherwise False
 -----------------------------------------------------------------------------}

{------------------------------------------------------------------------------
 Description: Read and process Effectus INCLUDE source code listing file
 -----------------------------------------------------------------------------}
procedure ReadInclude;
var
  filename : string;
  incl : TStringList;
begin
  //if not isInclude then Exit;
  
  // Open Effectus source file
  //f := FileOpen(ASM_icl[icl], fmOpenRead);
  //filename := GetCurrentDir + PathDelim + ASM_icl[icl];
  filename := ASM_icl[icl];
//   if not FileExists(filename) then begin
//     WriteLn('The source listing doesn''t exist!');
//     Halt(0);
//   end;

//   if f = -1 then begin
//     WriteLn('Error reading INCLUDE file!');
//     Exit;
//   end;

  CodeBuf.Clear;
  ReadSource(filename, true);
  
  //FileClose(f);

  // Create Effectus include source file
  FilenameSrc := ExtractFileName(ASM_icl[icl]);
  FilenameSrc := Copy(FilenameSrc, 1, RPos('.', FilenameSrc) - 1) + '.';
  FilenameSrc += meditMADS_src_ext;
  
  //writeln('ASM_icl[icl] = ', ASM_icl[icl]);
  //writeln('include filename = ', meditMADS_src_dir + FilenameSrc);

  //AssignFile(fASM_lib, meditMADS_src_dir + FilenameSrc);
  //Rewrite(fASM_lib);
  //CodeBuf.Clear;
  GenLoop;

  //for i := 0 to CodeBuf.Count - 1 do begin
  //  WriteLn(fASM_lib, CodeBuf[i]);
  //end;

  incl := TStringList.Create;  
  try
    incl.Assign(CodeBuf);
    //CloseFile(fASM_lib);
    incl.SaveTofile(meditMADS_src_dir + FilenameSrc);
  finally
    incl.Free;
  end;    
end;

{------------------------------------------------------------------------------
 Description: Sets mva or mwa mnemonic command depending on the type of source variable
 Parameters : src - Source variable
 Returns    : Returns mnemonic command depending on the type of source variable
 -----------------------------------------------------------------------------}
function mvwa(src : String) : String;
begin
  if System.Pos(src, 'T1T2T5T6') > 0 then
    Result := ' mva '
  else
    Result := ' mwa ';
end;

{------------------------------------------------------------------------------
 Description: Determines if source variable is a number (it accepts a number prefixed with $ sign)
 Parameters : src - Value to be checked
 Returns    : Returns True if source variable is number, otherwise False
 -----------------------------------------------------------------------------}
function IsNumber(src : Char) : Boolean;
begin
  Result := (src in ['0'..'9']) or (src = '$');
  //Result := ((src > Chr(47)) and (src < Chr(58))) or (src = '$');
end;

{------------------------------------------------------------------------------
 Description: Splits string to separate string values delimited by multi-character
              or one-byte delimiter. It does trim out a space characters.
 Parameters : Str - String value to be separated
              Delimiter - Delimiter to be used as separator in Str
              Flags - two possible values:
                - []: Trims out all occurrences of a space character
                - [cNoTrim]: Does not trim out a space character
 -----------------------------------------------------------------------------}
procedure Split(Str, Delimiter : String; Flags : TFlags);
var
  Len : Byte;
  i : Integer = 1;
  buffer : String = '';
  //isStrEnd : boolean = false;
begin
(*
  StrBuf.Clear;
  StrBuf.StrictDelimiter := False;
  StrBuf.Delimiter := Delimiter[1];
  ExtractStrings([Delimiter[1]], [], PChar(Str), StrBuf);
  for i := 0 to StrBuf.Count - 1 do
    StrBuf[i] := IfThen(sNoTrim in Flags, StrBuf[i], Trim(StrBuf[i]));
*)
  Len := Length(Delimiter);
  StrBuf.Clear;
  if System.Pos(Delimiter, Str) < 1 then begin
    StrBuf.Add(Trim(Str));
    Exit;
  end;
  while i < Length(Str) do begin
    if Copy(Str, i, Len) = Delimiter then begin
      if System.Pos(Delimiter, buffer) > 0 then begin
        buffer := Copy(buffer, Len + 1, Length(buffer) - Len)
      end;
      //if Length(buffer) > 0 then isStrEnd := true;
      StrBuf.Add(buffer);
      buffer := '';
    end;
    //if isStrEnd then break;
    //if i <= Length(str) then begin 
    buffer += Str[i];
    //end;
    Inc(i);
  end;
  //until i > Length(Str);
  buffer += Str[i];
  buffer := Copy(buffer, Len + 1, Length(Buffer) - Len);
  StrBuf.Add(buffer);
  for i := 0 to StrBuf.Count - 1 do
    StrBuf[i] := IfThen(sNoTrim in Flags, StrBuf[i], Trim(StrBuf[i]));
end;

{------------------------------------------------------------------------------
 Description: Splits string to separate string values
 Parameters : Str - String value to be separated
            Delim1
            Delim2
            Delim3
            Delim4
 -----------------------------------------------------------------------------}
procedure SplitEx2(Str : String; Delim1, Delim2, Delim3, Delim4 : Char);
var
  i : Integer;
  buffer : String = '';

function test(str : string; delim : char): boolean;
begin  
  if UpperCase(Str[i]) = UpperCase(Delim) then begin
    if UpperCase(Str[i + 1]) = UpperCase(Delim) then begin
      buffer := Copy(buffer, 2, Length(buffer));
      StrBuf2.Add(buffer);
      buffer := '';
      result := false;
      Exit;
    end
    else begin
      if System.Pos(UpperCase(Delim), UpperCase(buffer)) > 0 then
        buffer := Copy(buffer, 2, Length(Buffer) - 1);
    end;
    buffer := Strip(buffer, Delim1);
    buffer := Strip(buffer, Delim2);
    buffer := Strip(buffer, Delim3);
    buffer := Strip(buffer, Delim4);
    StrBuf2.Add(Buffer);
    buffer := '';
  end;
  result := true;
end;

begin
  //Buffer := '';
  StrBuf2.Clear;
  if (System.Pos(UpperCase(Delim1), UpperCase(Str)) < 1)
     and (System.Pos(UpperCase(Delim2), UpperCase(Str)) < 1)
     and (System.Pos(UpperCase(Delim3), UpperCase(Str)) < 1)
     and (System.Pos(UpperCase(Delim4), UpperCase(Str)) < 1) then
  begin
    StrBuf.Add(Str);
    Exit;
  end;
  for i := 1 to Length(Str) do begin
    if not test(str, Delim1) then Continue
    else if not test(str, Delim2) then Continue
    else if not test(str, Delim3) then Continue
    else if not test(str, Delim4) then begin
      Continue;
    end;
    if i = Length(Str) then begin
      buffer += Str[i];
      buffer := Copy(buffer, 2, Length(buffer) - 1);
      StrBuf2.Add(buffer);
    end;
    buffer += Str[i];
  end;
end;

{------------------------------------------------------------------------------
 Description: Extracts string delimited by Delimiter
 Parameters : Str - String value to be separated
              Delimiter - Delimiter to be used as separator in Str
              Index
              Flags
 Returns    : Extracted text
 -----------------------------------------------------------------------------}
function ExtractEx(Str, Delimiter : String; Index : Integer; Flags : TFlags) : String;
var
  buffer : String = '';
  i, delimPos : Integer;
  flag : Boolean = False;
begin
  for i := 1 to Length(Str) do begin
    if (UpperCase(Copy(Str, i, Length(Delimiter))) = UpperCase(Delimiter)) and not Flag then begin
      Flag := True;
      DelimPos := i;
    end;
    if (UpperCase(Copy(Str, i, Length(Delimiter))) = UpperCase(Delimiter)) then begin
      if Index = 2 then begin
        buffer := Copy(Str, DelimPos + Length(Delimiter), Length(Str) - DelimPos + Length(Delimiter));
      end;
      Break;
    end;
    buffer += Str[i];
  end;
  if sNoTrim in Flags then
    Result := buffer
  else
    Result := Trim(buffer);
end;

function Extract(offset : byte; str : string; delim : char; Flags : TFlags) : string;
var
  res : string;
begin
  res := ExtractDelimited(offset, str, [delim]);
  if (res = '') and (offset > 1) then begin
    res := ExtractDelimited(1, str, [delim]);
  end;

  if sNoTrim in Flags then
    Result := res
  else
    Result := Trim(res);
end;

{------------------------------------------------------------------------------
 Description: Checks and processes variable value depending on its type (string or numeric)
 Parameters : Str - Variable value to be checked
 Returns    : Returns processed variable value
 -----------------------------------------------------------------------------}
function AsmStrNum(Str : String) : String;
var
  Str1, Str2 : String;
begin
  Str := StringReplace(Str, _EFF, '', [rfReplaceAll]);
  if Str[1] in ['$', '#'] then begin
  end
  else if Str[1] in ['0'..'9'] then begin  //> Chr(47)) and (Str[1] < Chr(58)) then begin
  //if ((Str[1] > Chr(47)) and (Str[1] < Chr(58))) or (Str[1] = '$') or (Str[1] = '#') then begin
    Str := '#' + Str;
  end
  else begin
    if System.Pos('[', Str) > 0 then begin
      Str1 := ExtractEx(Str, '[', 1, []);
      Str2 := ExtractEx(Str, '[', 2, []);
      //Str1 := Extract(1, Str, '[', []);
      //Str2 := Extract(2, Str, '[', []);
      Str := Str1 + _EFF + '[' + Str2;
    end
    else begin
      if (System.Pos('b_param', LowerCase(Str)) < 1)
         and (System.Pos('w_param', LowerCase(Str)) < 1)
         and (System.Pos('$A0', LowerCase(Str)) < 1) then begin
        Str += _EFF;
      end;
    end;
  end;
  Result := Str;
end;

{------------------------------------------------------------------------------
 Description: Replaces one occurence of a character in a string with another
 Parameters : Str - String value to be processed
              Ch1 - Character to be replaced
              Ch2 - New character
 Returns    : New string value
 -----------------------------------------------------------------------------}
function Replace(Str : String; Ch1, Ch2 : Char) : String;
var
  i : Integer;
begin
  i := System.Pos(Ch1, Str);
  Delete(Str, i, 1);
  Insert(Ch2, Str, i);
  Result := Str;
//  Result := StuffString(Str, System.Pos(Ch1, Str), 1, Ch2);
end;

{------------------------------------------------------------------------------
 Description: Deletes all occurences of a character in a string
 Parameters : Str - String value to be processed
              Ch - Character to be deleted from the string
 Returns    : New string value
 -----------------------------------------------------------------------------}
function Strip(Str : String; Ch : Char) : String;
begin
  Result := StringReplace(Str, Ch, '', [rfReplaceAll, rfIgnoreCase]);
end;

{------------------------------------------------------------------------------
 Description: Extracts string between characters Ch1 and Ch2
 Parameters : Str - Input string
              Ch1 - Starting character of examined string
              Ch2 - Last character of examined string
 Returns    : Returns string between characters Ch1 and Ch2
 Examples:
   Str := Between('ProcX(int a, byte b);', '(', ')');
   Str := Between('PrintE("test")', '"', '"');
 -----------------------------------------------------------------------------}
function ExtractText(Str : String; Ch1, Ch2 : Char) : String;
begin
  result := Copy(Str, System.Pos(Ch1, Str) + 1, RPos(Ch2, Str)-System.Pos(Ch1, Str) - 1);
  if Trim(result) = '' then begin
    result := str;
  end;
end;

{------------------------------------------------------------------------------
 Description: Processes arithmetic expressions
 Parameters : VarStr - Type of variable
              Str1   - Variable name
              Str2   - Variable value
              Flag
              Index  - Processed element in set or array
 -----------------------------------------------------------------------------}
procedure MathExpr(VarStr, Str1, Str2 : String; Flag, Index : Byte);
var
  i, n : Integer;
  Oper : Char = '+';
  isAdd8 : Boolean = True;
  OperMemn, OperIncMemn, StrX, str : String;
begin
  if System.Pos(VarStr, 'T5T6T7T8') > 0 then begin
    //i := 0;
    str := UpperCase(ExtractEx(Str1, '[', 1, []));
    //str := Extract(1, Str1, '[', []);

//     for j := 1 to GVarCnt2 do begin
//       if UpperCase(GVar2[j].VarName + _EFF) = str then begin
//         i := 1;
//         Break;
//       end;
//     end;

    if not Checkvar02Equal(str, _EFF) then begin
      Exit;
    end;
//     if varList02.IndexOfName(str + _EFF) > -1 then begin
//       i := 1;
//     end;
      
    //if i = 0 then Exit;
  end;
  
  // Parse ' character to determine ASCII character
  if str2[1] = '''' then begin
    str2 := ExtractEx(str2, '''', 2, []);
    //str2 := Extract(2, str2, '''', []);
    str2 := IntToStr(ord(str2[1]));
  end;

  // Check operators
  if System.Pos('*', Str2) > 0 then Oper := '*'
  else if System.Pos('/', Str2) > 0 then Oper := '/'
  else if System.Pos('+', Str2) > 0 then Oper := '+'
  else if System.Pos('-', Str2) > 0 then Oper := '-'
  else if System.Pos('MOD', UpperCase(Str2)) > 0 then Oper := 'M'
  else if System.Pos('LSH', UpperCase(Str2)) > 0 then Oper := 'L'
  else if System.Pos('RSH', UpperCase(Str2)) > 0 then Oper := 'R'
  else if System.Pos('XOR', UpperCase(Str2)) > 0 then Oper := 'X'
  else if System.Pos('!', Str2) > 0 then Oper := '!'
  else if System.Pos('&', Str2) > 0 then Oper := '&'
  else if System.Pos('%', Str2) > 0 then Oper := '%';

  n := 0;
  if Oper = 'M' then
    n := System.Pos('MOD', UpperCase(Str2))
  else if Oper = 'L' then
    n := System.Pos('LSH', UpperCase(Str2))
  else if Oper = 'R' then
    n := System.Pos('RSH', UpperCase(Str2))
  else if Oper = 'X' then begin
    n := System.Pos('XOR', UpperCase(Str2))
  end;
  if n > 0 then begin
    Delete(Str2, n + 1, 1);
    Insert(' ', Str2, n + 1);
    Delete(Str2, n + 2, 1);
    Insert(' ', Str2, n + 1);
    Str2 := Strip(Str2, ' ');
  end;

  Split(UpperCase(Str2), UpperCase(Oper), []);

  if StrBuf.Count < 1 then begin
    writeln('Error: Parameter mismatch!');
    Exit;
  end;

  // Check the number of operands
  if StrBuf.Count = 1 then begin
    if Flag = 1 then begin
      // Processing type variable
      if System.Pos('.', StrBuf[0]) > 0 then begin
        StrX := ExtractEx(StrBuf[0], '.', 1, []);
        Str2 := ExtractEx(StrBuf[0], '.', 2, []);
        //StrX := Extract(1, StrBuf[0], '.', []);
        //Str2 := Extract(2, StrBuf[0], '.', []);
        for n := 1 to GVarCnt do begin
          if (GVar[n].VarName = StrX) and (GVar[n].ParentType = 'T9') then begin
            CodeBuf.Add(mvwa(VarStr)+StrX+_EFF+'.'+Str2+_EFF+' '+AsmStrNum(Str1));
            Break;
          end;
        end;
      end
      // Other variable expression processing
      else begin
        StrX := '';
        // Routing array variable to the vector
        for n := 1 to GVarCnt do begin
          if (UpperCase(GVar[n].VarName) = UpperCase(Str1)) and (GVar[n].Value <> '') then begin
//             for i := 1 to GVarCnt2 do begin
//               if (UpperCase(GVar2[i].VarName) = UpperCase(StrBuf[0])) and (System.Pos(GVar2[i].VarType, 'T5T6T7T8') > 0) then begin
//                 StrX := 'Addr';
//                 CodeBuf.Add(mvwa(VarStr) + '#' + AsmStrNum(StrBuf[0]) + ' ' + AsmStrNum(Str1));
//                 Break;
//               end;
//             end;
            for i := 0 to varList02.Count - 1 do begin
              var02.VarType := Extract(1, varList02.ValueFromIndex[i], ';', []);
              if (UpperCase(varList02.Names[i]) = UpperCase(StrBuf[0])) and (System.Pos(var02.VarType, 'T5T6T7T8') > 0) then begin
                StrX := 'Addr';
                CodeBuf.Add(mvwa(VarStr) + '#' + AsmStrNum(StrBuf[0]) + ' ' + AsmStrNum(Str1));
                Break;
              end;
            end;
          end;
        end;
        // Routing routine to the vector
        for n := 1 to GVarCnt do begin
          if (UpperCase(GVar[n].VarName) = UpperCase(Str1)) and (GVar[n].Value <> '') then begin
            for i := 0 to ProcCount - 1 do begin
              if UpperCase(RightStr(ProcBuf[i], Length(ProcBuf[i])-4)) = UpperCase(StrBuf[0]) then begin
                StrX := 'Addr';
                CodeBuf.Add(mvwa(VarStr) + '#' + StrBuf[0] + _REFF + ' ' + AsmStrNum(Str1));
                Break;
              end;
            end;
            if IsNumber(StrBuf[0][1]) then begin
              StrX := 'Addr';
              CodeBuf.Add(mvwa(VarStr) + '#' + StrBuf[0] + ' ' + AsmStrNum(Str1));
              Break;
            end;
          end;
        end;
        // Other variable expression processing
        if StrX = '' then begin
          CodeBuf.Add(mvwa(VarStr) + AsmStrNum(StrBuf[0]) + ' ' + AsmStrNum(Str1));
        end;
      end;
    end
    else begin
      // Handling array elements set by array with initialized memory address
//       if (GVar2[Index].ML_type = 'MemAddr') and (System.Pos(' ARRAY', UpperCase(Str1)) < 1) then begin
//         CodeBuf.Add(mvwa(VarStr) + AsmStrNum(StrBuf[0]) + ' ' + Str1)
//       end
       if (var02.ML_type = 'MemAddr') and (System.Pos(' ARRAY', UpperCase(Str1)) < 1) then begin
         CodeBuf.Add(mvwa(VarStr) + AsmStrNum(StrBuf[0]) + ' ' + Str1)
       end
      // BYTE and CHAR ARRAY
      else if (System.Pos(VarStr, 'T5T6') > 0) and (Index = 0) then begin
        CodeBuf.Add(' mva ' + AsmStrNum(StrBuf[0]) + ' $c0');
        str := ExtractText(Str1, '[', ']');
        CodeBuf.Add(' ldx ' + AsmStrNum(str));
        Str1 := ExtractEx(Str1, '[', 1, []);
        //Str1 := Extract(1, Str1, '[', []);
        CodeBuf.Add(' mva $c0 ' + Str1 + ',x');
      end
      // BYTE and CHAR ARRAY
      else if (System.Pos(VarStr, 'T5T6') > 0) and (var02.Location <> 'T5') then begin
        CodeBuf.Add(' mva ' + AsmStrNum(StrBuf[0]) + ' ' + Str1)
      end
      // INT and CARD ARRAY
      else if System.Pos(VarStr, 'T7T8') > 0 then begin
        //if GVar2[Index].Location <> 'SET' then begin
        if var02.Location <> 'SET' then begin
          if Flag = 2 then begin
            if System.Pos(' ARRAY', UpperCase(Str1)) < 1 then
              CodeBuf.Add(' mwa ' + AsmStrNum(StrBuf[0]) + ' ' +  Str1)
          end
          else begin
            StrX := ExtractEx(Str1, '[', 1, []);
            Str1 := ExtractEx(Str1, '[', 2, []);
            //StrX := Extract(1, Str1, '[', []);
            //Str1 := Extract(2, Str1, '[', []);
            Str1 := LeftStr(Str1, Length(Str1) - 1);
            //Example: items_eff_array_str_3
            //if System.Pos(Str1, ' ARRAY ') < 1 then
            SData[Cnt] := StrX + 'array_str_' + Str1 + ' .byte ' + QuotedStr(StrBuf[0]) + ',$9b';
            Inc(Cnt);
          end;
        end;
      end;
    end;
  end
  else begin
    isMath := True;
    // Check to see if any of expression variables is of type CARD
    for n := 1 to GVarCnt do begin
      if StrBuf.IndexOf(GVar[n].VarName) >= 0 then begin
        if GVar[n].ML_type = 'word' then begin
          isAdd8 := False;
          Break;
        end;
      end;
    end;
    if (StrBuf[0][1] in ['0'..'9']) and (StrToInt(StrBuf[0]) > 255) then begin
      isAdd8 := False;
    end;
    if (StrBuf[1][1] in ['0'..'9']) and (StrToInt(StrBuf[1]) > 255) then begin
      isAdd8 := False;
    end;
    if System.Pos(VarStr, 'T3T4') > 0 then isAdd8 := False;
    Str1 := LowerCase(Str1);
    StrBuf[0] := LowerCase(StrBuf[0]);
    StrBuf[1] := LowerCase(StrBuf[1]);
    // Processing arithmetic operation
    case Oper of
      '*': begin
             if FuncCheck(StrBuf[0]) then StrBuf[0] := '$A0';
             if FuncCheck(StrBuf[1]) then StrBuf[1] := '$A0';
             if isAdd8 then
               CodeBuf.Add(' Mul8 ' + AsmStrNum(StrBuf[0]) + ', ' + AsmStrNum(StrBuf[1]))
             else
               CodeBuf.Add(' Mul16 ' + AsmStrNum(StrBuf[0]) + ', ' + AsmStrNum(StrBuf[1]));
           end;
      '/': begin
             if FuncCheck(StrBuf[0]) then StrBuf[0] := '$A0';
             if FuncCheck(StrBuf[1]) then StrBuf[1] := '$A0';
             if isAdd8 then
               CodeBuf.Add(' Div8 ' + AsmStrNum(StrBuf[0]) + ', ' + AsmStrNum(StrBuf[1]))
             else
               CodeBuf.Add(' Div16 ' + AsmStrNum(StrBuf[0]) + ', ' + AsmStrNum(StrBuf[1]));
           end;
      '+': begin
             if isAdd8 then begin
               OperMemn := ' adb ';
               OperIncMemn := ' inc ';
             end
             else begin
               OperMemn := ' adw ';
               OperIncMemn := ' inw ';
             end;
             // a = a + 1
             // a = 1 + a
             if ((Str1 = StrBuf[0]) or (Str1 = StrBuf[1]))
                and (((StrBuf[0] = '1') or (StrBuf[1] = '1'))) then begin
               //CodeBuf.Add(' ' + AsmStrNum(StrBuf[0]) + ' ' + AsmStrNum(StrBuf[1]));
               CodeBuf.Add(OperIncMemn + Str1 + _EFF);
             end
             else begin
               // a = b + c
               if (StrBuf[0] <> StrBuf[1]) and (Str1 <> StrBuf[0]) and (Str1 <> StrBuf[1]) then begin
                 if ((Char(StrBuf[0][1]) in ['0'..'9'])
                    or (StrBuf[0][1] = '$')) and FuncCheck('') then
                 begin
                   CodeBuf.Add(' mwa ' + AsmStrNum(StrBuf[0]) + ' $A0');
                   StrBuf[0] := '$A0'
                 end;
                 if FuncCheck(StrBuf[0]) then
                   CodeBuf.Add(OperMemn + '$A0 ' + AsmStrNum(StrBuf[1]) + ' ' + AsmStrNum(Str1))
                 else if FuncCheck(StrBuf[1]) then
                   CodeBuf.Add(OperMemn + '$A0 ' + AsmStrNum(StrBuf[0]) + ' ' + AsmStrNum(Str1))
                 else begin
                   CodeBuf.Add(OperMemn + AsmStrNum(StrBuf[0]) + ' ' + AsmStrNum(StrBuf[1]) + ' ' + AsmStrNum(Str1))
                 end;
               end
               else if ((Str1 = StrBuf[0]) or (Str1 = StrBuf[1])) then begin
                 if (Str1 = StrBuf[0]) then
                   CodeBuf.Add(OperMemn + AsmStrNum(Str1) + ' ' + AsmStrNum(StrBuf[1]))
                 else
                   CodeBuf.Add(OperMemn + AsmStrNum(Str1) + ' ' + AsmStrNum(StrBuf[0]));
               end;
               if StrBuf.Count > 2 then begin
                 for i := 2 to StrBuf.Count - 1 do
                   CodeBuf.Add(OperMemn + AsmStrNum(Str1) + ' ' + AsmStrNum(StrBuf[i]));
               end;
             end;
           end;
      '-': begin
             if isAdd8 then begin
               OperMemn := ' sbb ';
               OperIncMemn := ' dec ';
             end
             else begin
               OperMemn := ' sbw ';
               OperIncMemn := ' dew ';
             end;
             // a = a - 1
             // a = 1 - a
             if ((Str1 = StrBuf[0]) or (Str1 = StrBuf[1]))
                and (((StrBuf[0] = '1') or (StrBuf[1] = '1'))) then
             begin
               CodeBuf.Add(OperIncMemn + Str1 + _EFF);
             end
             else begin
               // a = b - c
               if (StrBuf[0] <> StrBuf[1]) and (Str1 <> StrBuf[0]) and (Str1 <> StrBuf[1]) then begin
                 if ((StrBuf[0][1] in ['0'..'9'])
                    or (Copy(StrBuf[0],1,1) = '$')) and FuncCheck('') then
                 begin
                   CodeBuf.Add(' mwa ' + AsmStrNum(StrBuf[0]) + ' $A0');
                   StrBuf[0] := '$A0'
                 end;
                 if FuncCheck(StrBuf[0]) then
                   CodeBuf.Add(OperMemn + '$A0 ' + AsmStrNum(StrBuf[1]) + ' ' + AsmStrNum(Str1))
                 else if FuncCheck(StrBuf[1]) then
                   CodeBuf.Add(OperMemn + AsmStrNum(StrBuf[0]) + ' $A0 ' + AsmStrNum(Str1))
                 else begin
                   CodeBuf.Add(OperMemn + AsmStrNum(StrBuf[0]) + ' ' + AsmStrNum(StrBuf[1]) + ' ' + AsmStrNum(Str1));
                 end;
               end
               else if ((Str1 = StrBuf[0]) or (Str1 = StrBuf[1])) then begin
                 if (Str1 = StrBuf[0]) then
                   CodeBuf.Add(OperMemn + AsmStrNum(Str1) + ' ' + AsmStrNum(StrBuf[1]))
                 else
                   CodeBuf.Add(OperMemn + AsmStrNum(Str1) + ' ' + AsmStrNum(StrBuf[0]));
               end;
               if strbuf.Count > 2 then begin
                 for i := 2 to strbuf.Count - 1 do
                   CodeBuf.Add(OperMemn + AsmStrNum(Str1) + ' ' + AsmStrNum(StrBuf[i]));
               end;
             end;
           end;
      'M': CodeBuf.Add(' Mod8 ' + AsmStrNum(StrBuf[0]) + ', ' + AsmStrNum(StrBuf[1]));
      'L': begin
             CodeBuf.Add(' lda ' + AsmStrNum(StrBuf[0]));
             for n := 1 to StrToInt(StrBuf[1]) do CodeBuf.Add(' asl @');
             CodeBuf.Add(' sta $A0');
           end;
      'R': begin
             CodeBuf.Add(' lda ' + AsmStrNum(StrBuf[0]));
             for n := 1 to StrToInt(StrBuf[1]) do CodeBuf.Add(' lsr @');
             CodeBuf.Add(' sta $A0');
           end;
      'X', '!':
      begin
        CodeBuf.Add(' lda ' + AsmStrNum(StrBuf[0]));
        CodeBuf.Add(' eor ' + AsmStrNum(StrBuf[1]));
        CodeBuf.Add(' sta $A0');
      end;
      '&':
      begin
        CodeBuf.Add(' lda ' + AsmStrNum(StrBuf[0]));
        CodeBuf.Add(' and ' + AsmStrNum(StrBuf[1]));
        CodeBuf.Add(' sta $A0');
      end;
      '%':
      begin
        CodeBuf.Add(' lda ' + AsmStrNum(StrBuf[0]));
        CodeBuf.Add(' ora ' + AsmStrNum(StrBuf[1]));
        CodeBuf.Add(' sta $A0');
      end;
    end;
    if (Oper <> '+') and (Oper <> '-') then begin
      if Flag = 1 then
        CodeBuf.Add(mvwa(VarStr) + ' $A0 ' + Str1 + _EFF)
      else begin
        if System.Pos(VarStr, 'T5T6') > 0 then  // BYTE and CHAR array
          CodeBuf.Add(' mva $A0 ' + Str1 + _EFF)
        else if System.Pos(VarStr, 'T7T8') > 0 then  // INT and CARD array
          CodeBuf.Add(' mwa $A0 ' + Str1 + _EFF);
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Replaces all defined constants with their counterpart values in source code listing
 Examples:
   DEFINE Cls="PUT(125)"
   DEFINE NewLine="PUTE()"
   DEFINE max="21"
 -----------------------------------------------------------------------------}
procedure DefineCheck;
var
  i, n : LongInt;
  str : String;
  defKey,                  // DEFINE constant - new value list
  defValue : TStringList;  // DEFINE constant - original command list
begin
  defKey := TStringList.Create;
  defValue := TStringList.Create;
  // Create DEFINE list
  for i := 0 to CR_LF do begin
    str := UpperCase(Trim(TextBuf[i]));
    // Search for DEFINE command
    if (System.Pos('DEFINE ', str) > 0) and (System.Pos('("', str) < 1) and (str[1] <> ';') then begin
      str := StringReplace(str, 'DEFINE ', '', [rfReplaceAll]);
      Split(str, '=', []);
      StrBuf[1] := UpperCase(ExtractText(StrBuf[1], '"', '"'));
      defKey.Add(StrBuf[0]);
      defValue.Add(StrBuf[1]);
    end;
  end;
  // Replace DEFINE values
  for i := 0 to CR_LF do begin
    str := UpperCase(Trim(TextBuf[i]));
    // Exclude DEFINE constants, because these are already ready
    if System.Pos('DEFINE ', str) > 0 then Continue;
    // Search for DEFINE command alternatives 
    for n := 0 to defKey.Count - 1 do begin
      if (System.Pos(defKey[n], str) > 0) and (System.Pos('("', str) < 1) then begin
        TextBuf[i] := StringReplace(UpperCase(TextBuf[i]), UpperCase(defKey[n]), UpperCase(defValue[n]), [rfReplaceAll]);
        break;
      end;
    end;
  end;
  defKey.Free;
  defValue.Free;
end;

{------------------------------------------------------------------------------
 Description: Generate Mads assembler code file
 -----------------------------------------------------------------------------}
procedure GenerateCode;
var
  i, j : LongInt;
  buffer, ArrType : String;
  filename, filex : string;
begin
  //writeln('meditEff_src_filename = ', meditEff_src_filename);
  if Copy(meditEff_src_filename, 1, 1) = PathDelim then begin
    meditEff_src_filename := Copy(meditEff_src_filename, 2, Length(meditEff_src_filename) - 1);
  end;

  //filename := GetCurrentDir + PathDelim + meditEff_src_filename;
  filename := meditEff_src_filename;
  isIncFlag := False;
  ReadSource(filename, false);

  FilenameSrc := ExtractFileName(meditEff_src_filename);
  FilenameSrc := Copy(FilenameSrc, 1, RPos('.', FilenameSrc) - 1) + '.';
  FilenameBin := FilenameSrc + meditMADS_bin_ext;
  FilenameSrc += meditMADS_src_ext;
  FilenameOrig := FilenameSrc;
  
  //AssignFile(fASM, meditMADS_src_dir + FilenameSrc);
  filex := meditMADS_src_dir + FilenameSrc;
  //Rewrite(fASM);
  //WriteLn(fASM, ' org $', meditAddr);
  code.Add(' org $' + IntToStr(meditAddr));
  //WriteLn(fASM, '');
  code.Add('');
  //c:\atari\projects\effectus\lib\
  //WriteLn(fASM, ' icl ' + QuotedStr(meditMADS_rtl_dir + 'common.asm'));
  code.Add(' icl ' + QuotedStr(meditMADS_rtl_dir + 'common.asm'));
  //WriteLn(fASM, '');
  code.Add('');
  if sElseIf in flags2 then begin
    //WriteLn(fASM, ' .var else_flag .byte');
    code.Add(' .var else_flag .byte');
  end;

  Cnt := 1;
  ProcML_cnt := 0;
  MemCnt := Hex2Dec(IntToStr(meditMLAddr));  // default 32768 (dec) $8000 (hex)
  isGraphicsFlag := False;
  isGr := False;
  isInput := False;
  ForCnt := 0;
  word_Cnt := 1;
  CodeBuf.Clear;

  // Check for DEFINE constants
  DefineCheck;

  for i := 0 to CR_LF - 1 do begin
    CurLine := i;
    buffer := Strip(TextBuf[i], ' ');
    if (Length(buffer) > 0) and (buffer[1] = ';') then Continue;
    
    sc_Var;
    sc_Var2;
    sc_Array;
  end;

  for i := 1 to GVarCnt do begin
    // Other processing
    if UpperCase(GVar[i].ParentType) = UpperCase(GVar[i].OrigType) then begin
      if GVar[i].Value <> '' then
        CodeBuf.Add(GVar[i].VarName + _EFF + ' equ ' + GVar[i].Value)
      else begin
        if GVar[i].InitValue = -1 then
          CodeBuf.Add(' .var ' + GVar[i].VarName + _EFF + ' .' + GVar[i].ML_type)
        else
          CodeBuf.Add(' .var ' + GVar[i].VarName + _EFF + '=' +
                      IntToStr(GVar[i].InitValue) + ' .' + GVar[i].ML_type);
      end;
    end
    else begin
      if System.Pos(GVar[i].ParentType, 'T10') > 0 then begin  // POINTER
        if LowerCase(GVar[i].ML_type) = 'word' then
          CodeBuf.Add(' .var ' + GVar[i].VarName + _EFF + ' .' + GVar[i].ML_type)
        else
          //CodeBuf.Add(' .var ' + GVar[i].VarName + _EFF + ' .byte');
          CodeBuf.Add(' .var ' + GVar[i].VarName + _EFF + ' .word');
      end;
    end;
  end;

  //for i := 1 to GVarCnt2 do begin
  for i := 0 to varList02.Count - 1 do begin
    var02.VarType := ExtractDelimited(1, varList02.ValueFromIndex[i], [';']);
    var02.OrigType := ExtractDelimited(2, varList02.ValueFromIndex[i], [';']);
    var02.ParentType := ExtractDelimited(3, varList02.ValueFromIndex[i], [';']);
    var02.Location := ExtractDelimited(4, varList02.ValueFromIndex[i], [';']);
    var02.Value := ExtractDelimited(5, varList02.ValueFromIndex[i], [';']);
    var02.Dim := StrToInt(ExtractDelimited(6, varList02.ValueFromIndex[i], [';']));
    var02.ML_type := ExtractDelimited(7, varList02.ValueFromIndex[i], [';']);
    //var02.InitValue := StrToInt(ExtractDelimited(8, varList02.ValueFromIndex[i], [';']));

//     writeln('var02.VarType = ', var02.VarType);
//     writeln('var02.OrigType = ', var02.OrigType);
//     writeln('var02.ParentType = ', var02.ParentType);
//     writeln('var02.Location = ', var02.Location);
//     writeln('var02.Value = ', var02.Value);
//     writeln('var02.Dim = ', var02.Dim);
//     writeln('var02.ML_type = ', var02.ML_type);

    // BYTE and CHAR ARRAY
//    if System.Pos(GVar2[i].VarType, 'T5T6T7T8') > 0 then begin
    if System.Pos(var02.VarType, 'T5T6T7T8') > 0 then begin
      if System.Pos(var02.VarType, 'T5T6') > 0 then
        ArrType := 'byte'
      else begin
        ArrType := 'word';
      end;
      // BYTE ARRAY str1="Text"
      // BYTE ARRAY A(4)=$3200
//      if GVar2[i].Location = 'T5' then begin
//        if GVar2[i].ML_type = 'MemAddr' then begin

      if tempValues.IndexOfName(varList02.Names[i]) > -1 then begin
        var02.Value := tempValues.ValueFromIndex[tempValues.IndexOfName(varList02.Names[i])];
      end;

      if var02.Location = 'T5' then begin
        if var02.ML_type = 'MemAddr' then begin
//           if GVar2[i].Dim = 0 then
//             CodeBuf.Add(GVar2[i].VarName + _EFF + ' = ' + GVar2[i].Value + ' .array [' + IntToStr(meditArrMax) + '] .' + ArrType)
//           else
//             CodeBuf.Add(GVar2[i].VarName + _EFF + ' = ' + GVar2[i].Value + ' .array [' + IntToStr(GVar2[i].Dim + 1) + '] .' + ArrType);
          if var02.Dim = 0 then
            CodeBuf.Add(varList02.Names[i] + _EFF + ' = ' + var02.Value + ' .array [' + IntToStr(meditArrMax) + '] .' + ArrType)
          else
            CodeBuf.Add(varList02.Names[i] + _EFF + ' = ' + var02.Value + ' .array [' + IntToStr(var02.Dim + 1) + '] .' + ArrType);
        end
        else begin
          if var02.Dim = 0 then
            CodeBuf.Add(' .array ' + varList02.Names[i] + _EFF + ' .' + ArrType + ' = $ff')
          else begin
            CodeBuf.Add(' .array ' + varList02.Names[i] + _EFF + ' [' + IntToStr(var02.Dim + 1) + '] .' + ArrType + ' = $ff');
          end;
          CodeBuf.Add(' [0] = ' + QuotedStr(var02.Value) + ',$9b');
          //CodeBuf.Add(' [0] = ''' + var02.Value + ''',$9b');
        end;
      end
      else if var02.Value <> '' then begin
      //else if tempValue <> '' then begin
        var02.Value := Copy(var02.Value, 1, Length(var02.Value) - 2);
        if var02.Dim = 0 then
          CodeBuf.Add(' .array ' + varList02.Names[i] + _EFF + ' .' + ArrType + ' = $ff')
        else begin
          CodeBuf.Add(' .array ' + varList02.Names[i] + _EFF + ' [' + IntToStr(var02.Dim + 1) + '] .' + ArrType + ' = $ff');
        end;
        CodeBuf.Add(' ' + var02.Value);
      end
      else begin
        CodeBuf.Add(' .array ' + varList02.Names[i] + _EFF +
                    ' [' + IntToStr(var02.Dim + 1) + '] .' + ArrType + ' = $ff');
      end;
      if var02.ML_type <> 'MemAddr' then begin
        CodeBuf.Add(' .end');
      end;
      if isArray then begin
        CodeBuf.Add(' .var array_buffer_' + varList02.Names[i] + _EFF + ' .word');
        CodeBuf.Add(' .var array_index_' + varList02.Names[i] + _EFF + ' .byte');
      end;
    end
    // TYPE variables
    else if System.Pos(var02.VarType, 'T9') > 0 then begin
      CodeBuf.Add(' .struct ' + varList02.Names[i] + _EFF);
      for j := 1 to 255 do begin
        //if GVar[j].ParentType = '' then continue;
        if (UpperCase(GVar[j].ParentType) = UpperCase(varList02.Names[i])) then begin
           // and (Length(GVar[j].ML_type) > 0) then
          //CodeBuf.Add(inttostr(j) + ' ' + GVar[j].VarName + _EFF + ' .' + GVar[j].ML_type + 'xxx');
          CodeBuf.Add(GVar[j].VarName + _EFF + ' .' + GVar[j].ML_type);
        end;
      end;
      CodeBuf.Add(' .ends');
    end;
  end;

//   for i := 0 to CodeBuf.Count - 1 do begin
//     WriteLn(fASM, CodeBuf[i]);
//   end;
  code.AddStrings(CodeBuf);
  //WriteLn(fASM, '');
  code.Add('');

  Icl := 0;
  flags := [];
  isInclude := False;

  isIncFlag := True;
  for i := 0 to CR_LF do begin
    CurLine := i;
    sc_Include;
  end;

  //if isIncludeX and not ReadOrig then Exit;
//   if Copy(meditEff_src_filename, 1, 1) = PathDelim then begin
//     meditEff_src_filename := Copy(meditEff_src_filename, 2, Length(meditEff_src_filename) - 1);
//   end;

  // Read INCLUDE source code listing file
  if isInclude then begin
    ReadInclude;
    isInclude := False;
    isIncFlag := False;
    filename := meditEff_src_filename;
    ReadSource(filename, false);
  end;

  // Generate remain code
  CodeBuf.Clear;
  GenLoop;
  
//   for i := 0 to CodeBuf.Count - 1 do begin
//     WriteLn(fASM, CodeBuf[i]);
//   end;
  code.AddStrings(CodeBuf);

  DeviceCheck;
//  WriteLn(fASM, ' jmp *');
//  WriteLn(fASM, '');
  code.Add(' jmp *');
  code.Add('');
  sc_ML_data;

  //WriteLn(fASM, ' .link ' + AnsiQuotedStr(meditMADS_rtl_dir + 'runtime.obx', ''''));
  code.Add(' .link ' + AnsiQuotedStr(meditMADS_rtl_dir + 'runtime.obx', ''''));
  sc_Lib(meditMADS_rtl_dir);
  sc_Data;
  //WriteLn(fASM, '');
  code.Add('');
  
  //writeln('ProcCount = ', ProcCount, ' * ProcCount2 = ', ProcCount2);

  //if isIncludeX and not isInclude then
  //    WriteLn(fASM, ' run ' + RightStr(ProcBuf[ProcCount2 - 1], Length(ProcBuf[ProcCount2 - 1]) - 4) + _REFF)
  //else begin
    //WriteLn(fASM, ' run ' + RightStr(ProcBuf[ProcCount - 1], Length(ProcBuf[ProcCount - 1]) - 4) + _REFF);
  //end;
  code.Add(' run ' + RightStr(ProcBuf[ProcCount - 1], Length(ProcBuf[ProcCount - 1]) - 4) + _REFF);

  //CloseFile(fASM);
  code.SaveToFile(filex);
end;

function Checkvar02(str, startStr, endStr : string) : boolean;
var
  i : byte;
begin
  result := false;
  if varList02.Count = 0 then Exit;

  for i := 0 to varList02.Count - 1 do begin
    if System.Pos(startStr + UpperCase(varList02.Names[i]) + endStr, UpperCase(str)) > 0 then begin
      var02.VarName := varList02.Names[i];
      var02.VarType := ExtractDelimited(1, varList02.ValueFromIndex[i], [';']);
      var02.OrigType := ExtractDelimited(2, varList02.ValueFromIndex[i], [';']);
      var02.ParentType := ExtractDelimited(3, varList02.ValueFromIndex[i], [';']);
      var02.Location := ExtractDelimited(4, varList02.ValueFromIndex[i], [';']);
      var02.Value := ExtractDelimited(5, varList02.ValueFromIndex[i], [';']);
      var02.Dim := StrToInt(ExtractDelimited(6, varList02.ValueFromIndex[i], [';']));
      var02.ML_type := ExtractDelimited(7, varList02.ValueFromIndex[i], [';']);
      //var02.InitValue := StrToInt(ExtractDelimited(8, varList02.ValueFromIndex[i], [';']));
      //var02.Scope := StrToChar(ExtractDelimited(9, varList02.ValueFromIndex[i], [';']));
      result := true;
      break;
    end;
  end;
end;

function CheckExtraVarType(types : string) : boolean;
var
  i : byte;
begin
  result := false;
  if varList02.Count = 0 then Exit;
  for i := 0 to varList02.Count - 1 do begin
    var02.VarType := Extract(1, varList02.ValueFromIndex[i], ';', []);
    if System.Pos(var02.VarType, types) > 0 then begin
      result := true;
      var02.VarName := varList02.Names[i];
      break
    end;
  end;
end;

function Checkvar02Equal(str, addStr : string) : boolean;
var
  i : byte;
begin
  result := false;
  if varList02.Count = 0 then Exit;
  for i := 0 to varList02.Count - 1 do begin
    if UpperCase(varList02.Names[i] + addStr) = UpperCase(str) then begin
      var02.VarName := varList02.Names[i];
      var02.VarType := ExtractDelimited(1, varList02.ValueFromIndex[i], [';']);
      var02.OrigType := ExtractDelimited(2, varList02.ValueFromIndex[i], [';']);
      var02.ParentType := ExtractDelimited(3, varList02.ValueFromIndex[i], [';']);
      var02.Location := ExtractDelimited(4, varList02.ValueFromIndex[i], [';']);
      var02.Value := ExtractDelimited(5, varList02.ValueFromIndex[i], [';']);
      var02.Dim := StrToInt(ExtractDelimited(6, varList02.ValueFromIndex[i], [';']));
      var02.ML_type := ExtractDelimited(7, varList02.ValueFromIndex[i], [';']);
      //var02.InitValue := StrToInt(ExtractDelimited(8, varList02.ValueFromIndex[i], [';']));
      //var02.Scope := StrToChar(ExtractDelimited(9, varList02.ValueFromIndex[i], [';']));
      result := true;
      break;
    end;
  end;
end;

// procedure var02List;
// var
//   i : byte;
// begin
//   for i := 0 to varList02.Count - 1 do
//   begin
//     var02.VarName := varList02.Names[i];
//     var02.VarType := ExtractDelimited(1, varList02.ValueFromIndex[i], [';']);
//     var02.OrigType := ExtractDelimited(2, varList02.ValueFromIndex[i], [';']);
//     var02.ParentType := ExtractDelimited(3, varList02.ValueFromIndex[i], [';']);
//     var02.Location := ExtractDelimited(4, varList02.ValueFromIndex[i], [';']);
//     var02.Value := ExtractDelimited(5, varList02.ValueFromIndex[i], [';']);
//     var02.Dim := StrToInt(ExtractDelimited(6, varList02.ValueFromIndex[i], [';']));
//     var02.ML_type := ExtractDelimited(7, varList02.ValueFromIndex[i], [';']);
//     var02.InitValue := StrToInt(ExtractDelimited(8, varList02.ValueFromIndex[i], [';']));
//     //var02.Scope := StrToChar(ExtractDelimited(9, varList02.ValueFromIndex[i], [';']));
//   end;
// end;

procedure WatchVar(spot : string; index : byte);
begin
  //exit;
  WriteLn(spot, ' ==> ',
          'GVar[', index, '].VarType = ', GVar[index].VarType,
          #13#10'GVar[', index, '].OrigType = ', GVar[index].OrigType,
          #13#10'GVar[', index, '].VarName = ', GVar[index].VarName,
          #13#10'GVar[', index, '].Location = ', GVar[index].Location,
          #13#10'GVar[', index, '].Value = ', GVar[index].Value,
          #13#10'GVar[', index, '].Dim = ', GVar[index].Dim,
          #13#10'GVar[', index, '].ML_type = ', GVar[index].ML_type,
          #13#10'GVar[', index, '].Scope = ', GVar[index].Scope,
          #13#10'GVar[', index, '].InitValue = ', GVar[index].InitValue);
  readln;
end;

end.