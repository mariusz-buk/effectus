==================
  Effectus 0.5.1
==================

This is new version of Effectus, done from scratch. This is new branch version, currently only
for Windows platform. Other platforms will be supported when vital parts of the program will be
more stable.

The most important thing to consider was properly handling of Action! statements (declarations,
commands, assignments...) and multi-line support.

The next most important change is the way code is generated. I took Mad Pascal as the basis for
generating source code listings, which are further compiled to binary code with Mad Assembler
(Mads). Many thanks to Tomasz Biela (Tebe), author of these great tools. He made this all possible!

Many thanks also to all others helping me with porting to other platforms, suggestions,
testing and supporting the project in any way.

The steps are as follows:
- Action! code is parsed and appropriate Mad Pascal source code listing is generated
- Mad Pascal compiles this code to *.a65 file prepared for compilation by Mad Assembler
- Mad Assembler compiles *.a65 file to final binary code (*.xex)

examples directory includes test examples, which can be basis for your further development and
experimentation.

------------------
What is supported?
------------------

Data types
----------

BYTE, CHAR, INT, CARD

Extended data type
------------------

BYTE ARRAY, CARD ARRAY, POINTER
SBYTE ARRAY as temporary solution for BYTE ARRAY string definitions

- Variable memory address assignment

  Examples:
  BYTE CH=764, COL=710, BYTE GRACTL=$D01D

- TYPE declaration

  TYPE REC = [
    BYTE day, month CARD year
    BYTE height
  ]

- Declaring array variables pointing to memory address

  BYTE ARRAY arrD=28000
  CARD ARRAY arr=$8000

DEFINE declaration (constant substitutions for any statement)
------------------

Conditions and branches
-----------------------

- IF/THEN/ELSE, FOR, WHILE, UNTIL branches
- infinite loop DO OD
- EXIT statement to force exit from the branch

Graphics
--------

PROCedures: GRAPHICS, PLOT, DRAWTO, FILL, LOCATE
Global variable Color for setting the color to draw on screen

Sound
-----

PROCedures: SOUND, SNDRST

INCLUDE files
-------------

Files can be included, starting in the same directory as main compiled listing code.
Currently one level of included files is supported. This means only main listing program can read
files with INCLUDE directive, but not any other files, even if they have this directive called in.

String manipulation
-------------------

PROCedures:
  STRB, STRC, STRI, SCOPY, SCOPYS, SASSIGN, INPUTS,
  PRINT, PRINTE, PRINTB, PRINTBE, PRINTI, PRINTIE, PRINTC, PRINTCE, PRINTF, PUT, PUTE

FUNCtions:
  GETD, INPUTB, INPUTC, INPUTI, SCOMPARE, VALB, VALC, VALI

Arithmetic manipulation
-----------------------

Bitwise manipulation
--------------------

Bitwise/logical operators: AND (&), OR (%), XOR (!), LSH (left shift), RSH (right shift)

Data manipulation
-----------------

PROCedures:
  ZERO, SETBLOCK, MOVEBLOCK

Device I/O support
------------------

PROCedures:
  OPEN, CLOSE, PUTD, PUTDE, PRINTD, PRINTDE, XIO,
  PRINTBD, PRINTBDE, PRINTCD, PRINTCDE, PRINTID, PRINTIDE,
  INPUTSD, INPUTMD

FUNCtions:
  INPUTBD, INPUTCD, INPUTID

- Printing to text modes by using PrintD and PrintDE is allowed

Inline machine language
-----------------------

- Support for inline machine language anywhere in the body of code listing (after variable
  declaration)

  Examples:
    [$A9$21$8D$02C6$0$60]
    [
      $A9$90
      $3E$02C6 $0 $60
    ]

- PROCedure machine language support
- FUNCtion machine language support

  Example:

  PROC TEST=*(BYTE CURSOR,BACK,BORDER,X,Y,UPDOWN)
  [
    $8E 710  ; BACKGROUND COLOR
    $8C 712  ; BORDER COLOR
    $8D 752  ; CURSOR VISIBILITY
    $A5 $A5 $8D 755  ; CHARACTERS UPSIDE DOWN?
    $A5 $A3 $8D 85 0  ; COLUMN FOR TEXT
    $A5 $A4 $8D 84 0  ; ROW FOR TEXT
    $60]
    
You can send parameters to machine language routines. The compiler stores parameters using
A, X and Y registers, then zero-page addresses from $A3 to $AF are used.

Address      nth byte of parameters
-------      -----------------------
 A register   1st
 X register   2nd
 Y register   3rd
 $A3          4th
 $A4          5th
 :            :
 :            :
 $AF          16th

System manipulation
-------------------

PROCedures:
  POKE, POKEC

PROCedures:
  PEEK, PEEKC

Misc
----

- Additional PROCedures: POSITION, SETCOLOR
- Aditional FUNCtions: RAND, STICK, STRIG, Paddle, PTrig
- Custom PROCedures and FUNCtions are supported
  (parameters can be mixture of any scalar data type: BYTE, CARD, INT, CHAR)
- Memory address calls through PROCedures are supported (OS calls can be accomplished)

  Examples:
  ; Scroll screen
  PROC SCROLL=$F7F7()
  ; Cassette-beep sound
  PROC BEEPWAIT=$FDFC(BYTE times)

Effectus directory structure
----------------------------

- root directory: program executables, license documents and other supporting files
- examples: Action!/Effectus examples
- base: Mad Assembler library directory
- lib: Mad Pascal library directory

Command prompt execution
------------------------

effectus <filename> <parameters>

Available options:
  -i   Information about declared variables, PROCedures, FUNCtions and DEFINE constants
  -o:  Binary file extension
  -c   Clear summarized log file
  -t   Effectus only translate source to Mad Pascal
  -z   Variable zero page address
  -zb  BYTE variable zero page address
  -zw  CARD (word) variable zero page address
  -zp  Pointer (PByte) zero page address

- Effectus/Action! source code listing can reside on any path and resulting code
  is also generated there

- Log files are created on compile time

Missing features and bug issues
-------------------------------

You can read about missing features and bug issues in additional file dev_log.txt!

-------------------------------------------------------------------------------

Written by Bostjan Gorisek from Slovenia
References:
  https://github.com/mariusz-buk/effectus
  http://freeweb.siol.net/diomedes/effectus/

Mad Pascal and MAD Assembler (MADS) are products written by Tomasz Biela (Tebe) from Poland
References:
  http://mads.atari8.info/
  https://github.com/tebe6502/Mad-Pascal
  https://github.com/tebe6502/Mad-Assembler
