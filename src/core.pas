{
  Program: Effectus - Atari MADS cross-assembler/parser for Action! language
  Authors : Bostjan Gorisek (Effectus), Tebe (Mad Assembler)

  Unit file  : core.pas
  Description: Build-in Action! core behaviour

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
unit Core;
//{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
  sysutils, Classes, StrUtils;

procedure sc_Proc;
procedure sc_Return;
procedure sc_Include;
procedure sc_Var;
procedure sc_Var2;
procedure sc_Var3(xType, xVar, xVarType : String);
procedure sc_Array;
procedure sc_VarExpr;
procedure sc_Data;
procedure sc_ML_data;
procedure sc_ProcTrack;
procedure sc_For;
procedure sc_od;
procedure sc_fi;
procedure sc_else;
function FuncCheck(stmt : String) : Boolean;
procedure GenLoop;
procedure Cond(Stmt : String);
procedure sc_do;
procedure sc_Exit;
procedure sc_ML;

implementation

uses
  Decl, Common, Routines;

var
  typeRecName : string;

{------------------------------------------------------------------------------
 Description: Action! PROC and FUNC definitions
 -----------------------------------------------------------------------------}
procedure sc_Proc;
var
  k, m : byte;
  isWord : Boolean = False;
  n1, n, j : LongInt;
  cntPrm : byte = 0;
  ParamList : TStringList;
  FuncName, FuncParams, VarType, VarX, Buffer, MemAddr : String;
  parVal : array[0..15] of byte;
begin
  n1 := System.Pos('PROC ', UpperCase(TextBuf[CurLine]));
  n := System.Pos('FUNC ', UpperCase(TextBuf[CurLine]));
//  j := System.Pos(';', TextBuf[CurLine]);
  j := 100;

  if (((n1 > 0) and (n1 < j)) or ((n > 0) and (n < j)))
     and (System.Pos('"', TextBuf[CurLine]) < 1) then
  begin
    //writeln('proc = ', UpperCase(TextBuf[CurLine]));
    if n1 > 0 then
      Split(UpperCase(TextBuf[CurLine]), 'PROC', [])
    else begin
      Split(UpperCase(TextBuf[CurLine]), 'FUNC', []);
    end;

    FuncName := StrBuf[1];
    Split(FuncName, '(', []);
    FuncName := StrBuf[0];
    FuncParams := ExtractEx(StrBuf[1], ')', 1, []);
    //FuncParams := Extract(1, StrBuf[1], ')', []);

    // Check for routine vectored to specific memory address
    //MemAddr := ExtractEx(FuncName, '=', 2, []);
    //FuncName := ExtractEx(FuncName, '=', 1, []);
    //MemAddr := Trim(ExtractDelimited(2, FuncName, ['=']));
    MemAddr := Extract(2, FuncName, '=', []);
    FuncName := Extract(1, FuncName, '=', []);
    
    n := System.Pos('[', TextBuf[CurLine]);
    n1 := System.Pos('PROC ', UpperCase(TextBuf[CurLine]));
    j := System.Pos('FUNC ', UpperCase(TextBuf[CurLine]));

    // Point routine to specific memory address
    // Example: PROC SCROLL=$F7F7 ()
    if (FuncName <> MemAddr) and (n < 1) then begin
      flags += [sMemAddr];
    end;

    // Declare routine as block of machine code
    // Example: PROC Pokest2=*()[$A9$60$8D$02C6$0$60]
    if (n > 0) and ((n1 > 0) or (j > 0)) then begin
      flags += [sProcAsm];
    end;

    // Check for machine language mnemonics
    if System.Pos('=*', FuncName) > 0 then begin
      FuncName := Copy(FuncName, 1, Length(FuncName) - 2);
      CntML := MemCnt;
      Inc(ProcML_cnt);
      ProcML[ProcML_cnt].Name := FuncName;
      ProcML[ProcML_cnt].ProcType := 0;
      ProcML[ProcML_cnt].Code := ' .he';
      ProcML_start := True;
      PrgVar.SB := _SB_PROC_ML;
    end;

    // Routine with parameters  
    if Length(FuncParams) > 0 then begin
      ParamList := TStringList.Create;
      Buffer := '';
      StrBuf2.Clear;
      //Fillchar(parVal, 0, sizeof(parVal));
      FuncParams := StringReplace(FuncParams, ', ', ',', [rfReplaceAll]);
      Split(FuncParams, ' ', []);  // Split type and variables
      for n := 0 to StrBuf.Count - 1 do begin
        StrBuf2.Add(StrBuf[n]);
        j := VarTypes.IndexOf(StrBuf2[n]);
        if j > 1 then isWord := True;
      end;
      for n := 0 to StrBuf2.Count - 1 do begin
        j := VarTypes.IndexOf(StrBuf2[n]);
        // Check variable type
        if j >= 0 then begin
          case j of
            0, 1 : VarX := 'byte';
            2, 3 : VarX := 'word';
          end;
          VarType := VarTypes[j];
          Buffer += ' .' + VarX + ' ';
        // Process variables
        end
        else begin
          Split(StrBuf2[n], ',', []);
          // Loop through all parameters
          for n1 := 0 to StrBuf.Count - 1 do begin
            Inc(GVarCnt);
            GVar[GVarCnt].VarType  := SetType(VarType);
            GVar[GVarCnt].OrigType := '';
            GVar[GVarCnt].VarName  := StrBuf[n1];
            GVar[GVarCnt].Location := FuncName;
            GVar[GVarCnt].Value    := '';
            GVar[GVarCnt].Dim      := 0;
            GVar[GVarCnt].ML_type  := VarX;
            GVar[GVarCnt].Scope    := 'L';
            GVar[GVarCnt].InitValue := cntPrm;
            //WatchVar('1', GVarCnt);
            Inc(cntPrm);
            if not ProcML_start then begin
              ParamList.Add(StrBuf[n1]);
            end;
          end;
          for n1 := 0 to StrBuf.Count - 1 do begin
            if (sMemAddr in Flags) or (sProcAsm in Flags) then begin
              // Use Accumulator, X and Y register when up to three BYTE parameters are used
              //if (StrBuf.Count - 1 < 3) and (System.Pos(GVar[GVarCnt].VarType, 'T1T2') > 0) and not isWord then begin
              if (StrBuf.Count - 1 < 3) and not isWord then begin
                case n1 of
                  0: Buffer += 'a';
                  1: Buffer += ', x';
                  2: Buffer += ', y';
                end;
              // otherwise use Action! code block variables up to 16 parameters
              end
              else begin
                if System.Pos(GVar[GVarCnt].VarType, 'T1T2') > 0 then begin
                  case n1 of
                    0: Buffer += 'a_reg';
                    1: Buffer += ', x_reg';
                    2: Buffer += ', y_reg';
                  end;
                  if n1 > 2 then begin
                    Buffer += ', a' + Dec2Numb(n1, 1, 16) + '_par';
                  end;
                end
                else begin
                  if n1 = 0 then
                    Buffer += StrBuf[n1] + _EFF
                  else
                    Buffer += ', ' + StrBuf[n1] + _EFF;
                end;
              end;
            end
            else begin
              if n1 = 0 then
                Buffer += StrBuf[n1] + _EFF
              else
                Buffer += ', ' + StrBuf[n1] + _EFF;
            end;
          end;
        end;
      end;

      if (sMemAddr in Flags) or (sProcAsm in Flags) then begin
        if (StrBuf.Count - 1 < 3) and not isWord then
          CodeBuf.Add(FuncName + _REFF + ' .proc (' + LowerCase(Buffer) + ') .reg')
        else begin
          CodeBuf.Add(FuncName + _REFF + ' .proc (' + LowerCase(Buffer) + ') .var');
          // mva a4_par $a4
          for j := 3 to StrBuf.Count - 1 do begin
            CodeBuf.Add(' mva a' + IntToStr(j) + '_par $a' + IntToStr(j));
          end;

          VarX := '';
          for j := 1 to GVarCnt do begin
            if (ParamList.IndexOf(GVar[j].VarName) >= 0) and (GVar[j].Scope = 'L') then begin
            //  Inc(n);
              if System.Pos(GVar[GVarCnt].VarType, 'T3T4') > 0 then begin
              //if isWord then begin
                CodeBuf.Add(' .var ' + GVar[j].VarName + _EFF + ' .' + GVar[j].ML_type);
              end;
              //param[n] := GVar[j].VarName + _EFF;
            end;
          end;

          Fillchar(parVal, 0, sizeof(parVal));
          for j := 1 to GVarCnt do begin
            if (System.Pos(GVar[j].VarType, 'T1T2') > 0) and (GVar[j].Scope = 'L') then begin
              parVal[GVar[j].initValue] := 0;
              if GVar[j].initValue = 0 then
                CodeBuf.Add(' lda a_reg')
              else if GVar[j].initValue = 1 then
                CodeBuf.Add(' ldx x_reg')
              else if GVar[j].initValue = 2 then
                CodeBuf.Add(' ldy y_reg');
            end
            else if (System.Pos(GVar[j].VarType, 'T3T4') > 0) and (GVar[j].Scope = 'L') then begin
              VarX := GVar[j].VarName + _EFF;
              parVal[GVar[j].initValue] := 1;
              if GVar[j].initValue = 0 then begin
                CodeBuf.Add(' lda ' + VarX);
                CodeBuf.Add(' pha');
                CodeBuf.Add(' ldx ' + VarX + '+1');
              end;
              if GVar[j].initValue = 1 then begin
                if parVal[0] = 1 then begin
                  CodeBuf.Add(' ldy ' + VarX);
                  CodeBuf.Add(' mva ' + VarX + '+1 $A3');
                end
                else if parVal[0] = 0 then begin
                  CodeBuf.Add(' ldx ' + VarX);
                  CodeBuf.Add(' ldy ' + VarX + '+1 $A3');
                end;
                CodeBuf.Add(' pla');
              end;
              if GVar[j].initValue = 2 then begin
                m := 0;
                for k := 0 to 1 do begin
                  m += parVal[k];
                end;
                // All previous parameters byte values?
                if m = 0 then begin
                  CodeBuf.Add(' ldy ' + VarX);
                  CodeBuf.Add(' mva ' + VarX + '+1 $A' + IntToStr(GVar[j].initValue + 1));
                  CodeBuf.Add(' pla');
                // On previous parameter int/card value?
                end
                else if m = 1 then begin
                  CodeBuf.Add(' mva ' + VarX + '+1 $A' + IntToStr(GVar[j].initValue + 1));
                  CodeBuf.Add(' mva ' + VarX + '+1 $A' + IntToStr(GVar[j].initValue + 2));
                end;
              end;
              if GVar[j].initValue = 3 then begin
                m := 0;
                for k := 0 to 2 do begin
                  m += parVal[k];
                end;
                // All previous parameters byte values?
                //if m = 0 then begin
                CodeBuf.Add(' mva ' + VarX + '+1 $A' + IntToStr(GVar[j].initValue + m));
                CodeBuf.Add(' mva ' + VarX + '+1 $A' + IntToStr(GVar[j].initValue + m + 1));
              end;
            end;
          end;
        end;
      end
      else begin
        CodeBuf.Add(FuncName + _REFF + ' .proc (' + LowerCase(Buffer) + ') .var');
      end;

      if not isInclude
         and (LowerCase(RightStr(ProcBuf[ProcCount - 1], Length(ProcBuf[ProcCount - 1]) - 4)) = LowerCase(FuncName)) then
      begin
        isMainProc := True;
      end
      else begin
        isMainProc := False;
      end;

      if not (sMemAddr in Flags) and not (sProcAsm in Flags) then begin
        for j := 1 to GVarCnt do begin
          if (ParamList.IndexOf(GVar[j].VarName) >= 0) and (GVar[j].Scope = 'L') then
            CodeBuf.Add(' .var ' + GVar[j].VarName + _EFF + ' .' + GVar[j].ML_type);
        end;
      end;

      ParamList.Free;
    end
    // Routine with no parameters
    else begin
      isMainProc := False;
      if not isInclude then begin
        if UpperCase(RightStr(ProcBuf[ProcCount - 1], Length(ProcBuf[ProcCount - 1]) - 4)) = UpperCase(FuncName) then begin
          CodeBuf.Add(FuncName + _REFF);
          isMainProc := True;
        end
        else begin
          if PrgVar.SB <> _SB_PROC_ML then
            CodeBuf.Add(FuncName + _REFF + ' .proc');
        end;
      end
      else begin
        if PrgVar.SB <> _SB_PROC_ML then
          CodeBuf.Add(FuncName + _REFF + ' .proc');
      end;
    end;

    // Process assembler code block routine
    if (sMemAddr in flags) then begin
      flags -= [sMemAddr];
      if MemAddr <> '*' then begin
        CodeBuf.Add(' jsr ' + MemAddr);
        CodeBuf.Add(' rts');
        CodeBuf.Add('');
        CodeBuf.Add(' .endp');
      end
      else begin
        flags += [sAsm];
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! RETURN statement
 -----------------------------------------------------------------------------}
procedure sc_Return;
var
  n : Integer;
begin
  if (System.Pos('RETURN', UpperCase(TextBuf[CurLine])) > 0) then begin  // or (sMemAddr in flags) then
    if (System.Pos('(', UpperCase(TextBuf[CurLine])) > 0)
       and (System.Pos(')', UpperCase(TextBuf[CurLine])) > 0) then begin
      for n := 1 to GVarCnt do begin
        if System.Pos(UpperCase(GVar[n].VarName), UpperCase(TextBuf[CurLine])) > 0 then begin
          if not ProcML_start then begin
            CodeBuf.Add(' mwa ' + GVar[n].VarName + _EFF + ' $A0');
          end;
          Break;
        end;
      end;
    end;
    if sMemAddr in flags then begin
    //  CodeBuf.Add(' jsr ' + MemAddrCarry);
      flags -= [sMemAddr];
    end
    else if not isMainProc then begin
      CodeBuf.Add(' rts');
      CodeBuf.Add('');
      CodeBuf.Add(' .endp');
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Checks for Action! reserved standard function names in statements
 Parameters : stmt (string)
 Returns    : Returns boolean value accordingly to function name found or not
 -----------------------------------------------------------------------------}
function FuncCheck(stmt : String) : Boolean;
var
  n : Byte;
  bool : Boolean = True;
begin
  if stmt <> '' then begin
    bool := True;
    stmt := Trim(UpperCase(stmt))
  end
  else begin
    bool := False;
    stmt := UpperCase(TextBuf[CurLine]);
  end;
  Result := not bool;
  // Check for comments
  if System.Pos(';', stmt) > 0 then begin
    stmt := ExtractEx(stmt, ';', 1, []);
    //stmt := Extract(1, stmt, ';', []);
  end;
  // Check for functions
  for n := 0 to FuncList.Count - 1 do begin
    if System.Pos(UpperCase(FuncList[n]) + '(', stmt) > 0 then begin
      Result := bool;
      Break;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! variable declarations
 -----------------------------------------------------------------------------}
procedure sc_Var;
var
  n, j, k : LongInt;
  MemAddr, Buffer, VarType, VarX, Str1, Str2 : String;
begin
  if (System.Pos('[', TextBuf[CurLine]) > 0)
     and (System.Pos('TYPE ', UpperCase(TextBuf[CurLine])) > 0) then
  begin
    Exit;
  end;
  if not isType then begin
    // Scalar type variables
    for j := 0 to VarTypes.Count - 1 do begin
      n := System.Pos(UpperCase(VarTypes[j]) + ' ', UpperCase(TextBuf[CurLine]));
      if (n > 0) and VarDeclCheck(TextBuf[CurLine]) then begin
        if System.Pos(';', TextBuf[CurLine]) > 0 then begin
          CodeBuf.Add('; ' + ExtractEx(TextBuf[CurLine], ';', 2, []));
          //CodeBuf.Add('; ' + Extract(2, TextBuf[CurLine], ';', []));
          TextBuf[CurLine] := ExtractEx(TextBuf[CurLine], ';', 1, []);
          //TextBuf[CurLine] := Extract(1, TextBuf[CurLine], ';', []);
          n := System.Pos(UpperCase(VarTypes[j]) + ' ', UpperCase(TextBuf[CurLine]));
          if (n < 1) then Continue;
        end;

        Buffer := Trim(TextBuf[CurLine]);
        VarType := UpperCase(ExtractEx(Buffer, ' ', 1, []));
        //VarType := UpperCase(Extract(1, Buffer, ' ', []));

        if VarType = VarTypes[j] then begin
          if (VarType = 'CARD') or (VarType = 'INT') then begin
            VarType := 'word'
          end
          else if VarType = 'CHAR' then begin
            VarType := 'byte';
          end;
          VarX := LowerCase(VarType);
        end;

        VarType := ExtractEx(Buffer, ' ', 2, []);
        //VarType := Extract(2, Buffer, ' ', []);
        Split(VarType, ',', []);

        for n := 0 to StrBuf.Count - 1 do begin
          MemAddr := '';
          if System.Pos('=', StrBuf[n]) < 1 then begin
            Str2 := '-1';
          end
          else begin
            Buffer := Strip(StrBuf[n], ' ');
            Str1 := ExtractEx(Buffer, '=', 1, []);
            Str2 := ExtractEx(Buffer, '=', 2, []);
            //Str1 := Extract(1, Buffer, '=', []);
            //Str2 := Extract(2, Buffer, '=', []);
            k := System.Pos('[', Str2);
            if k < 1 then
              MemAddr := Str2
            else begin
              Str2 := ExtractText(Str2, '[', ']');
              PrgVar.SB := _SB_ARRAY_SET;
            end;
            StrBuf[n] := Str1;
          end;
          if System.Pos('"', StrBuf[n]) < 1 then begin
            Inc(GVarCnt);
            GVar[GVarCnt].VarType    := SetType(VarTypes[j]);
            GVar[GVarCnt].ParentType := SetType(VarTypes[j]);
            GVar[GVarCnt].OrigType   := SetType(VarTypes[j]);
            GVar[GVarCnt].VarName    := StrBuf[n];
            GVar[GVarCnt].Location   := '';
            GVar[GVarCnt].Value      := MemAddr;
            GVar[GVarCnt].Dim        := 0;
            GVar[GVarCnt].InitValue  := StrToInt(Str2);
            GVar[GVarCnt].ML_type    := VarX;
            //WatchVar('2', GVarCnt);
          end;
        end;
        Break;
      end;
    end;

    // Arrays and pointers
    //for j := 1 to GVarCnt2 do begin
    for j := 0 to varList02.Count - 1 do begin
      var02.VarType := ExtractDelimited(1, varList02.ValueFromIndex[j], [';']);
      var02.OrigType := ExtractDelimited(2, varList02.ValueFromIndex[j], [';']);
      var02.ParentType := ExtractDelimited(3, varList02.ValueFromIndex[j], [';']);
      var02.Location := ExtractDelimited(4, varList02.ValueFromIndex[j], [';']);
      var02.Value := ExtractDelimited(5, varList02.ValueFromIndex[j], [';']);
      var02.Dim := StrToInt(ExtractDelimited(6, varList02.ValueFromIndex[j], [';']));
      var02.ML_type := ExtractDelimited(7, varList02.ValueFromIndex[j], [';']);
      //var02.InitValue := StrToInt(ExtractDelimited(8, varList02.ValueFromIndex[j], [';']));

      if System.Pos(var02.VarType, 'T5T6T7T8T10') > 0 then Continue;

      //n := System.Pos(UpperCase(GVar2[j].VarName), UpperCase(TextBuf[CurLine]));
      n := System.Pos(UpperCase(varList02.Names[j]), UpperCase(TextBuf[CurLine]));
      if (n > 0) and VarDeclCheck(TextBuf[CurLine]) then begin
        Buffer := Trim(TextBuf[CurLine]);
        // Comments
        if System.Pos(';', Buffer) > 0 then begin
          CodeBuf.Add('; ' + ExtractEx(Buffer, ';', 2, []));
          //CodeBuf.Add('; ' + Extract(2, Buffer, ';', []));
          Buffer := ExtractEx(Buffer, ';', 1, []);
          //Buffer := Extract(1, Buffer, ';', []);
          // Bug found by Spaced Cowboy from AtariAge
          //n := System.Pos(UpperCase(VarTypes[j]) + ' ', UpperCase(Buffer));
          n := System.Pos(UpperCase(var02.VarType) + ' ', UpperCase(Buffer));
          if (n < 1) then Continue;
        end;

        VarType := ExtractEx(Buffer, ' ', 1, []);
        //VarType := UpperCase(Extract(1, Buffer, ' ', []));
        //VarType := UpperCase(VarType);
        if UpperCase(VarType) = UpperCase(varList02.Names[j]) then begin
          VarX := VarType;
          if (VarType = 'CARD') or (VarType = 'INT') then
            VarX := 'word'
          else if (VarType = 'BYTE') or (VarType = 'CHAR') then
            VarX := 'byte';
        end;
        VarType := ExtractEx(Buffer, ' ', 2, []);
        //VarType := Extract(2, Buffer, ' ', []);
        Split(VarType, ',', []);
        MemAddr := '';
        for n := 0 to StrBuf.Count - 1 do begin
          if System.Pos('"', StrBuf[n]) < 1 then begin
            Inc(GVarCnt);
            GVar[GVarCnt].VarType    := SetType(VarType);
            GVar[GVarCnt].ParentType := SetType(var02.VarType);
            GVar[GVarCnt].OrigType   := SetType(varList02.Names[j]);
            GVar[GVarCnt].VarName    := StrBuf[n];
            GVar[GVarCnt].Location   := '';
            GVar[GVarCnt].Value      := MemAddr;
            GVar[GVarCnt].Dim        := 0;
            GVar[GVarCnt].ML_type    := VarX;
            //WatchVar('3', GVarCnt);
            SData[Cnt] := GVar[GVarCnt].VarName + _EFF + ' ' + VarX + _EFF;
            Inc(Cnt);
          end;
        end;
        Break;
      end;
    end;
  end
  // TYPE declaration variables
  else begin
    for j := 0 to VarTypes.Count - 1 do begin
      n := System.Pos(UpperCase(VarTypes[j]) + ' ', UpperCase(TextBuf[CurLine]));
      if (n > 0) and VarDeclCheck(TextBuf[CurLine]) then begin
        Buffer := Trim(TextBuf[CurLine]);

        if System.Pos(';', Buffer) > 0 then begin
          CodeBuf.Add('; ' + ExtractEx(Buffer, ';', 2, []));
          //CodeBuf.Add('; ' + Extract(2, Buffer, ';', []));
          Buffer := ExtractEx(Buffer, ';', 1, []);
          //Buffer := Extract(1, Buffer, ';', []);
          n := System.Pos(UpperCase(VarTypes[j]) + ' ', UpperCase(Buffer));
          if (n < 1) then Continue;
        end;

        //Buffer := Trim(TextBuf[CurLine]);
        VarType := ExtractEx(Buffer, ' ', 1, []);
        //VarType := Extract(1, Buffer, ' ', []);

        if UpperCase(VarType) = VarTypes[j] then begin
          if (UpperCase(VarType) = 'CHAR') or (UpperCase(VarType) = 'BYTE') then
            VarType := 'byte'
          else if (UpperCase(VarType) = 'CARD') or (UpperCase(VarType) = 'INT') then
            VarType := 'word';
        end;

        Buffer := ExtractEx(Buffer, ' ', 2, []);
        //Buffer := Extract(2, Buffer, ' ', []);
        Split(Buffer, ',', []);
        for n := 0 to StrBuf.Count - 1 do begin
          MemAddr := '';
          if VarType = 'byte' then
            Inc(TypeMemCnt, 1)
          else begin
            Inc(TypeMemCnt, 2);
          end;
          if System.Pos(']', StrBuf[n]) > 0 then begin
            StrBuf[n] := Copy(StrBuf[n], 1, Length(StrBuf[n]) - 1);
            isType := False;
            PrgVar.SB := _SB_ARRAY_SET;
          end;
          Inc(GVarCnt);
          GVar[GVarCnt].VarType    := SetType(VarTypes[j]);
          //GVar[GVarCnt].ParentType := SetType(GVar2[GVarCnt2].VarName);
          GVar[GVarCnt].ParentType := SetType(varList02.Names[varList02.count - 1]);
          GVar[GVarCnt].OrigType   := SetType(VarTypes[j]);
          GVar[GVarCnt].VarName    := StrBuf[n];
          //GVar[GVarCnt].Location   := IntToStr(GVarCnt2);
          GVar[GVarCnt].Location   := IntToStr(varList02.count - 1);
          GVar[GVarCnt].Value      := MemAddr;
          GVar[GVarCnt].Dim        := 0;
          GVar[GVarCnt].ML_type    := VarType;
          //WatchVar('4', GVarCnt);
        end;
        Break;
      end;
    end;
    //if (System.Pos(']', TextBuf[CurLine]) > 0) and isType then begin
    //  isType := False;
    //end;
    isType := not (System.Pos(']', TextBuf[CurLine]) > 0) and isType;
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! complex ARRAY, TYPE and POINTER variable declarations
 -----------------------------------------------------------------------------}
procedure sc_Var2;
var
  n, n4, j : LongInt;
  CharPos : String[1];
  Buffer, VarType, VarX, Str1, Str2, xType, xVar, arrayValue : String;
  isFirstSpace : Boolean;
  effType : string;
  effVarName : string;
  effVarDim : string;
  effOrigType : string;
begin
  // TYPE variables handling  
  if System.Pos('TYPE ', UpperCase(TextBuf[CurLine])) > 0 then begin
    Buffer := Trim(TextBuf[CurLine]);

    if System.Pos(';', Buffer) > 0 then begin
      CodeBuf.Add('; ' + ExtractEx(Buffer, ';', 2, []));
      //CodeBuf.Add('; ' + Extract(2, Buffer, ';', []));
      Buffer := ExtractEx(Buffer, ';', 1, []);
      //Buffer := Extract(1, Buffer, ';', []);
      if System.Pos('TYPE ', UpperCase(Buffer)) < 1 then Exit;
    end;

    if System.Pos('"', TextBuf[CurLine]) > 0 then Exit;
    CodeBuf.Add('; Handling TYPE variables');
    CodeBuf.Add(' .var struct_ptr_var .word');
    CodeBuf.Add('');
    isType := True;
    TypeMemCnt := 0;

    //Buffer := Trim(TextBuf[CurLine]);
    Str1 := ExtractEx(Buffer, '=', 1, []);
    VarType := ExtractEx(Str1, ' ', 2, []);
    Str2 := ExtractEx(Buffer, '=', 2, []);
    //Str1 := Extract(1, Buffer, '=', []);
    //VarType := Extract(2, Str1, ' ', []);
    //Str2 := Extract(2, Buffer, '=', []);
    Split(Str1, ' ', []);
    Str2 := ExtractEx(Str2, '[', 2, []);
    //Str2 := Extract(2, Str2, '[', []);
    PrgVar.SB := _SB_TYPE;
    //Inc(GVarCnt2);

    // TYPE members, delimited with ,
    if System.Pos(',', Str2) > 0 then begin
      Split(Str2, ',', []);
      for n := 0 to StrBuf.Count - 1 do begin
        if n <> 0 then
          xVar := StrBuf[n]
        else begin
          Str1 := ExtractEx(StrBuf[n], ' ', 1, []);
          //Str1 := Extract(1, StrBuf[n], ' ', []);
          xType := Str1;
          Str2 := ExtractEx(StrBuf[n], ' ', 2, []);
          //Str2 := Extract(2, StrBuf[n], ' ', []);
          xVar := Str2;
        end;
        sc_var3(UpperCase(xType), xVar, VarType);
      end;
    end
    // TYPE lone member
    else begin
      Str1 := ExtractEx(Str2, ' ', 1, []);
      Str2 := ExtractEx(Str2, ' ', 2, []);
      //Str1 := Extract(1, Str2, ' ', []);
      //Str2 := Extract(2, Str2, ' ', []);
      sc_var3(UpperCase(Str1), Str2, VarType);
    end;

    varList02.Add(
      VarType + '=' +
      SetType('type') + ';' +
      SetType('type') + ';' +
      SetType('type') + ';' +
      '' + ';' +
      '' + ';' +
      '0' + ';' +
      '' + ';' +
      '' + ';' +
      '' + ';');

    //GVar2[GVarCnt2].VarType  := SetType('type');
    //GVar2[GVarCnt2].ParentType := SetType('type');
    //GVar2[GVarCnt2].OrigType := SetType('type');
    //GVar2[GVarCnt2].VarName  := VarType;
    //GVar2[GVarCnt2].Location := '';
    //GVar2[GVarCnt2].Value    := '';
    //GVar2[GVarCnt2].Dim      := 0;
    //GVar2[GVarCnt2].ML_type := '';
    Exit;
  end;

  // Array and pointer variables handling
  Buffer := Strip(UpperCase(TextBuf[CurLine]), ' ');

  if (System.Pos('PRINT(', Buffer) > 0)
     or (System.Pos('PRINTE(', Buffer) > 0) then
  begin
    Exit;
  end;

  isPtr := False;
  for j := 0 to VarTypes2.Count - 1 do begin
    n := System.Pos(UpperCase(VarTypes2[j]) + ' ', UpperCase(TextBuf[CurLine]));
    if n > 0 then begin
      n4 := System.Pos(';', TextBuf[CurLine]);
      if n4 > 0 then begin
        CodeBuf.Add('; ' + ExtractEx(TextBuf[CurLine], ';', 2, []));
        TextBuf[CurLine] := ExtractEx(TextBuf[CurLine], ';', 1, []);
        //TextBuf[CurLine] := Extract(1, TextBuf[CurLine], ';', []);
        n := System.Pos(UpperCase(VarTypes2[j]) + ' ', UpperCase(TextBuf[CurLine]));
        if n < 1 then Continue;
      end;
      if System.Pos('CARD ARRAY', UpperCase(TextBuf[CurLine])) > 0 then begin
        isArray := True;
      end
      else if System.Pos(' POINTER ', UpperCase(TextBuf[CurLine])) > 0 then begin
        isPtr := True;
        isFirstSpace := True;
      end;
      break;
    end;
  end;

  if n < 1 then Exit;

  Buffer := Trim(TextBuf[CurLine]);
  VarType := ''; VarX := '';

  // F.e.: CARD ARRAY values=[1 2 3 4 5 6 7]
  if (System.Pos(' ARRAY ', UpperCase(TextBuf[CurLine])) > 0)
     and (System.Pos('=', Buffer) > 0) and (System.Pos('[', Buffer) > 0) then
  begin
    Buffer := ExtractEx(Buffer, '=', 1, []);
    //Buffer := Extract(1, Buffer, '=', []);
    PrgVar.SB := _SB_ARRAY_SET;
  end;

  if (System.Pos(' ARRAY ', UpperCase(TextBuf[CurLine])) > 0) then begin
    Split(UpperCase(TextBuf[CurLine]), ' ARRAY ', []);
    VarX := StrBuf[0];
    Split(StrBuf[1], '=', []);
  end;

  // F.e.: BYTE ARRAY str1="Text"
  if (System.Pos(' ARRAY ', UpperCase(TextBuf[CurLine])) > 0) and (System.Pos('=', Buffer) > 0)
     and (System.Pos('"', Buffer) > 0) then begin
//      if (System.Pos('ARRAY', UpperCase(Buffer)) > 0) and (System.Pos('=', Buffer) > 0)
//         and (System.Pos('"', Buffer) > 0) then
    arrayValue := ExtractText(Buffer, '"', '"');
    //Split(UpperCase(TextBuf[CurLine]), ' ARRAY ', []);
    //VarX := StrBuf[0];
    //Split(StrBuf[1], '=', []);

//     Inc(GVarCnt2);
//     if VarX = 'BYTE' then
//       GVar2[GVarCnt2].VarType  := 'T5'
//     else begin
//       GVar2[GVarCnt2].VarType  := 'T7';
//     end;
//     GVar2[GVarCnt2].ParentType := 'T5';
//     GVar2[GVarCnt2].OrigType := 'T5';
//     GVar2[GVarCnt2].VarName  := StrBuf[0];
//     GVar2[GVarCnt2].Location := 'T5';
//     GVar2[GVarCnt2].Value := VarType;
//     GVar2[GVarCnt2].ML_type := '';
//     GVar2[GVarCnt2].Dim := 0;  // Length(VarType);

    if VarX = 'BYTE' then
      effType  := 'T5'
    else begin
      effType  := 'T7';
    end;

    effVarName := StrBuf[0];
    effVarDim := '0';

    // BYTE ARRAY str1(4)="Text"
    if (System.Pos('(', Buffer) > 0) and (System.Pos(')', Buffer) > 0) then begin
      VarType := ExtractEx(StrBuf[0], '(', 1, []);
      //VarType := ExtractEx(StrBuf[1], '=', 2, []);
      //VarType := Extract(1, StrBuf[0], '(', []);
      //GVar2[GVarCnt2].VarName := VarType;
      //GVar2[GVarCnt2].Dim := StrToInt(ExtractText(Buffer, '(', ')'));
      effVarName := VarType;
      effVarDim := ExtractText(Buffer, '(', ')');
    end;

    //writeln('effVarName = ', effVarName, ' * effVarDim = ', effVarDim, ' * VarType = ', VarType);
    //writeln(ExtractEx(StrBuf[1], '=', 2, []));
    //VarType := ExtractEx(StrBuf[1], '=', 2, []);
    //VarType := Replace(VarType, '"', '''');

    varList02.Add(
      effVarName + '=' +
      effType + ';' +
      'T5' + ';' +
      'T5' + ';' +
      'T5' + ';' +
      arrayValue + ';' +
      effVarDim + ';' +
      '' + ';' +
      '0' + ';' +
      '' + ';');
  end
  // BYTE ARRAY A(4)=$3200
  // BYTE ARRAY A(4)=18000
  else if (System.Pos(' ARRAY ', UpperCase(TextBuf[CurLine])) > 0) and (System.Pos('=', Buffer) > 0)
     and ((System.Pos('$', Buffer) > 0) or (IsNumber(StrBuf[1][1]))) then
  begin
//     Inc(GVarCnt2);
//     if VarX = 'BYTE' then
//       GVar2[GVarCnt2].VarType  := 'T5'
//     else begin
//       GVar2[GVarCnt2].VarType  := 'T7';
//     end;
//     GVar2[GVarCnt2].ParentType := 'T5';
//     GVar2[GVarCnt2].OrigType := 'T5';
//     GVar2[GVarCnt2].VarName  := StrBuf[0];
//     GVar2[GVarCnt2].Location := 'T5';
//     GVar2[GVarCnt2].Value := StrBuf[1];  // Memory address value
//     GVar2[GVarCnt2].ML_type := 'MemAddr';
//     GVar2[GVarCnt2].Dim := 0;

    if VarX = 'BYTE' then
      effType  := 'T5'
    else begin
      effType  := 'T7';
    end;

    effVarName := StrBuf[0];
    effVarDim := '0';

    // Check brackets
    if (System.Pos('(', Buffer) > 0) and (System.Pos(')', Buffer) > 0) then begin
      VarType := ExtractEx(StrBuf[0], '(', 1, []);
      //VarType := Extract(1, StrBuf[0], '(', []);
      effVarName := VarType;
      effVarDim := ExtractText(Buffer, '(', ')');
    end;

    varList02.Add(
      effVarName + '=' +
      effType + ';' +
      'T5' + ';' +
      'T5' + ';' +
      'T5' + ';' +
      StrBuf[1] + ';' +
      effVarDim + ';' +
      'MemAddr' + ';' +
      '0' + ';' +
      '' + ';');
  end
  else begin
    for n := 1 to Length(Buffer) do begin
      CharPos := Buffer[n];
      VarType += CharPos;

      // ARRAY
      if not isPtr then begin
        if (CharPos = ',') or (n = Length(Buffer)) then begin
          if n <> Length(Buffer) then begin
            VarType := Trim(Copy(VarType, 1, Length(VarType) - 1));
          end;

          // Extract variable and its dimension
          if System.Pos('(', VarType) < 1 then
            n4 := 0
          else begin
            n4 := StrToInt(ExtractText(VarType, '(', ')'));
            VarType := ExtractEx(VarType, '(', 1, []);
            //VarType := Extract(1, VarType, '(', []);
            PrgVar.SB := _SB_ARRAY;
          end;

          effVarName := '';

          // Is it ARRAY set?
          if System.Pos('[', TextBuf[CurLine]) > 0 then begin
            PrgVar.SB := _SB_ARRAY_SET;
            //GVar2[GVarCnt2].Location := 'SET';
            effVarName := 'SET';
          end;

          // Set variable parameters
//           Inc(GVarCnt2);
//           GVar2[GVarCnt2].VarType  := SetType(VarX);
//           GVar2[GVarCnt2].ParentType := SetType(VarTypes2[j]);
//           GVar2[GVarCnt2].OrigType := SetType(VarTypes2[j]);
//           GVar2[GVarCnt2].VarName  := Trim(VarType);
//           GVar2[GVarCnt2].ML_type := VarX;
//           GVar2[GVarCnt2].Value := '';
//           GVar2[GVarCnt2].Dim := n4;

          varList02.Add(
            Trim(VarType) + '=' +
            SetType(VarX) + ';' +
            SetType(VarTypes2[j]) + ';' +
            SetType(VarTypes2[j]) + ';' +
            effVarName + ';' +
            '' + ';' +
            IntToStr(n4) + ';' +
            VarX + ';' +
            '0' + ';' +
            '' + ';');

          RecPtrVar.ArrayDim := n4;
          VarType := '';
        end
        else if UpperCase(VarType) = UpperCase(VarTypes2[j]) then begin
          VarX := LowerCase(VarType);
          VarType := '';
        end;
      end
      // POINTER
      else begin
        effType := '';
        effOrigType := '';
        //effParentType := '';

        if (CharPos = ' ') and isFirstSpace then begin
          isFirstSpace := False;
          //Inc(GVarCnt2);
          //GVar2[GVarCnt2].OrigType := SetType(Copy(VarType, 1, Length(VarType) - 1));
          effOrigType := SetType(Copy(VarType, 1, Length(VarType) - 1));
          VarType := '';
        end;
        if (CharPos = ' ') and not isFirstSpace then begin
//           GVar2[GVarCnt2].VarType := SetType(Copy(VarType, 1, Length(VarType) - 1));
//           GVar2[GVarCnt2].ParentType := SetType(Copy(VarType, 1, Length(VarType) - 1));
          effType := SetType(Copy(VarType, 1, Length(VarType) - 1));
          //effParentType := SetType(Copy(VarType, 1, Length(VarType) - 1));
          effOrigType := SetType(Copy(VarType, 1, Length(VarType) - 1));
          VarType := '';
        end;
        if (n = Length(Buffer)) then begin
          // BYTE, CHAR
          //if System.Pos(GVar2[GVarCnt2].OrigType, 'T1T2') > 0 then
          if System.Pos(effOrigType, 'T1T2') > 0 then
            VarX := 'byte'
          // INT, CARD
          else if System.Pos(effOrigType, 'T3T4') > 0 then
            VarX := 'word'
          else begin
            //VarX := GVar2[GVarCnt2].OrigType;
            VarX := effOrigType;
          end;
//           GVar2[GVarCnt2].VarName  := VarType;
//           GVar2[GVarCnt2].Location := '';
//           GVar2[GVarCnt2].Value    := IntToStr(PtrCnt);
//           GVar2[GVarCnt2].Dim      := 0;
//           GVar2[GVarCnt2].ML_type := VarType;
     
//           varList02.Add(
//             VarType + '=' +
//             effType + ';' +
//             effOrigType + ';' +
//             effParentType + ';' +
//             '' + ';' +
//             IntToStr(PtrCnt) + ';' +
//             '0' + ';' +
//             VarType + ';' +
//             '0' + ';' +
//             '' + ';');
          varList02.Add(
            VarType + '=' +           // VarName
            'T10' + ';' +             // VarType
            'T10' + ';' +             // OrigType
            'T10' + ';' +             // ParentType
            '' + ';' +                // Location
            IntToStr(PtrCnt) + ';' +  // Value
            '0' + ';' +               // Dim
            'T10' + ';' +             // ML_type
            '0' + ';' +
            '' + ';');

          Inc(PtrCnt, 2);
          Inc(GVarCnt);
          GVar[GVarCnt].VarType  := SetType(VarX);
          GVar[GVarCnt].ParentType := SetType('POINTER');
          GVar[GVarCnt].OrigType := SetType(VarType);
          GVar[GVarCnt].VarName  := VarType + '_ptr';
          GVar[GVarCnt].Location := '';
          GVar[GVarCnt].Value    := '';
          GVar[GVarCnt].Dim      := 0;
          GVar[GVarCnt].ML_type := VarX;
          //WatchVar('5', GVarCnt);
          VarType := '';
        end;
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! variable declarations
 Parameters : xType (string) -
              xVar (string)
              xVarType (string)
 -----------------------------------------------------------------------------}
procedure sc_Var3(xType, xVar, xVarType : String);
var
  VarPos, j : LongInt;
  MemAddr, VarType : String;
begin
  for j := 0 to VarTypes.Count - 1 do begin
    VarPos := System.Pos(UpperCase(VarTypes[j]) + ' ', UpperCase(xType + ' ' + xVar));
    if (VarPos > 0) and VarDeclCheck(UpperCase(xType + ' ' + xVar)) then begin
      VarType := xType;
      if UpperCase(VarType) = UpperCase(VarTypes[j]) then begin
        if (VarType = 'BYTE') or (VarType = 'CHAR') then
          VarType := 'byte'
        else if (VarType = 'INT') or (VarType = 'CARD') then
          VarType := 'word';
      end;
      MemAddr := '';
      if System.Pos(']', xVar) > 0 then begin
        xVar := Copy(xVar, 1, Length(xVar) - 1);
        isType := False;
      end;
      if VarType = 'byte' then
        Inc(TypeMemCnt, 1)
      else begin
        Inc(TypeMemCnt, 2);
      end;
      Inc(GVarCnt);
      GVar[GVarCnt].VarType    := SetType(VarTypes[j]);
      GVar[GVarCnt].ParentType := SetType(xVarType);
      GVar[GVarCnt].OrigType   := SetType(VarTypes[j]);
      GVar[GVarCnt].VarName    := xVar;
      //GVar[GVarCnt].Location   := IntToStr(GVarCnt2);
      GVar[GVarCnt].Location   := IntToStr(varList02.count - 1);
      GVar[GVarCnt].Value      := MemAddr;
      GVar[GVarCnt].Dim        := 0;
      GVar[GVarCnt].ML_type    := VarType;
      //WatchVar('6', GVarCnt);
      Break;
    end;
  end;
  // Check closing bracket of type declaration
  if (System.Pos(']', xType + ' ' + xVar) > 0) and isType then begin
    isType := False;
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! ARRAY set variable declarations
 -----------------------------------------------------------------------------}
procedure sc_Array;
var
  n : Integer;
  Buffer : String;
begin
  if (System.Pos('[', TextBuf[CurLine]) > 0) then begin  //and (PrgVar.SB = _SB_NULL) then
    if System.Pos(' ARRAY ', UpperCase(TextBuf[CurLine])) > 0 then begin
      PrgVar.SB := _SB_ARRAY_SET;
      ArraySet_start := True;
    end;
  end;
  if ArraySet_start then begin
    // Array elements in [] block
    if (System.Pos('[', TextBuf[CurLine]) > 0) and (System.Pos(']', TextBuf[CurLine]) > 0) then begin
      Buffer := ExtractText(TextBuf[CurLine], '[', ']');
      ArraySet_start := False;
      PrgVar.SB := _SB_NULL;
    end
    // Start of array
    else if System.Pos('[', TextBuf[CurLine]) > 0 then begin
      Split(TextBuf[CurLine], '[', []);
      Buffer := StrBuf[1];
    end
    // End of array
    else begin
      Buffer := TextBuf[CurLine];
      if System.Pos(']', Buffer) > 0 then begin
        Buffer := Replace(Buffer, ']', ' ');
        ArraySet_start := False;
        PrgVar.SB := _SB_NULL;
      end;
    end;

    Buffer := Trim(Buffer);
    Split(Buffer, ' ', []);
    Buffer := '';
    // Loop through elements of the array
    for n := 0 to StrBuf.Count - 1 do begin
      // Ignore empty elements
      if Trim(StrBuf[n]) = '' then Continue;
      // Get element from the array
      if n = 0 then
        Buffer := StrBuf[n]
      else
        Buffer += ', ' + StrBuf[n];
    end;
    Buffer += ', ';

    // Store array elements
    if StrBuf[0] <> '' then begin
      //GVar2[GVarCnt2].Value := GVar2[GVarCnt2].Value + Buffer;
      //var02.Value := Extract(5, varList02.ValueFromIndex[varList02.Count - 1], ';', []);
      var02.Value := Buffer;
      tempValues.Add(
        varList02.Names[varList02.Count - 1] + '=' + var02.Value);
      //tempValue := var02.Value;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! variable expressions
 -----------------------------------------------------------------------------}
procedure sc_VarExpr;
var
  j, n, r, p : Integer;
  arrOper : TStringList;
  Str1, Str2, Str3, Str4, VarName, TempBuf, TempBuf2 : String;
begin
  if Pos('=', TextBuf[CurLine]) < 1 then Exit;
  for n := 1 to GVarCnt do begin
    Str1 := Strip(TextBuf[CurLine], ' ');
    if System.Pos('==', Str1) > 0 then begin
      Str2 := ExtractEx(Str1, '=', 2, []);
      //Str2 := Extract(2, Str1, '=', []);
      Str1 := ExtractEx(Str1, '==', 1, []);
    end
    else if (System.Pos('=-', Str1) > 0) then begin
      str2 := 'M=-' + ExtractEx(Str1, '=-', 2, []);
      str1 := ExtractEx(Str1, '=-', 1, []);
    end
    else begin
      Split(Str1, '=', []);
      Str1 := StrBuf[0];
      Str2 := StrBuf[1];
      // Parse ' character to determine ASCII character
      if str2[1] = '''' then begin
        str2 := ExtractEx(str2, '''', 2, []);
        str2 := IntToStr(ord(str2[1]));
      end;
    end;

    if (UpperCase(GVar[n].VarName) = UpperCase(Str1)) and FuncCheck('')
       and ExprCheck(UpperCase(TextBuf[CurLine])) then
    begin
      TempBuf := ''; TempBuf2 := '';
      if Checkvar02(str2, '', '(') then begin
        Str2 := Replace(Str2, '(', '[');
        Str2 := Replace(Str2, ')', ']');
        var02.Value := Str2;
        TempBuf := var02.VarType;   // Effectus variable type
        TempBuf2 := var02.VarName;  // Array name
      end;
//       for p := 1 to GVarCnt2 do begin
//         // Handle ARRAY variables
//         if System.Pos(UpperCase(GVar2[p].VarName) + '(', UpperCase(Str2)) > 0 then begin
//           Str2 := Replace(Str2, '(', '[');
//           Str2 := Replace(Str2, ')', ']');
//           GVar2[p].Value := Str2;
//           TempBuf := GVar2[p].VarType;   // Effectus variable type
//           TempBuf2 := GVar2[p].VarName;  // Array name
//           break;
//         end;
//       end;
      if (System.Pos('M=-', Str2) > 0) then begin
        isMath := True;
        CodeBuf.Add(' sub16 #65535 ' + GVar[n].VarName + _EFF);
        CodeBuf.Add(' mwa $A0 ' + GVar[n].VarName + _EFF);
        CodeBuf.Add(' inw ' + GVar[n].VarName + _EFF);
      end
      else begin
        if (System.Pos('=+', UpperCase(Str2)) > 0) or (System.Pos('=-', UpperCase(Str2)) > 0) or (System.Pos('=*', UpperCase(Str2)) > 0)
           or(System.Pos('=/', UpperCase(Str2)) > 0) or (System.Pos('=!', UpperCase(Str2)) > 0) or (System.Pos('=XOR', UpperCase(Str2)) > 0)
           or (System.Pos('=LSH', UpperCase(Str2)) > 0) or (System.Pos('=RSH', UpperCase(Str2)) > 0)
           or (System.Pos('=&', UpperCase(Str2)) > 0) or (System.Pos('=%', UpperCase(Str2)) > 0) then
        begin
          Delete(Str2, 1, 1);
          Str2 := Str1 + Str2;
          MathExpr(GVar[n].VarType, Str1, Str2, 1, n);
        end
        else begin
          if System.Pos('(', TextBuf[CurLine]) > 0 then begin
            Str4 := ExtractEx(Str2, '[', 1, []);
            Str3 := ExtractEx(Str2, '[', 2, []);
            //Str4 := Extract(1, Str2, '[', []);
            //Str3 := Extract(2, Str2, '[', []);
            Str3 := Copy(Str3, 1, Length(Str3) - 1);
            if IsNumber(Str3[1]) then begin
              MathExpr(GVar[n].VarType, Str1, Str2, 1, n);
            end
            else begin
              if sFor in flags then begin
                if System.Pos(TempBuf, 'T7T8') > 0 then begin  // INT ARRAY or CARD ARRAY
                  CodeBuf.Add(' ldy array_index_' + TempBuf2 + _EFF);
                  CodeBuf.Add(' mwa ' + Str4 + _EFF + ',y ' + GVar[n].VarName + _EFF);
                  CodeBuf.Add(' inc array_index_' + TempBuf2 + _EFF);
                end;
              end;
            end;
          end
          // Expression manipulation process
          else begin
            // Operator manipulation
            arrOper := TStringList.Create;
            try
              for r := 0 to Length(Str2) - 1 do begin
                if Str2[r] = '*' then
                  arrOper.Add('1')
                else if Str2[r] = '/' then
                  arrOper.Add('2')
                else if Str2[r] = '+' then
                  arrOper.Add('3')
                else if Str2[r] = '-' then
                  arrOper.Add('4');
              end;

              // Generate expression output
              if arrOper.Count = 0 then begin
                MathExpr(GVar[n].VarType, Str1, Str2, 1, n);
                Exit;
              end;
              SplitEx2(Str2, '*', '/', '+', '-');
              for r := 0 to arrOper.Count - 1 do begin
                if r = 0 then begin
                  if arrOper[r] = '3' then
                    Str2 := strbuf2[0] + '+' + strbuf2[1]
                  else if arrOper[r] = '4' then
                    Str2 := strbuf2[0] + '-' + strbuf2[1]
                  else if arrOper[r] = '1' then
                    Str2 := strbuf2[0] + '*' + strbuf2[1]
                  else if arrOper[r] = '2' then
                    Str2 := strbuf2[0] + '/' + strbuf2[1]
                end
                else begin
                  if arrOper[r] = '3' then
                    Str2 := Str1 + '+' + strbuf2[r + 1]
                  else if arrOper[r] = '4' then
                    Str2 := Str1 + '-' + strbuf2[r + 1]
                  else if arrOper[r] = '1' then
                    Str2 := Str1 + '*' + strbuf2[r + 1]
                  else if arrOper[r] = '2' then
                    Str2 := Str1 + '/' + strbuf2[r + 1]
                end;

                // Check precedence
                MathExpr(GVar[n].VarType, Str1, Str2, 1, n);
              end;
            finally
              if Assigned(arrOper) then FreeAndNil(arrOper);
            end;
          end;
        end;
      end;
    end
    // TYPE variable expression
    else if (System.Pos('.' + UpperCase(GVar[n].VarName), UpperCase(Str1)) > 0) and FuncCheck('')
            and ExprCheck(UpperCase(TextBuf[CurLine])) then begin
      if System.Pos('"', TextBuf[CurLine]) > 0 then Exit;
      for j := 1 to GVarCnt do begin
        if GVar[n].ParentType = GVar[j].OrigType then begin
          CodeBuf.Add(mvwa(GVar[n].VarType) + AsmStrNum(Str2) + ' ' +
                      GVar[j].VarName + _EFF + '.' + GVar[n].VarName + _EFF);
          Exit;
        end;
      end;
    end
    else if (System.Pos('.' + UpperCase(GVar[n].VarName), UpperCase(Str2)) > 0) and FuncCheck('')
            and ExprCheck(UpperCase(TextBuf[CurLine])) then begin
      if System.Pos('"', TextBuf[CurLine]) > 0 then Exit;
      for j := 1 to GVarCnt do begin
        if GVar[n].ParentType = GVar[j].OrigType then begin
          CodeBuf.Add(mvwa(GVar[n].VarType) + GVar[j].VarName + _EFF + '.' +
                      GVar[n].VarName + _EFF + ' ' + AsmStrNum(Str1));
          Exit;
        end;
      end;
    end;
  end;

  Str1 := TextBuf[CurLine];
  Split(TextBuf[CurLine], '=', []);
  Str1 := StrBuf[0]; Str2 := StrBuf[1];
  VarName := Str1;
  //for n := 1 to GVarCnt2 do begin
    //if System.Pos(UpperCase(GVar2[n].VarName) + '=@', UpperCase(TextBuf[CurLine])) > 0 then begin
 if Checkvar02(UpperCase(TextBuf[CurLine]), '', '=@') then begin 
    if FuncCheck('') and ExprCheck(UpperCase(TextBuf[CurLine])) then begin
      for p := 1 to GVarCnt do begin
        if System.Pos('@' + UpperCase(GVar[p].VarName), Str2) > 0 then begin
          CodeBuf.Add(' lda #<' + GVar[p].VarName + _EFF);
          CodeBuf.Add(' sta $c0');
          CodeBuf.Add(' lda #>' + GVar[p].VarName + _EFF);
          CodeBuf.Add(' sta $c1');
          CodeBuf.Add('');
          //CodeBuf.Add('; var02.VarType = ' + var02.VarType);
          // POINTER
          //if System.Pos(GVar2[n].VarType, 'T10') > 0 then begin
          if System.Pos(var02.VarType, 'T10') > 0 then begin
            for r := 1 to GVarCnt do begin
              if (System.Pos(GVar[r].ParentType, 'T10') > 0)
                 //and (UpperCase(GVar[r].OrigType) = UpperCase(GVar2[n].VarName)) then begin
                 and (UpperCase(GVar[r].OrigType) = UpperCase(var02.VarName)) then begin
                CodeBuf.Add(' mwa $c0 ' + GVar[r].VarName + _EFF);
                CodeBuf.Add('');
                Break;
              end;
            end;
          end;
          Break;
        end;
      end;
    end;
    //Exit;
  end
  // POINTER
  //else if System.Pos(UpperCase(GVar2[n].VarName) + '^=', UpperCase(TextBuf[CurLine])) > 0 then begin
  else if Checkvar02(UpperCase(TextBuf[CurLine]), '', '^=') then begin
    if FuncCheck('') and ExprCheck(UpperCase(TextBuf[CurLine])) then begin
      //if System.Pos(GVar2[n].VarType, 'T10') > 0 then begin
      if System.Pos(var02.VarType, 'T10') > 0 then begin
        for r := 1 to GVarCnt do begin
          if (System.Pos(GVar[r].ParentType, 'T10') > 0)
             //and (UpperCase(GVar[r].OrigType) = UpperCase(GVar2[n].VarName)) then
             and (UpperCase(GVar[r].OrigType) = UpperCase(var02.VarName)) then
          begin
            CodeBuf.Add(' mwa #' + Str2 + ' ' + GVar[r].VarName + _EFF);
            CodeBuf.Add(' lda ' + GVar[r].VarName + _EFF);
            CodeBuf.Add(' ldy #0');
            CodeBuf.Add(' sta ($c0),y');
            Break;
          end;
        end;
      end;
    end;
  end
  // Handling TYPE, ARRAY and POINTER variables
  //else if System.Pos(UpperCase(GVar2[n].VarName), UpperCase(Str1)) > 0 then begin
  else if Checkvar02(str1, '', '') then begin
    var0202.VarName := var02.VarName;
    var0202.VarType := var02.VarType;
    var0202.OrigType := var02.OrigType;
    var0202.ParentType := var02.ParentType;
    var0202.Location := var02.Location;
    var0202.Value := var02.Value;
    var0202.Dim := var02.Dim;
    var0202.ML_type := var02.ML_type;
    //var02.InitValue := StrToInt(ExtractDelimited(8, varList02.ValueFromIndex[j], [';']));

//     writeln('Checkvar02 str1 = ', str1);
//     writeln('var0202.VarName = ', var02.VarName,
//             #13#10'var0202.VarType = ', var02.VarType,
//             #13#10'var0202.OrigType = ', var02.OrigType,
//             #13#10'var0202.Value = ', var02.Value);
//    readln;

    if var0202.OrigType = 'T9' then begin
      typeRecName := var02.VarName;
    end;

    // Handling TYPE record ARRAY POINTER variables
    // ENTRY=DATA+(1*SIZE)
    if (System.Pos('(', Str1) < 1) and (System.Pos('.', Str1) < 1)
       //and (System.Pos(GVar2[n].VarType, 'T10') > 0) then  // POINTER
       and (System.Pos(var02.VarType, 'T10') > 0) then  // POINTER
    begin
      //for j := 1 to GVarCnt2 do begin
      for j := 0 to varList02.Count - 1 do begin
//           if (System.Pos(UpperCase(GVar2[j].VarName), UpperCase(Str2)) > 0)
//              and (System.Pos(GVar2[j].OrigType, 'T5T6T7T8') > 0) // ARRAY
//              and (System.Pos(GVar2[n].VarType, 'T10') > 0) then  // POINTER
        if (System.Pos(UpperCase(varList02.Names[j]), UpperCase(Str2)) > 0)
           //and (System.Pos(var02.OrigType, 'T5T6T7T8') > 0) // ARRAY
           and (System.Pos(var0202.VarType, 'T10') > 0) then  // POINTER
        begin
          Str3 := Str2;
          Str4 := ExtractEx(Str3, '+', 1, []);
          Str3 := ExtractEx(Str3, '+', 2, []);
          //Str4 := Extract(1, Str3, '+', []);
          //Str3 := Extract(2, Str3, '+', []);
           if Str3 <> '' then begin
//               //RecPtrVar.Name := GVar2[n].VarName;
             RecPtrVar.Name := var0202.VarName;
             RecPtrVar.Dim := StrToInt(Str3) div TypeMemCnt;
             RecPtrVar.Flag := True;
             (*
             for n1 := 1 to GVarCnt2 do begin
               if (UpperCase(GVar2[n1].VarName) = UpperCase(Str4))
                  and (PtrData <> GVar2[n].VarName + '_sv') then
               begin
                 r := (GVar2[n1].Dim div TypeMemCnt) - 1;
                 TypeMemDim := r;
                 PtrData := GVar2[n].VarName + '_sv';
                 SData[Cnt] := PtrData + _EFF + ' dta ' + GVar2[n].OrigType + _EFF + ' [' + IntToStr(r) + ']';
                 Inc(Cnt);
                 Break;
               end;
             end;
             *)
             //for n1 := 0 to varList02.Count - 1 do begin
             //writeln('RecPtrVar.Name = ', RecPtrVar.Name);
               if Checkvar02(Str4, '', '')
                  and (PtrData <> var0202.VarName + '_sv') then
               begin
                 r := (var02.Dim div TypeMemCnt) - 1;
                 TypeMemDim := r;
                 PtrData := var0202.VarName + '_sv';
                 //SData[Cnt] := PtrData + _EFF + ' dta ' + var0202.OrigType + _EFF + ' [' + IntToStr(r) + ']';
                 SData[Cnt] := PtrData + _EFF + ' dta ' + typeRecName + _EFF + ' [' + IntToStr(r) + ']';
                 Inc(Cnt);
               end;
           end;
        end
      end
    end
    // Handling ARRAY variables, not POINTERS
    //else if (System.Pos('(', Str1) > 0) and (System.Pos(GVar2[n].VarType, 'T10') < 1) then begin
    else if (System.Pos('(', Str1) > 0) and (System.Pos(var02.VarType, 'T10') < 1) then begin  // POINTER
      VarName := Replace(VarName, '(', '[');
      VarName := Replace(VarName, ')', ']');
      //GVar2[n].Value := VarName;
      var02.Value := VarName;
      Str3 := ExtractEx(VarName, '[', 2, []);
      Str4 := ExtractEx(VarName, '[', 1, []);  // array element name
      //Str3 := Extract(2, VarName, '[', []);
      //Str4 := Extract(1, VarName, '[', []);
      Str4 += _EFF + '[' + Str3;
      Str3 := Copy(Str3, 1, Length(Str3) - 1);  // array element index
      if IsNumber(Str3[1]) then begin
        if System.Pos('"', Str2) < 1 then begin
          //MathExpr(GVar2[n].VarType, Str4, Str2, 2, n)
          MathExpr(var02.VarType, Str4, Str2, 2, n)
        end
        else begin
          PrgVar.Pointer := CurLine;
          Str2 := ExtractText(Str2, '"', '"');
          if System.Pos(' ARRAY ', Str4) < 1 then
            //MathExpr(GVar2[n].VarType, Str4, Str2, 3, n);
            MathExpr(var02.VarType, Str4, Str2, 3, n);
        end;
      end
      else begin
        //MathExpr(GVar2[n].VarType, Str4, Str2, 2, 0);
        MathExpr(var02.VarType, Str4, Str2, 2, 0);
      end;
    end
    // Handling TYPE record ARRAY POINTER variables
//      else if (System.Pos(UpperCase(GVar2[n].VarName) + '.', UpperCase(Str1)) > 0)
//               and (System.Pos(GVar2[n].VarType, 'T10') > 0) then
    else if Checkvar02(UpperCase(str1), '', '.')
            and (System.Pos(var02.VarType, 'T10') > 0) then
    begin
      Split(Str1, '.', []);
      Str3 := AsmStrNum(Str2);
      for r := 1 to GVarCnt do begin
        if UpperCase(GVar[r].VarName) = UpperCase(StrBuf[1]) then begin
          if System.Pos('"', TextBuf[CurLine]) > 0 then Break;
          CodeBuf.Add(mvwa(GVar[r].VarType) + Str3 + ' ' + PtrData + _EFF +
                      '[' + IntToStr(RecPtrVar.Dim) + '].' + StrBuf[1] + _EFF);
          Break;
        end;
      end;
    end
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! INCLUDE directive
 -----------------------------------------------------------------------------}
procedure sc_Include;
var
  Temp : String;
begin
  if System.Pos('INCLUDE "', UpperCase(TextBuf[CurLine])) > 0 then begin
    isInclude := True;
    //isIncludeX := True;
    Temp := ExtractText(TextBuf[CurLine], '"', '"');
    if System.Pos(PathDelim, Temp) < 1 then begin
    //if (System.Pos('\', Temp) < 1) and (System.Pos('/', Temp) < 1) then
      if ExtractFileDir(meditEff_src_filename) <> '' then
        Temp := ExtractFileDir(meditEff_src_filename) + PathDelim + Temp;
    end;
    Inc(Icl);
    ASM_icl[icl] := Temp;
    Temp := StringReplace(ExtractFilename(Temp), '.EFF', '.asm', [rfIgnoreCase]);
    //WriteLn(fASM, ' icl ' + AnsiQuotedStr(Temp, ''''));
    code.Add(' icl ' + AnsiQuotedStr(Temp, ''''));
  end;
end;

{------------------------------------------------------------------------------
 Description: Mads words (labels) list
 -----------------------------------------------------------------------------}
procedure sc_Data;
var
  i : Byte = 1;
begin
  while SData[i] <> '' do begin
    //WriteLn(fASM, SData[i]);
    code.Add(SData[i]);
    Inc(i);
  end;
end;

{------------------------------------------------------------------------------
 Description: Mads words (labels) list
 -----------------------------------------------------------------------------}
procedure sc_ML_data;
var
  i : Byte = 1;
begin
  while ProcML_data[i] <> '' do begin
    //WriteLn(fASM, ProcML_data[i]);
    //WriteLn(fASM, ProcML[i].Code);
    code.Add(ProcML_data[i]);
    code.Add(ProcML[i].Code);
    Inc(i);
  end;
end;

{------------------------------------------------------------------------------
 -----------------------------------------------------------------------------}
function CheckProcML(Proc : String) : Boolean;
var
  bFound: Boolean = False;
  k : Integer;
begin
  for k := 1 to ProcML_cnt do begin
    if UpperCase(ProcML[k].Name) = UpperCase(RightStr(Proc, Length(Proc) - 4)) then begin
      bFound := True;
      Break;
    end;
  end;
  
  result := bFound;
end;

{------------------------------------------------------------------------------
 -----------------------------------------------------------------------------}
function GetMLAddress(Proc : String) : String;
var
  MLAddr: String = '';
  k: Integer;
begin
  for k := 1 to ProcML_cnt do begin
    if UpperCase(ProcML[k].Name) = UpperCase(RightStr(Proc, Length(Proc)-4)) then begin
      MLAddr := ProcML[k].Address;
      Break;
    end;
  end;
  result := MLAddr;
end;

{------------------------------------------------------------------------------
 Description: Action! procedures (PROC) and functions (FUNC)
 -----------------------------------------------------------------------------}
procedure sc_ProcTrack;
var
  n, n1, j, ParamInc, procPos, signPos : Integer;
  Buffer, param, Proc : String;
  Params : Array[1..21] of String;
begin
  if (System.Pos('PROC ', UpperCase(TextBuf[CurLine])) > 0)
     or (System.Pos('FUNC ', UpperCase(TextBuf[CurLine])) > 0) then
  begin
    Exit;
  end;

  for n := 0 to ProcCount - 1 do begin
    Proc := RightStr(ProcBuf[n], Length(ProcBuf[n]) - 4);
    procPos := System.Pos(UpperCase(Proc) + '(', UpperCase(TextBuf[CurLine]));
    signPos := System.Pos('"', TextBuf[CurLine]);
    if (signPos > 0) and (signPos < procpos) then
      Continue
    else if (procPos > 0)  then begin  //and (signPos = 0)) or ((signPos > 0) and ((signPos > procPos))) then begin
      Buffer := ExtractText(TextBuf[CurLine], '(', ')');
      Split(Buffer, ',', []);
      param := buffer;
      ParamInc := StrBuf.Count;
      if Buffer = '' then ParamInc := 0;
      buffer := '';
      if ParamInc > 0 then begin
        ParamInc := 0;
        for j := 1 to 21 do Params[j] := '';
        for j := 0 to StrBuf.Count - 1 do begin
          Inc(ParamInc);
          Params[ParamInc] := AsmStrNum(StrBuf[j]);
        end;

        // Check the parameters and fill appropriate global variables depending on the parameter type
        for j := 1 to ParamInc do begin
          for n1 := 1 to GVarCnt do begin
            if UpperCase(GVar[n1].VarName + _EFF) = UpperCase(Params[j]) then begin
              if System.Pos(GVar[n1].VarType, 'T1T2') > 0 then begin
                if CheckProcML(ProcBuf[n]) then begin
                  if j = 1 then
                    CodeBuf.Add(' lda ' + Params[j])
                  else
                    CodeBuf.Add(' ldx ' + Params[j]);
                end;
                if j = 1 then
                  Buffer := Params[j]
                else
                  Buffer += ', ' + Params[j];
              end
              else begin
                if CheckProcML(ProcBuf[n]) then begin
                  if System.Pos('#', Params[j]) > 0 then begin
                    if j = 1 then
                      CodeBuf.Add(' lda ' + Params[j])
                    else
                      CodeBuf.Add(' ldx ' + Params[j]);
                  end;
                end;
                if j = 1 then
                  Buffer := Params[j]
                else
                  Buffer += ', ' + Params[j];
              end;
            end;
          end;

          if Pos('#', Params[j]) > 0 then begin
            if StrToInt(ExtractEx(Params[j], '#', 2, [])) < 256 then begin
              if CheckProcML(ProcBuf[n]) then begin
                if j = 1 then
                  CodeBuf.Add(' lda ' + Params[j])
                else
                  CodeBuf.Add(' ldx ' + Params[j]);
              end
              else begin
                if j = 1 then
                  Buffer := Params[j]
                else
                  Buffer += ', ' + Params[j];
              end;
            end
            else begin
              if j = 1 then
                Buffer := Params[j]
              else
                Buffer += ', ' + Params[j];
            end;
          end;
        end;

        // End block: Check the parameters and fill variables
        if CheckProcML(ProcBuf[n]) then
          CodeBuf.Add(' jsr ' + GetMLAddress(ProcBuf[n]))
        else begin
          CodeBuf.Add(' ' + Proc  + _REFF + ' ' + Buffer);
        end;
      end
      else begin
        if CheckProcML(ProcBuf[n]) then begin
          if (param <> '') then begin
            if IsNumber(param[1]) then
              CodeBuf.Add(' lda #' + param);
          end;
          CodeBuf.Add(' jsr ' + GetMLAddress(ProcBuf[n]));
        end
        else begin
          CodeBuf.Add(' ' + Proc + _REFF);
        end;
      end;
      if System.Pos('=', TextBuf[CurLine]) > 0 then begin
        n1 := System.Pos('=', TextBuf[CurLine]) - 1;
        Buffer := Trim(Copy(TextBuf[CurLine], 1, n1));
        for n1 := 1 to GVarCnt do begin
          // BYTE and CHAR variables
          if (System.Pos(GVar[n1].VarType, 'T1T2') > 0)
             and (UpperCase(GVar[n1].VarName) = UpperCase(Buffer)) then
          begin
            CodeBuf.Add(' mva $A0 ' + Buffer + _EFF);
            Break;
          end
          else if (System.Pos(GVar[n1].VarType, 'T3T4') > 0)
             and (UpperCase(GVar[n1].VarName) = UpperCase(Buffer)) then
          begin
            CodeBuf.Add(' mwa $A0 ' + Buffer + _EFF);
            Break;
          end;
        end;
      end;
      Break;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! ending loop statement OD
 -----------------------------------------------------------------------------}
procedure sc_od;
var
  n1, n2 : Byte;
  Buffer : String;
begin
  if (System.Pos('OD', UpperCase(TextBuf[CurLine])) > 0) or (sOd in Flags) then begin
    // Check for infinite loop
    // Warning! Infinite loop is currently not allowed inside another loop statement. To be fixed...
    //if not (sFor in flags) and not (sWhile in flags) and not (sUntil in flags)
    //   and (System.Pos('"', UpperCase(TextBuf[CurLine])) < 1) then begin
    if (System.Pos('DO OD', UpperCase(TextBuf[CurLine])) > 0)
       and (System.Pos('"', UpperCase(TextBuf[CurLine])) < 1) then
    begin
      CodeBuf.Add('loop' + inttostr(CurLine) + ' jmp loop' + inttostr(CurLine));
      Exit;
    end;
    // Other processing
    Buffer := Trim(UpperCase(TextBuf[CurLine]));
    if (Copy(Buffer, 1, 2) = 'OD') or (sOd in Flags) then begin
      if sWhile in flags then begin
//         for n2 := 1 to GVarCnt2 do begin
//           // ARRAY
//           if System.Pos(GVar2[n2].VarType, 'T7T8') > 0 then
//              CodeBuf.Add(' inc array_index_' + GVar2[n2].VarName + _EFF);
//         end;
        if CheckExtraVarType('T7T8') then begin
          CodeBuf.Add(' inc array_index_' + var02.VarName + _EFF);
        end;
        CodeBuf.Add(' #end');
        if sExitFlag in flags2 then begin
          CodeBuf.Add('jump_from_while_' + IntToStr(WhileIndex));
          flags2 -= [sExitFlag];
        end;
        flags -= [sWhile];
      end
      // FOR loop
      else if sFor in flags then begin
        for n1 := 1 to GVarCnt do begin
          if UpperCase(ForVar[ForCnt].VarName) = UpperCase(GVar[n1].VarName) then begin
            if System.Pos(GVar[n1].VarType, 'T1T2') > 0 then begin  // BYTE, CHAR
              CodeBuf.Add(' ldx ' + ForVar[ForCnt].VarName + _EFF);
              CodeBuf.Add(' cpx ' + AsmStrNum(ForVar[ForCnt].EndValue));
              for n2 := 1 to StrToInt(ForVar[ForCnt].Step) do
                CodeBuf.Add(' inc ' + ForVar[ForCnt].VarName + _EFF);
            end
            else begin
              CodeBuf.Add(' lda ' + ForVar[ForCnt].VarName + _EFF);
              CodeBuf.Add(' cmp $A2');
              CodeBuf.Add(' lda ' + ForVar[ForCnt].VarName + _EFF + '+1');
              CodeBuf.Add(' sbc $A3');
              for n2 := 1 to StrToInt(ForVar[ForCnt].Step) do
                CodeBuf.Add(' inw ' + ForVar[ForCnt].VarName + _EFF);
            end;
            if isArray then begin
//               for n2 := 1 to GVarCnt2 do begin
//                 if System.Pos(GVar2[n2].VarType, 'T7T8') > 0 then  // ARRAY
//                   CodeBuf.Add(' inc array_index_' + GVar2[n2].VarName + _EFF);
//               end;
              if CheckExtraVarType('T7T8') then begin
                CodeBuf.Add(' inc array_index_' + var02.VarName + _EFF);
              end;
            end;
            Break;
          end;
        end;
        CodeBuf.Add(' jcc ' + ForVar[ForCnt].ForLabel);

        // Jump from FOR loop if EXIT command is executed
        if sExitFlag in flags2 then begin
          CodeBuf.Add('jump_from_' + ForVar[ForCnt].ForLabel);
          flags2 -= [sExitFlag];
        end;

        ForVar[ForCnt].ForEnd := True;
        Dec(ForCnt);
        n2 := 1;
        for n1 := 1 to 10 do begin
          if not ForVar[n1].ForEnd then begin
            n2 := 0;
            break;
          end;
        end;
        if n2 = 1 then begin
          flags -= [sFor];
        end;
      end
      // UNTIL loop
      else if sUntil in flags then begin
         CodeBuf.Add('loop_jump' + IntToStr(LoopIndex));
         flags -= [sUntil];
      end
      else begin
        CodeBuf.Add(' ldx #0');
        CodeBuf.Add(' cpx loop_var');
        CodeBuf.Add(' jcc loop' + IntToStr(LoopIndex));
        if sExitFlag in flags2 then begin
          CodeBuf.Add('loop_jump' + IntToStr(LoopIndex));
          flags2 -= [sExitFlag];
        end;
      end;
    end;
    Flags -= [sOd];
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! conditional statements
 Parameters : Stmt (string) - Selected loop/condition statement
              (WHILE, IF, ELSEIF)
 -----------------------------------------------------------------------------}
procedure Cond(Stmt : String);
var
  tmp : String = '';
  isArr : Boolean;
  n, n1, n2, n3, c1, c2 : Integer;
  str1, str2, expr, Number, Buffer, Buffer2, rtn, oper : String;
  arrOper : Array[0..9] of String[4];
begin
  Stmt := UpperCase(Stmt);

  for n := 0 to 9 do arrOper[n] := '';

  Buffer := Trim(UpperCase(TextBuf[CurLine]));
  
  if LeftStr(Buffer, Length(Stmt) + 1) = Stmt + ' ' then begin
    // Check for DO in the same line as branch command
    Buffer2 := UpperCase(TextBuf[CurLine]);
    if System.Pos(' DO', Buffer2) > 0  then begin
      Buffer2 := StringReplace(Buffer2,' DO', '', [rfReplaceAll]);
      TextBuf[CurLine] := Buffer2;
    end;

    if System.Pos(' OD', Buffer2) > 0  then begin
      Buffer2 := StringReplace(Buffer2,' OD', '', [rfReplaceAll]);
      TextBuf[CurLine] := Buffer2;
      Flags += [sOd];
    end;

    if Stmt = 'WHILE' then begin
      flags += [sWhile];
      CurrentBranch := 1;
    end;
    expr := Trim(LowerCase(TextBuf[CurLine]));
    expr := ExtractEx(expr, Stmt, 2, []);
    if System.Pos('IF', UpperCase(TextBuf[CurLine])) > 0 then begin
      expr := ExtractEx(expr, 'then', 1, []);
      if System.Pos(' FI', UpperCase(TextBuf[CurLine])) > 0 then
        Flags += [sFi];
    end;

    oper := '=';
    if System.Pos('=', expr) > 0 then begin
      Buffer2 := ExtractWord(1, expr, ['=']);
      Buffer := ExtractWord(2, expr, ['=']);
    end
    else if System.Pos('<', expr) > 0 then begin
      oper := '<';
      Buffer2 := ExtractWord(1, expr, ['<']);
      Buffer := ExtractWord(2, expr, ['<']);
    end
    else if System.Pos('>', expr) > 0 then begin
      oper := '>';
      Buffer2 := ExtractWord(1, expr, ['>']);
      Buffer := ExtractWord(2, expr, ['>']);
    end
    else if System.Pos('<>', expr) > 0 then begin
      oper := '#';
      Buffer2 := ExtractEx(expr, '<>', 1, []);
      Buffer := ExtractEx(expr, '<>', 2, []);
    end
    else if System.Pos('#', expr) > 0 then begin
      oper := '#';
      Buffer2 := ExtractWord(1, expr, ['#']);
      Buffer := ExtractWord(2, expr, ['#']);
    end;

    rtn := ExtractWord(1, Buffer2, ['(']);

    if (ProcBuf.IndexOf('FUNC' + rtn) >= 0) or (FuncList.IndexOf(rtn) >= 0) then begin
      //if (rtn = 'peek') or (rtn = 'peekc') then
     //   tmp := sc_Func1Ex('var19750412=' + Buffer2, rtn, '0')
     // else begin
        tmp := sc_Func('var19750412=' + Buffer2, rtn, '1');
     // end;
      expr := 'var19750412' + oper + Buffer;
      CodeBuf.Add(tmp);
    end;

    // Arrays
    isArr := False;
//     for n1 := 1 to GVarCnt2 do begin
//       if LowerCase(GVar2[n1].VarName) = LowerCase(rtn) then begin
//         isArr := True;
//         Buffer2 := expr;
//         Break;
//       end;
//     end;
    if varList02.IndexOfName(rtn) > -1 then begin
      isArr := True;
      Buffer2 := expr;
    end;

    // Parse IF and WHILE conditional OR and AND expressions for scalar types
    expr := StringReplace(expr,' and ','&', [rfReplaceAll]);
    expr := StringReplace(expr,' or ','|', [rfReplaceAll]);
    expr := StringReplace(expr,'#','<>', [rfReplaceAll]);
    expr := Strip(expr, ' ');
    expr := Strip(expr, '(');
    expr := Strip(expr, ')');
    c1 := System.Pos('&', expr);
    c2 := System.Pos('|', expr);
    StrBuf.Clear;
    if c1 + c2 = 0 then begin
      StrBuf.Add('dummy');  // Dummy value
    end
    else begin
      // If AND before OR
      if (c1 < c2) and (c1 > 0) then begin
      //if (c1sum < c2sum) and (c2sum > 0) and (c1 > 0) then
        arrOper[0] := '.and';
        arrOper[1] := '.or';
        StrBuf.Add(ExtractWord(1, expr, ['&']));
        StrBuf.Add(ExtractWord(2, expr, ['&', '|']));
        StrBuf.Add(ExtractWord(2, expr, ['|']));
      end
      // If OR before AND
      else if (c2 < c1) and (c2 > 0) then begin
      //end else if (c2sum < c1sum) and (c1sum > 0) and (c2 > 0) then
        arrOper[0] := '.or';
        arrOper[1] := '.and';
        StrBuf.Add(ExtractWord(1, expr, ['|']));
        StrBuf.Add(ExtractWord(2, expr, ['|', '&']));
        StrBuf.Add(ExtractWord(2, expr, ['&']));
      end
      // If AND exists and OR doesn't
      else if (c1 > 0) and (c2 < 1) then begin
      //end else if (c1sum > 0) and (c2sum < 1) then
        expr := StringReplace(expr,'&',' and ',[rfReplaceAll]);
        Split(expr, ' and ', []);
        for n3 := 0 to StrBuf.Count - 1 do begin
          arrOper[n3] := '.and';
        end;
      end
      // If OR exists and AND doesn't
      else if (c1 < 1) and (c2 > 0) then begin
        expr := StringReplace(expr,'|',' or ',[rfReplaceAll]);
        Split(expr, ' or ', []);
        for n3 := 0 to StrBuf.Count - 1 do begin
          arrOper[n3] := '.or';
        end;
      end;
    end;

    if isArr then expr := Buffer2;

    Buffer := '';
    for n3 := 0 to StrBuf.Count - 1 do begin
      for n2 := 1 to 20 do begin
        if StrBuf.Count = 1 then begin
          n := System.Pos(Operators[n2], expr);
          n1 := Length(Operators[n2]);
          if n > 0 then begin
            //Number := ExtractEx(expr, '<>', 2, []);
            Number := ExtractEx(expr, Operators[n2], 2, []);

            // Parse ' character to determine ASCII character
            if Number[1] = '''' then begin
              str1 := ExtractEx(TextBuf[CurLine], '''', 2, []);
              //str1 := ExtractEx(Number, '''', 2, []);
              str1 := IntToStr(ord(str1[1]));
              Number := str1;
            end;

            Number := AsmStrNum(Number);
            Buffer2 := ExtractEx(expr, Operators[n2], 1, []);

            // BYTE, CHAR, INT, CARD
            for n1 := 1 to GVarCnt do begin
              if LowerCase(GVar[n1].VarName) = LowerCase(Buffer2) then begin
                if System.Pos(GVar[n1].VarType, 'T1T2') > 0 then
                  Buffer := '.byte '
                else begin
                  Buffer := '.word ';
                end;
                if tmp <> '' then begin
                  Buffer += Buffer2 + _EFF + oper + Number;
                end
                else begin
                  Buffer += Buffer2 + _EFF + Operators[n2] + Number;
                end;
                Break;
              end;
            end;

            // Arrays
            //for n1 := 1 to GVarCnt2 do begin
              //if System.Pos(UpperCase(GVar2[n1].VarName) + '(', UpperCase(Buffer2)) > 0 then begin
            if Checkvar02(UpperCase(Buffer2), '', '(') then begin
              // BYTE ARRAY
              //if System.Pos(GVar2[n1].VarType, 'T5T6') > 0 then
              if System.Pos(var02.VarType, 'T5T6') > 0 then
                Buffer := '.byte '
              // INT and CARD ARRAY
              else begin
                Buffer := '.word ';
              end;
              str1 := AsmStrNum(ExtractEx(Buffer2, '(', 1, []));
              str2 := ExtractText(Buffer2, '(', ')');
              Buffer2 := str1 + '[' + str2 + ']';

              // Check if array index is a number
              if IsNumber(str2[1]) then begin
                buffer += buffer2 + Number;
                if tmp <> '' then
                  Buffer += oper
                else begin
                  Buffer += Operators[n2];
                end;
              end
              // or not
              else begin
                Buffer2 := '$c0';
                CodeBuf.Add(' ldx ' + AsmStrNum(str2));
                CodeBuf.Add(' mva ' + AsmStrNum(str1) + ',x $c0');
                if tmp <> '' then
                  Buffer += Buffer2 + oper + Number
                else begin
                  Buffer += Buffer2 + Operators[n2] + Number;
                end;
              end;
            end;
            Break;
          end;
        end
        else begin
          if System.Pos(Operators[n2], StrBuf[n3]) > 0 then begin
            Number := AsmStrNum(ExtractEx(StrBuf[n3], Operators[n2][1], 2, []));
            Buffer2 := ExtractEx(StrBuf[n3], Operators[n2][1], 1, []);
            for n1 := 1 to GVarCnt do begin
              if LowerCase(GVar[n1].VarName) = LowerCase(Buffer2) then begin
                if System.Pos(GVar[n1].VarType, 'T1T2') > 0 then  // BYTE, CHAR
                  Buffer += '.byte '  // + Buffer2 + _EFF + Operators[n2] + Number
                else begin
                  Buffer += '.word ';  // + Buffer2 + _EFF + Operators[n2] + Number;
                end;
                Buffer += Buffer2 + _EFF + Operators[n2] + Number;
                Break;
              end;
            end;
            if n3 < StrBuf.Count - 1 then begin
              Buffer += ' ' + arrOper[n3];
            end;
            Break;
          end;
        end;
      end;
    end;
    if (Stmt = 'IF') and (System.Pos('ELSEIF', UpperCase(TextBuf[CurLine])) < 1) then begin
      ifElseIndex := CurLine;
      if sElseIf in flags2 then begin
        CodeBuf.Add(' mva #0 else_flag');
      end;
      CodeBuf.Add(' #if ' + Buffer);
      if sElseIf in flags2 then
        CodeBuf.Add(' mva #1 else_flag');
    end
    else if Stmt = 'ELSEIF' then begin
      //CodeBuf.Add(' mva #0 else_flag');
      CodeBuf.Add(' #end');
      CodeBuf.Add(' #if ' + Buffer);
      if sElseIf in flags2 then
        CodeBuf.Add(' mva #1 else_flag');
    end
    else if Stmt = 'WHILE' then begin
//       for n2 := 1 to GVarCnt2 do begin
//         // ARRAY
//         if System.Pos(GVar2[n2].VarType, 'T7T8') > 0 then
//           CodeBuf.Add(' mva #0 array_index_' + GVar2[n2].VarName + _EFF);
//       end;
      if CheckExtraVarType('T7T8') then begin
        CodeBuf.Add(' mva #0 array_index_' + var02.VarName + _EFF);
      end;
      WhileIndex := CurLine;
      CodeBuf.Add(' #while ' + Buffer);
      if tmp <> '' then CodeBuf.Add(tmp);
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! ELSE conditional statement
 Parameters : Stmt (string) - Selected loop/condition statement
              (WHILE, IF, ELSEIF)
 -----------------------------------------------------------------------------}
procedure sc_else;
var
  str : String;
begin
  str := UpperCase(Trim(TextBuf[CurLine]));
  if (System.Pos('ELSE', str) > 0) and (System.Pos('ELSEIF', str) < 1) then begin
    if LeftStr(str, 4) = 'ELSE' then begin
      isElse := True;
      CodeBuf.Add(' #else');
      if sElseIf in flags2 then begin
        CodeBuf.Add(' #if .byte else_flag=#1');
        CodeBuf.Add(' jmp from_else' + IntToStr(ifElseIndex));
        CodeBuf.Add(' #end');
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! conditional closing directive FI
 Parameters : Stmt (string) - Selected loop/condition statement
              (WHILE, IF, ELSEIF)
 -----------------------------------------------------------------------------}
procedure sc_fi;
var
  Buffer : String;
begin
  Buffer := UpperCase(TextBuf[CurLine]);
  if (System.Pos('FI', Buffer) > 0) and (System.Pos('FIL', Buffer) < 1) then begin
    //Buffer := StringReplace(TextBuf[CurLine], ' FI ', 'FI', [rfReplaceAll]);
    //Buffer := Strip(UpperCase(TextBuf[CurLine]), ' ');
    //Buffer := UpperCase(TextBuf[CurLine]);
    //if (TextBuf[CurLine] = 'FI') or (System.Pos(' FI', UpperCase(TextBuf[CurLine])) > 0) then begin
    //if (Buffer = 'FI') then begin  // or (RightStr(Buffer, Length(Buffer) + 1) = ' FI') then begin
    if (Copy(Trim(Buffer), 1, 2) = 'FI') or (sFi in Flags) then begin // or (RightStr(Buffer, 3) = ' FI') then begin
    //if sFi in Flags then begin
    //if (Copy(Buffer, 1, 2) = 'FI') or (System.Pos(' FI', Buffer) > 0) then begin
      CodeBuf.Add(' #end');
      flags -= [sFi];
      // ELSE statement was found
      if isElse then begin
        CodeBuf.Add('from_else' + IntToStr(ifElseIndex));
      end;
      // ELSE statement set as not initialized again
      isElse := False;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! UNTIL branch statement
 Parameters : Stmt (string) - Selected loop/condition statement
              (WHILE, IF, ELSEIF)
 -----------------------------------------------------------------------------}
procedure sc_until;
var
  n, n2 : Integer;
  Buffer : String;
begin
  if (System.Pos('UNTIL ', UpperCase(TextBuf[CurLine])) > 0) then begin
    if System.Pos('"', TextBuf[CurLine]) > 0 then Exit;
    flags += [sUntil];
    Buffer := ExtractEx(UpperCase(TextBuf[CurLine]), 'UNTIL ', 2, []);
    for n2 := 1 to 20 do begin
      n := System.Pos(Operators[n2], Buffer);
      if n > 0 then begin
        Split(Buffer, Operators[n2], []);
        CodeBuf.Add(' lda ' + AsmStrNum(StrBuf[0]));
        if Operators[n2] = '>' then begin
          CodeBuf.Add(' ldx ' + AsmStrNum(StrBuf[1]));
          CodeBuf.Add(' inx');
          CodeBuf.Add(' stx $A0');
          CodeBuf.Add(' cmp $A0');
          CodeBuf.Add(' bcs loop_jump' + IntToStr(LoopIndex));
        end
        else if Operators[n2] = '<' then begin
          CodeBuf.Add(' cmp ' + AsmStrNum(StrBuf[1]));
          CodeBuf.Add(' bcc loop_jump' + IntToStr(LoopIndex));
        end
        else begin
          CodeBuf.Add(' cmp ' + AsmStrNum(StrBuf[1]));
          CodeBuf.Add(' beq loop_jump' + IntToStr(LoopIndex));
        end;
        Break;
      end;
    end;
    CodeBuf.Add(' jmp LabelUntil' + IntToStr(UntilIndex));
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! FOR branch statement
 Examples   : FOR n = 1 to 25600
              FOR i = 0 to 30 STEP 1
 -----------------------------------------------------------------------------}
procedure sc_For;
var
  n1 : LongInt;
  str : String;
begin
  n1 := System.Pos('FOR ', UpperCase(TextBuf[CurLine]));
  if (n1 > 0) then begin
    if System.Pos('"', TextBuf[CurLine]) > 0 then Exit;
    CurrentBranch := 0;
    Inc(ForCnt);
    str := UpperCase(TextBuf[CurLine]);
    if System.Pos(' DO', str) > 0  then begin
      str := StringReplace(str,' DO', '', [rfReplaceAll]);
      TextBuf[CurLine] := str;
    end;

    // For loop variable
    ForVar[ForCnt].VarName := ExtractEx(TextBuf[CurLine], '=', 1, []);
    ForVar[ForCnt].VarName := ExtractEx(UpperCase(ForVar[ForCnt].VarName), 'FOR', 2, []);

    // Start value
    ForVar[ForCnt].StartValue := ExtractEx(TextBuf[CurLine], '=', 2, []);
    Split(UpperCase(ForVar[ForCnt].StartValue), 'TO', []);
    ForVar[ForCnt].StartValue := StrBuf[0];

    // End value
    ForVar[ForCnt].EndValue := StrBuf[1];

    // STEP handling
    Split(UpperCase(ForVar[ForCnt].EndValue), 'STEP', []);
    if StrBuf.Count <= 1 then
      ForVar[ForCnt].Step := '1'
    else begin
      ForVar[ForCnt].EndValue := StrBuf[0];
      ForVar[ForCnt].Step := StrBuf[1];
    end;

    ForVar[ForCnt].ForEnd := False;

    // Check for nested FOR
    if ForCnt > 1 then begin
      ForVar[ForCnt].Nested := not ForVar[ForCnt - 1].ForEnd;
    end;

    for n1 := 1 to GVarCnt do begin
      if UpperCase(ForVar[ForCnt].VarName) = UpperCase(GVar[n1].VarName) then begin
        ForVarX := GVar[n1].VarName;
        CodeBuf.Add(mvwa(GVar[n1].VarType) + AsmStrNum(ForVar[ForCnt].StartValue) +
                    ' ' + AsmStrNum(ForVar[ForCnt].VarName));
        if isArray then begin
          if IsNumber(ForVar[ForCnt].StartValue[1]) then begin
//             for n2 := 1 to GVarCnt2 do begin
//               // ARRAY
//               if System.Pos(GVar2[n2].VarType, 'T7T8') > 0 then
//                 CodeBuf.Add(' mva #' + IntToStr(StrToInt(ForVar[ForCnt].StartValue)*2) +
//                             ' array_index_' + GVar2[n2].VarName + _EFF);
//             end;
            if CheckExtraVarType('T7T8') then begin
              CodeBuf.Add(' mva #' + IntToStr(StrToInt(ForVar[ForCnt].StartValue)*2) +
                          ' array_index_' + var02.VarName + _EFF);
            end;
          end;
        end;

        flags += [sFor];
        //Inc(ForCnt);
        //ForLabels[ForCnt] := 'for_loop' + IntToStr(ForCnt);
        ForVar[ForCnt].ForLabel := 'for_loop' + IntToStr(CurLine);

        if System.Pos(GVar[n1].VarType, 'T3T4') > 0 then begin
          CodeBuf.Add(' mwa ' + AsmStrNum(ForVar[ForCnt].EndValue) + ' $A2');
        end;

        CodeBuf.Add(ForVar[ForCnt].ForLabel);
        Break;
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Main routine for processing Action! source code listing
 Parameters : Flag (Boolean)
 -----------------------------------------------------------------------------}
procedure GenLoop;
var
  i : LongInt;
begin
  // ELSE statement not yet initialized
  isElse := False;

  // Loop through whole file
  for i := 0 to CR_LF do begin
    CurLine := i;

    // Check for comment (;) as the first character on the line
    if System.Pos(';', Trim(TextBuf[CurLine])) = 1 then begin
      CodeBuf.Add(Trim(TextBuf[i]));
      Continue;
    end;
    if System.Pos(';', Trim(TextBuf[CurLine])) > 1 then begin
      CodeBuf.Add('; ' + ExtractEx(TextBuf[CurLine], ';', 2, []));
      TextBuf[CurLine] := ExtractEx(TextBuf[CurLine], ';', 1, []);
      //CodeBuf.Add('; ' + Extract(2, TextBuf[CurLine], ';', []));
      //TextBuf[CurLine] := Extract(1, TextBuf[CurLine], ';', []);
    end;

    sc_Proc;
    sc_Return;

    // Parse machine code opcodes
    sc_ML;

    // Action! statements, assignments, directives
    sc_VarExpr;
    sc_ProcTrack;
    Cond('WHILE');
    sc_until;
    sc_for;
    sc_od;
    sc_do;
    Cond('IF');
    Cond('ELSEIF');
    sc_Exit;

    // Parse IF/THEN FI statement
    tmpBuf := '';
    if System.Pos('THEN ', UpperCase(TextBuf[i])) > 0 then begin
      tmpBuf := ExtractEx(TextBuf[CurLine], ' THEN ', 2, []);
      tmpBuf := StringReplace(tmpBuf, ' FI', '', [rfReplaceAll]);
    end;
    
    sc_Print(True);
    sc_Print(False);
    sc_PrintF;
    sc_Locate;

    sc_Command('Color', '3');
    sc_Command('Device', '3');

    sc_Command('Graphics', '1');
    sc_Command('Poke', '01');
    sc_Command('PokeC', '01');
    sc_Command('Position', '11');
    sc_Command('Plot', '11');
    sc_Command('DrawTo', '11');
    sc_Command('Fill', '11');
    sc_Command('SetColor', '111');
    sc_Command('Sound', '1111');

    sc_Command('SetBlock', '011');
    sc_Command('Zero', '01');
    sc_Command('MoveBlock', '001');

    sc_Command('Put', '1');
    sc_PutE;
    sc_PrintX('PrintB', False);
    sc_PrintX('PrintBE', True);
    sc_PrintX('PrintI', False);
    sc_PrintX('PrintIE', True);
    sc_PrintX('PrintC', False);
    sc_PrintX('PrintCE', True);

    sc_InputS;
    sc_SCopy;
    sc_SCopyS;
    sc_SAssign;
    sc_Command('SCompare', '11');
    sc_StrNum('StrB');
    sc_StrNum('StrC');
    sc_StrNum('StrI');

    sc_Open;
    sc_Close;
    sc_PrintDX(True);
    sc_PrintDX(False);
    sc_PutDX('PutD');
    sc_PutDX('PutDE');
    sc_Point;
    sc_Note;
    sc_GetD;
    sc_InputSMD('INPUTSD', '#255', '21');
    sc_InputSMD('INPUTMD', '0', '211');
    sc_PrintXD('PrintBD', False);
    sc_PrintXD('PrintBDE', True);
    sc_PrintXD('PrintID', False);
    sc_PrintXD('PrintIDE', True);
    sc_PrintXD('PrintCD', False);
    sc_PrintXD('PrintCDE', True);

    sc_SndRst;

    sc_Func('', 'Peek', '0');
    sc_Func('', 'PeekC', '0');
    sc_Func('', 'Stick', '1');
    sc_Func('', 'Strig', '1');
    sc_Func('', 'Paddle', '1');
    sc_Func('', 'Ptrig', '1');
    sc_Func('', 'Rand', '1');

    sc_ValB;
    sc_ValI;
    sc_ValC;

    sc_Input('InputB');
    sc_Input('InputI');
    sc_Input('InputC');

    sc_XIO;

    sc_else;
    sc_fi;

    if TextBuf[i] = LineEnding then CodeBuf.Add('');
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! loop statements plus initializing all necessary variables
 Parameters : Flag (Boolean)
 -----------------------------------------------------------------------------}
procedure sc_do;
var
  Buffer : String;
begin
  // Check to see if this is infinite loop (DO OD)
  // If this is the case, then no labels are defined
  if System.Pos(' OD', UpperCase(TextBuf[CurLine])) > 0 then begin
    Exit;
  end;

  // Normal DO processing
  if System.Pos('DO', UpperCase(TextBuf[CurLine])) > 0 then begin
    Buffer := Strip(UpperCase(TextBuf[CurLine]), ' ');
    if (Copy(Buffer, 1, 2) = 'DO') and not (sFor in flags)
       and not (sWhile in flags) and not (sUntil in flags) then
    begin
      CurrentBranch := 2;
      CodeBuf.Add(' mva #1 loop_var');
      LoopIndex := CurLine;
      CodeBuf.Add('loop' + IntToStr(LoopIndex));
      UntilIndex := CurLine;
      if sUntilFlag in flags2 then
        CodeBuf.Add('LabelUntil' + IntToStr(UntilIndex));
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Action! EXIT branch command
 -----------------------------------------------------------------------------}
procedure sc_Exit;
var
  Buffer : String;
begin
  if System.Pos('EXIT', UpperCase(TextBuf[CurLine])) > 0 then begin
    flags2 += [sExitFlag];
    Buffer := Strip(UpperCase(TextBuf[CurLine]), ' ');
    if Copy(Buffer, 1, 4) = 'EXIT' then begin
      //if sFor in flags then begin
      if CurrentBranch = 0 then
        //ForVar[ForCnt].ForEnd := True;
        //if ForCnt > 1 then Dec(ForCnt);
        //flags2 := flags2 + [sExitFlag];
        CodeBuf.Add(' jmp jump_from_' + ForVar[ForCnt].ForLabel)
        //Dec(ForCnt);
      else if CurrentBranch = 1 then
      //end else if sWhile in flags(*WhileFlag*) then
        CodeBuf.Add(' jmp jump_from_while_' + IntToStr(WhileIndex))
      else
        CodeBuf.Add(' jmp loop_jump' + IntToStr(LoopIndex));
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Checks for PROCs and FUNCs consisting of machine language code
              blocks embeded between [] pair
 -----------------------------------------------------------------------------}
procedure sc_ML;
var
  n : Integer;
  Buffer : String;
begin
  //if TextBuf[CurLine] = '' then Exit;

  // PROC / FUNC machine code call
  if ProcML_start then begin
    // Machine code [] block
    if (System.Pos('[', TextBuf[CurLine]) > 0) and (System.Pos(']', TextBuf[CurLine]) > 0) then begin
      Buffer := ExtractText(TextBuf[CurLine], '[', ']');
      ProcML_start := False;
      PrgVar.SB := _SB_NULL;
    end
    // Start of machine code
    else if System.Pos('[', TextBuf[CurLine]) > 0 then begin
      Split(TextBuf[CurLine], '[', []);
      Buffer := StrBuf[1];
    end
    // End of machine code
    else begin
      Buffer := TextBuf[CurLine];
      if System.Pos(']', Buffer) > 0 then begin
        Buffer := Replace(Buffer, ']', ' ');
        ProcML_start := False;
        PrgVar.SB := _SB_NULL;
      end;
    end;

    Buffer := Trim(Buffer);
    Split(Buffer, ' ', []);

    // Machine code opcodes without spaces (just opcodes supperceded with $)
    if StrBuf.Count <= 1 then begin
      Split(Buffer, '$', []);
      Buffer := '';
      for n := 0 to StrBuf.Count - 1 do begin
        if Length(StrBuf[n]) > 2 then begin
          StrBuf[n] := Copy(StrBuf[n], 3, 2) + ' ' + Copy(StrBuf[n], 1, 2);
        end;
        Inc(MemCnt, Length(StrBuf[n]) div 2);
        Buffer += ' ' + StrBuf[n];
      end;
    end
    // Machine code opcodes separated with spaces (decimal and hexadecimal format allowed)
    else begin
      Buffer := '';
      for n := 0 to StrBuf.Count - 1 do begin
        if Pos('$', StrBuf[n]) < 1 then begin
          StrBuf[n] := Dec2Numb(StrToInt(StrBuf[n]), 4, 16);
        end;
        StrBuf[n] := Trim(Replace(StrBuf[n], '$', ' '));
        if Length(StrBuf[n]) > 2 then begin
          StrBuf[n] := Copy(StrBuf[n], 3, 2) + ' ' + Copy(StrBuf[n], 1, 2);
        end;
        Inc(MemCnt, Length(StrBuf[n]) div 2);
        Buffer += ' ' + StrBuf[n];
      end;
    end;

    // Write machine code code block
    ProcML[ProcML_cnt].Code := ProcML[ProcML_cnt].Code + Buffer;

    // Write machine code memory address
    if not ProcML_start then begin
      Buffer := Dec2Numb(CntML, 4, 16);
      ProcML[ProcML_cnt].Address := '$' + Buffer;
      ProcML_data[ProcML_cnt] := ' org $' + Buffer;
      CntML := 0;
    end;
  end
  // Machine code anywhere in the program
  else if (System.Pos('[', TextBuf[CurLine]) > 0) then begin
    ML_start := True;

    // Check for non-inline assembler code starting with character '['
    if not (sProcAsm in Flags) then begin
      for n := 0 to VarTypes.Count - 1 do begin
        if System.Pos(VarTypes[n], UpperCase(TextBuf[CurLine])) > 0 then begin
          ML_start := False;
          Break;
        end;
      end;
      for n := 0 to VarTypes2.Count - 1 do begin
        if System.Pos(VarTypes2[n], UpperCase(TextBuf[CurLine])) > 0 then begin
          ML_start := False;
          Break;
        end;
      end;
    end;

    // No such situation, let's continue
    CntML := MemCnt;
    Inc(ProcML_cnt);
    PrgVar.SB := _SB_ML;
    ProcML[ProcML_cnt].Code := ' .he';
  end;

  if ML_start then begin  
    if (System.Pos('[', TextBuf[CurLine]) > 0) and (System.Pos(']', TextBuf[CurLine]) > 0) then begin
      Buffer := ExtractText(TextBuf[CurLine], '[', ']');
      PrgVar.SB := _SB_NULL;
      ML_start := False;
    end
    else if System.Pos('[', TextBuf[CurLine]) > 0 then begin
      Split(TextBuf[CurLine], '[', []);
      if StrBuf.Count > 1 then
        Buffer := StrBuf[1]
      else
        Buffer := '';
    end
    else begin
      Buffer := TextBuf[CurLine];
      if System.Pos(']', Buffer) > 0 then begin
        Buffer := Replace(Buffer, ']', ' ');
        ML_start := False;
        PrgVar.SB := _SB_NULL;
      end;
    end;

    Buffer := Trim(Buffer);
    Split(Buffer, ' ', []);
    if StrBuf.Count <= 1 then begin
      Split(Buffer, '$', []);
      Buffer := '';
      for n := 0 to StrBuf.Count - 1 do begin
        if Length(StrBuf[n]) > 2 then begin
          StrBuf[n] := Copy(StrBuf[n], 3, 2) + ' ' + Copy(StrBuf[n], 1, 2);
        end;
        Inc(MemCnt, Length(StrBuf[n]) div 2);
        Buffer += ' ' + StrBuf[n];
      end;
    end
    else begin
      Buffer := '';
      for n := 0 to StrBuf.Count - 1 do begin
        if Pos('$', StrBuf[n]) < 1 then begin
          StrBuf[n] := Dec2Numb(StrToInt(StrBuf[n]), 4, 16);
        end;
        StrBuf[n] := Trim(Replace(StrBuf[n], '$', ' '));
        if Length(StrBuf[n]) > 2 then begin
          StrBuf[n] := Copy(StrBuf[n], 3, 2) + ' ' + Copy(StrBuf[n], 1, 2);
        end;
        Inc(MemCnt, Length(StrBuf[n]) div 2);
        Buffer += ' ' + StrBuf[n];
      end;
    end;

    ProcML[ProcML_cnt].Code += Buffer;

    if not ML_start then begin
      //Buffer := Dec2Numb(CntML, 4, 16);
      //ProcML[ProcML_cnt].Address := '$' + Buffer;
      //ProcML_data[ProcML_cnt] := ' org $' + Buffer;
      CntML := 0;
      Buffer := ProcML[ProcML_cnt].Code;
      //if RightStr(Buffer, 3) = ' 60' then begin
      //  Buffer := Copy(Buffer, 1, Length(Buffer)-3);
      //end;
      CodeBuf.Add(Buffer);
      if sAsm in flags then begin
        CodeBuf.Add(' rts');
        CodeBuf.Add('');
        CodeBuf.Add(' .endp');
        flags -= [sAsm];
      end;
    end;

    if (sProcAsm in Flags) and (PrgVar.SB = _SB_NULL) then begin
      CodeBuf.Add(' rts');
      CodeBuf.Add('');
      CodeBuf.Add(' .endp');
      CodeBuf.Add('');
      flags -= [sProcAsm];
    end;
  end;
end;

end.