# Effectus 0.4.1

This is a new version of Effectus, done from scratch. This is a new branch version, currently for Windows and MacOS platforms. Other platforms will be supported when vital parts of the program will be more stable.

The most important thing to consider was properly handling of Action! statements (declarations,
commands, assignments...) and multi-line support.

The next most important change is the way code is generated. I took Mad Pascal as the basis for
generating source code listings, which are further compiled to binary code with Mad Assembler
(Mads). Many thanks to **Tomasz Biela** (Tebe), author of these great tools. He made this all possible!

Many thanks also to all others helping me with porting to other platforms, suggestions,
testing and supporting the project in any way.

The steps are as follows:
- Action! code is parsed and appropriate Mad Pascal source code listing is generated
- Mad Pascal compiles this code to *.a65 file prepared for compilation by Mad Assembler
- Mad Assembler compiles *.a65 file to final binary code (*.xex)

examples directory includes test examples, which can be basis for your further development and
experimentation.

## What is supported?

### Data types

```BYTE, CHAR, INT, CARD```

### Extended data type

``BYTE ARRAY, CARD ARRAY, POINTER``\
``SBYTE ARRAY`` as temporary solution for ``BYTE ARRAY`` string definitions

- Variable memory address assignment

  Examples: ``BYTE CH=764, COL=710, BYTE GRACTL=$D01D``

- TYPE declaration
  
  ```
  TYPE REC = [
    BYTE day, month CARD year
    BYTE height
  ]
  ```

- Declaring array variables pointing to memory address
  
  ```
  BYTE ARRAY arrD=28000
  CARD ARRAY arr=$8000
  ```

### DEFINE declaration (constant substitutions for any statement)

### Conditions and branches

- ``IF/THEN/ELSE``, ``FOR``, ``WHILE``, ``UNTIL`` branches
- infinite loop ``DO OD``
- ``EXIT`` statement to force exit from the branch

### Graphics

PROCedures: ``GRAPHICS``, ``PLOT``, ``DRAWTO``, ``FILL``, ``LOCATE``\
Global variable Color for setting the color to draw on screen

### Sound

PROCedures: ``SOUND, SNDRST``

### String manipulation

PROCedures:
  ``STRB``, ``STRC``, ``STRI``, ``SCOPY``, ``SCOPYS``, ``SASSIGN``, ``INPUTS``,
  ``PRINT``, ``PRINTE``, ``PRINTB``, ``PRINTBE``, ``PRINTI``, ``PRINTIE``, ``PRINTC``, ``PRINTCE``, ``PRINTF``, ``PUT``, ``PUTE``


FUNCtions:
  ``GETD``, ``INPUTB``, ``INPUTC``, ``INPUTI``, ``SCOMPARE``, ``VALB``, ``VALC``, ``VALI``

### Arithmetic manipulation

### Bitwise manipulation

Bitwise/logical operators: ``AND (&)``, ``OR (%)``, ``XOR (!)``, ``LSH`` (left shift), ``RSH`` (right shift)

### Data manipulation

PROCedures:
  ``ZERO, SETBLOCK, MOVEBLOCK``

### Device I/O support

PROCedures:
  ``OPEN``, ``CLOSE``, ``PRINTD``, ``PRINTDE``, ``PRINTBD``, ``PRINTBDE``, ``PRINTCD``, ``PRINTCDE``, ``PRINTID``, ``PRINTIDE``
  ``INPUTSD``, ``INPUTMD``

FUNCtions:  
  ``INPUTBD, INPUTCD, INPUTID``

- ``EOF`` (end of line) variable supported in ``IF``, ``WHILE`` and ``UNTIL`` branch conditions
- Printing to text modes by using PrintD and PrintDE is allowed

Inline machine language
-----------------------

- Support for inline machine language directly in the body of code listing

  Examples:
  ```
    [$A9$21$8D$02C6$0$60]
    [
      $A9$90
      $3E$02C6 $0 $60
    ]
  ```

- PROCedure machine language support
- FUNCtion machine language support

  Example:

  ```
  PROC TEST=*(BYTE CURSOR,BACK,BORDER,X,Y,UPDOWN)
  [
    $8E 710  ; BACKGROUND COLOR
    $8C 712  ; BORDER COLOR
    $8D 752  ; CURSOR VISIBILITY 
    $A5 $A5 $8D 755  ; CHARACTERS UPSIDE DOWN? 
    $A5 $A3 $8D 85 0  ; COLUMN FOR TEXT
    $A5 $A4 $8D 84 0  ; ROW FOR TEXT
    $60]
  ```

### System manipulation

PROCedures:
  ``POKE``, ``POKEC``

PROCedures:
  ``PEEK``, ``PEEKC``

### Misc

- Additional PROCedures: ``POSITION``, ``SETCOLOR``
- Aditional FUNCtions: ``RAND``, ``STICK``, ``STRIG``, ``Paddle``, ``PTrig``
- Custom PROCedures and FUNCtions are supported
  (parameters can be mixture of any scalar data type: ``BYTE``, ``CARD``, ``INT``, ``CHAR``)
- Memory address calls through PROCedures are supported (OS calls can be accomplished)

  Examples:
  ```
  ; Scroll screen
  PROC SCROLL=$F7F7()
  ; Cassette-beep sound
  PROC BEEPWAIT=$FDFC(BYTE times)
  ```

## Effectus directory structure

- root directory: effectus.exe, LICENSE-mads-mp, readme.txt, test.bat, del.bat
- /examples: Action!/Effectus examples
- /base: Mad Assembler library directory
- /lib: Mad Pascal library directory

## Command prompt execution

```
effectus <filename> <parameters>
```

Available options:\
  _-i  program information about variables and custom PROCedures_\
  _-o: object code extension_\
  _-c  clear summarized log file_

- Effectus/Action! source code listing can reside on any path and resulting code
  is also generated there

- Log files are created on compile time

## What is missing?

Many things! But new features will eventually pop in.

Not yet supported:
  - ``INCLUDE`` files
  - No proper error handling is done yet, so it happens that no errors show on the screen even if
    something went wrong

## Wierd stuff

- ``BYTE ARRAY`` definition for using as string holder must be declared as ``SBYTE ARRAY``

## Bugs

- Nested branches do not work correctly in some cases
- Declaring variables allows freedom, but some considerations must be taken. For example,
  proper syntax is:

  ```
  byte array ndl=[112 112 112 66 64 156 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 86 216 159 65 32 156]
  ```

  and NOT like this:

  ```
  byte array ndl=
    [112 112 112 66 64 156 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 86 216 159 65 32 156]
  ```

- ``TYPE`` declaration can be achieved in this manner:

  ```
  TYPE REC = [
    BYTE day, month CARD year
    BYTE height
  ]
  ```
  
  or
  
  ```
  TYPE REC =
  [
    BYTE day, month CARD year
    BYTE height
  ]
  ```
  
  but NOT like this:

  ```
  TYPE REC = [BYTE day, month CARD year
              BYTE height]
  ```

All this will be fixed at some point!


Written by **Bostjan Gorisek** from Slovenia
Page URLs: 
- http://gury.atari8.info/effectus/
- http://freeweb.siol.net/diomedes/effectus/
- https://github.com/mariusz-buk/effectus

Mad Pascal and MAD Assembler (MADS) are products written by **Tomasz Biela** (Tebe) from Poland\
Page URL: http://mads.atari8.info/
