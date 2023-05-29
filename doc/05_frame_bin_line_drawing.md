# FRAME.BIN

```

0080 ;FRAME12.SRC
0090 ;
0100 ;EQUATES
0110 X1=$CB;     	203
0120 Y1=$CC;     	204
0130 X2=$CD;     	205
0140 Y2=$CE;     	206
0150 TOP=$CF;      	207
0160 DX=$D0;     	208
0170 DY=$D1;     	209
0180 PIXZ=$DB;   	219
0190 PIXLO=$DC;  	220
0200 PIXHI=$DD;  	221
0210 YX4LO=$DE;  222
0220 YX4HI=$DF;  	223
0230 JUMP0=$3D;   61
0240 JUMP1=$3E;   62
0250 BACK0=$3F;   63
0260 BACK1=$40;   64
0270 XTND=$E6;    	230
0280 BASE0=$E7;  	231
0290 BASE1=$E8;  	232
0300 DATPT0=$E9; 233
0310 DATPT1=$EA; 234
0320 TIMER=$EB;  	235
0330 ;

```

This is a list of the 22 variables I use in FRAME.BIN, and in the 8 line routines.  They are all Page 0 locations, which saves save time (and space) by allowing the use smaller ML (machine language) instructions.  It was quite a chore to find 22 Page 0 addresses that weren't being used by the Atari operating system, but it was worthwhile nevertheless.


```

0340  *=$600
0350  PLA
0360  LDY #0
0370 ;
0380 ;    CLEAR THE SCREEN
0390  LDA 89
0400  STA PIXHI
0410  CLC
0420  ADC #8
0430  STA TOP
0440  LDA 88
0450  STA PIXLO
0460 SLOOP LDA #0
0470 CLOOP STA (PIXLO),Y
0480  INY
0490  BNE CLOOP
0500  INC PIXHI
0510  LDA PIXHI
0520  CMP TOP
0530  BNE SLOOP
0540  JMP NEWDRAW

```

Line 340 identifies that the routine starts at location 600.  Line 350 is the standard instruction at the start of every ML routine coming from BASIC, clearing the memory "stack" by throwing away the stack's top byte (the return address to get back to BASIC, which is no longer needed).   Line 360 clears the Y-register so that it can be used in the upcoming loop.

Now we come to the clear routine itself.  8 pages (2KB) of zeros will be written to the screen area, before we can start drawing.  Lines 390 and 400 store the high byte of the screen's starting address (location 89) into PIXHI, the high byte of our pixel counter.  Lines 410 through 430 add 8 pages to PIXHI and store this number into TOP, which will tell us when we're done clearing.  Then the screen address low byte is recovered from location 88 and stored in PIXLO.

Now we can start our loop.  Zero is put into the accumulator, and in line 470, it is stored in consecutive memory locations starting with PIXHI, PIXLO.  The locations are incremented using the Y-register.  In line 490, if Y=0 then PIXHI is incremented and compared to the TOP value to see if the clearing is complete.  PIXLO is never incremented in this routine - it doesn't need to be because the Y-register takes care of all the single-byte counting.  I'd originally used PIXLO to do that, but it took an extra byte (INC PIXLO is 3 bytes and INY is only 2) and also required that I clear 9 pages (420 ADC #9) instead of 8.  The reason for that?  I'll leave it as an "exercise for the reader".  When the clearing is done (PIXHI=TOP) the routine jumps ahead to NEWDRAW.

```

0820 NEWDRAW
0830  JSR DATLOAD
0840  STA Y1
0850  JSR DATLOAD
0860  STA X1

```

This little section simply uses the DATLOAD subroutine to save the next two bytes in the AWM file as Y and X-coordinates (remember, Y is listed first in the file).  Since we've just started a new frame, and we haven't yet reached the section that checks for the four instruction codes (FA, FC, FD, or FE), we can assume that a frame is never allowed to start with an instruction code.  It must always start with a Y-coordinate.

```

0590 DATLOAD
0600  LDA (DATPT0),Y; LOAD DATA
0610  INC DATPT0
0620  BNE SAMEBYTE
0630  INC DATPT1
0640 SAMEBYTE RTS; BACK TO MAIN LOOP

```

This is the DATLOAD subroutine.  It is a real subroutine (not just a short section like NEWDRAW) because it has an RTS instruction at the end.  Our data pointer (DATPT0, DATPT1) was loaded with the starting address of the animation data, back in line 1110 of the BASIC program.  Here in line 600, the next byte of data is loaded into the accumulator.  The Y-register in this case is not used as the low-byte data pointer, since that would interfere with its use in other areas (such as the clearing routine).  The register was left at zero at the end of the clearing routine, so it won't be initialized here, which saves a couple of bytes. (Might be a bad programming practice, but I'm hurting for memory space).  Anyway, DATPT0 is incremented (and DATPT1 if necessary) and we return to the main loop...

```

0870 ;
0880 DLOOP
0890 ;  YCODE ROUTINE
0900  JSR DATLOAD
0910  CMP #253: FD
0920  BEQ NEWDRAW
0930  CMP #252; FC
0940  BEQ FRAMEDONE;  BACK TO BASIC
0950  CMP #254; FE
0960  BEQ EXTEND
0970  CMP #250; FA
0980  BEQ RESTART
0990  STA Y2
1000  JSR DATLOAD
1010  STA X2

```

We've previously stored the first pair of line coordinates (X1, Y1).  Now we're going to pull the next data byte and determine whether it's a control code or a Y-coordinate.  If the byte is FD (Finished Drawing), we'll go back to NEWDRAW (where we were before) to get a new set of X1,Y1 coordinates.  Since currently this is only the third byte read we've read, it should be evident that it's useless to have just two coordinates followed by an FD code (nothing is drawn).  Lines 930 and 940 send control back to BASIC if an FC (Frame Completed) coded is encountered.  Again, we wouldn't expect that now, since this is only our third byte of data.  Lines 950 and 960 detect an FE code (Frame Extended) as send us to the EXTEND subroutine:

```

0660 EXTEND
0670  JSR DATLOAD
0680  STA XTND
0690  RTS; BACK TO BASIC

```

EXTEND is NOT a subroutine!  The RTS at the end returns us back to BASIC to display the frame (just like FC).  Before we go, though, the next byte of animation data is loaded.  The byte after FE is the number of frame-durations to delay the current frame (for the Atari player, 20ths of a second).  We call this byte XTND, and it gets stored in location 230 ($E6) to be pulled out by the BASIC program in line 1230 or 1320, as we covered earlier.  Okay, let's get back to what we were doing before:

```

0970  CMP #250; FA
0980  BEQ RESTART
```

If our byte is FA, we jump to the RESTART subroutine:

```

0710 RESTART
0720  LDA BASE0
0730  STA DATPT0
0740  LDA BASE1
0750  STA DATPT1
0760 ;
0770 FRAMEDONE RTS; BACK TO BASIC

```

Our pointers to the animation data, DATPT0 and DATPT1, are set back to the start of the file (BASE0 and BASE1) and we jump back to BASIC to display the last frame and start the animation over.

```

0990  STA Y2
1000  JSR DATLOAD
1010  STA X2

```

These last three lines execute if our byte is not a control code (so it must be a Y-coordinate).  It is stored as the Y2, and the next byte is retrieved and stored as X2.  Now we have (X1,Y1) and (X2,Y2) and we're ready to draw a line...


## LINE DRAWING

This next section is the nuts-and-bolts of our line drawing, and things will get a bit more "hairy".  All the organizing and setup is done, and now I'll show you how I:

1. Turn the X- and Y- coordinates into actual GRAPHICS 22 pixel locations
2. Select one of 8 line-drawing routines which use Bresenham's algorithm, a great little method which is perfectly suited to 8-bit machine language.
3. Execute the appropriate routine and "light the pixels" to create a straight line.
4. Return control back to FRAME.BIN, so that it can continue to the next line.
Okay, here we go.  This is the next section of FRAME.BIN:

```

1020 ;
1030 ; FIND THE PIXEL LOCATION
1040 ;
1050 ;  CALCULATE PIXZ USING TABLE
1060  LDA X1
1070  AND #7
1080  TAX
1090  LDA $6F8,X
1100  STA PIXZ

```

Back when we were discussing lines 510-570 of the BASIC program, we created a little table with the values 128, 64, 32, etc. which would be used to determine which pixel to light from the row of 8 pixels associated with each byte of screen memory.  Lines 1050 through 1110 above use our first X-coordinate (X1) to determine which value of the table will to light the first pixel.  On lines 1060 and 1070, X1 is ANDed with 7 (00000111) to strip off everything but the last 3 binary digits.  We then have a number 0 thru 7, which can be loaded into the X-register and used as an offset to find the correct value from the table.  We call this value PIXZ, and it's the byte that will be anded with the contents of the correct memory location in order to light the pixel.  Now let's find that memory location.

```

1110 ;  FIND THE ROW (Y-COORD X 20)
1120  LDA Y1
1130  LSR A
1140  LSR A
1150  LSR A
1160  LSR A
1170  STA PIXHI
1180  LSR A
1190  LSR A
1200  STA YX4HI
1210  LDA Y1
1220  ASL A
1230  ASL A
1240  STA YX4LO
1250  ASL A
1260  ASL A
1270  CLC
1280  ADC YX4LO
1290  STA PIXLO
1300  LDA PIXHI
1310  ADC YX4HI
1320  STA PIXHI

```

Finding the 2-byte pixel location means multiplying Y1 by 20 (since there are 20 memory bytes for each row) and dividing  X1 by 8 (8 pixels per byte) and then adding the two totals.  This will be an offset.  The final location will be found by adding this offset to the start of screen memory found in locations 88 and 89 ($58 and $59).

The 21 instructions in the section above (lines 1120 through 1320) are JUST to multiply Y1 by 20!  It may be a little hard to follow, but I've found that this sequence of instructions is the fastest way to execute the multiplication.  We will multiply Y1 by 16 and then multiply it by 4 and then add the two numbers together.  Remember, Y1 is 2 bytes that are treated as a single number (16 bits).

Here we go.  Multiplying Y1 by 16 is like shifting its 16 bits to the left 4 times.  The 4 highest bits of the low byte are moved into the high byte.  Lines 1120 thru 1170 perform an equivalent operation by shifting Y1 to the RIGHT 4 times and storing the result in the high byte (PIXHI).  Lines 1180 thru 1200 shift this number to the right 2 more times and store it as YX4HI.  This is the high byte of Y1 times 4, which will be added in later.

Lines 1210 thru 1240 reload Y1 and shift its bits to the LEFT 2 times, multiplying it by 4.  This number is stored in YX4LO.  We're not worried about losing digits to the left, since we've already taken care of the high-byte digits.  In lines 1250 and 1260 we again shift left 2 times, leaving the low byte of Y1 times 16 in the accumulator.  In line 1270 the carry bit is cleared (in case it was set by our left-shifts) so that it's doesn't mess up the addition that follows.  YX4LO is added to the accumulator and the final result is stored in PIXLO.  If this addition sets the carry bit, then it is used in the next addition between PIXHI and XY4HI.  PIXHI is then stored on line 1320.  The two-byte number PIXHI, PIXLO is Y1 multiplied by 20.

```

1330 ;  FIND THE BYTE (X-COORD / 8)
1340  LDA X1
1350  LSR A
1360  LSR A
1370  LSR A
1380  CLC
1390  ADC PIXLO
1400  STA PIXLO
1410  BCC NOCARRY
1420  INC PIXHI
1430 NOCARRY CLC
1440  LDA $58
1450  ADC PIXLO
1460  STA PIXLO
1470  LDA $59
1480  ADC PIXHI
1490  STA PIXHI

```

This section simply divides X1 by 8 (much easier than multiplying by 20), and adds it to PIXLO, performing the carry to PIXHI if necessary.  This creates the PIXLO, PIXHI offset.  This number is then added to the start of screen memory ($58, $59) with any carry automatically calculated.  The final PIXLO, PIXHI result is the memory location of the pixel to be lit.

We finally have the byte identified.  However, the pixel won't actually be lit until we get to one of the line-drawing routines.

```

1500 ;
1510 ;    SELECT A LINE ROUTINE
1520  LDX #0
1530  LDA X2
1540  SEC
1550  SBC X1
1560  BCS RIGHT
1570 ;
1580  LDX #4
1590  LDA X1
1600  SEC
1610  SBC X2
1620 RIGHT STA DX
1630 ;
1640  LDA Y2
1650  SEC
1660  SBC Y1
1670  BCS DOWN
1680 ;
1690  INX
1700  INX
1710  LDA Y1
1720  SEC
1730  SBC Y2
1740 DOWN STA DY
1750 ;
1760  LDA DX
1770  SEC
1780  SBC DY
1790  BCS GENTLE
1800  INX
1810 GENTLE TXA
1820  ASL A; MULTIPLY BY 2
1830  TAX
1840  LDA $6E8,X
1850  STA JUMP0
1860  LDA $6E9,X
1870  STA JUMP1

```

The section above is a long one, but I think it should be analyzed all in one piece.  It selects 1 of the 8 line-drawing routines, based on the X1,Y1 and X2,Y2 coordinates we have for the line.  Early on in this document, we defined the 8 routines:

- Right Down Gentle (RDG) - DX and DY both pos, DX > DY
- Right Down Steep (RDS) - DX and DY both pos, DY > DX
- Right Up Gentle (RUG) - DX positive and DY neg, DX > |DY|
- Right Up Steep (RUS) - DX positive and DY neg, |DY| > DX

- Left Down Gentle (LDG) - DX negative and DY positive, |DX| > DY
- Left Down Steep (LDS) - DX negative and DY positive, DY > |DX|
- Left Up Gentle (LUG) - DX and DY both negative, |DX| > |DY|
- Left Up Steep (LUS) - DX and DY both negative, |DY| > |DX|


In lines 440 thru 500 of our BASIC program, we had set up a table, starting at location 1768 ($6E8), of the starting memory addresses of the routines.  For example, the memory address stored in $6E9, $6E8 is the starting address of RDG, the memory address in $6EB, $6EA is the starting address of RDS, etc.  The SELECT section that we are now analyzing will use that table to create a 0-7 offset.  This will then be doubled so that it can be added to $6E8 and $6E9 to locate the appropriate routine.  We will treat the offset like a 3-bit number (000 to 111).  It will start at 000, and we will add a one (like a flag) at one of the three positions if certain conditions are met.  Here are the conditions:

If DX (X2 minus X1) is negative, add 100 (4) to the offset.
The line is being drawn LEFT (right-to-left)
If DY (Y2 minus Y1) is negative, add 010 (2) to the offset.
The line is being drawn UP (remember, Y-coords increase going down)

If  |DX| minus |DY| is negative (the abs. value of DX is less than the abs. value of DY), add 001 (1) to the offset.
The line is STEEP (rather than GENTLE)

You can see that the above conditions will give the 8 cases the following offsets:

```

RDG - 000  RDS - 001  RUG - 010  RUS - 011
LDG - 100  LDS - 101  LUG - 110  LUS - 111

```

Now that I've explained all that, it should be pretty quick to work through the listing.  The first piece:

```

1500 ;
1510 ;    SELECT A LINE ROUTINE
1520  LDX #0
1530  LDA X2
1540  SEC
1550  SBC X1
1560  BCS RIGHT
1570 ;
1580  LDX #4
1590  LDA X1
1600  SEC
1610  SBC X2
1620 RIGHT STA DX

```

We'll use the X-register to keep track of our offset.  Line 1520 initializes it to zero.  Lines 1530 through 1560 subtract X1 from X2 and if the result is positive (X2 is greater than X1, carry flag is unchanged), then we know the line is drawn to the RIGHT and we branch to line 1620, which stores the result of the subtraction as DX.  If the result of our subtraction is negative, we store 4 in the X-register on line 1580.  We then subtract the other way (X1 minus X2) to get a positive result, and store that as DX on line 1620.  Okay, now we'll check the next condition (UP-DOWN):

```

1630 ;
1640  LDA Y2
1650  SEC
1660  SBC Y1
1670  BCS DOWN
1680 ;
1690  INX
1700  INX
1710  LDA Y1
1720  SEC
1730  SBC Y2
1740 DOWN STA DY

```

In this section we first subtract Y1 from Y2, and if the result is positive, we skip down to line 1740 and save the result as DY.  If the result is negative, 2 is added to the X-register (with 2 "increment X" instructions) and then subtraction is reversed, and the positive result is saved as DY.

Okay, now the STEEP-GENTLE section:

```

1750 ;
1760  LDA DX
1770  SEC
1780  SBC DY
1790  BCS GENTLE
1800  INX
1810 GENTLE TXA
1820  ASL A; MULTIPLY BY 2
1830  TAX
1840  LDA $6E8,X
1850  STA JUMP0
1860  LDA $6E9,X
1870  STA JUMP1
1880 ;
1890 ; JUMP TO 1 OF 8 LINE ROUTINES
1900 ; (CHAR STRINGS IN BASIC)
1910 ;
1920  JMP(JUMP0)
1930 ;

```

DY is compared to DX, and if DY is bigger (STEEP), the X-register is increased by one.  Now the X-register has the complete 0-7 offset.  On lines 1810 thru 1830 that value is doubled, so that it can be used to offset both low and high memory locations.  On lines 1840 thru 1870,  these two locations are accessed, and the bytes are stored as JUMP0 and JUMP1.  On line 1920, we indirectly jump to the address in JUMP1, JUMP0. which is the start of one of the 8 line-drawing routines.  The routine executes, and at the end is an indirect jump to the memory address stored in locations  BACK0 and BACK1 ($3F and $40).  This memory address is $6DC.  Remember, we stored $6DC (1756) in locations $3F and $40 (63 and 64) back in lines 610 through 630 of the BASIC program.  Anyway, program control returns to address $6DC, which is the LDA #0 instruction in the following final section of FRAME.BIN:

```

1940 ;RETURN FROM LINE ROUTINES($6DC)
1950 ;AND
1960 ;UPDATE ENDPOINTS FOR NEXT DRAW
1970  LDA Y2
1980  STA Y1
1990  LDA X2
2000  STA X1
2010 ;
2020  JMP DLOOP

```

Lines 1970 thru 2000 save the new coordinates (X2,Y2) as old coordinates (X1,Y1) so that they will now be the starting coordinates when a new line is drawn (remember, the program draws "polylines" until it's told to stop by a code byte).  Line 2020 jumps back up to DLOOP to pull the next byte, check if it's a code byte, and go through the whole cycle again...


This completes are examination of WHAM.CTB and FRAME.BIN.  The only thing left to examine are the line-drawing routines, which are stored in WHAM.CTB as character strings.  We'll examine just the first one, RDG (Right-Down-Gentle) because they are all very similar.  We'll examine the routine in its assembly language listing, before it was assembled and turned into a character string.

## Bresenham's Line Algorithm

Before we look at the listing, though, we have to discuss the classic algorithm that makes the routines work, Bresenham's Line Algorithm.  Discovered (invented?) in 1962 by Jack Bresenham of IBM to control plotters, it is (I believe) the de facto standard algorithm for line-drawing in hardware, or in software when using only integer math (as we are).  The routine is very simple, taken from "Principles Of Interactive Computer Graphics", page 26.  I've used a slight variation:

```
E = DY - DX / 2

FOR J = 0 TO DX
   PLOT (X,Y)
   IF E > 0 THEN
	E = E + DY - DX
	Y = Y + 1
	END IF
   ELSE E = E + DY
	END IF
    X = X + 1
NEXT J
END
```

The algorithm is shown above for the basic limited case where DX > DY and both are positive (RDG in our routines).  Graphically it would be a slope between 0 and 1 (angle between 0 and 45 degrees).  The algorithm plots points which always increase one unit in the X-direction, but may or may not increase in the Y-direction.  For each new point, whether the Y value increases by 1 or by 0 is determined by whether the error term (E) is greater than 0.  E is then modified before the next plot, and E will swing back and forth between positive and negative values during the course of plotting the line.

We see that we can simplify things, since DY is always added to E, whether or not E > 0.  So we'll move E = E + DY up above the IF - THEN statement. In addition, we can simplify the initial condition E = DY - DX / 2 to E = - DX / 2, since DY is already going to be added after the first PLOT.  This gives us:

```

E = - DX / 2

FOR J = 0 TO DX
   PLOT (X,Y)
   E = E + DY
   IF E > 0 THEN
	E = E - DX
	Y = Y + 1
	END IF
    X = X + 1
NEXT J
END

```

Since machine language can't use multiple instructions in an "IF - THEN" branch, it will be advantageous to change "E >" to "E <" and express the routine in BASIC format:

```

10 E = -DX / 2
20 FOR J = 0 TO DX
30    PLOT (X,Y)
40    E = E + DY
50    IF E < 0 THEN 80
60    E = E - DX
70    Y = Y + 1
80    X = X + 1
90 NEXT J
100 END


```

In the above program (as mentioned earlier), E will swing back and forth between positive and negative values.  I decided to find out how much of a swing it actually was, so I ran the above BASIC program for the two worst cases, DX=159, DY=1 and DX=159, DY=95.  I found that E ranges from -159 to 94.  This is a range of 254 values, which, lucky for us, will fit into one byte.  Unfortunately, we still have the problem of dealing with negative and positive numbers in a single byte, and I've found from experience that it's very difficult to do proper conditional branching if the polarity of the number is unclear.  The value -159, for example, is too low to define E as a signed one-byte number (must be -128 to 127).  There must be a better way.  Since we can add any constant to E, as long as we add it to both the initial condition and the comparison value, what if we add DX to both?  Our routine becomes:


```

10 E = DX / 2
20 FOR J = 0 TO DX
30    PLOT (X,Y)
40    E = E + DY
50    IF E < DX THEN 80
60    E = E - DX
70    Y = Y + 1
80    X = X + 1
90 NEXT J
100 END

```

Running this program yields E values from 0 to 253.  Perfect!  We no longer have to worry about comparing negative values.

Now we're ready to look at one of the actual routines.  Here is the most basic routine, RDG:

```

10 ;RDG.SRC (RUN FROM ML)
20 ;DRAW RIGHT-DOWN-GENTLE
30 ;DX AND DY BOTH POS
40 ;AND DX > DY
50 ;
60 ;MY OWN EQUATES
70 E=$CF
80 DX=$D0
90 DY=$D1
100 PIXZ=$DB
110 PIXLO=$DC
120 PIXHI=$DD
130 BACK=$3F
140  *=$600

```

This first section merely specifies the variables and the starting location of the program when it was assembled ($600).  That starting location will be different once the routine is converted to a character string and inserted into the BASIC program.

```

150  LDA DX
160  TAX
170  INX
180  LSR A
190  STA E; E=DX/2
200  LDY #0

```

In lines 150-170, DX is put into the X-register to use as our counter (like FOR J = 0 TO DX).  The X-register is then incremented by one (INX) to allow for the fact that all the PLOTs occur before the X-register reaches zero.  Lines 180 and 190 store DX / 2 as E.  Line 200 initializes the Y-register so that it won't interfere with our pixel operations coming up.

```

210 LOOP LDA PIXZ
220  ORA (PIXLO),Y; OR WITH LOC
230  STA (PIXLO),Y; LIGHT THE PIXEL

```


Here's where we (FINALLY) do the plotting and light the pixels.  For the first point in the line, PIXZ is already loaded with the proper value to light the correct pixel in the group of 8.  For example, to light the third pixel (from the left) in the group, PIXZ would be 00100000, or 32 ($20).  In line 220, PIXZ is OR'ed with the number in location PIXHI,PIXLO (OR'ed so that no existing lighted pixels are erased) and in line 230 the result is stored back in PIXHI,PIXLO.

```

240  LDA E
250  CLC
260  ADC DY
270  STA E; E=E+DY

```

In lines 240 through 270, DY is added to E.


```
280  SEC
290  SBC DX; IF E<DX, FLAT
300  BCC INCXPIXEL
310  STA E; E=E-DX
```

In lines 280 through 300, the E < DX comparison is done.  First the carry flag is set.  Then DX is subtracted from E (which is already in the accumulator) and if the result is negative (E < DX), the carry flag will be cleared.  The BCC instruction will then take us to the INCXPIXEL section of the program.  If the carry flag remains set (E > DX) then subtraction result is stored in E (E = E - DX).

```

320 ;
330 INCYPIXEL CLC
340  LDA PIXLO
350  ADC #20
360  STA PIXLO
370  BCC INCXPIXEL
380  INC PIXHI

```

We get to the section above if E was > DX during the comparison.  It means that the Y-coordinate of the next pixel will be incremented by one.  That is what this section does.  Since GRAPHICS 22 has 160 pixels (or 20 bytes) per line, moving down a line (remember increasing Y takes us downward on the screen) is simply a matter of moving ahead 20 memory locations by adding 20 to the number PIXLO,PIXHI.  We add the number to PIXLO and if PIXLO goes over 256, we increment PIXHI by one.

```
390 ;
400 INCXPIXEL CLC
410  ROR PIXZ
420  BCC SAMEBYTE
430  ROR PIXZ
440  INC PIXLO
450  BNE SAMEBYTE
460  INC PIXHI
```

This section increments the X-coordinate of the next pixel.  It will occur every time we go around the loop.  Line 410 increments the X-coordinate by rotating the bits of PIXZ to the right.  The previous line clears the carry bit so that it can't accidently rotate a 1 into our PIXZ value.  What if PIXZ is 000000001?  A rotation to the right will cause the 1 to rotate into the carry bit.  If that's the case, then on line 420, we won't branch down to SAMEBYTE.  Instead, we'll rotate PIZ again so the the 1 comes out on the left (10000000) and we'll increment PIXZ.  When the next point is plotted, it's X-coordinate will be the left-most bit in the byte just to the right (the next pixel to the right).

```
470 ;
480 SAMEBYTE DEX
490  BNE LOOP
500  JMP(BACK)
```

The final section.  We're at the end of the loop, so we decrease the X-register by one and if it's not zero (we've looped less than DX + 1 times) then we go back and plot another point.  If the X-register is zero, we're done with the line and we to an indirect jump to the memory location stored in memory location BACK ($40,$3F).  This location is $6DC (although it may change), the Page 6 address where we will continue with the FRAME.BIN routine.
The differences between RDG and the other  7 routines are fairly minor, simple changes like switching the roles of DX and DY in the calculations, using DECXPIXEL and DECYPIXEL instead of INCXPIXEL and INCYPIXEL, etc.  At this point I will leave it to the reader himself to investigate the differences.  However, in the case of the L-routines being 5 bytes longer than the R-routines, I feel I must explain.  Here is a comparison of sections of RDG and LDG:

```

RDG					LDG
400 INCXPIXEL CLC		400 DECXPIXEL CLC
410  ROR PIXZ			410  ROL PIXZ
420  BCC SAMEBYTE		420  BCC SAMEBYTE
430  ROR PIXZ			430  ROL PIXZ
440  INC PIXLO			440  LDA PIXLO
450  BNE SAMEBYTE		450  SEC
460  INC PIXHI			460  SBC #1
470 ;					470  STA PIXLO
480 SAMEBYTE DEX		480  BCS SAMEBYTE
					490  DEC PIXHI
					500 ;
					510 SAMEBYTE DEX
```

The DECXPIXEL section of LDG is 3 instructions (5 bytes) longer than the INCXPIXEL section of RDG.  Here's why.  In lines 400 to 430, the two routines rotate and test PIXZ in a similar way.  However, starting at line 440, RDG takes only 3 instructions to increment PIXLO, see if it reaches 256 (0) and if it does, increment PIXHI.  For LDG, the same approach won't work.  If we decremented PIXLO by 1 and then checked for zero, it would be too early for PIXHI to be decremented.  We'd need instead to check PIXLO against 255 (-1) and that would require bringing it into the accumulator to do the comparison.  What if we just decremented PIXLO and then used the BPL (Branch on PLus) instruction to branch to SAMEBYTE if PIXLO was positive or zero?  The problem with that is that the BPL instruction looks at the Negative Flag and branches if it's not set, and the Negative Flag is set on all results that are higher than 127.  So PIXHI would constantly get decremented, instead of only when PIXLO reaches -1.

Anyway, what I've done instead is to simply pull PIXLO into the accumulator, subtract 1, and restore it.  Then the carry flag is checked and if it's still set (PIXLO did not go negative) then we don't decrement PIXHI.

We've now covered the player, WHAM12.BAS, including its character-string line-drawing routines, and FRAME.BIN, the frame-drawing routine which resides on Page 6 when the player is running.  Have fun!


***
Dave Coombs
Fair Oaks, CA
October 2009
***


