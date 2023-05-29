# AWM player for Atari 8 bit

Original by Dave Coombs.

Maintaining and formatting the repository in order to open up for collaboration.

Releases will be available via fujinet

fujinet.papa-robot.xyz

TODO:

- Add a Makefile and organize for cross compiling.
- Extract animation examples
- Format documentation in markdown.
- Add more primitives
- Open it for collaboration.

## Understanding Atari WAM Movies (AWM) and the WAM Player for the Atari XL/XE Computers

## Introduction (Dave Coombs)

The WAM movie format (Wire Animated Movie) was an idea that I came up with in December of 2005, or possibly a few months earlier.  The idea was to create animation files that would be the simplest, smallest kind of animated movies.  I decided that I would simply draw line segments from their endpoints, and that these endpoints should be only 2 bytes (one for X, one for Y).  Sequences of endpoint pairs would be used to form "polylines", saving bytes as opposed to specifying each line segment separately.  Also, single bytes would be used as "control bytes" to tell the WAM player to start a new polyline, start a new frame, or start the animation over.

From the beginning, one of my goals was to make animations that were capable of being played on an Atari 800 (or 800XL) computer.  This type of computer, first sold in 1979, is very primitive by today's standards, containing only 64KB of total memory (only about 40KB available to use), no hard drive, very slow floppy drives, and a very slow, simple microprocessor (CPU).  My goal was a frame rate of 12 frames per second, hopefully having enough memory space to play an animation that was 15 to 30 seconds long.  At the same time I was developing the animation player for the Atari, I was also developing two players to use on mainstream PC's, one created with QuickBasic for DOS, and the other created with Visual Basic 3.0 for Windows.  Unlike the Atari player, these PC players can quickly load a large animation and play it at a fast frame rate.  This is because today's mainstream PCs usually have CPU speeds in the Gigahertz (the Atari's is 1.8 Megahertz, 1000 times slower) and disk and memory size much greater than the Atari.  So the PC players I wrote were easily able to pull the endpoint data straight from the hard drive, draw the lines, and display the frames of a typical animation at 24 frames per second or more.

On the Atari, I quickly found out that I would be limited to animations which were 30KB in size!  Animations had to be loaded into memory before they were played because the floppy disk access was too slow to read from the floppy while the animation was playing.  It was crucial to load the animation into one continuous block of memory and 30KB was the largest block I was able to create.  After constant rewriting and re-tweeking, using both compiled BASIC (TurboBasic) and assembly language, I was able to create a player that could play an animation with 100 line segments in each frame, at a rate of 12 frames per second.  This allowed enough detail for reasonably interesting animations.  However, it turns out that the player only works with Atari XL & XE computers, since programs written in TurboBasic (even compiled) won't run on the original Atari 800.
