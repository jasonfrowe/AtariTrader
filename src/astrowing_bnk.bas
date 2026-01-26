   set romsize 128k
   set 7800header 'name Astro Wing 128k'
   ; set hssupport $4157
   set pokeysupport $450
   set zoneheight 16
   displaymode 160A
   set doublewide on
   
   bank 1
   alphachars '0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZ.!?,"$():*+-/<>'
   
   ; Include Global Variables
   incbasic "engine_variables.bas"

cold_start
reset_release_wait
   if switchreset then goto reset_release_wait
   
   screen_timer = 60
   music_active = 0 
   current_song = 1 
   current_level = 0
   goto title_entry_point bank2

init_game
   clearscreen
   current_level = 1
   player_lives = 3
   player_shield = 100
   fighters_remaining = 20
   fighters_bcd = converttobcd(20)
   score0 = 0
   
   px = 72 : px_hi = 1
   py = 90 : py_hi = 1
   
   vx_p = 0 : vx_m = 0 : acc_mx = 0
   vy_p = 0 : vy_m = 0 : acc_my = 0
   angle = 0 : rot_timer = 0 : shpfr = 0
   
   for iter = 0 to 3
      blife[iter] = 0 : elife[iter] = 0 : eblife[iter] = 0
   next
   alife = 0 : energy_on = 0 : bf_bul_life = 0
   
   gosub init_stars
   gosub set_level_config
   gosub refresh_static_ui
   goto level_1_entry bank4

   ; --- BANK 2: Title & Song 01 ---
   bank 2
   incbanner graphics/title_screen_conv.png 160A 0 1 2 3
   incbasic "engine_title.bas"

   ; --- BANK 4: Level 1 ---
   bank 4
   incgraphic graphics/fighter.png
   incgraphic graphics/asteroid_M_conv.png
   incgraphic graphics/blue_fighter.png
   incbasic "engine_level1.bas"

   ; --- BANK 8: Fixed ---
   bank 8
   incgraphic graphics/unified_font.png 160A 0 1 2 3
   incgraphic graphics/bullet_conv.png
   incgraphic graphics/fighter_explode_00_conv.png
   incgraphic graphics/fighter_explode_01_conv.png
   incgraphic graphics/fighter_explode_02_conv.png
   incgraphic graphics/fighter_explode_03_conv.png
   incgraphic graphics/fighter_explode_04_conv.png
   incgraphic graphics/fighter_explode_05_conv.png
   incgraphic graphics/fighter_explode_06_conv.png
   incgraphic graphics/fighter_explode_07_conv.png
   incgraphic graphics/sprite_spaceship1.png
   incgraphic graphics/sprite_spaceship2.png
   incgraphic graphics/sprite_spaceship3.png
   incgraphic graphics/sprite_spaceship4.png
   incgraphic graphics/sprite_spaceship5.png
   incgraphic graphics/sprite_spaceship6.png
   incgraphic graphics/sprite_spaceship7.png
   incgraphic graphics/sprite_spaceship8.png
   incgraphic graphics/sprite_spaceship9.png
   incgraphic graphics/sprite_spaceship10.png
   incgraphic graphics/sprite_spaceship11.png
   incgraphic graphics/sprite_spaceship12.png
   incgraphic graphics/sprite_spaceship13.png
   incgraphic graphics/sprite_spaceship14.png
   incgraphic graphics/sprite_spaceship15.png
   incgraphic graphics/sprite_spaceship16.png

   incbasic "engine_shared.bas"
