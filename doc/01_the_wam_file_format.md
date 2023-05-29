# The WAM File Format

The Atari WAM movie file (.awm) is a variation of the PC WAM file (.wam), so I'll cover the PC version first.  The file is very simple, consisting of the X,Y coordinate pairs of the endpoints of lines, as well as the "control bytes" mentioned earlier.  The Y-coordinate of an endpoint is always listed first.  Y-coordinates range from 0 to 240, X-coordinates range from 0 to 255.  The player program reads the Y-coordinate first.  If it is a control byte (250 through 255), then the program stops reading and executes the appropriate function (start new line, start new frame, etc.).  If the Y-coordinate is 240 or less, the program reads the next byte (the X-coordinate), and draws a line to these coordinates from the previously read X,Y pair.  Here is a list of the 6 control bytes:

250 (FA)  - Finished Animation - Signals the end of the animation.  Occurs only once, at the very end of the file.
251 (FB) - Flip Background color (and frame finished) - Changes the background color for effects such as lightning.
252 (FC) - Flip Color (line color) - Signals the end of a polyline, and a new color for the next polyline.
253 (FD) - Finished Drawing - Signals the end of a polyline.
254 (FE) - Frame Extended (and finished) - Signals the end of a frame and delays the next frame.  Useful for titles.
255 (FF) - Finshed Frame - Signals the end of a frame.

Let's work through a sample animation file.  Say you're examining a WAM file with an editor which shows the bytes in hexadecimal form (hex editor) and the first 20 bytes look like this:

```
7D   D4   8C   D2   8C   F1   7E   F2   FD   83   CF   63   74   FD   7D   C3   89   C3   FF   67
```

The decimal equivalents of these 20 bytes are:

```
125, 212, 140, 210, 140, 241, 126, 242, 253, 131, 207, 99, 116, 253, 125, 195, 137, 195, 255, and 103
```

So, the first point plotted will have a Y-coordinate of 125 and an X-coordinate of 212 (remember, Y is listed first in a WAM file).  A line will then be drawn to the next point, which is 210, 140 (X=210, Y=140).  From there, a line will be drawn to 241,140 and then to 242,126.  Then the player will read 253, which is a "control byte" (FD in hex) which means "Finished Drawing".  So there will be no line segment drawn to 207,131.  A new "polyline" (multiple segments connected end-to-end) will be started at those coordinates.  A single line segment will be drawn to 116,99 before another FD is encountered and another new polyline is started.  Near the end of the list, the player will read 255 (FF), meaning "Finished Frame".  At this time the finished frame (screen picture) will be displayed while the next frame is started.  The 20th number on our list (103) will be the Y-coordinate of the first endpoint in that frame.  The very last number in the whole animation file will always be 250 (FA), meaning "Finished Animation".

So why do the Y-coordinates only go up to 239 (not 255) and why are they listed first?  Well, six of the possible Y-numbers (250 thru 255) are the control bytes and are interpreted as instructions, not coordinates.  It was appropriate to use Y-numbers to do this, because the Y-length of a PC screen is shorter than the X-length, so the lost resolution would be less noticeable.  239 was set as the maximum Y value, creating 240 possible Y-values (0-239). The total of 240 was used, not 250, because 240 is a nice round number and neatly scalable to higher resolutions, which is done by the PC WAM Players.  Anyway, the Y-coordinates are listed first because a control byte needs to be detected and executed before any more data is read.  In other words, the data is normally read in pairs, but a control byte must be read by itself.

The PC players can play the WAM files in a number of different resolutions.  Immediately after each X or Y-coordinate coordinate is read, it is multiplied by some constant value, so when the lines are drawn, the size of a figure simply depends on what constant value was used.  When the player is started, the user is asked for the screen resolution to use, and the constant value is calculated from that.  Popular resolutions are 640x480, 640x350, and 320x240.  Self-playing WAM files (DOS .EXE files) are always played at 640x350 resolution (full-screen) and at 18 frames per second.