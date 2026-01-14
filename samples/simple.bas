   ; *************************************
   ; * Simple 7800basic Example          *
   ; * Demonstrates basic features       *
   ; *************************************

   ; Configure ROM and display
   set romsize 32k
   displaymode 160A

   ; Import character graphics
   incgraphic graphics/alphabet_4_wide.png 160A

   ; Set up palette colors
   P0C1 = $34  ; purple
   P0C2 = $64  ; blue  
   P0C3 = $0F  ; white

   ; Display simple message
__Loop
   clearscreen
   characterset alphabet_4_wide
   plotchars 'hello world' 0 56 88
   drawscreen
   goto __Loop
