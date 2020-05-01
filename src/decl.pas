{
  Program: Effectus - Action! language parser and cross-assembler to native code
           for Atari 8-bit home computers

  Authors : Bostjan Gorisek (Effectus), Tebe (Mad Assembler, Mad Pascal)

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
  VERSION = '0.4';  // Effectus version

type
  { Machine language holder }
  TProcML = record
    Name : String;
    ProcType : Byte;
    Code : String;
    Address : String[5];
    isAsm : boolean;
    strAsm : string
  end;

  TVarPtr = record
    dataType    : string;
    isVar       : boolean;
    isVarStart  : boolean;
    isDataType  : boolean;
    isVarOver   : boolean;
    isVarEnd    : boolean;

    // ARRAY declaration flags
    arrayDataType : string;
    isArrayDataType : boolean;
    isByteArray : boolean;      // Is BYTE ARRAY with predefined values?
    byteArray : string;         // BYTE ARRAY predefined values storage
    isCardArray : boolean;      // Is CARD ARRAY with predefined values?
    cardArray : string;         // CARD ARRAY predefined values storage

    pointerDataType : string;
    isPointerDataType : boolean;
    isPointerAddress : boolean;

    typeDataType : string;
    isTypeDataType : boolean;
    typeDataTypeVar : string;
    isTypeRecVarLast : boolean;
    typeRecVarCnt : byte;

    // Temporary storage
    str01, str02 : string;
    
    isDefine : boolean;
    isFunc : boolean;
  end;

  TBranchPtr = record
    isIfThen : boolean;
    isIfThenNext : boolean;
    isElseNext : boolean;
    isElseIfNext : boolean;
    isEndIfNext : boolean;
    isIfThenInProgress : boolean;
    ifThenCode : string;
    ifTempCode : string;

    isFor : boolean;
    isForDoNext : boolean;
    isForToNext : boolean;
    isForOdNext : boolean;
    forCode : string;

    isWhile : boolean;
    isWhileDoNext : boolean;
    isWhileOdNext : boolean;
    whileCode : string;
    
    isDoOd : boolean;
    isUntil : boolean;
    untilCode : string;
  end;

  TPrgPtr = record
    isProcBegin : boolean;
    isProcFirstBegin : boolean;
    isBegin : boolean;
    isProc : boolean;
    isFunc : boolean;
    isProcName : boolean;
    isProcParams : boolean;
    procParams : string;
    strProcName : string;
    strProcLocalName : string;
    isProcAddr : boolean;
    isFuncAsm : boolean;
    strAsmDecl : string;

    colorValue : string;  // color variable current value
    
    isByteBuffer : boolean;
  end;

  TDevicePtr = record
    isOpen : boolean;
    isDevice : boolean;
    isStick : boolean;
    isGraphics : boolean;
    isGr0 : boolean;
  end;

  Flag = (sFor, sWhile, sUntil, sNoTrim, sMemAddr, sProcAsm, sOd, sFi, sAsm);
  TFlags = Set of Flag;

var
  procs, funcs : TStringList;
  keywords : TStringList;
  vars : TStringList;  // Variables
  ProcParams : TStringList;  // PROCedure parameters
  dataTypes : TStringList;  
  code : TStringList;
  effCode : TStringList;  
  isClearLog : Boolean = False;
  ProcCount : LongInt;  // PROC statement count
  FuncCount : LongInt;  // FUNC statement count
  FuncList : TStringList;
  defineList : TStringList; 
  filenameSrc : string;
  procML : TProcML;
  CurLine : LongInt;
  //aEOF : Array[0..7] of Integer;
  optOutput,
  optBinExt, //meditMADS_src_dir,
  //meditMADS_rtl_dir,// meditMADS_bin_dir,
  meditMADS_log_dir : String;
  //meditAddr, meditMLAddr, meditArrMax : Integer;
  actionFilename : String = '';
  //flags2 : TFlags2;  
  isInfo : Boolean = False;  // Information about variables, procedures and functions
  myProcs, myFuncs : TStringList;
  //operators : TStringList;
  oper : TStringList;

  dataValue : string;
  prgPtr : TPrgPtr;
  branchPtr : TBranchPtr;
  varPtr : TVarPtr;
  devicePtr : TDevicePtr;
  paramCntx : byte;
  paramTypes : string;
  prgName : string;
  
  operators : TStringArray;

procedure Init;
procedure CreateLists;
procedure DestroyLists;

implementation

{------------------------------------------------------------------------------
 Description: Initialize global variables
 -----------------------------------------------------------------------------}
procedure Init;
begin
  FuncList.Clear;
  code.Clear;
  effCode.Clear;
  procs.Clear;
  funcs.Clear;
  ProcParams.Clear;
  dataTypes.Clear;
  vars.Clear;
  keywords.Clear;
  myProcs.Clear;
  myFuncs.Clear;
  defineList.Clear;

  ProcCount := 0; FuncCount := 0;

//   for i := 0 to 7 do begin
//     isIOerror[i] := False;
//     aEOF[i] := 0;
//   end;

  // Action! keywords  
  keywords.Add('MODULE=0');
  keywords.Add('PROC=0');
  keywords.Add('FUNC=0');
  keywords.Add('RETURN=0');
  keywords.Add('INCLUDE=0');
  keywords.Add('SET=0');
  keywords.Add('DEFINE=0');
  keywords.Add('EXIT=0');
  keywords.Add('BREAK=0');
  //keywords.Add('TYPE=0');
  // Branches
  keywords.Add('IF=1');
  keywords.Add('THEN=1');
  keywords.Add('ELSE=1');
  keywords.Add('ELSEIF=1');
  keywords.Add('FI=1');
  keywords.Add('FOR=1');
  keywords.Add('STEP=1');
  keywords.Add('TO=1');
  keywords.Add('WHILE=1');
  keywords.Add('UNTIL=1');
  keywords.Add('DO=1');
  keywords.Add('OD=1');
  // Conditional operators
//   keywords.Add('AND=2');
//   keywords.Add('OR=2');
//   keywords.Add('RSH=2');
//   keywords.Add('LSH=2');
//   keywords.Add('MOD=2');
//   keywords.Add('XOR=2');

  dataTypes.Add('BYTE=1');
  dataTypes.Add('CHAR=1');
  dataTypes.Add('INT=1');
  dataTypes.Add('CARD=1');
  dataTypes.Add('ARRAY=2');
  dataTypes.Add('POINTER=2');
  dataTypes.Add('SBYTE=3');
  dataTypes.Add('TYPE=4');

  // Action! PROCedures  
  procs.Add('Print=4');
  procs.Add('PrintE=4');
  procs.Add('PrintD=4');
  procs.Add('PrintDE=4');
  procs.Add('PrintB=4');
  procs.Add('PrintBE=4');
  procs.Add('PrintBD=4');
  procs.Add('PrintBDE=4');
  procs.Add('PrintC=4');
  procs.Add('PrintCE=4');
  procs.Add('PrintCD=4');
  procs.Add('PrintCDE=4'); 
  procs.Add('PrintI=4');
  procs.Add('PrintIE=4');
  procs.Add('PrintID=4');
  procs.Add('PrintIDE=4');
  procs.Add('PrintF=4');
  procs.Add('Put=4');
  procs.Add('PutE=4'); 
  procs.Add('PutD=4');
  procs.Add('PutDE=4');
  procs.Add('InputS=4');
  procs.Add('InputSD=4');
  procs.Add('InputMD=4');
  procs.Add('Open=4'); 
  procs.Add('Close=4');
  procs.Add('XIO=4');
  procs.Add('Note=4');
  procs.Add('Point=4');
  procs.Add('Graphics=4');
  procs.Add('SetColor=4'); 
  procs.Add('Plot=4');
  procs.Add('DrawTo=4');
  procs.Add('Fill=4');
  procs.Add('Position=4');
  procs.Add('Sound=4');
  procs.Add('SndRst=4'); 
  procs.Add('SCopy=4');
  procs.Add('SCopyS=4');
  procs.Add('SAssign=4');
  procs.Add('Error=4');
  procs.Add('Zero=4');
  procs.Add('SetBlock=4');
  procs.Add('MoveBlock=4');
  procs.Add('StrB=4');
  procs.Add('StrC=4');
  procs.Add('StrI=4');
  procs.Add('Poke=4');
  procs.Add('PokeC=4');

  // PROCedure parameters  
  procParams.Add('Print=1;1');
  procParams.Add('PrintE=1;1');
  procParams.Add('PutE=0');
  procParams.Add('PrintB=1;2');
  procParams.Add('PrintBE=1;2');
  procParams.Add('PrintI=1;3');
  procParams.Add('PrintIE=1;3');
  procParams.Add('PrintC=1;4');
  procParams.Add('PrintCE=1;4');
  procParams.Add('Put=1;2');
  procParams.Add('PrintF=255;255');
  
  procParams.Add('Graphics=1;2');
  procParams.Add('Plot=2;4;2');
  procParams.Add('DrawTo=2;4;2');
  procParams.Add('Position=2;4;2');
  procParams.Add('SetColor=3;2;2;2');
  procParams.Add('Fill=2;4;2');

  procParams.Add('Poke=2;4;2');
  procParams.Add('PokeC=2;4;4');
  
  procParams.Add('Zero=2;4;4');
  procParams.Add('SetBlock=3;4;4;2');
  procParams.Add('MoveBlock=3;4;4;4');
  
  procParams.Add('Sound=4;2;2;2;2');
  procParams.Add('SndRst=0');
  
  procParams.Add('SCopy=2;1;1');
  procParams.Add('SCopyS=4;1;1;2;2');
  procParams.Add('SAssign=4;1;1;2;2');
  procParams.Add('StrB=2;2;1');
  procParams.Add('StrC=2;4;1');
  procParams.Add('StrI=2;3;1');
  
  procParams.Add('InputS=1;1');
  
  procParams.Add('Open=4;2;1;2;2');
  procParams.Add('Close=1;2');
  procParams.Add('PrintD=2;2;1');
  procParams.Add('PrintDE=2;2;1');
  procParams.Add('PrintBD=2;2;2');
  procParams.Add('PrintBDE=2;2;2');
  procParams.Add('PrintCD=2;2;4');
  procParams.Add('PrintCDE=2;2;4');
  procParams.Add('PrintID=2;2;3');
  procParams.Add('PrintIDE=2;2;3');
  procParams.Add('InputSD=2;2;1');
  procParams.Add('InputMD=3;2;1;2');

  funcs.Add('Color=0');
  //funcs.Add('EOF=0');
  funcs.Add('Rand=1');
  funcs.Add('Peek=1');
  funcs.Add('PeekC=1');
  funcs.Add('ValB=1');
  funcs.Add('ValC=1');
  funcs.Add('ValI=1');
  funcs.Add('Stick=1');
  funcs.Add('Strig=1');
  funcs.Add('GetD=1');
  funcs.Add('InputB=1');
  funcs.Add('InputC=1');
  funcs.Add('InputI=1');
  funcs.Add('InputBD=1');
  funcs.Add('InputCD=1');
  funcs.Add('InputID=1');
  funcs.Add('SCompare=1');
  funcs.Add('Locate=1');

  // FUNCtion parameters
  procParams.Add('Color=0');
  //procParams.Add('EOF=0');
  procParams.Add('Locate=2;4;2');
  
  procParams.Add('Rand=1;2');
  procParams.Add('Peek=1;4');
  procParams.Add('PeekC=1;4');
  procParams.Add('ValB=1;1');
  procParams.Add('ValC=1;1');
  procParams.Add('ValI=1;1');
  procParams.Add('Stick=1;2');
  procParams.Add('Strig=1;2');

  procParams.Add('Paddle=1;2');
  procParams.Add('Ptrig=1;2');

  procParams.Add('GetD=1;2');
  procParams.Add('InputB=1;0');
  procParams.Add('InputC=1;0');
  procParams.Add('InputI=1;0');
  procParams.Add('InputBD=1;2');
  procParams.Add('InputCD=1;2');
  procParams.Add('InputID=1;2');
  procParams.Add('SCompare=2;1;1');

  //ProcBuf.CaseSensitive := False;
end;

{------------------------------------------------------------------------------
 Description: Create string lists
 -----------------------------------------------------------------------------}
procedure CreateLists;
begin
  effCode := TStringlist.create;
  code := TStringList.Create;
  procs := TStringList.Create;
  funcs := TStringList.Create;
  dataTypes := TStringList.Create;
  vars := TStringList.Create;
  FuncList := TStringList.Create;
  ProcParams := TStringList.Create;
  keywords := TStringList.Create;
  myProcs := TStringList.Create;
  myFuncs := TStringList.Create;
  defineList := TStringList.Create;
  oper := TStringlist.create;
end;

{------------------------------------------------------------------------------
 Description: Destroy string lists
 -----------------------------------------------------------------------------}
procedure DestroyLists;
begin
  effCode.Free;
  code.Free;
  procs.Free;
  funcs.Free;
  dataTypes.Free;
  vars.Free;
  FuncList.Free;
  ProcParams.Free;
  keywords.Free;
  myProcs.Free;
  myFuncs.Free;
  defineList.Free;
  oper.Free;
end;

end.