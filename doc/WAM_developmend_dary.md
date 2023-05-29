# WAM Development Diary
* Dave Coombs *


WHAMLO (160x96 ) has a max. anim size of between 28,183 and 28,359 bytes.  B$ must be dimensioned at 32,000 to achieve this (for some reason).

WHAMHI (160x192) has a max. anim size of less than 26,100 bytes.  B$ is currently dimensioned at 26,050 and a 26,033 byte anim has run successfully.

With current dimension settings, both programs must be compiled and run with no BASIC cartridge present to avoid running out of memory.


Running on a P4 system (2.8MHz) at max emulation speed, 108 frames of the CAR animation played in 5.93 sec. at low-res (18.2 FPS, 4.4 KB/sec) and 7.84 sec. at high-res. (13.8 FPS, 3.3 KB/sec).

Normal Atari speeds (ouch!):

108 los-res frames in 103 sec. (1.05 FPS, 252.7 bytes per sec.).
108 high-res frames in 136 sec. (.794 FPS, 191.4 bytes per sec.).

1/21/07

Completed 1st working version of WHAMLO in ACTION!!  It uses ACTION's "Zero" routine to clear
the screen instead of writing in the background color.  Performance is a little better than twice that
of the Compiled BASIC version, which does write in the background color.  UPDATE: Complete "background draw" version in ACTION! and later, the Compiled BASIC version with an ML "Clear" routine.  The results:

For the 60 frames of DEMO1A.AWM, at standard Atari speed,

ACTION! version 1 (with ACTION! clear routine) took 11.15 sec.
ACTION! version 2 (with background draw) took 20.54 sec.
Compiled BASIC version 1 (with ML clear routine) took 14.15 sec.
Compiled BASIC version 2 (with background draw) took 24.18 sec.

For PIST.AWM, ACTION! version 1 played at 456 bytes per sec (7.06 FPS).
DEMO1A.AWM was played at 637 bytes per sec (5.35 FPS)

ACTION! version 2 played PIST.AWM at 3.97 FPS.

So, my ACTION! programs have brought me full-circle to see once again that DrawTo routines are very slow.
I'm starting to see that ACTION! just has far too many limitations - one being the need for the ACTION! "cartridge", and the other major one being the apparent inability to play a file larger than 8K.  No matter what I try (changing starting addresses, using variables to set memory aside, etc.) I can't get ACTION! to let me have more 8K of CONSECUTIVE memory locations...

Okay, WHAMCLR.OBJ is complete.  B$ is dimensioned at 28,500 bytes (the max that would work) and it STILL runs the CAR124.AWM animation, which is 28,183 bytes!  Hard to figure.

Anyway, of course my final big accomplishment will be to fix my ML draw routines (trouble with 0,0 to 92,20) and hopefully use them (with BASIC Compiled version 1 or version 2) to finally get good speed!!

2/5/07

I found I could get a little more speed by "tidying things up".  In GRAPHICS 22, I still need to save 4K (16 pages) for each screen for some reason, but I WAS able to reduce my CLEAR routine to just clearing 9 pages (just over 2K) instead of 15 pages, and still have it work.  I guess the GRAPHICS 22 screens are just a little over 2K each, but for some reason need 4K of separation for page-flipping.  Anyway, I call my modified routines WHAMCLS.BAS, WHAMCLS.OBJ, CLS.SRC, and CLS.BIN.

WHAMCLS.OBJ played DEMO1A.AWM in 13.25 sec. (PIST.AWM ran at 6.1 FPS).
WHAMCLR.OBJ played DEMO1A.AWM in 14.14 sec.

6.7% speed increase - not a lot, but it is something...

Also, operating system makes a difference.  When I switched from the XL system back to OS-B, WHAMCLS.OBJ took 15.44 sec. !!

Let's see - 0.89 sec saved over 60 frames is 14.83 ms saved per frame, which is the time it takes to clear 6 pages.  So clearing 9 pages would take about 22.25 ms, or only 1/50 of a second.  Truly, the HUGE factor is draw time...

Anyway, it looks like the screen clear works at 103,000 bytes per sec, which is about 17 machine cycles per byte cleared.  This seems very reasonable, since STA (CURLO),Y takes 5 cycles, INC CURLO takes 5, and BNE LOOP takes 2 cycles.  12 cycles, plus add a little for the things that happen every 256 cleared bytes, and also a little time for the CPU to do other stuff, and 17 cycles sounds just about right...

Anyway, let's examine the main loop in the BASIC program WHAMCLS.BAS:

The loop starts at line 300 and ends at "500 GOTO 300".  Screen 1 is first selected, then erased.  Then we run the draw subroutine.  This is what should be replaced by ML first (lines 520 thru 660).  The only thing we'll need to pass to the ML world is D, which is the memory location of the next byte we'll read.  In fact, we don't even have to pass D, since we'll always be incrementing it in the ML world!  At the start of the program, we can just poke D into our favorite page zero locations, and use it from there!

2/8/07 - Next question - which branching ML codes are relocatable?  I know that JSR is, and JMP is not.  What about BMI, BNE, etc?  It's important to have relocatable code, since I'm running my ML routines as BASIC strings...
Answer: JMP and JSR are both absolute mode instructions, and therefore not relocatable.  Branch instructions (BMI, BNE, etc) are all relative mode, and therefore relocatable.

2/9/07 - I'm using Chasin's CIOV routines for PLOT and DRAWTO, but there's a problem.  He uses commands like STA ICCOM,X which are unprintable characters (see AT_DIS3.XLS for a list of unprintable characters).  I could kludge my way around this problem by printing parts of the ML string and patching it back together, but I'll do something else.  I'll just define a value like ICCOMS to be ICCOM + $60.  Then I can use STA ICCOMS and the problem is gone...

One of my WHAM control characters ($FD) is an unprintable ATASCII character also (253) so I've used BASIC to store it and I pull it out in the ML routine...

2/11 - Well, WHMLOOP.BAS doesn't work, and I don't know why - it just shows a blank white screen.  So, I'm making a small BASIC program (CIOTEST.BAS) with small ML routine to see if I can get the CIO PLOT to work at all first...

Okay, CIOTEST.BAS has failed, and I'm  getting frustrated with it.  I've tried a bunch of different ways and I can't even get it to plot a point from my BASIC USR routine, even though both Chasin and Stanton imply that it should work.  Maybe the problem is with the Atari emulator.  Maybe it is the fact that I'm going to ML from BASIC and that all the important info such as GRAPHICS mode is lost when I get to ML.  I don't know.  I think it's time to go back to my own draw routines (ditch the OS, or "Master Control Program").  Yeah, I'll be TRON on this one, and do my own drawing.  I'll start simply, by just running one leg of my draw routine (say RDG) with a simpler version of WHAMCLS (no page flipping) and integrate all 4 routines slowly, ideally fixing their bugs as I go.  Sigh...

2/15 - I have a new plan for the player.  First of all, I'll use ML_WHAM.ABC to organize the various functions.  Second, I'm going to scrap the idea of making all of the code relocatable.  I'll still use a string variable to save memory for the data, but from now on I'll locate the ML routines on page 6.  I'll do this by using DATA statements at the end of the BASIC program and READing them into page 6 locations.  This shouldn't take very long (only 256 locations with compiled BASIC) and it will finally allow me to use ML JSR's and to get away from silly band-aids like "BAD253".  I've concluded that while character strings are great as a final application for BASIC ML routines, they're really lousy for troubleshooting in the combined BASIC-ML environment...

Quick reminder of what you're up against:

1.8 MHz playing 12FPS is 150,000 cycles per frame
Typical animation (SPACE.AWM) has 50 lines/frame
Comes to 3,000 cycles per line.
It's looking like one pixel may take 100 cycles
Therefore, lines must be an average of 30 pixels long.

Could work...

2/16 - Question:  Can you (from ML) place coordinate numbers into ROWCRS ($54) and COLCRS ($55) and then look at OLDADR ($5E,$5F) to automatically get the address???

No such luck.  It appears that you have to actually execute a drawing command (jumping to a CIO routine) in order for the address to be deposited into OLDADR (even POSITION from BASIC won't do it).  It's clear that this calculation is part of what the CIO does...


Okay, we begin.

What overall ML storage do we need?

Within a frame being drawn, we need:

1. DATAHI and DATALO, the starting address of data to be read.

2. DATHI and DATLO, the current address of data to be read.

3.  Locations 88 and 89, which hold the starting address of the current screen.

4.  SCRLO and SCRHI, which hold the address of the current byte.

5. Previous X and Y.

6.  DX and DY, which are calculated from comparison of newly read data and previous X and Y.


2/17 -  Progress is going pretty well on my "combined BASIC-ML" program (WHMLOOP.BAS).  I'm using all DATA statements to read the ML instructions into page 6, and I've listed the assembler nemonics as REM's beside the data.  INCXPXL, DECYPXL, etc. have become subroutines, and I replaced the looping routine to calculate Z (the bit position to use to light a pixel) with an 8-byte Z "lookup table", which resides at the end of page 6.  I may try to move it to the upper page zero locations ($D2 thru $FF).  I'm already using some of these locations for variables, so I'm trying to be cautious.  They are pretty much all for the BASIC floating-point routines, which I'm trying not to use, but I don't know whether they will change during the simple BASIC commands which I still need for troubleshooting (FOR-NEXT, etc.).  Once the program is compiled to integer, it shouldn't be a problem...

2/18 - Argh!  This is frustrating.  ATARI BASIC won't allow me to put a REM on the same line as a DATA statement.  Apparently, DATA doesn't recognize the colon as a divider and tries to read the REM.  I'll just have to put them on separate lines (alternating).  Sigh...

Okay, I finally got my "ML multiply by 20" test program (X20.BAS) to run!  The good news is that I seem to be able to use extra page zero addresses ($DA thru $E0), even without compiling, and BASIC doesn't seem to mind.  The not-so-good news is that before compiling, I have to remove all my REM statements which are intermingled with the DATA statements, because the compiler doesn't like them.

2/22 - I'm working on PIXLOC.BAS which is a precursor to PLOT.BAS, which will plot points using ML.  PIXLOC.BAS simply inputs the X and Y coordinates, and in GRAPHICS 6, provides the byte location (PIXHI,PIXLO) and the value to OR (PIXZ). 2/23 - I've had some problems with the program (it actually got completely erased once) mostly because I'm using the BASIC floating-point page zero locations.  I found a work-around in that I only have the BASIC program do any calculating BEFORE I run the ML routine.  I even use locations $D4 and $D5 to bring a result from the USR function, so that I can avoid doing a BASIC floating point calculation.  Even with this, I still have to reboot the Atari after every time I run the program, or bad things will happen...

2/24 - I've created PIXLOC2.BAS, which uses only safe page zero locations as a precaution.  However, I think my crashing problems were just oversights (no PLA, no RTS, wrong locations loaded, that sort of thing).  Anyway, in my struggle to get PIXZ to be something other than zero, I stumbled into a little speed-up.  Instead of ORing the X-coord with 7 and then subtracting it again, I can just AND the X-coord with 7 and make the adjustment in the values of the Z lookup table, thus saving a little time in ML...

Okay, now both PIXLOC.BAS and PIXLOC2.BAS work correctly.  Now it's time to create "PLOT.BAS"!

2/25
Plot to fill the GRAPHICS 6 screen (12800 pixels)
in BASIC takes 66 sec. (194 plots per sec)
Compiled version takes 19 sec. (674 pps)
PLOTS.BAS, using my ML routine, takes 167 sec (77 pps)
.
PLOTS2.BAS does all the looping and plotting in ML.  BASIC is only there to call my ML routine.
PLOTS2.BAS takes only 1.3 sec! (10,000 pps).

Since Atari runs at 1.8 MHz, each pixel is taking 180 cycles.  Looking at the ML routine, if we ignore the cycles for the looping commands, which occur only 1 time in 160, we see that the code for the average pixel takes 132 cycles.  So, plotting efficiency of the Atari is 132/180 or 73%, not bad when you remember that the processor has to do other things also.

I did try to speed things up a little (PLOTS3.BAS) by including the SEI instruction at the beginning of the ML routine (right after PLA) and the CLI instruction at the end (just before RTS).  The SEI instruction disables the maskable interrupts, including the vertical blank interrupt, the display list interrupt, and the keyboard.  The CLI instruction restores these interrupts at the end of the routine, so that the keyboard can be used when the ML routine is over.  This modification didn't seem to speed up the program at all (still filled in 1.3 sec) but neither did it cause the program to crash (no ill effects from plotting with VBI's and DLI's disabled).

Okay, now I'm back to WLOOP2.BAS (actually WLOOP3.BAS).  I substituted in my PLOT routine and I'm ready to get back working on DRAWTO.

2/28/07 - Let's summarize the total player program (WLOOP3.BAS), so that we can keep things straight in our heads, shall we?

A.  The main program

1. Sets up room for the file name, file data, and frame clear routine.
2. Loads the ML code for the draw routine and sets up the z-table.
3. Asks for the file name and loads the data into memory.
4. Calculates and stores the starting location of data for ML.
5. Sets up the two GRAPHICS 22 screens for page-flipping.
6. Sets up colors.
7. Animation loop - alternately points to screen 1 & screen 2, performing a draw and then an erase for each one.

B.  ML frame draw routine (nothing passed from BASIC to ML)

1. Loads Y-coord, X-coord, and Plots
2. Loads Y-coord character and checks whether it is data or a signal character.
3. If data, then also loads X-coord.  Subtracts previous X-coord and Y-coord from new X-coord and Y-coord to
get DX and DY
4.




ML ROUTINES:

1000 - 1400 Main (48 bytes) - from $600 to $62F
2000 - 2680 Plott (77 bytes) - from $630 to $67C
3000 - 3500 Drawtu (67 bytes) - from $67D to $6BF

4000 - 4130 INCXPXL (16 bytes) - from $6C0 to $6CF
4140 - 4270 DECXPXL (16 bytes) - from $6D0 to $6DF
4280 - 4370 INCYPIXL (11 bytes) - from $6E0 to $6EA
4380 - 4480 DECYPXL (12 bytes) - from $6EB to $6F6
4490 - 4610 Z-Table (8 bytes) - from $6F8 to $6FF

3/3/07 - Determined for certain that the "Main" routine is going to be at least 65 bytes.  Therefore, there is no way the entire frame draw routine will fit in 256 bytes...

3/4 - Okay, then, let's make "Main" relocatable, and keep the rest of the routines on Page 6.  We'll restore our "bogus compare" commands to Main to avoid using JMP.

Revised version (WLOOP4.BAS):

1000 - 1800 Main (100 bytes) - Address for D$

2000 - 2680 Plott (77 bytes) - from $600 to $64C
3000 - 3500 Drawtu (112 bytes) - from $650 to $6BF

4000 - 4130 INCXPXL (16 bytes) - from $6C0 to $6CF
4140 - 4270 DECXPXL (16 bytes) - from $6D0 to $6DF
4280 - 4370 INCYPIXL (11 bytes) - from $6E0 to $6EA
4380 - 4480 DECYPXL (12 bytes) - from $6EB to $6F6
4490 - 4610 Z-Table (8 bytes) - from $6F8 to $6FF

3/5 - Okay, now you're struggling with Drawtu, and with how much decision-making you should put into the Main routine.  You've gotten PLOTT to work, you've found space for the PXL INC & DEC subroutines, and you know the basic form for the Main routine.  You've gotten the 8 Drawtu cases to work (mostly) also.  The hard part now is putting it all together.

The Decision-Making:

How to subtract two sets of two numbers to get DX and DY, and how to evaluate the cases (DX neg, DY>DX, etc) in order to get to the proper draw routine, and how to do it elegantly and efficiently in ML?

Well, in summary, you're comparing DX, DY, and zero, and putting them in order.

Okay, here's a fractured idea that just came to me.  For now, just do AWM files in 128x96 resolution.  That is, GRAPHICS 22 with vertical bars to indicate where the X-coords cut off.  Or, you can just keep things in the middle of the screen.  If DX is never greater than 127, it won't get complicated to represent positive and negative numbers...

Okay, 0 to 127 are positive and 128 to 255 are negative.

3/6 - I took source codes for the 8 Drawtu cases (LDS, RUS, etc) and cut out the initialization (mostly not needed) and the dividing DX and DY by 4 (hopefully not needed) and renamed the parts LDS2, RUS2, etc. in the WHAM directory.  From here I will
attempt to decide whether the routines are short enough to preserve in their entirety...

3/7 - Next idea - make a subroutine out of the error section.  Have a universal variable that can be changed to be either DX or DY.  Branch to 8 separate cases in the main Drawtu section, but have each case be a very small section consisting almost completely of subroutine calls.

Branch to INCPIXL subroutine.  In INCPIXL, if A=0 then do the X-INC.  If A=1 then do the Y-INC.

3/8 - Okay, next plan.  Have a variable (on page 0) that uses just 3 bits as flags.  If DX>0, add 1 to it.  If DY>0, add 2.  If DX>DY, add 4.  You then have 8 possible values (0 to 7), representing the 8 Drawtu cases.  Then use this value to specify an incremental memory location (as in LDA ($600),Y) where you have previously stored 8 program addresses, corresponding to the 8 subroutines.  Rewrite DRAWALL.BAS as DRAWALL2.BAS, using the PLOT ML routine and the new Drawtu routine.  Basic should pass the values of X1, Y1, X2, and Y2 and ML should do the rest...

3/11
Organization for DRAWALL2.BAS
```
BASIC program
    Main ML routine
        Plott Subroutine
        Drawtu Subroutine
	  RDG subroutine (case 0)
	  RDS subroutine (case 1)
		.
		.
		.
	  INCXPXL (called by case routines)
	  INCYPXL (called by case routines)
		.
		.
		.
```

Exact format format of SELECT byte:

DX>0 then right, else left (add 4)
DY>0 then down, else up (add 2)
DX>DY then gentle, else, steep (add 1)

000 = 0 = RDG, subroutine at $600
001 = 1 = RDS, subroutine at $620
010 = 2 = RUG, subroutine at $640
011 = 3 = RUS, subroutine at $660
100 = 4 = LDG, subroutine at $680
101 = 5 = LDS, subroutine at $6A0
110 = 6 = LUG, subroutine at $6C0
111 = 7 = LUS, subroutine at $6E0

3/18 - Well, I've finished my first draft of the main ML routine for DRAWALL2.BAS.  One thing I've found is that it's better for me to use SEC-SBC-BCS when comparing two numbers than to use CMP-BMI.  The reason is that when CMP does its "subtraction", it sets the negative (minus) flag if the subtraction is greater than 127.  In other words, it treats the resulting byte (which is only used to set the status registers) as a signed 7-bit number.  That won't work for me, because my results can be greater than 127 (0 to 159)...


1000 - 1800 Main (57 bytes) - Address for D$

2000 - 2630 Plott (69 bytes) - from $600 to $644
3000 - 3500 Drawtu (96 bytes) - from $650 to $6AF

4000 - 4130 INCXPXL (16 bytes) - from $6B0 to $6BF
4140 - 4270 DECXPXL (16 bytes) - from $6C0 to $6CF
4280 - 4370 INCYPIXL (11 bytes) - from $6D0 to $6DA
4380 - 4470 DECYPXL (12 bytes) - from $6E0 to $6EB
4480           Address table (8 bytes) - from $6F0 to $6F7
4500           Z-Table (8 bytes) - from $6F8 to $6FF


6/11/07 - Back on the "Chain Gang" after three months away!  Anyway, I'm back into it, and I've created DRAWALL2.ABC to help me organize my thoughts and remember where I left off...

6/12 - Okay, here's where I make a change to save some space (and time).  I see that I'm plotting the first point not only in the PLOTT routine, but then again in the DRAWTU routine.  I'll take that section out of the PLOTT routine (since DRAWTU always follows PLOTT) and call the change Drawall3.txt.

Did some cleanup on Drawall3.txt.  Now the next thing to do is to compare the 8 cases, and decided at what point I should use the address table to branch to the cases.  Later I can finalize the actual addresses in the table.

6/13 - I believe I've made a mistake in the structure of Drawall.  The JSR command doesn't allow you to jump to a subroutine at a variable location.  It requires you to specify the hard location of the subroutine.  This means that I can't use the SELECT variable as I had planned.  So then, I won't specify the lines case in the MAIN rooutine.  What's more, I'll make the PLOTT routine part of the character string (no need to give it page six space, really).  Okay, here we go with Drawall4.txt...


1000 - 1800 Main (57 bytes) - Address for D$

2000 - 2630 Plott (69 bytes) - from $600 to $644
3000 - 3500 Drawtu (96 bytes) - from $650 to $6AF

4000 - 4130 INCXPXL (16 bytes) - from $6B0 to $6BF
4140 - 4270 DECXPXL (16 bytes) - from $6C0 to $6CF
4280 - 4370 INCYPIXL (11 bytes) - from $6D0 to $6DA
4380 - 4470 DECYPXL (12 bytes) - from $6E0 to $6EB
4500           Z-Table (8 bytes) - from $6F8 to $6FF

The main routine will alway have use DRAWTU, but it won't always use PLOTT.


6/20 - I CAN use the SELECT variable!  Simply use JMP(X), the indirect jump.

The only true subroutines you have are INCXPXL, DECXPLX, INCYPXL, and DECYPXL.  They're the only routines that need to be accessed from different locations and need to return control to those locations.  All the other routines, PLOTT, DRAWTU, etc can be jumped to and they will always return to the same location.

DRAWALL4.TXT now uses the LUS routine, the slowest but most memory efficient.  The routine establishes the DRAWTU case by way of the L, U, and S flags.  Each time a pixel is determined for DRAWTU, all three flags are checked (thus the slowness).  However, the code is more compact and there is no need to jump to a different routine in memory for each of the 8 cases.

6/21 - I keep changing my tune - now I've gone away from LUS (DRAWALL4) and back to SELECT (DRAWALL3).  I'm back to using the SELECT table, which will hold the one-byte page 6 address of each of the 8 cases.  The

6/23 - Okay, try again.  Here are all the sections of the program and their descriptions:

POS - Given X1 and Y1, calculate the location of the byte in memory (PIXHI, PIXLO) and the number to be ANDed to that location (PIXZ)

SELECT - Using X1, X2, Y1, and Y2, calculate DX and DY, and identify the line case using the x-register (0 to 7) and then use the address table to store the appropiate "jump" address into JUMP0 (JUMP1 is set to zero and not needed since the address is on page 6).  DRUN, which will set the number of pixels in the line, is set to DX if gentle, DY if steep.  Conversely, DRISE is set to DY if gentle, DX if steep.

SELECT (version 2) - Using X1, X2, Y1, and Y2, calculate DX and DY, and identify the line case using the variables L, U, and S (ie if L, U, and S are all one, LUS is the case; if they are all zero, RDG is the case).

DRAWTU - This is a composite of the eight original routines.

7/1- Back again.  I've decided that there will be two low-byte jump values.  These values will represent the locations of the first and second pixel subroutine to use in any of the 8 cases (they all have two pixel subroutines).  This means that I don't need 8 separate case routines in page 6 memory!  By setting up DRISE, DRUN, JUMPA, and JUMPB in the SELECT routine, I should be able to duplicate any of the 8 original case routines and only require page 6 memory for the 4 pixel subroutines...

Oops, that idea won't work because I'd be using indirect jump, JMP(X), to go to the 4 pixel routines, and they wouldn't know where to return.  And I couldn't use JSR, because the subroutine name has to be stated - it can't be a variable.  Maybe I should make the "middle section" a subroutine instead...

7/4 - l just modified DrawList3.txt to include all 8 cases, each section containing 4 JSR's.  But those JSR's take 6 clock cycles apiece, and would have to be done for EVERY PIXEL!  At that moment, I decided on a simpler, better solution for all of this.  I will keep the 8 routines as they are, as character strings.  This will fill up space, but will provide the fastest line drawing.  I will store their starting addresses ( ie ADR(A$)) in the BASIC section, and then run the ML section from page 6.  The ML section will use the SELECT routine to indirect jump (JMP(X)) to the proper char string and then there will be an indirect (or direct) jump back.  Some day I will have all this hard-coded in ML, but for now I'll use BASIC to help me organize my space...

The first thing is to go back to the 8 case routines and modify them to work with the main ML routine on page 6.  An indirect jump JMP(BACK) is added to each routine.  BACK is location $E1, and for now it contains $678 (1656) which is the last line of the main routine, RTS.

7/5 - Okay, here is the structure of DRAWALL5:

1-83 - Dimension and define all 8 character-string routines, as you did in DRAWALL.BAS.  Record starting addresses in AD array.

100 - Read ML routine from DATA statements, which includes SELECT routine and POS routine.  For now, poke it into page 6 locations (it may all fit now that DRAW routines are completely within character strings).

200 - Calculate high and low bytes for the 8 starting addresses and poke them into address table.

300 - Calculate the 8 Z-values and poke them into Z-table.

400 - Set up the graphics mode, input the coordinates and poke them into memory locations, and call the main ML routine.

ML Section

500 - Equates

600 - POS routine

700 - SELECT routine

800 - END

7/6 - Okay, making good progress modifiying DRAWALL5.BAS and the 8 cases so that they would work together.  However, I did run into one snag, which I was able to gracefully manuver around.  When constructing character strings, the numbers 27-31 ($1B thru $1F) are awkward because they are unprintable characters (ESC and 4 arrow keys).  The number 28 (UPARROW) was coming up in the STEEP routines.  It was part of a BPL command which was branching 28 steps ahead.  Fortunately I remembered that I could print the UPARROW character by holding ESC while hitting the UPARROW key.  I broke STRING.BAS into two sections, printing "around" the character, and then "hand-entered" it myself.

7/7 - Debugging DRAWALL5.BAS -

I debugged the first couple of errors pretty quickly, but the third error made me realize that I'm a little confused about the memory locations used for the JMP(X) instruction, both in the main ML routine and in the 8 case routines.  I'll review the facts in hopes of clearing up the confusion.  First of all, page 6 addresses are 2 BYTES!  The PAGE 0 addresses are the 1 BYTE addresses.  Okay, here's how it should be organized:

The address table

$06E8, $06E9 - holds AD(0), starting address of RDG$
$06EA, $06EB - holds AD(1), starting address of RDS$
    |           |              |                           |
    |           |              |                           |
$06F6, $06F7 - holds AD(7), starting address of LUS$


4pm - Okay, verified that the Main ML routine was typed in correctly.  Ran DRAWALL6.BAS and entered X1, Y! as 0,0 and X2,Y2 as 50,50.  Program completely crashed - I know why - return address is still listed as $678.  It should be $67D.  Fixed, but program crashed again!  Okay, had to resize the loop to read 125 ($7E) bytes in the main routine.

Okay, works for 0,0 to 100,50 (RDG)
Okay for 20,10 to 40,60 (RDS)
Okay for 10,70 to 100,60 (RUG)
Okay for 100,75 to 110,0 (RUS)
Okay for 150,0 to 5,30 (LDG)
Bad for 75,5 to 60,70 (LDS) -crashed!
Again bad for 150,0 to 140,70 (LDS)
Okay for 150,70 to 0,0 (LUG)
Okay for 100,30 to 10,20 (LUG) but after drawing 2 lines, never returns to ENTER prompt...
Okay for 100,75 to 90,0 (LUS)

10pm - Fixed LDS routine.  Problem was simple - LDS$ was dimensioned at 78 instead of 79 like the other routines.

LDG and LUG still hang after drawing two lines.  I notice that LUG from 150,75 to 0,0 never draws completely to 0,0.

These problems may very well be caused by error value problems, or some other fault in my implimentation of Bresenham's algorithm.  However, for now I will keep the case routines as they are, and move on with the main routine.  I have moved to NEWHAM2.ATR and renamed the program DRAW.BAS and the ML source ML.SRC.  I will now expland into a test program to check the speed of the line drawing...

7/8 - The first results from the line draw test are in, and they are encouraging!  160 lines in 0.6 sec!  Lines range from 50 to 160 pixels in length, so the average should be 105.  Lines were set to be drawn from 0,0 (which is plotted each time) to 159,50 then 158,50 and so on until 0,50.  Sets of 4 lines were drawn on top of each other, making the final drawing look like it had only 40 lines.  I know that this is because I divided DX and DY by 4 to keep the error small, and the problem will be fixed in the future.  In addition, one line (or set of four) was drawn partially out of place.  Again, this could be a slight problem with the drawing routines, or it could be the result of using sensitive page zero locations without compiling the program.  Anyway, now I'll modify the test to use the full range of GRAPHICS 6 (y-values 0 to 79).

160 lines in 0.7 sec!  Lines range from 80 to 160 pixel, average is 120.  Again, groups of 4 and again one line partially out of place.

Okay, let's do the math:
(160 x 105) / 0.6 = 28,000 pixels/sec
(160 x 120) / 0.7 = 27,428 pixels/sec
1.8 mill cyles per sec / 27,700 pixels per sec
= 65 cycles per pixel.

I said that I needed 100 cpp or less...
I'm ahead of the game and very happy!

(In comparison, BASIC takes 8.4 seconds for the second case - 1/12 the speed - for 2286 pps...)

7/9 - Maybe it's finally time to fix up the drawing routines.  I'll stop dividing DX and DY by four, but I'll also probably have to make the error value (E) two bytes instead of one...

7/10 - Whew!  Close call, but I made it.  I created ERRTEST.BAS to test the E values for my implementation of Bresenham's algorithm.  It looked like I would have to split E up into 2 bytes, which was going to make the compares very messy, especially for negative E's.  However, what I found is that minimum value of E that occurs is -78 (for case 159, 1) and the maximum is 174 (for case 159, 95).  This is great news because it means that I can fit all the positive and negative cases of E into one byte (cutting it close, 253 values).  Also, instead of comparing 2 * E to DX, I'll compare E to DX / 2.  Unfortunately, this won't work at the higher resolution (case 191,159 gives E values of around 250), but I my never use high res anyway because it will probably take nearly twice as long to draw frames.

So, 174 is $AE and -78 is $B2.  We'll say that $0 to $AF is positive (0 to 175) and $B0 to $FF is negative (176 to 255).
The Atari treats 0 to 127 as pos and 128 to 255 as neg.  We'll be changing those rules a bit...

Well, the program runs, but it still has a couple of line breaks.  I went back to the old DRAWALL.BAS program, and made it into a multiline version DA2.BAS.  I tried to solve the problem of the break when X2=112, and found that the LOC value jumps abruptly from 40171 to 39936.  That's $9CEB to $9C00, so somehow LOCLO is suddenly disappearing.  You add 20 to $9CEB and you should get $9D00, but instead you're getting $9C00. I created RDG1.SRC to try adding a little differently, but it still didn't fix the problem.  Maybe the emulator is the problem...

HaHa!  I fixed the dang thing!  It was just the INC PIXLO section, and I was somehow expecting an INC statement to set the carry flag!  How silly!

7/11 - Okay, I now fixed the final problem with DrawTest, the routine that uses RDG and RDS to fill half the screen.  It was only filling up to Y=78, so I added an INX statement near the beginning of the RDG and RDS case routines, to account for the fact that the loops never draw the last point in the line (because PLOT is first, and DEX / BNE LOOP is at the end of the routine).  The most recent DrawTest is DT3.BAS.
The final line (0,0 to 0,79) is still not drawn, but this is simply because the main ML routine has DEC X2 at the end, similar to the case routines.  I won't bother to fix this since this is only a test program.  I will, however, fix the other 6 case routines and put their strings into DT3.BAS, so that it can be used as a template when I soon return to WHAM.BAS!

Extremely cool!  I just finished testing all the case routines in GRAPHICS 22 (full screen).  I did this by sticking different "corner values" into X1,Y1,X2,Y2, and also changing whether X2 or Y2 was decremented.  The GRAPHICS 22 version is DT4.BAS.  All cases work great!

I have to say that I've reached a milestone in my ATARI WHAM programming.  There's still a lot to done - encorporate the new routines into a WHAM player, optomize the routines, add timing to the player, etc.  But probably none of my future accomplishments will match this first one, when I decided to sit down and write my own line-drawing routine!!!



ML Section:
$600 - $644 	POS routine
$645 - $67C	 DRAWTU SELECT routine

RDG$, RDS$, RUG$,RUS$,LDG$,LDS$,LUG$,LUS$ routines
excuted here

$67D - $681 	LOOP routine and return to BASIC

$682 - $6E7	102 more bytes for the main program

$6E8 - $6F7 	DRAWTU Routine Address Table
$6F8 - $6FF 	Z-Table


7/12 - Well, compiled BASIC is really having its problems!  I tried to compile DT4.BAS, but the compiler gives a system error when it encounters a subscripted variable!!!  Even this simple program creates a system error during compilation:

10 DIM A(10)
20 A(5) = 25
30 END

So, I replaced AD() with AD$() and used STR$ and VAL statements to get around the problem, using char string operations.  Finally, I got rid of all the REM statements that were after the DATA statements, and the thing finally compiled.  But the emulator crashed when I ran it!!

I'm going to try compiling the simple program above on a real Atari 800, but I'm pretty fed up with the compiler.  I'll just have to live with the slow speed of BASIC, and but everything I can into ML...

On the disk LineWam.atr, I had created DRAWINT.OBJ, the compiled version of DRAWALL.BAS, and it ran, so maybe there's hope, if I can find out what's wrong with the way I've programmed DT4C.BAS...

7/13 - Ultimately, problems lead to the search for solutions, and that leads to discoveries.  Sure enough, I tried the DataSoft Compiler on my REAL ATARI and it gave the same system error when trying to compile the simple program above!  How did they manage to sell this thing, with such a major flaw!!!

However, when one door closes another one opens.  I tried TurboBasic today, and it's great.  You just boot off the TBasic disk (without the Atari Basic cartridge) and it looks just like Atari Basic!  It even jumps to DOS easily, although I don't yet know how to get back without rebooting.  Anyway, it runs my Atari Basic programs 3 times as fast!  For example, DT4.BAS took 5.30 sec total with Atari Basic (4.60 sec. to set up and 0.75 sec to draw) and Turbo Basic to 2.25 sec total (1.50 to set up and 0.75 to draw).  The Basic portion (the setup) was 3 times as fast.  I have to see what it will do with WHAMCLS.BAS.  Also, Turbo Basic has its own compiler - maybe my troubles are over!

Compiled DT4.BAS with no trouble.  Had to read the instructions carefully to run it, but ran in 1.7 sec total, or 1.0 sec setup time.  That's nearly 5 times as fast as Atari Basic!!

Remember, TBasic only runs on XL machines (and later)...

Here now are some benchmarks for running WHAMCLS.BAS and loading the animation PIST.AWM.  For the BASIC version (with both Atari Basic and Turnbo Basic), DIM B$(28500) had to be changed (was lowered to 10,000) to allow extra room for the Basic language.

Atari Basic:
19 sec. to load the data, 15.4 sec to play the 16 frames.

Compiled with DataSoft
2.0 sec for the data, 2.6 sec for the frames

Turbo Basic
7.9 sec for the data, 6.2 sec for the frames

Turbo Basic Compiled
2.8 sec for the data, 3.25 sec for the frames

So, compiled Turbo Basic is not quite as fast as compiled DataSoft.  No matter!  ML will take care of the speed, and the 40% extra time to load the animation, I'll just have to live with.
In actuality, when I remove the SIO patch (fast disk access) option from the emulator, it takes 3.6 sec for the Turbo Basic Compiled version to load the data, closer to the time a real disk drive would take...

The point is, the Turbo Basic compiler WORKS!  And it works on my Atari Basic programs the way they are, with subscripted variables, and REM statements mixed in with DATA statements, and everything else.  Warts and all...

Oh, and did I mention that the compiled files were about 1/4 of the size of those from the DataSoft compiler???

7/14 - Okay, first benchmark on a real Atari!  My "partial version" of DT4.BAS (only RDG$ and RDS$ are included so far) takes 3.87 sec to setup and 0.7-0.75 sec to draw (I'll create a more accurate measure soon) - that same specs as the emulated version.  But wait!  It seems to setup FASTER than the emulated version (3.87 sec vs. 4.60 sec).  I believe that this is because the lines RUG$= "***", RUS$="****", etc. are missing.  It must take time to put all those characters into the memory locations for the character string.  So loading char strings with ML routines is not instantaneous.  Again, there's no "free lunch"!  Judging by the fact that the truncated version loaded about a second quicker, and there were 6 x 78 = 468 chars that didn't have to be loaded, it's safe to say that Basic loads about 500 bytes per second using the char string method...

My first attempt at officially timing DT4.BAS was DT4TIME.BAS.  It set the jiffy clock (location $14) to zero in BASIC, and measured it again after the ML section was over.  Results:

52 jiffies or 0.867 sec.  Ave line length = (96+160) / 2 = 128.  128 x 159 = 20352 pixels.  (1.8 MHz * 0.867 ) / 20352 pixels = 77 cycles per pixel.

I then tried a more accurate timing from ML (DT4TIME2.BAS), but couldn't get ML to store the result from location 24.  So, I improvised by estimating the # of jiffies BASIC added to the timing.  I ran DT4TIME.BAS from X = 0 to 102, which drew very close to 1/2 the number of pixels (10149) as the first case.  It timed at 28 jiffies.  Therefore, I could deduce that BASIC was taking 4 jiffies and the real ML times were 48 and 24, respectively. So:

48 jiffies is .8 sec.  (1.8 MHz * 0.8) / 20352 = 71 cycles per pixel

This also brings up a crucial point.  If BASIC takes 4 jiffies (15) when it jumps to and from ML, and this happens every frame, performance will seriously suffer - I'll probably eventually have to do the whole routine, except for the prompt and loading the data file from disk, in ML...

Tried the same 2 cases with Turbo Basic.  The results were 51 and 27 respectively, or 3 jiffies for BASIC. Better!  Tried case 1 with compiled TBasic, same result - 51 jiffies.

I also decided to actually go into a case routine (RDG.SRC) and time out how many cycles are supposed to be used for each pixel The best case was 51 cycles, worst was 104.  Average of the two is 77.5 cycles.  I'm certain that I can skim off at least 10 cycles when I go back and optimize...

7/15 - Okay, I'm optimizing, and I believe I see some things that can be sped up.  I'm changing RDG4 by going back to RDG, and and have fixed a simple mistake I had made in the INCXPIXEL section:

INC LOCLO
BCC SAMEBYTE
INC LOCHI

Incrementing LOCLO doesn't set the carry flag.  I found that out later, and made some lengthy changes to fix that problem.  However, all I needed to do was change BCC SAMEBYTE to BNE SAMEBYTE, since the INC instruction does set the ZERO flag if the memory location (LOCLO, in this case) has rolled over to zero.  I could also have used BVC SAMEBYTE, since the OVERFLOW flag is also set when an INC instruction causes a memory location to roll over.

Anyway, RDG4mod is now 72 bytes.

2nd optimization - remove CLC's at lines 300 and 570, SEC at line 480.  These instructions are probably not needed.
I just found out that the SEC is needed, but not the two CLC's.  The RDG routine is now 70 bytes.
Maximum 94 cycles for the loop, min 42, average 68.

3rd optimization - move  ORA (PIXLO),Y and STA (PIXLO),Y to the end of the routine (SAMEBYTE section).  Remove LDA PIXZ from the beginning of the loop (saves 3 cycles) and remove INX from the section before the loop (no longer needed).  Also, to be complete, LDY #0, ORA (PIXLO),Y and STA (PIXLO),Y
must be added to the main ML section in the POS routine (now becomes PLOTT) to work properly in drawing distinct lines.  Its absence is not noticed in the test routine, where there is only one starting point for all the lines (usually 0,0).

The RDG4mod routine is now 67 bytes.  Maximum 91 cycles for the loop, min 39, average 65.

Okay, my attempt at optimization 3 is doing all kinds of weird things, so I'm going back to optimization 2.  I'll use the old DT4TIME.BAS program and just update the 4 routines to be 70 bytes, leaving plotting out of the main routine for now.  I'll call it DT5TIME and all the routines RDG5, RDS5, etc...

In the final test, all my contortions only reduced the time of DT5TIME.BAS to 50 jiffies.  Figuring 4 for Basic, that's 46 / 60 or .767 sec. (1.8 MHz x 0.767) / 20352 pixels = 67.8 cycles per pixel, maybe the best I'll get...

7/16 - Okay, optimization 3 is back again!  This time I'm just making a tiny adjustment to RDG5, moving the LOOP label from line 200 LDA PIXZ to line 210 ORA (PIXLO),Y.  What this should do is automatically cut 3 cycles out of the RDG loop with having to modify the main ML routine.

It worked - down to 49 jiffies now (1.8 x .75) / 20352 = 66.3 cycles per pixel !!!

The 2nd part of opt3 is to replace the ROR A's in RDG with ROR PIXZ.  If this works (if it sets the carry flag), then it should cut out 3 cycles when the byte# (PIXLO) stays the same.  When the byte # changes (1 out of 8 times), no cycles will be lost or gained.
I'll try it with RDG first, then RDS.

Renaming DT5TIME.BAS as DT5.BAS

I started to perform the ROR A to ROR PIXZ change on RDG5, then realized that I couldn't receive the benefit of it (3 less cycles by eliminating SAMEBYTE STA PIXZ) unless I undid my earlier mod and moved the LOOP label back up to 200 LDA PIXZ.  So it's pretty much a wash in RDG5. However I did perform the ROR A to ROR PIXZ mod on RDS5.  It worked and time went down again to 48 jiffies!  (1.8 x .733) / 20352 = 64.9 cpp !!

I then went back to RDG5, moved the LOOP label back up, and made it similar to RDS5, for consistency.  However, this brought the time back to 49 jiffies.  I'm not worried about it right now, because I just got a great idea for optimization 4....

During the loop, I load DX or DY and cut it in half to compare with E.  But this halving operation could be done before the loop.  I just call this new variable HALF and store it in $E3 (227).

Now, because 1/2 DX or DY is no longer being calculated in the loop, I can get tricky.  Starting with RDG5, I switch the sections of INCYPIXEL, so that the E=E-DX section comes first.  I adjust the label names accordingly.  Then I switch the places of E and HALF in the previoius section, resulting in LDA E and CMP HALF.  I change the BPL that follows to BMI.  Now everything should work, and I can get rid of LDA E in the next section because E is already in the accumulator!  Ah, ha!  I can get rid of the previous LDA E also, because the accumulator has not changed since STA E before the first compare!

Ah, the first result is glorious!  Down to 46 jiffies and RDS5 still to be modified...

That done, 45 jiffies is the result.  60.4 cycles per pixel.  Remember, I started with 71 cpp.  I KNEW I could knock out at least 10 cycles!  Can I do more????

Okay - Optimization 5.  It starts out slowly, on RDG (saved to RDG5), by moving the INCXPIXEL routine up, so that it immediately follows ORA (PIXLO),Y and STA (PIXLO),Y.  This gives the opportunity to use PIXZ, which is already in the accumalator, for the ROR instructions.  ROR PIXZ is changed back to ROR A in two places and STA PIXZ is added to the end of the INCXPIXEL section.  This saves 3 cycles when the first branch (BCC) is not taken and no change in cycles when it is taken.  Unfortunately the branch is taken 7 out of 8 times, so the total cycle savings is fairly small...

Optimization 5 doesn't work.  It causes the screen to fill with apparent garbage, which is just, I believe, the error value and the pixel incrementing being one turn out of synch.  In any case, I think that's a hint that I'm done with my optimization for now.  It was successful and I achieved my goal of cutting out at least 10 cycles.  I will now implement the new code across all eight cases, and finally proceed on to the WHAM player.  I will relabel all the cases RDG5.SRC, RDS5.SRC, etc. for clarity...

7/18 - Some interesting results, now that I've updated half the routines (RDG,RDS,RUG, and RUS):

When decrementing the X-axis, and drawing from (0,95), the result for RUG / RUS is the same as for RDG / RDS , 45 jiffies.  However, when decrementing the Y-axis, RUG / RUS takes 35 jiffies, and RDG / RDS takes only 34 jiffies.  So we can average it at 34.5.  Taking away 4 jiffies for BASIC, we get 30.5.  Then we have to look at the number of pixels actually drawn, which is different from decrementing the X-axis (pixels don't just fill the screen - many of them write over each other in this test).  We have 95 lines (last one not drawn), all of length 160, or 15200 pixels.  (1.8 MHz * 0.508) / 15200 = 60.2.

So 60.2 cycles per per pixel, virtually the same as before, with only 60% of the lines of the previous case.  It's as I suspected then, the initial plot takes a miniscule amount of time compared to the time to draw the rest of the line (probably around 1% for these long lines).

You know, I think I've been wrong to subtract 4 jiffies for BASIC.  I ran and y-axis decrement test for RDG / RDS (only uses RDG) running about 1/2 the number of lines (47), and it was 16 jiffies compared to 34!  The nearer you get to vertical or horizontal, the faster the line draws, since it can skip the first INC routine more often.  In fact, it might behoove me at some point to create specific routines for horiz and vert. lines, so they could just fly when they occur.  Later for that.  What I end up believing is that BASIC doesn't add much to the time, and that my ML times are not as good as I thought.  I'll have to solve the problem of timing from within ML (I'll need that eventually) if I want to get accurate readings.  I did try drawing just one line, and got down to 1 jiffy.  So I should just subtract 1 from the displayed number to get an accurate count.  I still cut 10 cycles from when I started, and now I can contentedly go on to the WHAM player!

Revised optimized time: 65 cycles for x-dec, 66 for y-dec
Revised original time: 75 cycles for x-dec

7/19 - Well, things aren't going as smoothly for the case that draw to the left, but I'm dealing with it.  I was having some real trouble with LDG5 early on, getting strange errors, until I realized that the problem was coming from inserting the SRC file with the ATR Utility.  From now on, I will try as much as possible to simply modify existing files in the emulator world, rather then inserting them from Windows.

That cleared up, I was able to get LDG optimized ALMOST to the point of RDG.  There's a problem with DECXPIXEL that doesn't occur with INCXPIXEL, and I don't think I can get around it.  It has to do with incrementing or decrementing PIXLO and PIXHI as a pair so that they act as a 16-bit counter.  It works fine in RDG (incrementing) because I can use BNE to check to see if PIXLO's rolled back to zero, and if it has, increment PIXHI.  Going in the negative direction, however, there is no command I can use.  When PIXLO goes below zero, I must decrement PIXHI.  You'd think I could use BMI or BPL, but those instructions see all large 8-bit number as negatives, so when PIXLO is above 127, PIXHI will always be decremented.  The result is a mess of pixels on the screen.

So what I've done is to go back to LDG4 (just for DECXPIXEL) and optimize what I can.  The ROL PIXZ section stays put, but for the second part of DECXPIXEL, I've gone back to LDA PIXLO, SBC #1, etc.  Yes, this adds 5 cycles (and 5 bytes), but it's not that bad.  That part of the routine is only used when the byte changes (1 out of 8 times), and of course, I only take the hit on left-side drawing.  On average, then, it should only be a loss of about 5/16 cycle.  Still, it's frustrating, since once again left and right drawing routines are not the same length...

 Okay, LDG5 finally works and it only takes 34 jiffies, decrementing on the y-axis.  Good news!

Fighting corruption in the program - good grief!!
I couldn't for the life of me figure out why an extra line was being drawn when testing the LUS case.  It seem to be that the initial RUS5.SRC file was corrupted when it was sent over from Windows, and now it has a bad effect in a case where it's not even being used.  I've reconstructed a "clean" program, DT.BAS, and it doesn't work to just reassemble the old RUS.SRC file, so I'll have to build it from scratch in the Atari world...

I've decided that the problem with the "extra line" was not corruption at all, but an anomaly.  I think that I'm testing LUS and LUG, but when the line is being drawn straight up, (159,95 to 159,0), the program has actually selected RUS over LUS.  For some reason, the previous RUS drew that line accurately, and my optomized version tries to move the end one pixel to the right, so half of it ends up on the other side of the screen...

7/20 - Okay, so the RUS routine isn't perfect, but it's good enough and it's time to move on.  I think an new "disk image" is in order.  Also, I need to clean up my old files.  I'm getting rid of all the BIN, OBJ, and TXT files, since they can always be recreated.

Okay, I created a new diskfile called ML_WHAM.ATR, and I put WHAMCLS.BAS and DT5.BAS on it.  I put it in a new ML_WHAM_Project directory with this file (Perform.rtf).  So, here we go with the next phase:

ML WHAM Project

The main point will be to some combine WHAMCLS.BAS with DT5.BAS, and from there slowly convert more and more of the BASIC part to ML.  I need to set up a structure that lets me do that.  I think that the first step is to set up the selection portion of the drawing routine as a char string, just like the drawtu routines are.  I'll modify DT5 to be DT6 to develop the string and test it.  So the case char string routines would be called by the draw char string routine.  That would get rid of most of those DATA and REM statements used now to load the ML.  The only problem would be establishing an address on the main string where the case strings could return (BACK).  It would not longer be fixed, so it would have to be an offset from the starting address of the main string (ADR()).


7/22 - Ouch!  For some reason, BASIC won't accept a character string longer than 107 characters!  I don't understand...
Well, for now I'll try a dangerous move, separating my MAIN routine into 2 strings, M1 and M2, dimensioning them together, and hoping they land together in memory.  Up until now, this is where my string routines have been placed:

RDG$ : AD(0) = 12566
RDS$ : AD(1) = 12632 (+66)
AD(0) thru AD(8) = 12698 (+66)
RUG$ : AD(2) = 12752 (+54)
RUS$ : AD(3) = 12818 (+66)
LDG$ : AD(4) = 12884 (+66)
LDS$ : AD(5) = 12955 (+71)
LUG$ : AD(6) = 13026 (+71)
LUS$ : AD(7) = 13097 (+71)

The AD array was dimensioned after RDS$, and each of its 9 possible elements uses 6 bytes in BASIC (the size of a floating-point variable).
So all the dimensioned objects were stored in consecutive memory locations.

Anyway, I'm going to start M1$ (100 bytes) and M2$ (30 bytes) right after LUS$, and check their addresses to see if they land together...

I'm in luck!  They do land together, though apart from the other strings (13371 and 13471).  The modified DrawTest program is called COMBINED.BAS, and I'm just going to bypass the loading from DATA statements and see whether M1$ and M2$ can do the same job...

7/23 - My problem with character strings is NOT that they are limited to 107 chars!  It's that the Atari emulators (the two that I have tried) do not record more than 3 lines (114 chars) in a BASIC program, for some reason.  and Atari800Win 3.1 can't be used right now because it doesn't even recognize the "=" key on my laptop!

Anyway I think the way around all this is, instead of using M1$ and M2$ and hoping that they land together in memory, I'll do something like:

DIM A$(200)
A$(1,100)="jkdflerigflsdf"
A$(101,200)="eriomfv;sf;ler"

That SHOULD work...

7/26 - That DOES work.  However, the character string doesn't work.  The screen remains blank.  However, control does return to the BASIC portion, and the screen reads "speed = 3 jiffies".

7/27 - Today, COMB2.BAS works fine, when it didn't work yesterday.  Hard to understand.  Anyway, it's time to start merging COMB2.BAS and WHAMCLS.BAS.  First, I'll compare the two and try to change line numbers to make them compatable.  Then, I'll save one as LISTed text and try to ENTER it after I've LOADed the other one...

7/28 (from Chicago airport)

Well, I combined COMB2.BAS with WHAMCLS.BAS to form WHAMML.BAS, but it crashes the Atari when I load PIST.AWM.

The first thing I checked was that I was not introducing a problem with the CLEAR (CL$) routine.  I had changed the routine to use page-zero locations E4$ and E5$ instead  of CC$ and CD$, so that it could coexist with the current COMB2 routines.  I substituted the modified CLEAR routine into WHAMCLS.BAS (renaming it WHAMCLT.BAS), but it performed correctly, so the modified CLEAR routine is okay...

Okay, the MAIN ML routine has to be broken up into the POS routine and the SELECT/DRAW portion.  I think I will do that to begin with by just using USR(MAIN$+offset).  The offset should put me right at the SELECT portion, and by reassembling MAIN.SRC, I can see that it starts at $645, so offset = $45, or 69.

On second thought, I've decided to divide MAIN into POS and DRAW routines.  I'll do this by cutting MAIN.SRC into POS.SRC and DRAW.SRC,adding RTS to the end of POS and adding PLA to the beginning of DRAW.  The modified BASIC program will be called WHAMCLM.BAS.

I tried WHAMCLM.BAS, the data was loaded and the screen turned white, but then the Atari crashed.  I believe that the problem is that my BACK address (for the case routines to return) is no longer correct since I split MAIN into POS and DRAW.

7/30 - Back home!  Corrected the BACK address, but now I'm having trouble with the registers I'm using.  $E1 and $E2 (225 and 226) are apparently changing because of the FP math the program is using in BASIC, so I'm changing BACK0 and BACK1 to $D2 and $D3 (210 and 211) instead.  Unfortunately, I have to go back through all 8 case routines and change them.  Sigh...

Okay, I've renamed the program (with the 8 cases modified) WHAMCLN.BAS.  Darn - still crashes...

So $D2 and $D3 don't work, either.  I'll have to check all my page zero locations (except $CB thru $D1) with the same test, making sure I put the END after loading the data file, since that part is what seems to put BASIC into floating-point mode...

You need 19 page zero locations for your routines.  Here's a list of good ones and bad ones:

GOOD:
$3D thru $40 (61 thru 64) - 4 locations, cassette flags
$CB thru $D1 (203 thru 209) - 7 locations, unused by BASIC
$DB thru $DF (219 thru 223) - 5 locations, unused FP extra registers
$E6 thru $EB (230 thru 235) - 6 locations - FP register 2

BAD:
$D2 & $D3 (210 & 211) - reserved for BASIC FP
$D4$ thru $D9 (212 thru 217) - FP register 0
$DA (218) - FP extra register - FP uses it
$E0 thru $E5 (224 thru 229) - FP register 1
$EC thu $FF (236 thru 255) - Misc. used registers

Okay, I'm reformatting all routines to the following:

X1 - $CB (203)
Y1 - $CC (204)
X2 - $CD (205)
Y2 - $CE (206)
E - $CF(207)
DX - $D0 (208)
DY - $D1 (209)
PIXZ - $DB (219)
PIXLO - $DC (220)
PIXHI - $DD (221)
YX4LO - $DE (222)
YX4HI - $DF (223)
JUMP0 - $3D (61)
JUMP1 - $3E (62)
BACK0 - $3F (63)
BACK1 - $40 (64)
HALF - $E6 (230)
CURLO - $E7 (231)
CURHI - $E8 (232)
DATPT0 - $E9 (233)
DATPT1 - $EA (234)

Okay, I've relabeled the modified case routines as RDG6.SRC thru LUS6.SRC, and placed them in the LINE4 directory.

I also modified CLS, POS, and DRAW and saved them with their old names.  I will use WHAMCLN.BAS to hold the modified strings.
I've even created a new disk, ML2WHAM.ATR, which will hold the new routines and program.

Okay, WHAMCLN.BAS has been modified, but still crashes.  It does get through the POS routine okay (reaches line 1200) but crashes on the first time through the DRAW routine (line 1287).  What I'll do now is modify the DRAW routine to be simpler (returning without going to the case routines) and see how far it gets...

Viewing PIST.AWM (all 1032 bytes), I see that the first numbers are $32, $84, $38, $84.  This is the first line in a rectangle (probably the piston).  The two points are (132, 50) and (132,56).  The line is drawn straight down.

Modified DRAW.SRC, taking out the JMP (JUMP0) instruction, and relabeled it DRAW2.SRC.  Inserted it into the program, which was relabeled WHAMCLT.BAS (the "T" is for "test").

I put an END at list 1289, and the program didn't crash.  It never had to go to a case routine, and returned to BASIC from the DRAW routine.
PEEK (61) = 23 (JUMP0).
PEEK (62) = 19 (JUMP1)
JUMP address = 19*256 + 23 = 4887
Something wrong there, I think.

At the begining of the DRAW routine, the instruction should be
LDX #0
not LDA #0, as it was.

Now:
PEEK (61) = 36
PEEK (62) = 45
JUMP address = 45*256 +36 = 11556,
which is the starting address of RDS !!

Entered the changes back in WHAMCLN.BAS and...

The PLAYER PLAYS!  (not very well, though...).  The box and the "rod" aren't bad, but the circle is really terrible.

The lines within a poly are all connected, so the problem can't be with the PIXZ values - it must be the drawing algorithm...

7/31 - Now I'm using WHAMONE.BAS (WHAMCLN scaled down to just accept X1,Y1,X2,Y2) to evaluate line quality.  I have to improve the quality of my 8 cases, which is especially bad for short lines.  I've tweeked them for speed, now I have to get the quality...



FRAME 1:
The box is its own poly, starting from the upper-left corner and drawn counter-clockwise.  Then the rod & circle are drawn (all one piece), with the rod starting at the left side of the box, and continuing counter-clockwise around the circle.

8/2 - Getting over the flu.  I see by using WHAMONE.BAS that the lines are not acceptable.  For example, if I draw a nearly horizontal line that's one pixel in the y-directions, and the line is shorter than 47 pixels, the line is drawn perfectly straight.  Even when the line is longer than 47 pixels, the shift doesn't come in the center of the line, as it should.  I believe the problem is initializing the error value.  It shouldn't be initialized to zero.  I will check my books and figure out how to initialize E....

Here is my drawing routine as it stands (RDG case) :

E=0

For I = 1 to DX
Plot X,Y
E=E+DY
If E < 0 then goto INCX
If E < DX / 2 then goto INCX
E = E - DX
Y = Y + 1

INCX
X = X + 1

Next I

Here is the routine from Newman-Sproull :

E = 2DY - DX		E = DY - DX/2

For I = 1 to DX
Plot X,Y

If E > 0 then
Y = Y + 1
E = E - 2DX		E = E - DX

End If
E = E + 2DY		E = E + DY
X = X + 1

Next I

As we can see, it's basically identical to my routine (when all the E factors are halved, which makes no difference since we are only looking at the sign of E) except for E being initialized to DY - DX/2.  Also, the position of E = E + DY has been changed.  I will try changing those two things to get better lines.  First, I will try E = DY - DX/2.  This should be easy to do, since I have already halved DX.

Okay.  The problem has nothing to do with my algorithm, or the initial value of E.  Those things were all fine.  The problem was with how I was doing comparisons with E.

Recall that in earlier versions of the case routines, I was using DX/4 and DY/4 to increment and decrement E; otherwise E would become to large to accurately hold in one byte.  Using DX/4 and DY/4 severely hurt the accuracy of the line drawing, though (accurate only to 4 pixels).  Then I found that for GRAPHICS 22, E would never be greater than 174 (0,0 to 159,95) or less than -78 (0,0 to 159,1).  That meant that I could use 1 byte (255 possibilities) to cover all the needed values.  I would just have make some adjustments to the way I tested E.  What I came up with was to compare E to 176 to see if it was in the 0 to -80 range and if so, note that it was negative and not compare it to DX/2 (where it would be interpreted as positive).  The problem was that in using the instruction CMP #176, a negative would be assumed if the result was over 128!  E's of 0 to 46 never yielded a change in Y (for RDG) so short lines were drawn wrong.  I changed CMP #176 to SBC #176 and BCS INCXPIXEL, using the carry flag, for correct results.  The new routines are RDG7, RDS7, etc.  I decided to delete the previous versions (RDG6,etc.) from the Atari drive, since I have all the source code in PC format anyway...

Another little change I made was to remove a SEC instruction just before subtracting DX from E (in RDG, it is at the beginning of INCYPIXEL).  There is no need to set the carry flag here, since the one-byte subtraction won't use it, and the carry flag is always cleared a couple instructions later.  I've changed all the case routines and renumbered them, and will reinsert them onto the Atari disk...

8/3 -  Okay, I've completed WHAMCLO.BAS, and it's better, but still not as good as it needs to be.  In playing PIST.AWM, the rod and wheel are drawn together as one polygon.The cumulative error of continuous line drawing with no repositioning is too great, and the wheel ends up looking like an unwinding spring.  I didn't want to reposition for each line of a poly, because of speed loss, but I guess I'll have to.  It make cause some disconnect between lines, so we'll see if that's acceptable...

That's better, but it's still "ragged", and slower.  Now I'm going to go through an exercise to evaluate the cumulative error in making mulitple draws after one position instruction.  I'll call the program LINEFIX.BAS, and I'll put it on its own disk, DRAWFIX.ATR.  I'll draw a circle in the center of the screen, using calculated points and the PLOT and DRAWTO commands, and then I'll try to draw over it with my routines and attempt to discover where I've gone wrong...

8/4 - Okay, I'm using LINEFIX3.BAS to find out where the routines are a little off.  In so doing I found a mistake in LDG7.SRC and LUG7.SRC.  I've initialized $E to zero, instead of E...

Okay, here's the list of case routine ailments:

RDG7 & RDS - okay
RUG7 - Adds 1 to Y2 (must increase DY)
(fixed by adding INC DY at start - RUG8.SRC)
RUS7 - Adds 1 to X2 and Y2 (must decrease DX, increase DY)
(fixed by adding DEC DX, INC DY at start - RUS8.SRC)
LDG7 - Adds 1 to X2 (must increase DX)
(fixed by adding INC DX at start - LDG8.SRC)
LDS7 - Adds 1 to X2 (must increase DX)
(fixed by adding INC DX at start - LDS8.SRC)
LUG7 - Adds 1 to X2 and Y2 (must increase DX and DY)
(fixed by adding INC DX, INC DY at start - LUG8.SRC)
LUS7 - Adds 1 to Y2 (must increase DY)
(fixed by adding INC DY at start - LUS8.SRC)

Okay, the drawing routines are now good enough to draw more complicated animations (SPACE.AWM) recognizably, but they still are not completely accurate, and when a figure overlaps a screen border, especially the top or bottom, bad things happpen.  Still, I'm going to proceed on with converting the frame-draws to ML.  I can always go back and continue to refine the case routines.  The current program is called WHAMCLO.BAS.

I modified the new WHAMCLO.BAS to WHAMCLP.BAS (run position routine for every line) and it might be a little slower, but the drawing quality is definitely acceptable now.  Ultimately, the speed wouldn't be that much of a factor, and I wouldn't have to worry about keeping polys small when I first traced the animation...

Okay, all work has been consolidated onto ML3WHAM.ATR, where I shall start the frame draw ML routine.  It will be called FRAME.SRC, and it will contain both POS.SRC and DRAW.SRC.  To start with, I won't even separate the two.

8/7/07 - So, I've started to write FRAME.SRC.  It would be nice to make

LDA (DATPT0),Y
INC DATPT0
BNE SAMEBYTE
INC DATPT1
SAMEBYTE RTS

into a "DATLOAD" subroutine, but I can't do that until I put my frame routine into page 6, instead of in a char string.  You know, perhaps it's time to go back to page 6.  The POS and DRAW routines together are only 128 bytes, and I have $600 to $6E7 free (232 bytes).  Will the extra stuff take up more than 100 bytes?  It will cut out bytes if I can use subroutines, for sure.  You know, I could assemble it and save it as a BIN file and just load it from DOS, until I got it running...

8/8 - I found that I needed another 2 page zero locations, to store BASE0 and BASE1 for when the animation was restarted and DATPT0 and DATPT1 needed to be reset.  You see, even though the frame routine is currently limited to drawing frames, it still has to reset the data pointer when the animation is restarted.
Anyway, I obtained the extra locations by changing the CURLO and CURHI locations in the CLS routine from $E7 and $E8 to $DE and $DF (CLS is relabeled CL).  It will be sharing these locations with YX4LO and YX4HI of the frame routine, but it won't matter because the two routines run at different times, and all the values are temporary.  So, I'm then free to use $E7 and $E8 for BASE0 and BASE1 in the frame routine.  The BASE0 and BASE1 values are constants, established when the BASIC program starts ("BASE=ADR(DAT$)") so those locations ($E7 and $E8) can't be used for any other purpose...

Okay, I just assembled FRAME.SRC, and the whole routine is 188 bytes, but there's some problems with the branches being too long (>128 bytes).

Now it's 191 bytes, but all the branches are short.  However, the code is NOT relocatable (can't put it into a string), so I may have to modify it in the future...

AWESOME!  IT WORKS!  - Hard to believe.

We'll let's time it for PIST.AWM:

Okay, 10 repetitions is 160 frames, and take 12 sec.  That's 13 frames per sec.
For DEMO1A, the 60 frames took 4.9 sec.  That's 12.24 FPS.
So WHAMF.BAS is 2 -3 times as fast as WHAMCLS.BAS

Whoa-ho!  I used Turbo Basic, and not only is it faster, but it includes a BLOAD command, so that I can load FRAME.BIN without going to DOS!  Time for the 60 frames of DEMO1A was 3.0 sec.  20FPS!!  Now to try the Turbo Basic Compiler...

10 repetitions (600 frames) in 25.6 sec.  That's 23.4 FPS.  Decent speed, one must say...
The first frame of DEMO1A.AWM is 110 bytes, 42 lines.  If this is typical, then 984 lines per second could be displayed (I had been shooting for 600 lines per second).  However these may be smaller than normal lines, and frame 1 may be the largest frame, skewing the results.  Let's try DEMO1B.AWM...

27.45 sec for 600 frames - 21.85 FPS, still not bad.

CAR108.AWM - The big test.  The file is 26,033 in size, so I had to DIM D$(29,000).  When I first tried 31,000 there wasn't enought mem left for GRAPHICS 22 page flipping...

5 repetitions of 108 frames is 540 frames in 37.2 sec, or 14.5 frames per sec.  That's almost 14 times as fast as normal BASIC!

Okay, the next challenge is to figure out how to fix the garbage which occurs at the bottom of the screen when I try to draw with Y's higher than about 85.  I can rescale my anims, of course, but that's not fixing the problem, that's running away from it...

8/9 - I figured out the problem with the garbage at the bottom of the screen.  For some reason, I had CL$ (the clear routine) set to clear only 8 memory pages, instead of 9.  Since GRAPHICS 22 screens are slightly OVER 2K, it is crucial to clear 9 pages...

I discovered that I CAN play CAR124.AWM, with DAT$ dimmed at 29,000.  On the downside, I also discovered that I can't use Atari 130XE's extra 64K as a continuous block, and neither BASIC nor Turbo BASIC will recognize the extra memory, so I guess that 29K is the largest animation I can run...

CAR124.AWM runs in 8.5 sec (14.6 FPS).  Quality is okay, but the tire wheels and trees have "wicks"  because the rounded edges use so many lines, which many times are off by a pixel.  Some day I will correct those drawing routines...

It takes CAR124.AWM 1 min. 25 sec. to load, at normal Atari disk speed.  SPACE.AWM (8KB) takes 25 sec. to load.

Turns out that I can DIM DAT$ to 30,000 and still run CAR124.AWM.

To summarize, I'm currently running WHAMFTB.BAS, which has been compiled to WHAM.CTB on TBASIC.ATR (in drive 1).  WHAMFTB.BAS differs from WHAMF.BAS in that it includes BLOAD "D2:FRAME.BIN", which works in TBASIC but not in regular Atari BASIC (Atari BASIC has no BLOAD command).  The WHAMFTB.BAS program also utilizes the 8 case routines as character strings, originating from RDG8.SRC thru LUS8.SRC.  The CL$ string routine (CLEAR FRAME), reuses $DE and $DF as CURLO and CURHI, and clears 9 pages.  To show an animation, I have TBASIC.ATR in drive 1 and the animation disk in drive 2.  I go to DOS, use L to load RUNTIME.COM from D1, load WHAM.CTB from D1, and then load the animation from D2.  This will be simplified when I make an autorun file to load the RUNTIME module, the player, and the animation...

8/10 - Okay, I could start working on movies, or work on steady timing for 12FPS.  One goal for movies is to create something meaningful, 30 sec. long, that runs on Atari.  Thats 360 frames, and to fit into 30K, frames would have to average 83 bytes or less.  That's significantly less lines than SPACE.AWM, which is about 112 bytes per frame.  Something like a dancing leaf would certainly work, though, as would my story of a leaf with personality...

Steady timing for 12FPS - It was remarkably easy!  Just two statments in BASIC:

965 IF PEEK(20)<T THEN 965
967 POKE 20,0

These are inserted in two places, at the beginning of the SCREEN 1 section, and at the beginning of the SCREEN 2 section.  Then

PRINT "JIFFIES PER FRAME";:INPUT T

is added right after the filename prompt, and we're all set.

The timing is very accurate!  Timing SPACE.AWM at 5 jiffies yielded 11.99 FPS, and 4 jiffies yielded 15.001 FPS.  The only downside was that while SPACE.AWM will run at 20.2 FPS without the timing statements in the program, it will only do 18.5 FPS with jiffies set to 3, and only 19.5 FPS with jiffies set to 2.  But, let's compile and see what happens...

Compiled version is much better.  SPACE.AWM with jiffies=3 runs at 19.95 FPS...

So, timing is good for now.  I could now work on movies, or look at the two problems still remaining.  The small problem is to go back and figure out once and for all why my case routines aren't completely correct.  RDG and RDS work fine by themselves (check on that again, though...) but the others alll need an offset to correct them, which ends up making them inaccurate at some point.

The second problem is how to make the animations load faster.  This could be a big problem, as I've heard that it's tough to load from disk using ML.  However, if I look through my reference books, I may find that someone else has already figured out a solution for this...

I started to think about the idea of simply reading DAT$ from the data file in BASIC, figuring it would put DAT$ where I DIMMED it, but I'm having trouble with ERROR 136 (EOF).

I also got started back in the direction of transferring ATR files to the real Atari.  Xformer 2000 might give me an option of making a cable to connect my Atari drive to PC through the printer port, and I'll try again with APE, using that SIO2PC board, which may or may not be broken...

8/12 (1am) - Finished "inking" (tracing) Boxes.awm, pretty impressive - 120 frames, 8.8KB, runs at 20 FPS.

One thing I can try in Turbo BASIC is BGET and BPUT, block commands that I could use instead of GET and PUT and which might be faster...

I could also try a BLOAD of a WHAM file, if I can find a way to specify where in memory it goes - evaluate one of your existing BIN files to see it the mem location is listed at the start...

9:30am - Well, BGET and BPUT didn't work, but I think that BLOAD will.  I evaluated an Atari BIN file (FRAME.BIN) using HexEdit, and it is staightforward:

FF FF - The first 2 bytes
00 06 - The starting address (LSB first)
BE 06 - The end address (1726 in this case, 191 bytes)
68 - The first instruction (PLA)
.
.
60 - The last instruction (RTS)

So all I have to do is doctor my AWM files to look like this format.  It will be no trouble putting in the proper length, but the starting address will be ADR(DAT$), so hopefully that won't change - bad programming technique, I know, but I really want to speed up the data loading...

With DIM DAT$(10000), ADR(DAT$) = 18301

However, if I change the size of the BASIC program, it pushes DAT$ up.  Adding several lines of PRINT "HI" pushed DAT$ up to 18357.

When running the compiled version, DAT$ starts at 12276.
When I change the BASIC version to DIM DAT$(24000), it runs fine and ADR(DAT$) = 18295.

Okay, the good news is that TurboBASIC will BLOAD a file on top of an area previously dimensioned, without complaining.  The STRANGE news is that when I BLOADed BOXES2.AWM, it was supposed to start at $5000 (20480), but ended up starting at 20490!  Why the extra 10 bytes.  Don't know, but I'll just tweek around it for now...
I've now done away with the "+10 tweek", and the player works fine!  Loads very fast!  Current name is WHAMGTB.BAS, but I'm starting ML6WHAM.ATR and I'll just call the program WHAM.BAS.  I'll automatically change DAT$ from 24,000 to 30,000 before I compile it...

Okay, now everything works.  CAR2.AWM has a header that places it in memory from $3000 to $9E16 (12,288 to 40,470) and is about the largest animation I'll see.  At normal Atari disk speeds, it now loads in 20 sec (very reasonable) and BOXES2.AWM which goes into memory from $5000 (20,480) to $7258 (29,272), loads in 6.5 sec.

9pm - Well, I certainly have been knocking down the problems, one by one, mostly within BASIC.  Now that I have 12fps timing and data quickloading in hand, I COULD go back and improve the line-drawing routines, or I COULD make some animations, but for now I think I'll explore Turbo Basic's DIR instruction, to see if it makes a "file requestor"...

There is no file requestor, but there is a disk directory, and now I'm trying to make a startup disk that will allow the user to easily select a movie and play it.  It works fine with BOXES.AWM, but not with CAR.AWM, so I fear I may be getting tight on dimensioned space again...

8/13 - Aha!  Now I see that DAT$ is starting at 12,423 ($3087), so CAR.AWM has to go past that.  We'll store CAR.AWM at $3200 (12,800) to $A016 (40982) and see if that works...

It works fine!  Now I've taken all existing AWM movies and converted them to the new format.

Here is a list a movies and where in memory they're stored.  Remember that the actual file will have 6 more bytes than the animation itself (listed below), since the header is 6 bytes:

CAR.AWM - $3200 to $A016 (12,800 to 40982) - 28,183 bytes
BOXES.AWM - $5000 to $7258 (20,480 to 29,272) - 8793 bytes
SPACE.AWM - $5000 to $6EA1 (20,480 to 28,321) - 7842 bytes
DEMO1A.AWM - $5000 to $6BE3 (20,480 to 27,619) - 7140 bytes
DEMO1B.AWM - $5000 to $6AC8 (20,480 to 27,336) - 6857 bytes
WALK.AWM - $5000 to $5703 (20,480 to 22,275) - 1796 bytes
PIST.AWM - $5000 to $5407 (20,480 to 21,511) - 1032 bytes
DEMO2.AWM - $3200 to $8B48 (12,800 to 53656) - 22857 bytes
DEMO1AB.AWM - $5000 to $86AC (20,480 to 34476) - 13997 bytes

Now I've got everything set for the user with the bootable WHAMDISK.ATR.  A directory of the files comes up, and the user just types one in.  The user can abort with the BREAK key, and select R to run another movie.  I've included instructions, and on ML6WHAM.ATR, there are two similar files:

WHAM.BAS is the BASIC-runnable version, with DAT$ DIMMed at 24,000 and D2: as the reference drive for files

WHAMC.BAS is the version to be compiled and put on bootable disk.
DAT$ is 30,000 and D1: is the reference drive.

Later I tried to make a boot disk with 130KB so that I could fit the DEMO2.AWM file on it also.  DOS 2.5 kept giving me trouble - when I went over the basic 90KB size, the files would be shown with brackets <> around them.  If they were AWM files, they couldn't be found by the player.  Finally I made a 130K disk (WDISK2.ATR) on which I copied the AWM files first, and the brackets around the other files, AUTORUN.CTB, AUTORUN.SYS, etc. don't seem to matter - the disk runs fine...

8/14 - Okay, now it's back to see if I can do a better job with the case routines.  To do this, I've created LFOLD.BAS on  ML3WHAM.ATR.  LFOLD.BAS is LINEFIX.BAS, with the version 7 routines used instead of version 8 (which were a "band-aid" fix of 7).  RDG7 and RDS7 always worked fine.  We'll start working on RUG7, which added 1 to Y2 when it plotted...

Okay, I found out what was wrong with RUG7 - nothing!  The problem came when I used DRAW.SRC and tried to save 1 byte (2 cycles) by removing the SEC instruction for the Y2-Y1 subtraction in the "UP" case.

Now I've added the SEC back into the right-left routine.  Everything is fixed except RUS and LUS.  RUS adds 1 to X2 and LUS subtracts 1 from X2.

Found it - RUS and LUS were missing a CLC (which I thought was unimportant).  Okay, here's my plan - every case will be upgraded to version 9.  CLC's and SEC's will ALWAYS be used when there is and ADC or SBC (in all routines).  I was naive to think that they weren't needed if the carry flag wasn't checked.  They DO affect the result of the math in many cases!!!

8/15 (49th birthday!) - I'd translated all the case routines to version 9, as well as the frame routine, adding all those CLC's and SEC's, but the program was crashing.  Then last night I did it again (forgot the disk) an this time it worked.  No more spikey trees in CAR.AWM!  I've put all the version 8 and version 9 case and frame routines into vers8 and vers9 directories (renamed from line5 and line6).

Now on ML7WHAM.ATR, I'll relabel everything as WHAM.BAS, WHAMC.BAS, etc. and never see the spikey trees again...

WHAMDISK has now been updated, and everything runs very well.  No more spikes in PIST.AWM or in DEMO1B.AWM.

Next up is to try again to see if I can have just one position routine for each poly.  This will mainly involve modifying FRAME (and also the return address - specified in WHAM.BAS - for the case routines).

Well, it's still quite evident that the "one plot per polygon" idea is "not ready for Prime Time".  I modified the frame routine (now stored as FRAME10.SRC in the "vers9" directory), but the results were only slightly better than before.  The boxes wobble about (although relatively not too bad), the wheel of the piston is too big (although it is closed, at least) and rotates off center, SPACE.AWM and DEMO1B.AWM look like a 3-year-old's drawings as the lines dance all over the place.  For a speed test, I used 600 frames from DEMO1B.AWM running with uncompiled Turbo Basic and jiffies set at 0.  "One plot per poly" offered less than 5% speed increase over the current program (33.5 sec vs. 35.0 sec.), which is pretty much what you would expect.  DEMO1B.AWM was the type of anim which would have most benefitted from the new routine, since it has lots of short lines.

I was going to try to optimize the current version, FRAME9.SRC, a little more, but why?  Even if I doubled the speed per line, say from 200 to 100 cycles (probably impossible to do), it would still be a speed increase of only 5%, 10% at most.  Why bother?

A better idea is to work on getting the whole animation loop into ML.  It make be taking a lot of time to go back and forth to BASIC between frames.  Can I add the clear routine to the frame routine (only 33 bytes) and still make it all fit in a 256 byte space?  Ah, ha!  Now I have another challenge...

Well, I started on ANIM.SRC, to put the whole animation loop into ML, but then I realized that I'd need more variables for the start of screen memory SC1L, SC1H, SC2L, SC2H, and for the display list (DL1 and DL2), so I decided to do it one chunk at a time.  I modified FRAME9.SRC and called it FRAME10.SRC, which combines the CLEAR routine with frame draw.  Results for 600 frames of DEMO1B.AWM with uncompiled TB and jiffies = 0 were 33.0 sec!  Better than "one plot per poly" and MUCH cleaner!

8/16 - Two directions today.  One is continued optimization of the players.  It occurs to me that the case routines (version 9) can be optimized more.  The section to compare E with 176 could be eliminated.  Let's look at RDG9.SRC as an example.  The section consists of:

SEC  -  2 cycles
SBC #176  -  2 cycles
BCS INCXPIXEL  -  2 cycles
LDA E  - 3 cycles

This is very expensive - 9 cycles!  It would be great if we could eliminate it, keeping E in the accumulator during CMP HALF.

For GRAPHICS 22, we know that E will always be between (-78) and (+174).  What if we made E always positive?  What if we started E at 80?  The comparison factor (DX / 2) would have 80 added to it also.  E could then swing between 2 and 254.  Since E only undergoes addition and subtraction during the inner loop, it shouldn't matter that we add 80 to both E and DX / 2.  WORTH A TRY!

It works, and saves 9 cycles for the innner loops of all cases.  I started to make another optimization to RDG.  I moved the INCXPIXEL section up, just below ORA and STA (PIXLO).  This enabled me to use the existing LDA PIXZ and change the two ROR PIZ instructions to ROR A.  I then had to add an STA PIXZ struction at the end of the INCXPIXEL section.  This would have saved me 3 cycles altogther, but only when the byte changed, which was one time out of 8.  So the savings really would have been 3/8 cycle.  Plus, it wouldn't have worked on the steep cases, because for them, INCYPIXEL and DECYPIXEL would have occurred every time, and those routines don't use PIXZ.  So, the whole savings would have averaged 3/16 cycle, with the downside of making the routines less uniform and harder to understand.  So, I just stick with my 9 cycle savings for removing the SBC #176 group.  I'll call the new routines RDG10.SRC, etc.

9/17 - Well, I got the mod completed, and I was looking for something like a 10% speedup, but I only got about 5% (600 frames of DEMO1B.AWM with uncompiled TB and jiffies=0 was 31.5 sec).
I believe that this is because often the program didn't get to the 2nd compare, so I wasn't really saving the full 9 cycles.  The FINAL speedup will be, of course, when I convert the entire animation loop to ML.

Just for yucks, let's look at the worst-case line, LDS10, which like LUS10, has that awful DECXPIXEL routine every time around.  Total worst-case cycles would be 89, but let's see the real average:
```
 1st 29 cycles - Always
LOOP LDA PIXZ		3
 ORA (PIXLO),Y		5
 STA (PIXLO),Y		5
 LDA E			3
 CLC			2
 ADC DY		3
 STA E			3
 CMP HALF		3
 BMI DECXPIXEL	2

Next 20 - Only if rise
 SEC			2
INCYPIXEL SBC DX	3
 STA E			3
 CLC			2
 LDA PIXLO		3
 ADC #20		2
 STA PIXLO		3
 BCC DECXPIXEL	2

Next 5 - Only if rise and 1 of 256
 INC PIXHI		5

Next 9 - Always
DECXPIXEL CLC 	2
 ROL PIXZ		5
 BCC SAMEBYTE	2

Next 17 - Only if 1 of 8
 ROL PIXZ		5
 SEC			2
 LDA PIXLO		3
 SBC #1		2
 STA PIXLO		3
 BCS SAMEBYTE	2

Next 5 - Only if 1 of 8 and 1 of 256
 DEC PIXHI		5

Next 4 - Always
 SAMEBYTE DEX	2
 BNE LOOP		2
 JMP (BACK)
```
Let's assume that we have rise 1/2 the time, which is reasonable.  The totals are:

Always = 42
20 rise x 1/2 = 10
5 x 1/2 x 1/256 = .01
17 x 1/8 = 2.125
5 x 1/8 x 1/256 = .0025

Total = very close to 54

Yikes!  I just found that there's an ANOMOLY involving CAR.AWM and RDG10!  For some reason, one of the lines of the house moves for a couple of frames, and it's caused by RDG10.  I've tried changing a bunch of things in RDG10, but I can't seem to fix it.  What I'll do is use RDG9 with version 10 of the other routines, all on ML8WHAM.ATR.  On ML7WHAM.ATR, I'll have the "safe" programs, using all version 9 case routines.  Similarly, with the WAMDISKS.  WHAMDISK.ATR will alway be the current disk.  WDISK1.ATR will have the old "spikey" program, WDISK2 will have the version 9, and WDISK3 will have version 10 with RDG9...

Okay, comparing the speed of the WDISK2 and WDISK3 players.

For 50 revolutions (800 frames) of PIST.AWM at jiffies=0:

WDISK2 = 31.06 sec (25.8 FPS)
WDISK3 = 30.16 sec (26.5 FPS)
3% speed increase

For 5 revolutions (600 frames) of BOXES.AWM at jiffies=0

WDISK2 = 30.15 sec (19.9 FPS)
WDISK3 = 28.97 sec (20.7 FPS)
3% speed increase

For 10 revolutions (700 frames) of SPACE.AWM at jiffies=0

WDISK2 = 29.44 sec (23.8 FPS)
WDISK3 = 28.75 sec (24.35 FPS)
2.4% speed increase

The new player is able to play CAR.AWM at exactly 12FPS with jiffies = 5.

The 1st 40 frames of CAR.AWM take 11,300 bytes, or 282.5 bytes per frame.  Therefore, the player is playing 3390 bytes per sec.

A typical frame (frame 4) consisted of 277 bytes and 87 lines.  The final frame, 120 was 160 bytes and 63 lines.  So number of lines was fairly consistent, even if number of pixels plotted varied a lot.

Okay, back to the idea of putting the whole animation loop into ML.  FRAME.BIN (FRAME10) currently takes up 222 bytes, from $600 to $6DD.  The address table and the Z-table take up $6E8 to $6FF, so $6DE to $6E7 (10 bytes) are all that's left.  It doesn't look good.  The CLEAR routine might have to go back to being a string, and jump back like the case routines do.  However, that would use up another couple of page zero addresses, UNLESS I HARD-WIRED THEM INTO the ROUTINE.  Now that's an idea!  I could do the same with the case routines and save time and page zero space...

8/18/07 - Different approach now, though.  I think it's a bad idea to hardwire.  Also, I want to see what the maximum benefit is from converting to ML.  So, my approach is simple.  Since the BASIC portion currently provides only timing and page-flipping, I'll get rid of those two things and check the performance.  It just means moving the first USR call to after the SHOW remark, and modifying FRAME.SRC so tht it loops and never returns to BASIC.  The screen will be flickery, but I'll get a good idea of the maximum speed atainable.  Now, off to it!

Results:

For 50 revolutions (800 frames) of PIST.AWM:
All ML -  28.70 sec
WHAM no timer - 29.90 sec

For 5 revolutions (600 frames) of BOXES.AWM:
All ML - 28.10 sec
WHAM no timer - 28.97 sec

For 10 revolutions (700 frames) of SPACE.AWM:
All ML - 27.47 sec
WHAM no timer - 28.56

NOT WORTH IT
We now see that the speedup by going to ML would be 4% or less (remember you still would have to add the extra instructions to FRAME.BIN and then find room for it).  And the downside of going for that 3-4% is too great.  There is no way to stop an animation running on the all-ML player, except to reboot.  Compiled TB gives a lovely way (BREAK key) to exit an animation and start another one as it is, with none of the speed penalty which would be incurred by constantly checking the keyboard in BASIC.  Also, if you can afford to lose some speed, the option to stop the animation and change the speed (without reloading) is always there.  When the system is transferred to the real Atari, loading times for the operating system and for animations will be long.  The all-ML version would require the user to reboot the system to play each new animation, and that's just not worth an extra 3-4% speedup...

Thus, optimization is now pretty much finished.  The only change in the forseeable future might be to upgrade RDG to version 10 if I found out what caused the CAR anomoly, or to downgrade all the case routines to version 9 if I have trouble with any new animations.  Again, the interface might be improved, and give the option to change speed.

A GRAPHICS 30 version?  Possible, but it would take more RAM, more programming (gnarly), slow down the player, and restrict animation length.

No this concept was really meant to be implemented in GRAPHICS 22, using Compiled Turbo Basic, and displaying this awesome 1-byte WHAM format I've created.  I have to be happy with the way it's worked out.  No, it's not GRAPHICS 8, there's no sound or text, no 100K animation on extended RAM, and for all the world, it's only the old 8-bit Atari.  But it was something I set out to do nearly 2 years ago (the earliest reference I could find was from 12/3/05, which was an entry in WHAM.ABC...).

And the player is not fast, but it is fast enough to tell stories...

And the animations will not be long, but long enough to tell stories...

And the pictures will not be beautiful, but they will be enough...

AND I DID IT !!!!!!!


8/22/07 - Well, that was all very dramatic...

In actuality, though, I slightly missed the mark on my performance goal.  The goal was to have an average frame of 30 lines 50 pixels long (or 50 lines 30 pixels long) which would play at 12FPS.  That would require the player to draw a pixel every 100 machine cycles.  I made some test animations to try this (TEST.AWM, TEST2.AWM, TEST3.AWM).  "Test" has all 30 lines vertical.  This easily plays at 12FPS, for obvious reasons.  "Test2" demonstrates the worst case, all lines being 45 degrees.  It runs at only 11.25 FPS.  "Test3" was my best estimate for an average case, all lines being about 22.5 degrees.  It runs at 11.375 FPS, meaning that each pixel takes 105.5 cycles.  Now I've created "Test4", which is 50 lines of 30 pixels, sloped at 22.5 degrees.  This one runs at 10.75 FPS, which comes to 111.5 cycles per pixel.  A little off the mark but very close, so I have nothing to be ashamed about...


Now we come to the point where it's time to start modifiying your own behavior.  You need to be thinking of good stories to produce.  But also, you need to become very good at using the CHARACTER ANIMATION CAPABILITIES of your creation software.  Your principle programs are Lightwave 5.0, Animation:Master 7.1, trueSpace 4.3, Real 3D 3.5, and Poser 3.  These versions of these programs have been chosen because they have IK and motion graphs and are capable of being run from your tablet.  You are now in a world where:

1) Lighting doesn't matter (except in some odd cases when you want to show shadows as outlines)
2) Texturing doesn't matter
3) Modeling is CRUCIAL, but is based on simplicity and clarity of design, not great detail and complexity.
4) Motion is ABSOLUTELY CRUCIAL.
5) Character Rigging is ABSOLUTELY CRUCIAL.
6) Timing is ABSOLUTELY CRUCIAL.
7) Staging / Layout is ABSOLUTELY CRUCIAL.
8) Story is ABSOLUTLEY CRUCIAL.

Interesting point now.  Without shadows, it is often difficult to show position and depth.  Possibly it will become commonplace for me to use a few stray lines to indicate shadows.

The Real 3D User's Guide had a good point.  You can set up an icon to load an environment in Real 3D automatically when it starts up.  THIS SHOULD BE DONE WITH ALL YOUR SOFTWARE, IF POSSIBLE.  All startup environments could be taylored for hidden-line creation and rendering.

12/1/07 - A few months later, and I seem to have another modification to make to my Atari WAM player.  I'm currently writing a story about two tennis players, and I decided that it would be very useful to render single points (as for the eyes of the players).  This could be done in only 3 bytes.  I put together a test file (Test.wam) of only single points, and the VB player and QB player render it find, but the Atari player won't because od the I had saved some steps.

12/12/07 - For now, I've given up on the idea of plotting single points in the Atari player.  When I use FRAME10P.BIN with the player, it does work, but it plots extra points, meaning the lines are drawn too far, and "spikeiness" emerges.  To avoid this, I'd have to modify all 8 case routines (and re-enter them as strings in the BASIC program) of course debugging and recompiling again.  I don't want to do this right now, since I'm immersed in story and I don't see using single points in the foreseeable future...

 Epilogue - 2/10/08

I've now written an Amiga player (WHAM1) in Compiled AMOS Basic.  The compiled version doesn't run much faster than the native (uncompiled) version, which is pretty slow.  CAR.WAM runs about 5FPS (320x200 res), and about 3FPS when the house is in the scene.  PIST.WAM runs about 13 FPS, BOXES.WAM about 12FPS (pulling data from a file in RAM), and SPACE.WAM runs about 8 FPS.

So, to do a comparision, CAR.AWM runs at about 1 FPS on an Atari with uncompiled BASIC (160x96 res), 3-5 FPS on an Amiga with compiled AMOS (320x200 res) and 12FPS on an Atari with compiled TurboBasic and my drawing routines (160x96 res).

The bottom line is that the Amiga drawing speed is too slow, even when compiled and run on a 50MHz A2000.  I just used DRAW TO and PLOT statements, and I don't have the energy to try to write my own ML drawing routines like I did for the Atari.

2/16/08 - The final chapter in the the creation of the Atari WHAM player is now over.  I finally got the SIO2PC hardware to work, running with APE for Windows on a 2300 tablet.  I was able at last to transfer files between the PC and the Atari, and thus was able to transfer the WHAM player and WAM animations to a real Atari 800XL and play them.  Performance was pretty much what I expected - play speed was exactly the same as the emulator, while loading from floppy was just a little slower than expected (28 sec for CAR.AWM).  The animations look fine and run great, BOXES.AWM spinning endlessly on the Atari screen at a full 20 FPS.  I feel a great deal of satisfaction now, knowing that this thing I created runs on a real Atari machine.  There will be more animations in the future, for sure, to demonstrate what the Atari can still do...

5/6/08 - The largest animation yet, HOUSE15.AWM, 29,923 bytes (29,929 with header), stored from 3100h to A5E2h.  It is 318 frames playing at 15FPS, 21.2 sec.  Had to cut 57 frames from original 375-frame 15FPS anim.

And onward...

10/11/09 - I've been writing the documentation for the Atari WAM player (we're up to version 11 now - WHAM11.BAS and FRAME11.BAS) and it turns out that I've trying to fix the software at the same time.  I converted FLIP (Starline) from the PC version and found that there were still some stray lines.  At the time, I just corrected the lines with  HexEdit, but now I want to actually fix the line-drawing routines.  What I'll do is convert FLIP.AWM again, but shorten it to just the necessary frames.  I'll find the first line that's bad and figure out what routine it calls.  Then I'll construct a BASIC program which goes through the same steps (but in BASIC) to draw the line, and play with it until I can get it to work...

TEST.AWM is made up of 10 lines, 6 of which are not drawn correctly.  From the top, the lines are as follows:

Line 1(RDG) - 25, 9 to 158,12, DX = 123, DY = 3, drawn correctly
Line 2 (LDG) - 158,14 to 0,18, DX = -158, DY = 4, drawn too steep, steps drop 2 pixels
Line 3 (RDG) - 0,26  to 159,28, DX = 159. DY = 2, drawn correctly
Line 4 (LDG) - 159, 32 to 0,34, DX = -159, DY = 2, drawn too steep, steps drop 2 pixels
All RDG's okay, all LDG's too steep, with 2 pixel drop.

I decided to try a bigger challenge.  TEST2.AWM is made up of lines 12 lines that use every routine.  Not only did it draw lines wrong, but it left garbage in the bottom half of the screen.  TEST3.AWM is a shortened version of test 210/13, with no steep lines.  It left garbage also.  In TEST4.AWM, I'd eliminated all but two lines, one RDG and one LUG.  It still left garbage!  It looks like RDG might be the only routine working, for long lines...

I tried to substitute what I thought were all the vers. 9 routines back into the program, calling it WHAM12.BAS, and run it from BASIC with DAT$ cut down to 20KB.  It totally crashed the Atari...

Okay, let's try again with WHAM12.BAS (from BASIC).  We'll reassemble LDG9, put it in a string, and try playing TEST.AWM again...

That works.  Version 9 of RDG and LDG work okay.  Now we'll try vers. 9 of RUG and LUG.  Yes, it fixed TEST4.

10/13/09 - Now I've put all the version 9 routines into WHAM13.BAS, and TEST2 runs perfectly!

10/15/09 - Tried to redo the line routines (vers. 12 on WHAMDEV12.ATR) but the first one, RDG12, doesn't work right on TEST2.AWM.  Problem line is 00,16 to 9E,27 (0,22 to 158,39.  Got to fix it.  DX = 158 (9E), DY = 17 (11).

Okay, I've found the problem.  It's the CMP instruction on line 260.  After the 2nd pixel is plotted, E=19.  Line 260 tests the accumulator against 160 by subtracting to get       -141.  But CMP only sets the negative flag for numbers 128 or greater and  -141 is the  same as +115.  So the BMI instruction on line 270 sees no negative flag set, so it doesn't branch...

This could work to my favor.  What if I go back to E=0...

10/26/09 - Now it's all "water over the dam", "water under the bridge".  The documentation is finished ("Instructions.rtf") and the drawing routines are optimized.  Everything (WHAM, FRAME, RDG, etc.) is all version 12.  I found that setting E=DX/2 at the beginning and then comparing E to DX did the trick since that made E stay beween 0 and 253 (always a positive number).  I got rid of the variable HALF and defined XTND as the extrend value ($E6), separate from the error value E ($CF).  In so doing, I was able to eliminate initiallizing XTND in FRAME.BIN, saving enough space to move the first two memory-clearing instructions out of WHAM.BAS and back into FRAME.BIN, where they belong.

With the reducing of line-drawing routines by a total of 88 bytes (11 bytes per routine), I was able to dimension DATA$ at 30,250 bytes.  Its starting address is now $315A (12634) instead of $31B2 (12722).

Previously:

DIM DAT$ 30,000, start of DAT$ = $31B2 (12722), end of DAT$ = $A6E1 (42722)
(I think the DIM statement adds an extra element for zero)
If AWM's were started at $3200 (12800), they could only go to 42722 and be 29923 bytes!

Now:

DIM DAT$ 30,250, start of DAT$ = $315A (12634), end of DAT$ = $A784 (42884)

It's all done now, all's well that ends well...


