=================================================================
Effectus - Atari MADS cross-assembler/parser for Action! language
=================================================================

Description
-----------

The goal of Effectus project is to make it as compatible with Action! programming
language as possible. The name Effectus comes from Latin word for "execution".
Effectus compiles and produces MADS assembly language listing and binary files
for execution on real 8-bit Atari or emulation software on PC.

Mad Assembler (MADS) is integrated directly into Effectus program starting from
version 0.3, so there is no need to call MADS externally. The version of MADS
cross-compiler source code used is 2.0.8. Generated assembly language listing can
be further edited by you if necessary. You can configure Effectus with several
parameters by typing them in command prompt shell or by using config.ini file,
which can be edited.

You can check for Effectus examples in \examples directory. Runtime and supporting
libraries are contained in \lib directory. The libraries and their implementation
can be changed, but keep in mind that the number and order of parameters should
not be changed to ensure the proper functioning of Effectus application. It is
advisable to keep config.ini configuration file in the same directory as Effectus
binary, but if not, default configuration settings apply.

With this project, maintaining the compatibility with Action! language will be of
HIGH priority.

Home of Effectus is at http://gury.atari8.info/effectus/


Credits
-------

I have to thank everybody who helped me with support and suggestions, especially
the author of MADS, "Tebe", who helped me with many important suggestions to
improve the code and "greblus" for compiling Effectus for Linux
platform and making many tests with many suggestions, too.

Special thanks go also to other people (mainly from AtariAge and atarionline.pl
forums) for the additional help by testing and finding bugs in Effectus, plus
providing new test examples: Cosi, w1k, Kaz, ascrnet, dwhyte, devwebcl, twh/f2,
TXG/MNX and all others not listed here.


Installation
------------

Program and its dependencies are archived in ZIP file. Extract (unzip) the files
in directory of your choice. It is recommended to put config.ini file in the same
directory as Effectus binary, but if not, the proper parameter values must be set
as mentioned above. To run Effectus, type effectus in command prompt shell
following the Effectus source code listing file with properly qualified pathname
and optional parameters.


Program usage
-------------

- win32 platform: effectus <filename> <parameters>

Program parameters: 

-a:address    Program starting address
-e:extension  Source code extension
-o:extension  Binary file extension
-r:path       Effectus runtime library directory
-l:path       Log filename (full pathname)
-m:address    Machine language starting address
-c            Clear log file
-i            Effectus variable usage list
-n:value      Maximum number of ARRAY elements


Effectus source code information
--------------------------------

Effectus is compiled with Free Pascal Compiler version 3.0.4. Source code is
available in src directory, including six files:

- effectus.pas
  (Main module calling all other components and showing all avaiable parameters)
- decl.pas
  (Variable declarations, constants, initializations...)
- common.pas
  (Common library with methods used in other units)
- core.pas
  (Core unit implementing the core functioning of Effectus parsing Action! code)
- routines.pas
  (Unit library implementing all supported Action! procedures and functions)
- inifiles.pas
  (Unit library with support for reading and writing INI files)
- mads_unit.pas
  (Firepower unit which runs it all... Tebe's Mad Assembler integrated in Effectus)

Effectus binary is produced by typing this command in command prompt shell:

c:\lazarus\fpc\3.0.4\bin\i386-win32\fpc -Mdelphi -vh -O3 effectus.pas
(or any other destination where your copy of Free Pascal resides)

Parameters may vary, but additional tests are necessary to be sure Effectus
would work as expected.

Enjoy using Effectus!

Bostjan Gorisek (Gury)
