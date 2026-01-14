   ; *************************************
   ; * AtariTrader - Main Game           *
   ; * A trading game for Atari 7800     *
   ; *************************************

   ; Set up ROM size and display mode
   set romsize 48k
   set zoneheight 16
   set screenheight 192
   
   displaymode 160A

   ; Import character set for text display
   incgraphic graphics/alphabet_4_wide.png 160A

   ; Dimension variables
   dim playerx = d
   dim playery = e
   dim frame = f
   dim gameover = g
   
   ; Set up colors for palette 0
   P0C1 = $26  ; green
   P0C2 = $86  ; light green
   P0C3 = $0F  ; white

   ; Set up colors for palette 1
   P1C1 = $42  ; red
   P1C2 = $44  ; light red
   P1C3 = $46  ; lighter red

   ; Initialize game state
   playerx = 75
   playery = 88
   frame = 0
   gameover = 0

   ; Main game loop
   clearscreen
__Main_Loop
   ; Set character set before using plotchars
   characterset alphabet_4_wide

   ; Draw title
   plotchars 'ataritrader' 0 56 88

   ; Handle joystick input
   if joy0up && playery > 16 then playery = playery - 1
   if joy0down && playery < 176 then playery = playery + 1
   if joy0left && playerx > 0 then playerx = playerx - 1
   if joy0right && playerx < 152 then playerx = playerx + 1
   
   ; Simple "player" sprite (using character plot as placeholder)
   plotchars 'x' 1 playerx playery

   ; Check for fire button
   if joy0fire0 then gosub __Fire_Action

   ; Update frame counter
   frame = frame + 1

   ; Draw screen and repeat
   drawscreen
   
   if !gameover then goto __Main_Loop
   goto __Game_Over

   ; Fire button action
__Fire_Action
   return

   ; Game over screen
__Game_Over
   clearscreen
   characterset alphabet_4_wide
   plotchars 'game over' 0 60 88
   drawscreen
   goto __Game_Over
