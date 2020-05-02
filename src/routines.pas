{
  Program: Effectus - Atari MADS cross-assembler/parser for Action! language
  Authors : Bostjan Gorisek (Effectus), Tebe (Mad Assembler)

  Unit file  : routines.pas
  Description: Library for handling build-in Action! procedures and routines

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
unit Routines;
//{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
  SySutils, Classes, StrUtils, Decl, Core, Common;

procedure sc_Print(boolCR: Boolean);
procedure sc_PutE;
procedure sc_PrintX(Proc : String; lEnter : Boolean);
procedure sc_SndRst;
procedure sc_InputS;
procedure sc_SCopy;
procedure sc_SCopyS;
procedure sc_SAssign;
procedure sc_XIO;
procedure sc_Open;
procedure sc_Close;
procedure sc_PrintDX(boolCR : Boolean);
procedure sc_PutDX(Proc : String);
procedure sc_PrintXD(Proc : String; isAtariCR : Boolean);
procedure sc_InputSMD(Proc, Max, Flags : String);
procedure sc_Point;
procedure sc_Note;
procedure sc_GetD;
procedure sc_Locate;
procedure sc_StrNum(Proc : String);
procedure sc_PrintF;
procedure sc_Input(Proc : String);
procedure sc_ValB;
procedure sc_ValI;
procedure sc_ValC;
procedure sc_Command(CmdName, Flag : String);
function sc_Func(str, Proc, Flag : String) : string;
function GetParams(StrBufX : String; lNum, lConv : Boolean; ParamTypes : String) : Integer;
function SetRoutine(routineName : string; bool01, bool02: boolean; paramStr: string) : boolean;
function Atari_CR(isAtariCR : boolean) : string;

implementation

{------------------------------------------------------------------------------
 Description: Handles Action! Print procedure statements
 Parameters : boolCR (Boolean) - Flag for new line
 -----------------------------------------------------------------------------}
procedure sc_Print(boolCR : Boolean);
var
  n, n1 : LongInt;
  Text_ASM, TextX, Proc : String;
begin
  TextX := Strip(TextBuf[CurLine], ' ');
  Proc := 'PRINT';

  if boolCR then begin
    Proc += 'E';
  end;

  if (System.Pos(UpperCase(Proc + '("'), UpperCase(TextX)) > 0) then begin
    //if System.Pos(UpperCase(Proc) + '("")', UpperCase(TextX)) > 0 then begin
    if System.Pos(UpperCase(Proc) + '("")', UpperCase(TextBuf[CurLine])) > 0 then begin
      if boolCr then CodeBuf.Add(' PutE');
    end
    else begin
      //Text_ASM := ExtractText(TextX, '"', '"');
      Text_ASM := ExtractText(TextBuf[CurLine], '"', '"');
      CodeBuf.Add(' jsr printf');
      //if boolCR then
        CodeBuf.Add(' dta c' + QuotedStr(Text_ASM) + Atari_CR(boolCR) + ',0')
      //else
      //  CodeBuf.Add(' dta c' + QuotedStr(Text_ASM) + ',0');
    end;
  end
  // String variable as parameter
  else if (System.Pos(UpperCase(Proc + '('), UpperCase(TextX)) > 0) then begin
    CodeBuf.Add(' jsr printf');
    Text_ASM := ExtractText(TextBuf[CurLine], '(', ')');
    if cnt_InputS > 0 then begin
      n := 1;
      for n1 := 1 to cnt_InputS do begin
        if System.Pos(Text_ASM + '_', InputS_buf[n1]) < 1 then
          Continue
        else begin
          n := n1;
        end;
        if InputS_buf[n1] = '' then Break;
      end;
      if (n <> 1) and (InputS_buf[n] <> '') then begin
        //if boolCR then
          CodeBuf.Add(' dta ' + AnsiQuotedStr('#', '''') + Atari_CR(boolCR) + ',0');
        //else begin
        //  CodeBuf.Add(' dta ' + AnsiQuotedStr('#', '''') + ',0');
        //end;
        CodeBuf.Add(' dta a(' + InputS_buf[n] + _EFF + ')');
      end;
    end
    else begin
      //if boolCR then
      CodeBuf.Add(' dta c' + AnsiQuotedStr('#', '''') + Atari_CR(boolCR) + ',0');
      //else begin
      //  CodeBuf.Add(' dta c' + AnsiQuotedStr('#', '''') + ',0');
      //end;
      // Handle ARRAY variables      
      //for n1 := 1 to GVarCnt2 do begin
        //if System.Pos(UpperCase(GVar2[n1].VarName) + '(', UpperCase(Text_ASM)) > 0 then begin
        if Checkvar02(Text_ASM, '', '(') then begin
          TextX := ExtractText(Text_ASM, '(', ')');
          Text_ASM := var02.VarName + _EFF + 'array_str_' + TextX;
          //Break;
        end;
        //end;
      //end;
      if System.Pos(_EFF, LowerCase(Text_ASM)) > 0 then
        CodeBuf.Add(' dta a(' + Text_ASM + ')')
      else
        CodeBuf.Add(' dta a(' + Text_ASM + _EFF + ')');
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! PutE procedure statements
 -----------------------------------------------------------------------------}
procedure sc_PutE;
var
  Buffer : String;
begin
  Buffer := Trim(TextBuf[CurLine]);
  if (System.Pos('PUTE()', UpperCase(Buffer)) > 0) then begin
    CodeBuf.Add(' PutE');
  end;
end;

{------------------------------------------------------------------------------
 Description: General method for handling Action! routines
 Parameters : CmdName - Name of the routine
              Flag    - Flag to determine how to handle parameters
 -----------------------------------------------------------------------------}
procedure sc_Command(CmdName, Flag : String);
var
  i, count : LongInt;
  tmp : String = '';
  proc, buffer : String;
begin
  Buffer := Strip(TextBuf[CurLine], ' ');
  Proc := CmdName;

  if System.Pos(UpperCase('=' + Proc), UpperCase(Buffer)) > 0 then begin
    tmp := ExtractEx(Buffer, '=', 1, []);
    //tmp := Extract(1, Buffer, '=', []);
  end;

  if Flag[1] = '3' then  
    CmdName := '='
  else begin
    CmdName := '(';
  end;

  if System.Pos(UpperCase(Proc + CmdName), UpperCase(Buffer)) > 0 then begin
    count := GetParams(Buffer, True, False, Flag);
    buffer := mValues[0];

    for i := 1 to count do begin
      if mValues[i] <> '' then
        buffer += ', ' + mValues[i];
    end;

    CodeBuf.Add(' ' + Proc + ' ' + buffer);

    if tmp <> '' then
      CodeBuf.Add(' mva $A0 ' + tmp + _EFF);
  end;
end;

{------------------------------------------------------------------------------
 Description: General code for handling Action! Print procedure statements
 Parameters : Proc   - Print routine name
              lEnter - Atari carriage return flag
 -----------------------------------------------------------------------------}
procedure sc_PrintX(Proc : String; lEnter : Boolean);
var
  n, n1 : LongInt;
  mValue, mValue2, mValue3, mLabel, VarIndex, Buffer, mTemp : String;

procedure dta(str : String);
var
  r : Byte;
begin
  CodeBuf.Add(' dta c' + QuotedStr('%') + Atari_CR(lEnter) + ',0');
  if IsNumber(mValue3[1]) then begin
    CodeBuf.Add(' dta a(' + mLabel + ')');
    SData[Cnt] := mLabel + ' dta a(' + mValue3 + ')';
    Inc(Cnt);
  end
  else begin
    if str = 'eff_byte' then
      CodeBuf.Add(' dta a($c0)')
    // Processing the type variable
    else begin
      if System.Pos('.', str) > 0 then begin
         mValue := ExtractEx(str, '.', 1, []);
         mValue2 := ExtractEx(str, '.', 2, []);
//        mValue := Extract(1, str, '.', []);
//        mValue2 := Extract(2, str, '.', []);
        for r := 1 to GVarCnt do begin
          if (GVar[r].VarName = mValue) and (GVar[r].ParentType = 'T9') then begin
            CodeBuf.Add(' dta a(' + mValue + _EFF + '.' + mValue2 + _EFF + ')');
            Break;
          end;
        end;
      end
      // Other processing
      else begin
        //CodeBuf.Add(' dta a(' + str + ')')
        CodeBuf.Add(' dta a(' + AsmStrNum(str) + ')')
      end;
    end;
  end;
end;

begin
  Buffer := Strip(TextBuf[CurLine], ' ');
  n1 := System.Pos(UpperCase(Proc + '('), UpperCase(Buffer));
  if (n1 > 0) then begin
    mLabel := '_' + Proc + '_' + IntToStr(CurLine) + '_' + IntToStr(n1);
    mValue := ExtractText(Buffer, '(', ')');
    mValue3 := mValue;
    //for n := 1 to GVarCnt2 do begin
      //if Pos(UpperCase(GVar2[n].VarName), UpperCase(mValue)) > 0 then begin
    if Checkvar02(mValue, '', '') then begin
      mValue2 := ExtractEx(mValue, '(', 1, []);
      //mValue2 := Extract(1, mValue, '(', []);
      VarIndex := ExtractText(mValue, '(', ')');
      mValue := Replace(mValue, '(', '[');
      mValue := Replace(mValue, ')', ']');
      if UpperCase(var02.VarName) = UpperCase(mValue2) then begin
        if System.Pos(var02.VarType, 'T7T8') > 0 then begin
          if not (((sFor in flags) and (ForVarX = VarIndex))
             or (sWhile in flags) or (sUntil in flags)) then
          begin
            if IsNumber(VarIndex[1]) then
              CodeBuf.Add(' mva #' + VarIndex + '*2 array_index_' + mValue2 + _EFF)
            else
              CodeBuf.Add(' mva ' + VarIndex + _EFF + '*2 array_index_' + mValue2 + _EFF);
          end;
          CodeBuf.Add(' ldy array_index_' + var02.VarName + _EFF);
          CodeBuf.Add(' lda ' + var02.VarName + _EFF + ',y');
          CodeBuf.Add(' sta array_buffer_' + var02.VarName + _EFF);
          CodeBuf.Add(' inc array_index_' + var02.VarName + _EFF);
          CodeBuf.Add(' ldy array_index_' + var02.VarName + _EFF);
          CodeBuf.Add(' lda ' + var02.VarName + _EFF + ',y');
          CodeBuf.Add(' sta array_buffer_' + var02.VarName + _EFF + '+1');
        end;
      end;
      (*
      if boolArray and (((sFor in flags) and (ForVarX = VarIndex))
         or (sWhile in flags) or (sUntil in flags))
         and (UpperCase(GVar2[n].VarName) = UpperCase(mValue2))
         and (System.Pos(GVar2[n].VarType, 'T7T8') > 0) then

      //if (UpperCase(GVar2[n].VarName) = UpperCase(mValue2))
      //   and (System.Pos(GVar2[n].VarType, 'T7T8') > 0) then
      begin
        CodeBuf.Add(' jsr printf');
        if lEnter then
          CodeBuf.Add(' dta c''%''' + ',$9b,0')
        else begin
          CodeBuf.Add(' dta c''%''' + ',0');
        end;
        CodeBuf.Add(' dta a(array_buffer_' + GVar2[n].VarName  + _EFF + ')');
        *)

      // POINTER OR ARRAY
        if System.Pos(var02.VarType, 'T10') > 0 then begin
          if System.Pos(UpperCase(var02.VarName) + '.', UpperCase(mValue)) > 0 then begin
            VarIndex := ExtractEx(mValue3, '.', 2, []);
            //VarIndex := Extract(2, mValue3, '.', []);
            for n1 := 1 to GVarCnt do begin
              if UpperCase(GVar[n1].VarName) = UpperCase(VarIndex) then begin
                CodeBuf.Add(mvwa(GVar[n1].VarType) + PtrData + _EFF +
                            '[' + IntToStr(RecPtrVar.Dim) + '].' + VarIndex + _EFF +
                            ' struct_ptr_var');
                Break;
              end;
            end;
            CodeBuf.Add(' jsr printf');
            CodeBuf.Add(' dta c''%''' + Atari_CR(lEnter) + ',0');
            CodeBuf.Add(' dta a(struct_ptr_var)');
          end
          else begin
            CodeBuf.Add(' jsr printf');
            CodeBuf.Add(' dta c''%''' + Atari_CR(lEnter) + ',0');
            for n1 := 1 to GVarCnt do begin
              if (System.Pos(GVar[n1].ParentType, 'T10') > 0)
                 and (UpperCase(GVar[n1].OrigType) = UpperCase(var02.VarName)) then
              begin
                CodeBuf.Add(' dta a(' + GVar[n1].VarName + _EFF + ')');
                Break;
              end;
            end;
          end;
        end
        else begin
          mTemp := AsmStrNum(ExtractText(mValue, '[', ']'));
          mTemp := ExtractEx(mTemp, '[', 2, []);
          mTemp := StringReplace(mTemp, '#', '', [rfReplaceAll]);
          if System.Pos(var02.VarType, 'T5T6') > 0 then begin
            if IsNumber(mTemp[1]) then
              CodeBuf.Add(' ldx #' + mTemp)
            else begin
              CodeBuf.Add(' ldx ' + mTemp);
            end;
            CodeBuf.Add(' mva ' + mvalue2 + _EFF + ',x $c0');
            //CodeBuf.Add(' mva ' + mvalue2 + _EFF + '[' + mTemp + ']' + ' $c0');
            mValue2 := 'eff_byte';
          end
          else if System.Pos(var02.VarType, 'T7T8') > 0 then begin
//               Buf := ExtractText(Buffer, '(', ')');  // Array element
//               Buf2 := ExtractText(Buf, '(', ')');    // Array element index
//               Buf := Extract(Buf, '(', 1);

//               if IsNumber(Buf2[1]) then
//                 CodeBuf.Add(' mva #' + Buf2 + '*2 array_index_' + Buf + _EFF)
//               else
//                 CodeBuf.Add(' mva ' + Buf2 + _EFF + '*2 array_index_' + Buf + _EFF);

//               CodeBuf.Add(' ldy array_index_' + Buf + _EFF);
//               CodeBuf.Add(' lda ' + Buf + _EFF + ',y');
//               CodeBuf.Add(' sta array_buffer_' + Buf + _EFF);
//               CodeBuf.Add(' inc array_index_' + Buf + _EFF);
//               CodeBuf.Add(' ldy array_index_' + Buf + _EFF);
//               CodeBuf.Add(' lda ' + Buf + _EFF + ',y');
//               CodeBuf.Add(' sta array_buffer_' + Buf + _EFF + '+1');

//               mValue2 := 'array_buffer_' + Buf;

            mValue2 := 'array_buffer_' + var02.VarName;
          end;
          CodeBuf.Add(' jsr printf');
          dta(mvalue2);
      end;
      exit;
    end;

    mValue2 := ExtractText(Buffer, '(', ')');

    // Check to see if variable is a BYTE value
    n1 := 0;
    for n := 1 to GVarCnt do begin
      if (System.Pos(GVar[n].VarType, 'T1T2') > 0)
         and (UpperCase(GVar[n].VarName) = UpperCase(mValue2)) then
      begin
        n1 := 1;
        mValue2 := AsmStrNum(mValue2);
        CodeBuf.Add(' mva ' + mValue2 + ' $c0');
        CodeBuf.Add(' jsr printf');
        dta('eff_byte');
        break;
      end;
    end;
    if n1 = 0 then begin
      CodeBuf.Add(' jsr printf');
      dta(mValue2);
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! SndRst procedure statement
 -----------------------------------------------------------------------------}
procedure sc_SndRst;
var
  buffer : String;
begin
  Buffer := Strip(TextBuf[CurLine], ' ');
  if (System.Pos(UpperCase('SndRst('), UpperCase(Buffer)) > 0) then begin
    CodeBuf.Add(' SndRst');
  end;
end;

{------------------------------------------------------------------------------
 Description: General method for handling Action! functions
 Parameters : Proc - Function name
              Flag - Parameter type
 -----------------------------------------------------------------------------}
function sc_Func(str, Proc, Flag : String) : string;
var
  i, j : Integer;
  Str1, Str2, Buffer, FuncPrm : String;
  arrOper : TStringList;
  tmp : String = '';
begin
  if str = '' then
    Buffer := Strip(TextBuf[CurLine], ' ')
  else begin
    Buffer := Strip(str, ' ');
  end;

  i := System.Pos(UpperCase(Proc + '('), UpperCase(Buffer));
  if (i > 0) then begin
    arrOper := TStringList.Create;
    try
      if str = '' then
        Buffer := Trim(TextBuf[CurLine])
      else begin
        Buffer := Trim(str);
      end;
      
      GetParams(Buffer, False, False, Flag);
      Split(Buffer, '=', []);
      Str1 := StrBuf[0];
      Str2 := StrBuf[1];
      FuncPrm := ExtractText(Str2, '(', ')');

      // Special case - Direct memory address pointer in variable assignment expression
      if System.Pos('+', FuncPrm) > 0 then begin
        Str2 := ExtractEx(FuncPrm, '+', 1, []);
        FuncPrm := ExtractEx(FuncPrm, '+', 2, []);
        //Str2 := Extract(1, FuncPrm, '+', []);
        //FuncPrm := Extract(2, FuncPrm, '+', []);

        if str = '' then begin
          CodeBuf.Add(' ' + Proc + ' ' + Str2 + _EFF + '+' + FuncPrm);
          CodeBuf.Add(' mwa $A0 ' + Str1 + _EFF);
        end
        else begin
          tmp += ' ' + Proc + ' ' + Str2 + _EFF + '+' + FuncPrm  + LineEnding;
          tmp += ' mwa $A0 ' + Str1 + _EFF + LineEnding;
        end;
        
        if Assigned(arrOper) then FreeAndNil(arrOper);
        Exit;
      end;

      // Normal processing
      for i := 1 to GVarCnt do begin
        if System.Pos(UpperCase(GVar[i].VarName) + '=', UpperCase(Str1 + '=' + Str2)) > 0 then begin
          if str = '' then begin
            if Flag[1] = '0' then
              CodeBuf.Add(' ' + Proc + ' ' + mValues[0])
            else begin
              CodeBuf.Add(' ' + Proc + ' ' + AsmStrNum(mValues[0]));
            end;
          end
          else begin
            if not FuncCheck('') then begin
              if Flag[1] = '0' then
                tmp += ' ' + Proc + ' ' + mValues[0] + LineEnding
              else begin
                tmp += ' ' + Proc + ' ' + AsmStrNum(mValues[0]) + LineEnding;
              end;
            end;
          end;
          for j := 0 to Length(Str2) - 1 do begin
            if Str2[j] = '+' then
              arrOper.Add('1')
            else if Str2[j] = '-' then
              arrOper.Add('2')
            else if Str2[j] = '*' then
              arrOper.Add('3')
            else if Str2[j] = '/' then
              arrOper.Add('4')
          end;

          // Generate expression output
          if arrOper.Count = 0 then begin
            if str = '' then
              CodeBuf.Add(mvwa(GVar[i].VarType) + '$A0 ' + Str1 + _EFF)
            else begin
              tmp += mvwa(GVar[i].VarType) + '$A0 ' + Str1 + _EFF + LineEnding;
            end;
            Break;
          end;
          SplitEx2(Str2, '+', '-', '*', '/');
          for j := 0 to arrOper.Count - 1 do begin
            if j = 0 then begin
              if arrOper[j] = '1' then
                Str2 := strbuf2[0] + '+' + strbuf2[1]
              else if arrOper[j] = '2' then
                Str2 := strbuf2[0] + '-' + strbuf2[1]
              else if arrOper[j] = '3' then
                Str2 := strbuf2[0] + '*' + strbuf2[1]
              else if arrOper[j] = '4' then
                Str2 := strbuf2[0] + '/' + strbuf2[1]
            end
            else begin
              if arrOper[j] = '1' then
                Str2 := Str1 + '+' + strbuf2[j + 1]
              else if arrOper[j] = '2' then
                Str2 := Str1 + '-' + strbuf2[j + 1]
              else if arrOper[j] = '3' then
                Str2 := Str1 + '*' + strbuf2[j + 1]
              else if arrOper[j] = '4' then
                Str2 := Str1 + '/' + strbuf2[j + 1]
            end;
            MathExpr(GVar[i].VarType, Str1, Str2, 1, 0);
          end;
          Break;
        end;
      end;
    finally
      if Assigned(arrOper) then FreeAndNil(arrOper);
    end;
  end;

  result := tmp;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! ValB procedure statement
 -----------------------------------------------------------------------------}
procedure sc_ValB;
var
  i : Integer;
  mLabel, Buffer : String;
begin
  if not SetRoutine('VALB', true, true, '1') then Exit;

  Buffer := Strip(TextBuf[CurLine], ' ');
  //Split(Buffer, '=', []);
  //Str1 := StrBuf[0];

  for i := 1 to GVarCnt do begin
    if System.Pos(UpperCase(GVar[i].VarName) + '=', UpperCase(Buffer)) > 0 then begin
      mLabel := '_strval_' + IntToStr(CurLine) + '_';
      SData[Cnt] := mLabel + ' dta a(' + mValues[0] + ')';
      Inc(Cnt);
      CodeBuf.Add(' mva ' + mLabel + ' $A0');
      CodeBuf.Add(mvwa(GVar[i].VarType) + '$A0 ' + mValues[10] + _EFF);
      Break;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! ValI procedure statement
 -----------------------------------------------------------------------------}
procedure sc_ValI;
var
  i : Integer;
  mLabel, Buffer : String;
begin
  if not SetRoutine('VALI', true, true, '1') then Exit;

  Buffer := Strip(TextBuf[CurLine], ' ');
  //Split(Buffer, '=', []);

  for i := 1 to GVarCnt do begin
    if System.Pos(UpperCase(GVar[i].VarName) + '=', UpperCase(Buffer)) > 0 then begin
      mLabel := '_strval_' + IntToStr(CurLine) + '_';
      SData[Cnt] := mLabel + ' dta a(' + mValues[0] + ')';
      Inc(Cnt);
      CodeBuf.Add(' mwa ' + mLabel + ' $A0');
      CodeBuf.Add(mvwa(GVar[i].VarType) + '$A0 ' + mValues[10] + _EFF);
      Break;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! ValC procedure statement
 -----------------------------------------------------------------------------}
procedure sc_ValC;
var
  i : Integer;
  mLabel, Buffer : String;
begin
  if not SetRoutine('VALC', true, true, '1') then Exit;

  Buffer := Strip(TextBuf[CurLine], ' ');
  //Split(Buffer, '=', []);

  for i := 1 to GVarCnt do begin
    if System.Pos(UpperCase(GVar[i].VarName) + '=', UpperCase(Buffer)) > 0 then begin
      mLabel := '_strval_' + IntToStr(CurLine) + '_';
      SData[Cnt] := mLabel + ' dta a(' + mValues[0] + ')';
      Inc(Cnt);
      CodeBuf.Add(' mwa ' + mLabel + ' $A0');
      CodeBuf.Add(mvwa(GVar[i].VarType) + '$A0 ' + mValues[10] + _EFF);
      Break;
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! input of numeric values with functions
              InputB, InputI and InputC
 Parameters : Proc - Function name
 -----------------------------------------------------------------------------}
procedure sc_Input(Proc : String);
var
  Buffer : String;
begin
  Buffer := Strip(TextBuf[CurLine], ' ');
  if System.Pos('=' + UpperCase(Proc) + '()', UpperCase(Buffer)) > 0 then begin
    Buffer := ExtractEx(Buffer, '=', 1, []);
    //Buffer := Extract(1, Buffer, '=', []);
    CodeBuf.Add(' getline #hex_num');
    CodeBuf.Add(' ldx #0');
    CodeBuf.Add(' lda hex_num,x');
    CodeBuf.Add(' sbc #48');
    CodeBuf.Add(' sta ' + Buffer + _EFF);
    CodeBuf.Add(' lda #10');  // Currently, only numbers 0 to 9 are shown
    CodeBuf.Add(' cmp ' + Buffer + _EFF);
    CodeBuf.Add(' bcc jfv' + IntToStr(CurLine));
    CodeBuf.Add(' jmp skip' + IntToStr(CurLine));
    CodeBuf.Add('jfv' + IntToStr(CurLine) + ' mva #0 ' + Buffer + _EFF);
    CodeBuf.Add('skip' + IntToStr(CurLine));
  end;
end;

(******************************************************************************
                               String routines
******************************************************************************)

{------------------------------------------------------------------------------
 Description: Handles Action! InputS procedure statement
 -----------------------------------------------------------------------------}
procedure sc_InputS;
var
  Buffer : String;
begin
  Buffer := Strip(TextBuf[CurLine], ' ');
  if System.Pos('INPUTS(', UpperCase(Buffer)) > 0 then begin
    Buffer := ExtractText(TextBuf[CurLine], '(', ')');
    CodeBuf.Add(' getline #' + Trim(Buffer) + _EFF);
  end;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! SCopy procedure statement InputB, InputI and InputC

 PROC SCopy(targetString, sourceString)
 SCopy(str1,"String1")
 SCopy(str1,str2)
 -----------------------------------------------------------------------------}
procedure sc_SCopy;
begin
{    
str1 1=str1, "Atari"
StrBuf: SCopy(str1 / "Atari")
str1 2=str1
str2 1=Atari
}
  if not SetRoutine('SCOPY', true, false, '11') then Exit;

  CodeBuf.Add(' ldx #0');
  CodeBuf.Add('loop_' + IntToStr(CurLine));

  if System.Pos('#', mValues[1]) > 0 then
    mValues[1] := ExtractEx(mValues[1], '#', 2, []);
    //mValues[1] := Extract(2, mValues[1], '#', []);

  CodeBuf.Add(' mva ' + mValues[1] + ',x ' + mValues[0] + ',x');
  CodeBuf.Add(' inx');

  //for i := 1 to GVarCnt2 do begin
    //if UpperCase(GVar2[i].VarName + _EFF) = UpperCase(mValues[1]) then begin
  if Checkvar02Equal(mValues[1], _EFF) then    
    CodeBuf.Add(' cpx #' + IntToStr(var02.Dim))
  else begin
    CodeBuf.Add(' cpx #' + IntToStr(mLength[1]));
  end;

  CodeBuf.Add(' jcc loop_' + IntToStr(CurLine));
end;

{------------------------------------------------------------------------------
 Description: Handles Action! SCopyS procedure statement
 
 PROC SCopyS(targetString, sourceString, BYTE start, stop)

 Examples:
   SCopyS(str1, "LATARIAN", 2, 6)
   SCopyS(str2, str1, 2, 4)
 -----------------------------------------------------------------------------}
procedure sc_SCopyS;
begin
  //Buffer := Strip(TextBuf[CurLine], ' ');
  //if System.Pos('SCOPYS(', UpperCase(Buffer)) > 0 then begin
  //  if GetParams(TextBuf[CurLine], True, False, '1111') <> 3 then Exit;

  if not SetRoutine('SCOPYS', true, false, '1111') then Exit;

  if System.Pos('#', mValues[1]) > 0 then
    mValues[1] := ExtractEx(mValues[1], '#', 2, []);
    //mValues[1] := Copy(mValues[1], 2, Length(mValues[1]) - 1);

  if System.Pos('#', mValues[3]) < 1 then begin
    CodeBuf.Add(' mva ' + mValues[3] + ' b_param1');
    CodeBuf.Add(' dec b_param1');
  end;

  CodeBuf.Add(' ldy ' + mValues[2]);
  CodeBuf.Add(' dey');
  CodeBuf.Add(' ldx #0');
  CodeBuf.Add('loop_' + IntToStr(CurLine));
  CodeBuf.Add(' lda ' + mValues[1] + ',y');
  CodeBuf.Add(' sta ' + mValues[0] + ',x');
  CodeBuf.Add(' iny');
  CodeBuf.Add(' inx');

  if System.Pos('#', mValues[3]) < 1 then
    CodeBuf.Add(' cpx b_param1')
  else begin
    mValues[3] := ExtractEx(mValues[3], '#', 2, []);
    //mValues[3] := Extract(2, mValues[3], '#', []);
    CodeBuf.Add(' cpx #' + IntToStr(StrToInt(mValues[3]) - 1));
  end;

  CodeBuf.Add(' jcc loop_' + IntToStr(CurLine));
end;

{------------------------------------------------------------------------------
 Description: Handles Action! SAssign procedure statement
 -----------------------------------------------------------------------------}
procedure sc_SAssign;
begin
  if not SetRoutine('SASSIGN', true, false, '1111') then Exit;

  if System.Pos('#', mValues[1]) > 0 then begin
    mValues[1] := ExtractEx(mValues[1], '#', 2, []);
    //mValues[1] := Extract(2, mValues[1], '#', []);
  end;

  CodeBuf.Add(' ldy ' + mValues[2]);
  CodeBuf.Add(' dey');
  CodeBuf.Add(' ldx #0');
  CodeBuf.Add('loop_' + IntToStr(CurLine));
  CodeBuf.Add(' lda ' + mValues[1] + ',y');
  CodeBuf.Add(' sta ' + mValues[0] + ',x');
  CodeBuf.Add(' iny');
  CodeBuf.Add(' inx');
  CodeBuf.Add(' cpx ' + mValues[3]);
  CodeBuf.Add(' jcc loop_' + IntToStr(CurLine));
end;

{------------------------------------------------------------------------------
 Description: Handles Action! XIO routine
 Action! syntax: PROC XIO(BYTE channel, 0, command, aux1, aux2, fileString)
 -----------------------------------------------------------------------------}
procedure sc_XIO;
var
  n, n1 : LongInt;
  Proc, mParams, Buffer : String;
begin
  Buffer := Strip(TextBuf[CurLine], ' ');
  Proc := 'XIO';
  n1 := System.Pos(UpperCase(Proc + '('), UpperCase(Buffer));
  if n1 > 0 then begin
    Buffer := Trim(TextBuf[CurLine]);
    GetParams(Buffer, False, False, '00011111111');
    for n := 0 to n1 do begin
      case n of
        1: mParams := mValues[0];
        2: //
        else
          mParams += ', ' + mValues[n];
      end;
    end;
    CodeBuf.Add(' ' + Proc + ' ' + mParams);
  end;
end;

(******************************************************************************
                          Input/output (I/O) routines
******************************************************************************)

{------------------------------------------------------------------------------
 Description: Handles Action! Open procedure statement
 Action! syntax: PROC Open(BYTE channel, fileString, BYTE mode, aux2)
 -----------------------------------------------------------------------------}
procedure sc_Open;
var
  mParams : String;
begin
    if not SetRoutine('Open', false, false, '211') then Exit;
    mParams := '';
    mParams := mValues[0];
    mParams += ', ' + mValues[2];
    mParams += ', ' + mValues[1];  // + _EFF;
    //Num := 1;
    CodeBuf.Add(' Open ' + mParams);
// BMI - short jump
// JMI - long jump
    isIOerror[1] := True;
    CodeBuf.Add(' jmi stop1');  // + IntToStr(Num));
  //end;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! Close procedure statement
 Action! syntax: PROC Close(BYTE channel)
 -----------------------------------------------------------------------------}
procedure sc_Close;
begin
  if not SetRoutine('Close', false, false, '2') then Exit;
  CodeBuf.Add(' Close ' + mValues[0]);
end;

{------------------------------------------------------------------------------
 Description: Handles Action! PrintD and PrintDE procedure statement
 Parameters : boolCR
 Action! syntax:
   PROC PrintDE(BYTE channel, string)
 Examples:
   PrintD(6,"hi, atariage")
   PrintDE(1,text_buf)
 -----------------------------------------------------------------------------}
procedure sc_PrintDX(boolCR : Boolean);
var
  n, Value, Code : Integer;
  Buf, Str1, Str2, Str3 : String;
begin
  Str1 := Strip(TextBuf[CurLine], ' ');
  if boolCR then
    Buf := 'PrintDE('
  else begin
    Buf := 'PrintD(';
  end;
  if (System.Pos(UpperCase(Buf), UpperCase(Str1)) > 0) then begin
    Str1 := ExtractEx(TextBuf[CurLine], '(', 2, []);
    //Str1 := Extract(2, TextBuf[CurLine], '(', []);
    Split(Str1, ',', []);
    //StrBuf[0] := Channel(StrBuf[0]);
    Buf := StrBuf[0];
    Val(Buf, Value, Code);
    if Code = 0 then begin
      if Buf[1] = '$' then begin
        Buf := Copy(Buf, 2, Length(Buf) - 1);
        n := StrToInt(Buf) * 10;
        StrBuf[0] := '#$' + IntToStr(n);
      end
      else begin
        Buf := '#$' + Buf + '0';
        StrBuf[0] := Buf;
      end;
    end;
    if System.Pos('"', Str1) > 0 then begin
      Str3 := ExtractText(Str1, '"', '"');
      Value := Length(Str3);
      Str2 := '_str_buffer_' + IntToStr(CurLine) + _EFF;
      SData[Cnt] := Str2 + ' .byte ' + QuotedStr(Str3);
      if boolCR then begin
        SData[Cnt] := SData[Cnt] + ', $9b';
      end;
      Inc(Cnt);
      CodeBuf.Add(' Read ' + StrBuf[0] + ', #9, #' + Str2 + ', #' + IntToStr(Value));
    end
    else begin
      Str3 := Copy(StrBuf[1], 1, Length(StrBuf[1]) - 1);
      //for n := 1 to GVarCnt2 do begin
        //if UpperCase(GVar2[n].VarName) = UpperCase(Str3) then begin
        if Checkvar02Equal(Str3, '') then begin
          Value := var02.Dim;
        end;
      CodeBuf.Add(' Read ' + StrBuf[0] + ', #9, #' + Str3 + _EFF + ', #' + IntToStr(Value));
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! PutD and PutDE procedure statement
 Parameters : Proc - Procedure name value
 Action! syntax:
   PROC PutD(BYTE channel, CHAR character)
 -----------------------------------------------------------------------------}
procedure sc_PutDX(Proc : String);
var
  mParams : String;
begin
  //Buf := Strip(TextBuf[CurLine], ' ');
  //if (System.Pos(UpperCase(Proc + '('), UpperCase(Buf)) > 0) then begin
    if not SetRoutine(Proc, false, false, '21') then Exit;
    //mParams := '';
    //GetParams(Buf, False, False, '21');
    mParams := mValues[0];
    mParams += ', ' + mValues[1];
    CodeBuf.Add(' ' + Proc + ' ' + mParams);
  //end;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! GetD function statement
 Action! syntax:
   CHAR FUNC GetD(BYTE channel)
 -----------------------------------------------------------------------------}
procedure sc_GetD;
begin
  if not SetRoutine('GETD', false, false, '2') then Exit;
  //  GetParams(Buf, False, False, '2');
    //mParams := mValues[0];
  CodeBuf.Add(' GetD ' + mValues[0]);
  CodeBuf.Add(' mva $A0 ' + ExtractEx(TextBuf[CurLine], '=', 1, []) + _EFF);
  //CodeBuf.Add(' mva $A0 ' + Extract(1, TextBuf[CurLine], '=', []) + _EFF);
end;

{------------------------------------------------------------------------------
 Description: Generic Action! print device procedure statement
 Parameters : Proc - Procedure name value
              isAtariCR - New line
 -----------------------------------------------------------------------------}
procedure sc_PrintXD(Proc : String; isAtariCR : Boolean);
var
  n1 : Integer;
  buf, mLabel, mParams : String;
begin
  Buf := Strip(TextBuf[CurLine], ' ');
  n1 := System.Pos(UpperCase(Proc + '('), UpperCase(Buf));
  if (n1 > 0) then begin
    mLabel := '_' + Proc + '_' + IntToStr(CurLine) + '_' + IntToStr(n1);
    GetParams(Buf, False, False, '21');
    mParams := mValues[0];
    CodeBuf.Add(' printfd ' + mParams);
    //if lEnter then
      CodeBuf.Add(' dta c' + QuotedStr('%') + Atari_CR(isAtariCR) + ',0');
    //else begin
    //  CodeBuf.Add(' dta c' + QuotedStr('%') + ',0');
    //end;
    if mValues[1][1] = '#' then begin
      Buf := Copy(mValues[1], 2, Length(mValues[1]) - 1);
      CodeBuf.Add(' dta a(' + mLabel + ')');
      SData[Cnt] := mLabel + ' dta a(' + Buf + ')';
      Inc(Cnt);
    end
    else begin
      Buf := mValues[1];
      CodeBuf.Add(' dta a(' + Buf + ')');
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! Input procedure statements
 Parameters : Proc - Procedure name (InputSD, InputMD)
              Max - Maximum length of buffer
              Flags - Flags to determine number of parameters
 Action! syntax:
   PROC InputSD(BYTE channel, string)
   PROC InputMD(BYTE channel, string, BYTE max)
 -----------------------------------------------------------------------------}
procedure sc_InputSMD(Proc, Max, Flags : String);
var
  mParams, Buf : String;
begin
  Buf := Strip(TextBuf[CurLine], ' ');
  if (System.Pos(Proc + '(', UpperCase(Buf)) > 0) then begin
    //mParams := '';
    GetParams(Buf, False, False, Flags);
    mParams := mValues[0];  // IOCB channel number
    mParams += ', #5';  // Get record
    mParams += ', ' + mValues[1] + _EFF;  // Get buffer
    if Flags = '211' then Max := mValues[2];
    mParams += ', ' + Max;  // Length of buffer
    CodeBuf.Add(' Read ' + mParams);
  end;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! Point procedure statement
 Action! syntax: PROC Point(BYTE channel, CARD sector, BYTE offset)
 -----------------------------------------------------------------------------}
procedure sc_Point;
begin
  //Buffer := Strip(TextBuf[CurLine], ' ');
  //Proc := 'Point';
  //if System.Pos(UpperCase(Proc + '('), UpperCase(Buffer)) > 0 then begin
    //GetParams(Buffer, False, False, '211');
  if not SetRoutine('POINT', false, false, '211') then Exit;
    //mParams := mValues[0];
  CodeBuf.Add(' Point ' + mValues[0] + ', ' + mValues[1] + ', ' + mValues[2]);
  //end;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! Note procedure statement
 Action! syntax: PROC Note(BYTE channel, CARD POINTER sector, BYTE POINTER offset)
 -----------------------------------------------------------------------------}
procedure sc_Note;
begin
  //Buffer := Strip(TextBuf[CurLine], ' ');
  //Proc := 'Note';
  //if System.Pos(UpperCase(Proc + '('), UpperCase(Buffer)) > 0 then begin
  if not SetRoutine('NOTE', false, false, '111') then Exit;
  //GetParams(Buffer, False, False, '111');
  //mParams := mValues[0];
  CodeBuf.Add(' Note ' + mValues[0] + ', ' + mValues[1] + ', ' + mValues[2]);
end;

{------------------------------------------------------------------------------
 Description: Handles Action! Locate function statement
 Action! syntax: BYTE FUNC Locate(CARD column, BYTE row)
 -----------------------------------------------------------------------------}
procedure sc_Locate;
begin
  //if System.Pos('LOCATE(', UpperCase(Buf)) > 0 then begin
    //GetParams(Buf, False, False, '11');
  if not SetRoutine('LOCATE', false, false, '11') then Exit;
  CodeBuf.Add(' Locate ' + mValues[0] + ', ' + mValues[1]);
  //Buf := ExtractEx(TextBuf[CurLine], '=', 1, []) + _EFF;
  CodeBuf.Add(' mva $A0 ' + mValues[10] + _EFF);
end;

{------------------------------------------------------------------------------
 Description: Handles Action! StrB, StrI and StrC procedure statements
 Parameters : Proc - Name of the string conversion routine (StrB, StrI or StrC)
 Action! syntax: PROC StrB(BYTE number, string)
 -----------------------------------------------------------------------------}
procedure sc_StrNum(Proc : String);
var
  n : LongInt;
begin
  if not SetRoutine(Proc, false, false, '11') then Exit;

  if System.Pos('#', mValues[0]) > 0 then begin
    mValues[0] := ExtractEx(mValues[0], '#', 2, []);
    //mValues[0] := Extract(2, mValues[0], '#', []);
  end;

  if System.Pos('#', mValues[1]) > 0 then begin
    mValues[1] := ExtractEx(mValues[1], '#', 2, []);
    //mValues[1] := Extract(2, mValues[1], '#', []);
  end;

  CodeBuf.Add(' ldy #0');

  if IsNumber(mValues[0][1]) then begin
    for n := 1 to Length(mValues[0]) do begin
      CodeBuf.Add(' mva #''' + mValues[0][n] + '''' + ' ' + mValues[1] + _EFF + ',y');
      if n < Length(mValues[0]) then CodeBuf.Add(' iny');
    end;
  end
  else begin
    CodeBuf.Add(' 3 mva ' + mValues[0] + _EFF + ' ' + mValues[1] + _EFF + ',y');
  end;
end;

{------------------------------------------------------------------------------
 Description: Calculates dec/hex convention if necessary
 Parameters : Value -
 Returns    : Returns string value with recalculated number in dec/hex 
 -----------------------------------------------------------------------------}
function Channel(Value : String) : String;
var
  n : Byte;
  Buf : String;
begin
  if Value[1] <> '#' then
    Result := Value
  else begin
    Buf := Copy(Value, 2, Length(Value) - 1);
    if Buf[1] = '$' then begin
      Buf := Copy(Buf, 2, Length(Buf) - 1);
      n := StrToInt(Buf) * 10;
      Result := '#$' + IntToStr(n);
    end
    else begin
      n := StrToInt(Buf) * 16;
      Result := '#' + IntToStr(n);
    end;
  end;
end;

{------------------------------------------------------------------------------
 Description: Handling routine parameters
 Parameters    : StrBufX
                 lNum       - Indication if parameter values need additional processing
                              before converting to appropriate type values
                 lConv      - Convert string value directly to number value or not
                 ParamTypes - Flags to determine how to handle parameters
 Returns       : Number of command parameters
 -----------------------------------------------------------------------------}
function GetParams(
  StrBufX : String;
  lNum, lConv : Boolean;
  ParamTypes : String) : Integer;
var
  i, j : Integer;
  paramCount : Integer;  // Number of parameters
  flag : Boolean = False;
  mVal, Buf, Buf2, StrBuffer : String;
  arrOper, StrBuf3 : TStringList;
  isChannel : boolean = false;
begin
  for i := 0 to 9 do begin
    mValues[i] := '';
    mLength[i] := 0;
  end;

  StrBuffer := '_str_buffer_' + IntToStr(CurLine);
  StrBuf3 := TStringList.Create;
  StrBuf3.Clear;

  mValues[10] := ExtractEx(TextBuf[CurLine], '=', 1, []);
  //mValues[10] := Extract(1, TextBuf[CurLine], '=', []);

  if ParamTypes = '3' then
    Buf := ExtractEx(strbufx, '=', 2, [])
    //Buf := Extract(2, strbufx, '=', [])
  else begin
    Buf := ExtractText(strbufx, '(', ')');
  end;

  if System.Pos('(', Buf) > 0 then begin
    Buf := Replace(Buf, '(', '[');
  end;

  if System.Pos(')', Buf) > 0 then begin
    Buf := Replace(Buf, ')', ']');
  end;

  Split(Buf, ',', []);
  paramCount := StrBuf.Count - 1;
  for i := 0 to paramCount do begin
    StrBuf3.Add(StrBuf[i]);
  end;

  for i := 0 to paramCount do begin
    mVal := StrBuf3[i];
    if mVal = '""' then mVal := Chr(39);
    if IsNumber(mVal[1])
       and ((ParamTypes[i + 1] in ['1', '2']) or (ParamTypes[1] = '3')) then
    begin
      mValues[i] := Trim('#' + mVal);
    end
    else if mVal[1] = '''' then begin
      if (mval = Chr(39)) then begin
        mval += ' ';
      end;
      mValues[i] := '#' + mVal + ''''
    end else begin
      Flag := False;
      //for j := 1 to GVarCnt2 do begin
      //  if System.Pos(UpperCase(GVar2[j].VarName), UpperCase(StrBufX)) > 0 then begin
      if Checkvar02(StrBufX, '', '') then begin
        Flag := True;
        if not lNum then begin
          mValues[i] := '#' + Trim(mVal);
        end
        else begin
          Buf := ExtractText(StrBufX, '(', ')');  // Array element
          Buf2 := ExtractText(Buf, '(', ')');     // Array element index
          Buf := ExtractEx(Buf, '(', 1, []);
          //Buf := Extract(1, Buf, '(', []);
          if (UpperCase(var02.VarName) = UpperCase(Buf)) and (System.Pos(var02.VarType, 'T5T6') > 0) then begin
            if IsNumber(Buf2[1]) then
              CodeBuf.Add(' ldx #' + Buf2)
            else begin
              CodeBuf.Add(' ldx ' + Buf2);
            end;
            CodeBuf.Add(' mva ' + Buf + _EFF + ',x $c0');
            mValues[i] := '$c0';
          end
          else if (UpperCase(var02.VarName) = UpperCase(Buf)) and (System.Pos(var02.VarType, 'T7T8') > 0) then begin
            if IsNumber(Buf2[1]) then
              CodeBuf.Add(' mva #' + Buf2 + '*2 array_index_' + Buf + _EFF)
            else begin
              CodeBuf.Add(' mva ' + Buf2 + '*2 array_index_' + Buf + _EFF);
            end;
            CodeBuf.Add(' ldy array_index_' + Buf + _EFF);
            CodeBuf.Add(' lda ' + Buf + _EFF + ',y');
            CodeBuf.Add(' sta array_buffer_' + Buf + _EFF);
            CodeBuf.Add(' inc array_index_' + Buf + _EFF);
            CodeBuf.Add(' ldy array_index_' + Buf + _EFF);
            CodeBuf.Add(' lda ' + Buf + _EFF + ',y');
            CodeBuf.Add(' sta array_buffer_' + Buf + _EFF + '+1');
            mValues[i] := 'array_buffer_' + Buf + _EFF;
          end
          else begin
            mValues[i] := Trim(mVal) + _EFF;
          end;
        end;
      end;

      arrOper := TStringList.Create;
      try
        if mVal[1] <> '"' then begin
          // Handle parameters and their operators
          // Check and count oparators contained in paramater value
          for j := 0 to Length(mVal) - 1 do begin
            if (mVal[j] = '+') or (mVal[j] = '-') or (mVal[j] = '*') or (mVal[j] = '/') then begin
              arrOper.Add(mVal[j]);
            end;
          end;
          if arrOper.Count > 0 then begin
            SplitEx2(mVal, '+', '-', '*', '/');
            for j := 0 to arrOper.Count - 1 do begin
              if j = 0 then
                mVal := strbuf2[0] + arrOper[j] + strbuf2[1]
              else begin
                if ParamTypes[i + 1] = '1' then
                  mVal := 'b_param' + IntToStr(i + 1) + arrOper[j] + strbuf2[j + 1]
                else begin
                  mVal := 'w_param' + IntToStr(i + 1) + arrOper[j] + strbuf2[j + 1];
                end;
              end;
              if ParamTypes[i + 1] = '1' then begin
                mValues[i] := 'b_param' + IntToStr(i + 1);
                MathExpr('T1', mValues[i], mVal, 1, 0);
              end
              else begin
                mValues[i] := 'w_param' + IntToStr(i + 1);
                MathExpr('T2', mValues[i], mVal, 1, 0);
              end;
            end;
          end;
        end;
        if not Flag and (arrOper.Count = 0) then begin
          if IsNumber(mVal[1]) then
            mValues[i] := mVal
          else
            mValues[i] := mVal + _EFF;
        end;
      finally
        if Assigned(arrOper) then FreeAndNil(arrOper);
      end;
      if mValues[i][1] = '"' then begin
        if lConv then
          mValues[i] := ExtractText(mValues[i], '"', '"')
        else begin
          if Copy(mValues[i], 3, 1) = '"' then
            mValues[i] := '#' + QuotedStr(mValues[i][2])
          else begin
            SData[Cnt] := StrBuffer + ' .byte ' +
                          //StrBuffer + _EFF + ' .byte ' +
                          QuotedStr(Copy(mValues[i], 2, Length(mValues[i]) - Length(_EFF) - 2)) +
                          ', $9b';
            mLength[i] := Length(mValues[i]) - Length(_EFF) - 2;
            Inc(Cnt);
            mValues[i] := '#' + StrBuffer;
          end;
        end;
      end
      else begin
        if LowerCase(mValues[i]) = 'device' then
          mValues[i] := 'device.devscr';
      end
    end;
  end;

  // Calculate dec/hex convention if necessary
  for i := 0 to paramCount do begin
    if ParamTypes[i + 1] = '2' then begin
      mValues[i] := Channel(mValues[i]);
      isChannel := true;
    end;
  end;

  if isChannel then begin
    if paramCount = 0 then paramCount := 1
  end
  else begin
    Inc(paramCount);
  end;
  //PrgVar.ParamStr := False;
  Result := paramCount;
  StrBuf3.Free;
end;

{------------------------------------------------------------------------------
 Description: Handles Action! PrintF procedure statement
 Parameters : None

format char	description for Action!:
%I	INT
%U	CARD (the U stands for Unsigned) and BYTE
%C	print as a character
%H	Hexadecimal number
%E	the RETURN character
%%	output the percent sign
%S	output as a string

Some examples:
  PrintF("%EA%EB%E")
  PrintF("%EThe sum of %U and %U is %U%E",a,b,a+b
  PrintF("The letter %C.%E",65)
  PrintF("Score %U: %U",player,score(player))

MADS method:
 jsr printf
 dta c'tekst #@%',$9b,0
 dta a(string)
 dta a(float)
 dta a(word)
 -----------------------------------------------------------------------------}
procedure sc_PrintF;
var
  n, n1 : Integer;
  VarxCnt : Integer = 0;
  Str1, Str2 : String;
  varx : Array[0..21] of string[10];
begin
  Str1 := Strip(TextBuf[CurLine], ' ');
  if System.Pos('PRINTF("', UpperCase(Str1)) > 0 then begin
    Str2 := ExtractText(TextBuf[CurLine], '"', '"');
    Str1 := ExtractWord(3, TextBuf[CurLine], ['"']);
    Str1 := ExtractEx(Str1, ',', 2, []);
    Str1 := ExtractEx(Str1, ')', 1, []);
    //Str1 := Extract(2, Str1, ',', []);
    //Str1 := Extract(1, Str1, ')', []);
    Split(Str1, ',', []);

    if StrBuf.Count = 0 then Varx[0] := Str1;

    for n := 0 to StrBuf.Count - 1 do begin
      varx[n] := StrBuf[n];
    end;
    Str2 := StringReplace(Str2, '%%', '_eff_p_eff_', []);
    Split(Str2, '%', [sNoTrim]);
    for n := 0 to StrBuf.Count - 1 do begin
      if n = 0 then begin
        if StrBuf[n] <> '' then begin
          if StrBuf[n] = '_eff_p_eff_' then
            CodeBuf.Add(' put #' + QuotedStr('%'))
          else begin
            StrBuf[n] := StringReplace(StrBuf[n], '_eff_p_eff_', ':', []);
            CodeBuf.Add(' jsr printf');
            CodeBuf.Add(' dta c' + QuotedStr(StrBuf[n]) + ',0');
          end;
        end;
      end
      else if UpperCase(StrBuf[n][1]) = 'E' then begin
        CodeBuf.Add(' PutE');
        Str2 := ExtractEx(StrBuf[n], 'E', 2, [sNoTrim]);
        //Str2 := Extract(2, StrBuf[n], 'E', []);
        if Str2 <> '' then begin
          Str2 := StringReplace(Str2, '_eff_p_eff_', ':', []);
          CodeBuf.Add(' jsr printf');
          CodeBuf.Add(' dta c' + QuotedStr(Str2) + ',0');
        end;
      end
      else if UpperCase(StrBuf[n][1]) = 'I' then begin
        CodeBuf.Add(' jsr printf');
        CodeBuf.Add(' dta c' + QuotedStr('%') + ',0');
        CodeBuf.Add(' dta a(' + Varx[VarxCnt] + _EFF + ')');
        Inc(VarxCnt);
        Str2 := ExtractEx(StrBuf[n], 'I', 2, [sNoTrim]);
        //Str2 := Extract(2, StrBuf[n], 'I', []);
        if Str2 <> '' then begin
          Str2 := StringReplace(Str2, '_eff_p_eff_', ':', []);
          CodeBuf.Add(' jsr printf');
          CodeBuf.Add(' dta c' + QuotedStr(Str2) + ',0');
        end;
      end
      else if UpperCase(StrBuf[n][1]) = 'U' then begin
        for n1 := 1 to GVarCnt do begin
          if (UpperCase(GVar[n1].VarName) = UpperCase(Varx[VarxCnt])) then begin
            // BYTE and CHAR variables
            if (System.Pos(GVar[n1].VarType, 'T1T2') > 0) then begin
              CodeBuf.Add(' mva ' + Varx[VarxCnt] + _EFF + ' $c0');
              CodeBuf.Add(' jsr printf');
              CodeBuf.Add(' dta c' + QuotedStr('%') + ',0');
              CodeBuf.Add(' dta a($c0)');
            end
            // Other variable types
            else begin
              CodeBuf.Add(' jsr printf');
              CodeBuf.Add(' dta c' + QuotedStr('%') + ',0');
              CodeBuf.Add(' dta a(' + Varx[VarxCnt] + _EFF + ')');
            end;
            Inc(VarxCnt);
            Break;
          end;
        end;
        Str2 := ExtractEx(StrBuf[n], 'U', 2, [sNoTrim]);
        //Str2 := Extract(2, StrBuf[n], 'U', []);
        if Str2 <> '' then begin
          Str2 := StringReplace(Str2, '_eff_p_eff_', ':', []);
          CodeBuf.Add(' jsr printf');
          CodeBuf.Add(' dta c' + QuotedStr(Str2) + ',0');
        end;
      end
      else if UpperCase(StrBuf[n][1]) = 'C' then begin
        Str2 := StrBuf[n];
        GetParams('Put(' + VarX[VarxCnt] + ')', False, False, '1');
        Inc(VarxCnt);
        CodeBuf.Add(' Put ' + mValues[0]);
        if mValues[0] <> '' then begin
          Str2 := ExtractEx(Str2, 'C', 2, [sNoTrim]);
          //Str2 := Extract(2, Str2, 'C', []);
          if Str2 <> '' then begin
            Str2 := StringReplace(Str2, '_eff_p_eff_', ':', []);
            CodeBuf.Add(' jsr printf');
            CodeBuf.Add(' dta c' + QuotedStr(Str2) + ',0');
          end;
        end;
      end
      else if UpperCase(StrBuf[n][1]) = 'H' then begin
        CodeBuf.Add(' ShowHex ' + Varx[VarxCnt] + _EFF);
        CodeBuf.Add(' jsr printf');
        CodeBuf.Add(' dta c' + QuotedStr('$000') + ',0');
        CodeBuf.Add(' jsr printf');
        CodeBuf.Add(' dta c' + QuotedStr('#') + ',0');
        CodeBuf.Add(' dta a(hex_num+1)');
        Inc(VarxCnt);
        Str2 := ExtractEx(StrBuf[n], 'H', 2, [sNoTrim]);
        //Str2 := Extract(2, StrBuf[n], 'H', []);
        if Str2 <> '' then begin
          Str2 := StringReplace(Str2, '_eff_p_eff_', ':', []);
          CodeBuf.Add(' jsr printf');
          CodeBuf.Add(' dta c' + QuotedStr(Str2) + ',0');
        end;
      end
      else begin
        if StrBuf[n] <> '' then begin
          StrBuf[n] := StringReplace(StrBuf[n], '_eff_p_eff_', ':', []);
          CodeBuf.Add(' jsr printf');
          CodeBuf.Add(' dta c' + QuotedStr(StrBuf[n]) + ',0');
        end;
      end;
    end;
  end;
end;

function SetRoutine(
  routineName : string; bool01, bool02: boolean; paramStr: string) : boolean;
var
  temp : string;
begin
  result := false;
  temp := Strip(TextBuf[CurLine], ' ');
  if System.Pos(UpperCase(routineName) + '(', UpperCase(temp)) > 0 then begin
    if GetParams(TextBuf[CurLine], bool01, bool02, paramStr) = Length(paramStr) then begin
      result := true;
    end;
  end;
end;

function Atari_CR(isAtariCR : boolean) : string;
begin
  if isAtariCR then
    result := ',$9b'
  else
    result := '';
end;

end.
