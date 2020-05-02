{
  Program: Effectus - Atari MADS cross-assembler/parser for Action! language
  Authors : Bostjan Gorisek (Effectus), Tebe (Mad Assembler)

  Unit file  : decl.pas
  Description: Declaration and destruction code

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
unit Decl;
//{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

Uses
  SySUtils, Classes;

const
  VERSION  = '0.3.1';  // Effectus version number

type
  { Program indicators }
  TPrgVar = record
    Pointer : Word;  // Line pointer
    SB : Byte;       // Square bracket function
  end;

  { Variable holder }
  TVar = record
    VarType : String;
    OrigType : String;
    ParentType : String;
    VarName : String;
    Location : String;
    Value : String;
    Dim : Integer;
    InitValue : Integer;
    ML_type : String;
    Scope : Char;
  end;

  { Record holder }
  TRecPtrVar = record
    Name : String;
    Dim : Integer;
    ArrayDim : Integer;
    Flag : Boolean;
  end;

  { Machine language holder }
  TProcML = record
    Name : String;
    ProcType : Byte;
    Code : String;
    Address : String[5];
  end;

  { For variable holder }
  TForVar = record
    VarName : String;
    VarType : String;
    StartValue : String;
    EndValue : String;
    Step : String;
    ForLabel : String;
    Nested : Boolean;
    ForEnd: Boolean;
  end;

  Flag = (sFor, sWhile, sUntil, sNoTrim, sMemAddr, sProcAsm, sOd, sFi, sAsm);
  TFlags = Set of Flag;

  Flag2 = (sUntilFlag, sExitFlag, sElseIf);
  TFlags2 = Set of Flag2;

const
  MAX_LINE = 255;

  Operators: Array[1..20] of String[2] =
    ('<=',  { Bitwise or }
     '>=',  { Bitwise xor }
     '==',  { Equal (same as =) }
     '<<',  { Arithmetic shift left }
     '>>',  { Arithmetic shift right }
     '<>',  { Not equal }
     '!=',  { Not equal (same as <>) }
     '|',   { Bitwise or }
     '^',   { Bitwise xor }
     '&&',  { Logical and }
     '||',  { Logical or }
     '+',   { Addition }
     '-',   { Subtraction }
     '=',   { Equal }
     '*',   { Multiplication }
     '/',   { Division }
     '%',   { Remainder }
     '&',   { Bitwise and }
     '<',   { Less than }
     '>');  { Greater than }

  NotExpr: Array[1..9] of String[6] =
    ('BYTE ', 'CARD ', 'INT ', 'CHAR ', 'FOR ', ' THEN', 'WHILE ', 'IF ', 'UNTIL ');
  
  NotVarDecl: Array[1..4] of String[9] =
    (' ARRAY ', ' POINTER ', ' FUNC ', 'PROC ');

  { Variable types }
  _EFF_T1 = 'BYTE';
  _EFF_T2 = 'CHAR';
  _EFF_T3 = 'INT';
  _EFF_T4 = 'CARD';
  _EFF_T5 = 'BYTE ARRAY';
  _EFF_T6 = 'CHAR ARRAY';
  _EFF_T7 = 'INT ARRAY';
  _EFF_T8 = 'CARD ARRAY';
  _EFF_T9 = 'TYPE';
  _EFF_T10 = 'POINTER';

  { Square bracket function }
  _SB_NULL      = 0;
  _SB_ARRAY     = 1;
  _SB_ARRAY_SET = 2;
  _SB_PROC_ML   = 3;
  _SB_TYPE      = 4;
  _SB_ML        = 5;

  _EFF = '_eff_';    // Effectus variable suffix name  
  _REFF = '_reff_';  // Effectus routine suffix name
  //_ATARI_CR = ',$9b';  // Atari carriage return

var
  Cnt, Icl, word_Cnt, cntx, ProcML_cnt,
  MemCnt, CntML : Integer;
  //TextBuf: Array[1..255*255] of String[MAX_LINE];
  TextBuf: TStringList;
  ASM_icl : Array[1..255] of String[MAX_LINE];
  ProcBuf, PrmBuf, tmpList : TStringList;
  //fASM, fASM_lib : TextFile;  // source code file handlers
  code : TStringList;
  isMainProc, UntilFlag, isGraphics, isSound, isPrintF,
  isIO, isPrintFD, isMath, isControllers, isInput: Boolean;
  isType: Boolean = False;
  isDelLog : Boolean = False;
  SData, ProcML_data : Array[1..255] of String[MAX_LINE];
  CR_LF,                  // Number of ACTION! source code lines found
  ProcCount,  // PROC statement count
  FuncCount : LongInt;    // FUNC statement count
  isInclude, isGraphicsFlag, isGr : Boolean;
  isIncFlag : Boolean;
  FuncList, GrProcs, SoundProcs, PrintFProcs, PrintFDProcs, ControllerProcs, IOProcs : TStringList;
  FilenameSrc, FilenameBin, FilenameOrig,
  ForVarX : String;
  ForCnt, cnt_InputS : LongInt;
  SCopy_buf, InputS_buf : Array[1..255] of String[MAX_LINE];
  CodeBuf, StrBuf, StrBuf2,
  VarTypes, VarTypes2 : TStringList;
  mValues : Array[0..10] of String[255];
  mLength : Array[0..10] of byte;
  GVar : Array[1..255] of TVar;
  var02, var0202 : TVar;
  varList02 : TStringList;
  ProcML : Array[1..255] of TProcML;
  GVarCnt, CurLine : LongInt;
  isIOerror : Array[0..7] of Boolean;
  mStatusLog, mStatus : String;
  aEOF : Array[0..7] of Integer;
  meditMADS_bin_ext, meditMADS_src_ext, meditMADS_src_dir,
  meditMADS_rtl_dir, meditMADS_dir, meditMADS_bin_dir,
  meditMADS_log_dir : String;
  meditAddr, meditMLAddr, meditArrMax : Integer;
  meditEff_src_filename : String = '';
  SrcLine, PtrData : String;
  isArray : Boolean = False;
  isPtr : Boolean = False;
  PtrCnt : Integer = 0;
  RecPtrVar : TRecPtrVar;
  TypeMemCnt : Integer = 0;
  TypeMemDim : Integer = 0;
  isSCopy : Boolean = False;
  ProcML_start : Boolean = False;
  ML_start : Boolean = False;
  ArraySet_start : Boolean = False;
  LoopIndex, WhileIndex, UntilIndex,
  ifElseIndex : LongInt;
  PrgVar : TPrgVar;
  isElse : Boolean;  // ELSE statement handling
  flags : TFlags;
  flags2 : TFlags2;
  isInfo : Boolean = False;  // Information about variables, procedures and functions
  MemAddrCarry : String;
  ForVar : Array[1..10] of TForVar;
  CurrentBranch : Byte;
  tmpBuf : String;
  tempValues : TStringList;

function SetType(TypeParam : String) : String;
procedure Init;
procedure CreateLists;
procedure DestroyLists;

implementation

{------------------------------------------------------------------------------
 Description: Check the type of parameter/variable
 -----------------------------------------------------------------------------}
function SetType(TypeParam : String) : String;
begin
  if UpperCase(TypeParam) = _EFF_T1 then Result := 'T1'
  else if UpperCase(TypeParam) = _EFF_T2 then Result := 'T2'
  else if UpperCase(TypeParam) = _EFF_T3 then Result := 'T3'
  else if UpperCase(TypeParam) = _EFF_T4 then Result := 'T4'
  else if UpperCase(TypeParam) = _EFF_T5 then Result := 'T5'
  else if UpperCase(TypeParam) = _EFF_T6 then Result := 'T6'
  else if UpperCase(TypeParam) = _EFF_T7 then Result := 'T7'
  else if UpperCase(TypeParam) = _EFF_T8 then Result := 'T8'
  else if UpperCase(TypeParam) = _EFF_T9 then Result := 'T9'
  else if UpperCase(TypeParam) = _EFF_T10 then Result := 'T10'
  else Result := TypeParam;
end;

{------------------------------------------------------------------------------
 Description: Initialize variables
 -----------------------------------------------------------------------------}
procedure Init;
var
  i : LongInt;
begin
  cntx := 1;

  TextBuf.Clear;
  FuncList.Clear;
  GrProcs.Clear;
  SoundProcs.Clear;
  PrintFProcs.Clear;
  PrintFDProcs.Clear;
  ControllerProcs.Clear;
  CodeBuf.Clear;
  StrBuf.Clear;
  StrBuf2.Clear;
  ProcBuf.Clear;
  PrmBuf.Clear;
  VarTypes.Clear;
  VarTypes2.Clear;
  tmpList.Clear;
  varList02.Clear;
  tempValues.Clear;
  code.Clear;
  //incl.Clear;

  PrgVar.Pointer := 0;
  PrgVar.SB := _SB_NULL;
  
  flags := []; flags2 := [];

  ProcCount := 0; FuncCount := 0; //ProcCount2 := 0;
  cnt_InputS := 0;

  for i := 1 to 255 do begin
    SData[i] := '';
    SCopy_buf[i] := '';
    InputS_buf[i] := '';
    //bool_InputS[i] := False;

    GVar[i].VarType  := '';
    GVar[i].OrigType  := '';
    GVar[i].ParentType  := '';
    GVar[i].VarName  := '';
    GVar[i].Location := '';
    GVar[i].Value    := '';
    GVar[i].Dim      := 0;
    GVar[i].InitValue := -1;
    GVar[i].Scope := 'G';
  end;
  for i := 1 to 10 do begin
    ForVar[i].VarName := '';
    ForVar[i].VarType := '';
    ForVar[i].StartValue := '';
    ForVar[i].EndValue := '';
    ForVar[i].Step := '';
    ForVar[i].ForLabel := '';
    ForVar[i].Nested := False;
    ForVar[i].ForEnd := True;
  end;

  GVarCnt := 0;
  RecPtrVar.Name := '';
  RecPtrVar.Dim := 0;
  RecPtrVar.ArrayDim := 0;
  RecPtrVar.Flag := False;

  { inititalize library variables to False }
  isGraphics := False;
  isIO := False;
  isMath := False;
  isPrintF := False;
  isPrintFD := False;
  isSound := False;
  isControllers := False;

  { Variable types }
  VarTypes.Add('BYTE');
  VarTypes.Add('CHAR');
  VarTypes.Add('INT');
  VarTypes.Add('CARD');

  { Variable types }
  VarTypes2.Add('BYTE ARRAY');
  VarTypes2.Add('CHAR ARRAY');
  VarTypes2.Add('CARD ARRAY');
  VarTypes2.Add('INT ARRAY');
  VarTypes2.Add(' POINTER');
  VarTypes2.Add('TYPE ');
  
  { Graphics library routines }
  GrProcs.Add('Graphics');
  GrProcs.Add('Plot');
  GrProcs.Add('DrawTo');
  GrProcs.Add('Fill');
  GrProcs.Add('Color');
  GrProcs.Add('Position');
  GrProcs.Add('Locate');

  { Sound library routines }
  SoundProcs.Add('Sound');
  SoundProcs.Add('SndRst');

  { PrintF library routines }
  PrintFProcs.Add('Print');
  PrintFProcs.Add('PrintE');
  PrintFProcs.Add('PrintB');
  PrintFProcs.Add('PrintBE');
  PrintFProcs.Add('PrintI');
  PrintFProcs.Add('PrintIE');
  PrintFProcs.Add('PrintC');
  PrintFProcs.Add('PrintCE');
  PrintFProcs.Add('PrintF');

  { I/O library routines }
  IOProcs.Add('Open');
  IOProcs.Add('Close');
  IOProcs.Add('GetD');
  IOProcs.Add('PrintDE');
  IOProcs.Add('PrintD');
  IOProcs.Add('PutDE');
  IOProcs.Add('PutD');
  IOProcs.Add('Point');
  IOProcs.Add('Note');
  IOProcs.Add('InputSD');

  { Print to device routines }
  PrintFDProcs.Add('PrintBDE');
  PrintFDProcs.Add('PrintBD');
  PrintFDProcs.Add('PrintCDE');
  PrintFDProcs.Add('PrintCD');
  PrintFDProcs.Add('PrintIDE');
  PrintFDProcs.Add('PrintID');
  
  { Game controller routines }
  ControllerProcs.Add('Stick');
  ControllerProcs.Add('Strig');
  ControllerProcs.Add('Paddle');
  ControllerProcs.Add('Ptrig');

  for i := 0 to 7 do begin
    isIOerror[i] := False;
    aEOF[i] := 0;
  end;

  ProcBuf.CaseSensitive := False;

  // Delete log file if console -dl option is selected
   if isDelLog and DeleteFile(meditMADS_log_dir) then begin
     Writeln('Log file is cleared!');
   end;
end;

{------------------------------------------------------------------------------
 Description: Create string lists
 -----------------------------------------------------------------------------}
procedure CreateLists;
begin
  TextBuf := TStringList.Create;
  CodeBuf := TStringList.Create;
  FuncList := TStringList.Create;
  GrProcs := TStringList.Create;
  SoundProcs := TStringList.Create;
  PrintFProcs := TStringList.Create;
  IOProcs := TStringList.Create;
  PrintFDProcs := TStringList.Create;
  ControllerProcs := TStringList.Create;
  StrBuf := TStringList.Create;
  StrBuf2 := TStringList.Create;
  ProcBuf := TStringList.Create;
  PrmBuf := TStringList.Create;
  VarTypes := TStringList.Create;
  VarTypes2 := TStringList.Create;
  tmpList := TStringList.Create;

  code := TStringList.Create;
  //incl := TStringList.Create;

  varList02 := TStringList.Create;
  varList02.NameValueSeparator := '=';

  tempValues := TStringList.Create;
  tempValues.NameValueSeparator := '=';
end;

{------------------------------------------------------------------------------
 Description: Destroy string lists
 -----------------------------------------------------------------------------}
procedure DestroyLists;
begin
  TextBuf.Free;
  FuncList.Free;
  GrProcs.Free;
  SoundProcs.Free;
  PrintFProcs.Free;
  PrintFDProcs.Free;
  ControllerProcs.Free;
  CodeBuf.Free;
  StrBuf.Free;
  StrBuf2.Free;
  ProcBuf.Free;
  PrmBuf.Free;
  IOProcs.Free;
  VarTypes.Free;
  VarTypes2.Free;
  tmpList.Free;
  varList02.Free;
  tempValues.Free;
  code.Free;
  //incl.Free;
end;

end.