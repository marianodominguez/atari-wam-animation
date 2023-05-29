# Structure of the Atari AWM Player

Now that we've covered the origins and history of the AWM Player, let's go into the details of how it works.  The player is really made up of three parts:

1. The compiled TurboBASIC WHAM player program, WHAM.CTB (compiled from WHAM.BAS), which has been renamed AUTORUN.CTB on the disk so that it will run when the Atari is booted.

1. FRAME.BIN, the machine language routine to create the animation frames (by drawing lines from the endpoint data).  FRAME.BIN is called from WHAM.CTB.

1. The eight invididual line-drawing routines (RUG$, RUS$, RDG$, RDS$, LUG$, LUS$, LDG$, and LDS$) that are stored as character strings in WHAM.CTB.  They are called from FRAME.BIN.

In addition to AUTORUN.CTB and FRAME.BIN, the WHAM player disk contains the TurboBASIC runtime module, RUNTIME.COM, which has been renamed AUTORUN.SYS, so that it will run when the Atari is booted,  The disk also contains the standard ATARIDOS files DOS.SYS and DUP.SYS, as well as several AWM files (animations).  I believe the easiest thing is to go through the whole process of playing an animation, following the program execution as it jumps from BASIC to machine language and back, rather than trying to explain the three parts of the program individually.

So, let's start to examine WHAM.BAS, the uncompiled version of WHAM.CTB:

```

10 REM WHAM12.BAS
20 REM WHAM PLAYER WITH FULL FRAME
30 REM ML DRAW ROUTINES
40 DIM AD(8)
50 DIM RDG$(59), RDS$(59)
60 DIM RUG$(59), RUS$(59)
70 DIM LDG$(64), LDS$(64)
80 DIM LUG$(64), LUS$(64)
90 DIM FILE$(20), DAT$(30000)
100 DIM F$(15), BG$(3)

```

Lines 40 though 100 are DIM statements, making room in memory for data and machine language code.  On line 40, AD is an array which will hold the starting addresses of the 8 line-drawing routines.  Lines 50-80 save space for the 8 routines themselves.  You may notice that the 8 routines are not all the same length.  The "R" routines (RDG$, RDS$, etc) which draw left-to-right (X increasing), are 5 bytes shorter than the "L" routines (LDG$, LSD$, etc).  On line 90, FILE$ saves space for the input filename, which includes the drive spec, "D1:".  DAT$ is the 30KB space that is reserved for the animation itself (if you run WHAM.BAS directly from TurboBASIC, without compiling, DAT$ needs to be reduced to about 20KB, or the Atari will run out of memory - the TurboBASIC language takes up 8 to 10KB).  On line 100, F$ is another variable for the input filename, this time without the "D1:".  BG$ is a character variable to hold the "YES" or "NO" answer concerning whether to draw the background in black.

```

110 REM
120 REM RIGHT, DOWN, GENTLE
130 RDG$="jkdsfl$#$#(fl5-fdk;vbk;r42904f,mg.cvsojsedroqw*()#+_@......."
140 AD(0)=ADR(RDG$)
150 REM RIGHT, DOWN, STEEP
160 RDS$="kleortii0324809dfjrwejfglsdf...."
170     :
180     :
190
  :
  :
420 AD(7)=ADR(LUS$)

```

On line 130, the first machine language line-drawing routine, RDG$, is defined as a long string of printable characters, each one representing a byte of the machine language routine (the string shown is just for illustration purposes - to see the actual string you must view it on the Atari, as many of the characters are used only on the Atari).  The string was created by first assembling the machine code (from the assembly language program) with the Atari Assembler/Editor Cartridge and storing it as a BIN file.  Then the following little BASIC program (STRING.BAS) was run:

```

10 REM STRING.BAS
20 BLOAD "D1:RDG12.BIN"
30 FOR J = 0 TO 69
40    PRINT CHR$( PEEK ( 1536 + J ) ) ;
50 NEXT J
60 END

```

Line 20 loads the binary file into memory, starting with location 1536 ($600).  The file name will change as all 8 routines are converted to strings, one by one ( version 12 of the line-drawing routines is used with WHAM12.BAS ).  Lines 30 through 50 loop through the memory locations ( page 6 of memory) and print out a character for each byte.  70 was selected as a number of character to print because it is larger than any of the string lengths.  The extra 6 or 11 null characters were simply deleted after the string was printed.  Then a line number and quotation marks were added, and the whole group of characters was copied and pasted into WHAM.BAS.

Character strings are a well-known way of storing Atari assembly language routines, popular because BASIC automatically finds a safe place in memory to store the routine without the user having to worry about it  The limitation is that the routine has to be relocatable code, meaning that no instructions such as JMP or JSR, which jump to specific memory locations, must be included in the code.  Fortunately, our routines contain only relative branches such as BEQ, and one indirect jump, JMP(), at the end of each of the 8 routines.

Let's return now to WHAM.BAS.  Line 140 defines the first element in the AD array as the starting memory location of the RDG$ character string.  Therefore, it is also the starting location of the memory area where the RDG line-drawing routine will be stored.  So, the 8 elements of the AD array will be used to store the starting locations of the 8 routines.  The main routine, FRAME.BIN, itself stored on Page 6 of memory, will use the elements of the AD array to jump to the 8 routines.

The instructions in lines 130 and 140 are repeated 7 more times up to line 420, defining the character strings for and starting locations of RDS (Right-Down-Steep) through LUS (Left-Up-Steep).

```

430 REM
440 REM SET UP ADDRESS TABLE AT $6E8
450 FOR J=0 TO 7
460 ML1=INT(AD(J)/256)
470 ML0=AD(J)-ML1*256
480 POKE 1768+J*2, ML0
490 POKE 1769+J*2, ML1
500 NEXT J

```

One at a time, the starting address of each line-drawing routine is broken down into two bytes, and the bytes are stored in adjacent memory addresses.  AD(0) is stored in addresses 1768 and 1769 ($6E8 and $6E9), AD(1) is stored in addresses 1770 and 1771 ($6EA and $6EB), and so on up to address 1783 ($6F7).  These will then be used by FRAME.BIN to access the line-drawing routines.

```

510 REM
520 REM SET UP Z-TABLE AT $6F8
530 Z=128
540 FOR K=0 TO 7
550 POKE 1784+K,Z
560 Z=Z/2
570 NEXT K

```

This section sets up a table of 8 values: 128, 64, 32, 16, 8, 4, 2, and 1.  The binary equivalents of these values are:

```

128	10000000
64	01000000
32	00100000
16	00010000
8	00001000
4	00000100
2	00000010
1	00000001

```

These numbers will be used to draw lines!  The 8 line-drawing routines draw lines by lighting the individual pixels in the line.  Since the graphics mode being used, GRAPHICS 22 (GRAPHICS 6 without a text area), has just 2 colors, each pixel has just one bit of screen memory assigned to it.  If the bit is set to 1, the pixel will "turn on" (display the drawing color) and if the bit is 0, the pixel will "turn off" (display the background color).  Of course, individual bits can't be stored by the Atari, so in GRAPHICS 22, a set of 8 consecutive pixels (in a horizontal row) has one byte of screen memory.  When it's time for one of the drawing routines to light a pixel, one of the 8 bytes in the table above is used in the appropriate memory address.  It actually ORed with the byte already in that address, so that none of the 1's already there will be replaced by 0's (which would erase pixels on the screen which had been drawn previously).
This table of values is created in BASIC and stored in memory locations 1784 through 1791 ($6F8 through $6FF) when the player is first started, so that the values don't have to be calculated while the animation is playing, using up valuable CPU time.

```

580 REM PLACE THE CASE ROUTINE RETURN
590 REM ADDRESS INTO "BACK" ($3F,$40)
600 REM THAT ADDRESS IS NOW $6DC
610 BACK=1756
620 B1=INT(BACK/256):B0=BACK-(B1*256)
630 POKE 63,B0:POKE 64,B1

```

When the player is running, the FRAME.BIN machine language routine will call one of the 8 line routines to draw a line.  When that routine is done, it needs return control to FRAME.BIN at a pre-determined memory location.  The group of BASIC statements above stores that memory location (1756 or $6DC) as two bytes in locations 63 and 64 ($3F and $40).  It can then be used by each line-drawing routine in an indirect jump (JMP()) back to FRAME.BIN.

```

640 REM
650 BLOAD "D1:FRAME.BIN"
660 ? "DIRECTORY OF ATARI WHAM MOVIES"
670 ? "             (AWM)"
680 ?
690 DIR "D1:*.AWM"
700 ?
710 ? "TYPE THE NAME OF A MOVIE FILE TO PLAY"
720 ? "  (IT'S NOT NECESSARY TO TYPE .AWM)"
730 PRINT
740 ? "    WHEN FINISHED, PRESS <BREAK>"
750 ? "     TO SELECT ANOTHER, PRESS R"
760 ?

```

Line 650 above does a binary load of FRAME.BIN from the Atari disk drive, storing it starting in memory location $600.  A title is printed on the Atari screen, and TurboBASIC's DIR command is used to display a list of animations (.AWM files) available on the disk.  Then the user is given further instructions.


```

770 PRINT "FILE";:INPUT F$
780 FILE$="D1:":FILE$(4)=F$
790 IF INSTR(FILE$,".AWM")<>0 THEN 810
800 FILE$(LEN(FILE$)+1)=".AWM"
810 ? "DARK BACKGROUND(Y OR N)";:INPUT BG$
820 ? "JIFFIES PER FRAME";:INPUT T
830 PRINT "LOADING DATA..."
840 BLOAD FILE$
850 OPEN #1,4,0,FILE$
860 GET #1,N:GET #1,N
870 GET #1,S0:GET #1,S1
880 BASE=S1*256+S0
890 CLOSE #1

```

This group of BASIC commands prompts the user for the name of the animation to play, then asks whether the user wants a dark background (white lines on a black background rather than black lines on a white background) and asks the speed at which to play each frame of the animation, measured in "jiffies".  A "jiffy" is 1/60 of a second, so if the user wanted to play the animation at 12 frames per second, 5 jiffies would be specified.

Then the animation file is loaded with the BLOAD command.  The BLOAD command was designed in TurboBASIC to load assembly language routines into memory.  The file's first two bytes must be FFFF.  The next two must be the starting memory location where the file is stored, lower byte listed first.  The next two must be the ending memory location of the file, lower byte listed first.  The main file follows these 6 "header bytes".  I found that BLOAD is the fastest way to load an animation into memory at high speed.  BLOAD doesn't care if the loaded file is a machine language routine or animation data, as long as the 6 header bytes are present.

So it's easy to add FFFF to the beginning of the AWM file, but how do you determine the starting memory location?  If you recall, we used DIM DAT$(30000) to reserve a 30KB section of memory for animation data.  If we compile a version of the player which prints out ADR(DAT$), we find that the starting address is 12798, or $31FE.  Therefore, I construct my AWM files with a starting address of $3200.  I guess there's no guarantee that this location would work with different Atari machines, different operating systems, etc. but it's worked for all my animations so far.  The last two header bytes are found simply by adding the size of the animation data to the starting address and subtracting 1.  To summarize, an AWM file that had 12,800 bytes (3200 hex) of data would begin like this:

```

FFFF 0032 FF63

```

with the starting address being $3200 (12800) and the ending address being $63FF (25599).

Getting back to our BASIC listing:


```

840 BLOAD FILE$
850 OPEN #1,4,0,FILE$
860 GET #1,N:GET #1,N
870 GET #1,S0:GET #1,S1
880 BASE=S1*256+S0
890 CLOSE #1

```

After we BLOAD the file, we open it, and start reading bytes.  In line 860, the first two bytes (FF) are read and thrown away.  The next two bytes are stored as BASE, which is our starting address for the data.

```

900 REM
910 REM SET UP 2 SCREENS
920 GRAPHICS 22
930 DL1=PEEK(560)+PEEK(561)*256
940 SC1L=PEEK(DL1+4)
950 SC1H=PEEK(DL1+5)
960 POKE 106,PEEK(106)-16
970 GRAPHICS 22
980 DL2=PEEK(560)+PEEK(561)*256
990 SC2L=PEEK(DL2+4)
1000 SC2H=PEEK(DL2+5)

```

The next instructions are pretty much standard for any Atari BASIC program that does page-flipping.  We'll set up two areas in memory for GRAPHICS 22 screens, and then store their starting locations for future use.  Line 920 sets up the first GRAPHICS 22 screen.  Line 930 finds the starting location of Atari's "Display List" for that screen.  We won't say much now about the Display List now except that bytes 5 and 6 of it contain the starting location of our GRAPHICS 22 screen.  So, lines 940 and 950 save those bytes as SC1L and SC1H (screen 1 low and high bytes).

Line 960 is very important.  Atari memory location 106 is called RAMTOP and it represents the total number of pages (256 byte sections) of free memory that are available.  By subtracting 16 from that value and restoring it in location 106, we fool the Atari into thinking that it has 4KB less memory than it really does (16 * 256 = 4KB).  That way the Atari will allocate 4KB more memory so that we can set up a second GRAPHICS 22 screen (as we do in line 970).  Lines 980-1000 store the starting memory location of the second screen.  Now we have two GRAPHICS 22 screen memory areas to used, and we will be able to execute "page flipping" by drawing on one screen area while we're displaying the other.

Note:  Even though GRAPHICS 22 screens are only about 1920 bytes in size, I have to reserve 16 pages (4KB) for the second screen to make page-flipping work properly.  It turns out that this is because of the way BASIC reserves memory for GRAPHICS 22 screens.  It starts the first screen at 47072 ($B7E0), which is unfortunate.  When you reserve 8 more pages (2KB) for a second screen, the screen starts at 45024 ($AFE0), which means the screen will cross a 4K-boundary at $AFFF.  Programmers are warned to keep graphics screens from crossing 4K boundaries, which cause "garbage" on the screens for some reason.  Reserving a full 4KB (and wasting almost 2KB) seems the only way to keep the second screen away from $AFFF.  I can't seem to get the Atari to put the first GRAPHICS 22 screen anywhere but 47072, and I've tried all sorts of things (changing the number of pages subtracted from location 106, poking values into locations 144, 145 and 741, 742, etc) to get the second screen around the 4KB boundary, but no luck.  Ultimately, I'm stuck with reserving 4KB and wasting 2KB...

```

1010 REM SET EXTEND BYTE TO ZERO
1015 POKE 230,0

```

The "extend byte" (location 230 or $E6) is used to hold the delay value that's read when an FE (Frame Extend) command is encounter in the AWM file.  Here we initialize its value so that no frames are delayed accidentally.

```

1020 COLOR 1
1030 IF BG$="Y" OR BG$="YES" THEN 1060
1040 SETCOLOR 0,0,0:SETCOLOR 4,0,14
1050 GOTO 1070
1060 SETCOLOR 0,0,14:SETCOLOR 4,0,0

```

This section sets line and background colors to black and white respectively, which are reversed if the user answered "YES" to the "DARK BACKGROUND?" prompt earlier.  Color #1 will be used from drawing, which is color register 0 in GRAPHICS 22 mode.  Line 1040 sets register 0 to color black and luminance 0.  It sets register 4 (the background) to color 0 and luminance 14 (maximum), which produces a white color for the background.  Line 1060 does the opposite, setting register 0 to white and register 4 to black.

```

1070 REM POKE DATA PTR INTO $E9 AND $EA
1080 DP=BASE
1090 DP1=INT(DP/256):DP0=DP-(DP1*256)
1100 POKE 231,DP0:POKE 232,DP1
1110 POKE 233,DP0:POKE 234,DP1

```

We got the number for BASE, the starting address of the data, on line 880.  Now we separate it into high and low bytes, and store those bytes in two locations.  The first location is 231, 232 (E7, E8) which is called BASE0, BASE1 and is a permanent record of where the data starts.  The second location is 233, 234 (E9, EA) which is called DATAPT0, DATAPT1 (in FRAME.BIN) and is pointer to the next data byte to be read by FRAME.BIN.

```

1120 REM
1130 REM ANIMATION LOOP
1140 REM
1150 REM
1160 REM SCREEN 1
1170 POKE 20,0
1180 POKE 88,SC1L:POKE 89,SC1H
1190 REM ERASE & DRAW FRAME
1200 A=USR(1536)
1210 REM SHOW
1220 POKE DL2+4,SC1L:POKE DL2+5,SC1H
1230 IF PEEK(20)<T+3*PEEK(207) THEN 1230
1235 POKE 230,0

```

Now we get to the meat of the player, the Main Animation Loop.  Earlier we set up two screen areas.  Now we'll be erasing and drawing on one while we display the other.  We'll start with Screen 1.  Line 1170 initializes Atari's clock.  It will be used as a timer to make sure that each frame lasts the same number of "jiffies" (60ths of a second), the value T that was entered by the user.  Take a look ahead at line 1230.  First, we'll examine a simpler version of that line:

```

1230 IF PEEK(20)<T THEN 1230

```

We're checking the clock again, and the program will stay on this line until T 60ths of a second have passed since line 1170.  For example, if the user had entered 3 for "number of jiffies", then the program will stay on line 1230 until 3/60ths (1/20th) of a second has passed.

Now let's look at line 1230 as it actually is:

```

1230 IF PEEK(20)<T+3*PEEK(230) THEN 1230

```

An additional factor has been added.  Location 230 ($E6) is called (in FRAME.BIN) "XTND" for "extend value".  When FRAME.BIN encounters an FE code (meaning extend or delay the previous frame) it reads the number immediately following the FE.  That number is then put into location 230 and when control is returned to the BASIC program (WHAM.CTB), line 1230 is executed and the frame is delayed by 3 times the value of location 230.  The number 3 was chosen as a multiplier to mimic the delay which would occur in the PC version of the animations.  In PC WAM animations, the number after the FE represents the number of frames delayed (in 18ths of a second, since PC animations are played at 18 FPS).  So 3/60ths of a second is closest to 1/18th.

Anyway, following line 1230 is:

```

1235 POKE 230,0

```

We're simply initializing the extend value again.  Once it's been used for a frame, we have to make sure that it disappears until the next FE command is encountered.




Okay, now that we've covered the first and last lines of the section, let's look at the middle:

```

1180 POKE 88,SC1L:POKE 89,SC1H
1190 REM ERASE & DRAW FRAME
1200 A=USR(1536)
1210 REM SHOW
1220 POKE DL2+4,SC1L:POKE DL2+5,SC1H

```

Atari locations 88 and 89 hold the starting address of the screen which will be used for drawing.  On line 1180, we store the starting address of SCREEN 1 in those locations.  Line 1200 transfers control to FRAME.BIN, starting at location 1536 ($600).  Before we discuss FRAME.BIN, let's finish with line 1220.  It is the line which displays the finished frame, by POKEing SCREEN1's starting address into the 4th and 5th bytes of Atari's display list.  These locations determine which memory area is being SHOWN on the computer screen, as opposed to locations 88 and 89, which determine which memory area is being DRAWN ON.

## Finishing Up BASIC

I know I promised that we'd get to FRAME.BIN next, but let's finish up the last little bit of WHAM.CTB, since it's just a duplication of what's come before:

```

1240 REM
1250 REM SCREEN 2
1260 POKE 20,0
1270 POKE 88,SC2L:POKE 89,SC2H
1280 REM ERASE & DRAW FRAME
1290 A=USR(1536)
1300 REM SHOW
1310 POKE DL2+4,SC2L:POKE DL2+5,SC2H
1320 IF PEEK(20)<T+3*PEEK(230) THEN 1320
1330 REM
1340 GOTO 1130

```

This section just does the same thing for SCREEN2 as the previous section did for SCREEN1.  It sets the timer, finds the start of SCREEN2, and executes FRAME.BIN, the erase-and-draw routine.  All this time, SCREEN1 is being displayed, so the viewer sees not lines being drawn or even any flicker.  In line 1310, SCREEN2 is displayed, and line 1320 adds any necessary delay.  Line 1340 takes us back to the start of the animation loop, so we can do it all again.

Okay, now we'll go through the machine language listing of the frame-drawing routine, FRAME.BIN.  As I explain its execution sequence, I'll be jumping around a bit, so the line numbers may seem out of sequence.  FRAME.BIN contains 3 subroutines – DATLOAD (lines 590-640), EXTEND (lines 660-690), and RESTART (lines 710-770).

