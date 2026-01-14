   ; *************************************
   ; * Joystick Demo                     *
   ; * Test joystick input               *
   ; *************************************

   set romsize 32k
   displaymode 160A

   ; Import character graphics
   incgraphic graphics/alphabet_4_wide.png 160A

   ; Variables
   dim cursorx = a
   dim cursory = b

   ; Colors
   P0C1 = $42
   P0C2 = $44
   P0C3 = $0F

   ; Initialize
   cursorx = 80
   cursory = 96

__Loop
   clearscreen
   
   characterset alphabet_4_wide
   plotchars 'joystick test' 0 50 10
   plotchars 'use joystick' 0 50 20
   
   ; Read joystick
   if joy0up && cursory > 16 then cursory = cursory - 1
   if joy0down && cursory < 176 then cursory = cursory + 1
   if joy0left && cursorx > 0 then cursorx = cursorx - 1  
   if joy0right && cursorx < 152 then cursorx = cursorx + 1
   
   ; Draw cursor
   plotchars '.' 0 cursorx cursory
   
   drawscreen
   goto __Loop
