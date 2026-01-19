   set romsize 48k
   
   displaymode 160A
   set doublewide on
   set pokeysupport on
 
   ; Import graphics
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
   
   incgraphic graphics/bullet_conv.png
   incgraphic graphics/fighter_conv.png
   ; Explosion Frames (Split for animation)
   incgraphic graphics/fighter_explode_00_conv.png
   incgraphic graphics/fighter_explode_01_conv.png
   incgraphic graphics/fighter_explode_02_conv.png
   incgraphic graphics/fighter_explode_03_conv.png
   incgraphic graphics/fighter_explode_04_conv.png
   incgraphic graphics/fighter_explode_05_conv.png
   incgraphic graphics/fighter_explode_06_conv.png
   incgraphic graphics/fighter_explode_07_conv.png
   incbanner graphics/title_screen_conv.png 160A 0 1 2 3
   
   incgraphic graphics/asteroid_M_conv.png
   incgraphic graphics/Boss_conv.png
   
   ; Define custom mapping for scoredigits (0-9 + A-F)
   alphachars '0123456789ABCDEF'
   incgraphic graphics/scoredigits_8_wide.png 160A

   ; Import Alphabet for Title Cards
   alphachars ' ABCDEFGHIJKLMNOPQRSTUVWXYZ.!?,"$():'
   incgraphic graphics/alphabet_8_wide.png 160A
   
   ; ---- Dimensions ----
   dim px = var0
   dim py = var1
   dim vx_p = var2
   dim vx_m = var3
   dim vy_p = var4
   dim vy_m = var5
   dim rx = var6
   dim ry = var7
   dim angle = var8 
   dim shpfr = var9
   dim rot_timer = var10
   dim move_step = var11
   dim temp_acc = var12
   dim frame = var13
   dim common = var14
   dim temp_v = var15
   dim bcooldown = var16
   dim iter = var17
   dim temp_bx = var38
   dim temp_by = var39

   ; Bullet Arrays (mapped to var space)
   ; Positions are 8.8 fixed point for smooth movement (using word if possible, but let's stick to byte for coords + remainder logic if we want, or just simple integers for bullets?)
   ; Bullets are fast (4px/frame), so integer math is probably fine, but we need direction.
   ; Let's use the same dual-velocity system or just simple signed logic if possible.
   ; To match player physics style (dual-var) might be complex for arrays.
   ; Let's use simple Signed 8-bit Math for bullets: 0=Stop, 1-127=Pos, 128-255=Neg.
   dim bul_x = var18 ; uses 18, 19, 20, 21
   dim bul_y = var22 ; uses 22, 23, 24, 25
   dim bul_vx = var26 ; uses 26, 27, 28, 29
   dim bul_vy = var30 ; uses 30, 31, 32, 33
   dim blife = var34 ; uses 34, 35, 36, 37
   
   dim player_lives = $254B ; Lives Variable (Safe from collisions)

   ; Enemy Bullet Variables (Pool of 2)
   ; Using var60+
   dim ebul_x  = var60 ; 60-63 ... Need High Bytes for these too?
   ; For now, keep bullets/enemies strictly Screen Space?
   ; User said "Infinite World". Everything needs to be World Space eventually.
   ; Let's keep them Screen Space temporarily to confirm Player scrolling first.
   dim ebul_y  = var64
   dim ebul_vx = var68 ; 68-71
   dim ebul_vy = $2560 ; Moved to 160 safe zone
   dim eblife  = $2564 ; 164-167

   ; High Byte Arrays for Bullets (World Coords)
   ; dim bul_x_hi = $2580 ; Removed (Unused)
   ; dim bul_y_hi = $2584 ; Removed (Unused)
   ; dim ebul_x_hi = $2588 ; Removed (Unused)
   ; dim ebul_y_hi = $258C ; Removed (Unused)
   dim temp_val_hi = $2590
   dim ecooldown = var72
   dim temp_w = var73
   
   ; Level Difficulty Config (MOVED to avoid collision with ex_hi at var74-77)
   dim enemy_move_mask = $25A2     ; Frame mask for enemy movement speed
   dim enemy_fire_cooldown = $25A3 ; Cooldown frames after enemy fires
   
   dim asteroid_move_mask = $25AD
   dim asteroid_base_speed = $25AE
   
   ; Boss Variables (Phase 4)
   dim boss_x = $25B0
   dim boss_y = $25B1
   dim boss_hp = $25B2
   dim boss_state = $25B3
   dim bvx = $25B4           ; Boss Velocity X
   dim bvy = $25B5           ; Boss Velocity Y
   dim boss_x_hi = $25B6     ; Boss X High Byte (World)
   dim boss_y_hi = $25B7     ; Boss Y High Byte (World)
   dim boss_scr_x = $25B8    ; Boss Screen X (Cached)
   dim boss_scr_y = $25B9    ; Boss Screen Y (Cached)
   dim boss_on = $25BA       ; Boss Visible Flag
   
   ; Safety Buffer 76-79
   
   ; Starfield Variables (20 stars)
   ; Moved to var80+ to prevent memory corruption from scratch vars
   dim star_x = var80 ; 80-99
   dim star_y = $2500 ; 2500-2519
   dim star_c = $2520 ; 2520-2539
   dim sc1 = $2544
   dim sc2 = $2545
   dim sc3 = $2546
   dim cycle_state = $2547

   ; Enemy Variables (Single Enemy for now)
   ; Enemy Variables (Pool of 4)
   ; var40-59 (20 bytes)
   dim ex = var40 ; 40,41,42,43
   dim ey = var44 ; 44,45,46,47
   dim evx = var48 ; 48,49,50,51
   dim evy = var52 ; 52,53,54,55
   dim elife = var56 ; 56,57,58,59
   
   ; High Byte Arrays for Enemies (World Support)
   dim ex_hi = var74 ; 74,75,76,77 (Using Buffer)
   dim ey_hi = $2540 ; 2540-2543
   
   ; Physics Accumulators (Dedicated)
   dim acc_mx = var78
   dim acc_my = var79

   ; Music State (Safe Zone per MEMORY_MAP)
   dim music_active = $25AC ; 0=Stopped, 1=Playing
   dim music_ptr_lo = $25AA
   dim music_ptr_hi = $25AB
   dim current_song = $25AF ; 1=Song_01, 2=Song_02 (Moved from 25AD conflict)
   
   
   ; ASM Driver uses dedicated ZP vars stolen from star array (unused slots)
   dim music_zp_lo = var98
   dim music_zp_hi = var99
   
   dim rand_val = $254C
   dim screen_timer = $254D ; Generic timeout timer
   
   ; Asteroid Variables (Single Large Asteroid)
   ; Moved to var150 to make room for enemy arrays
   dim ax = $2550
   dim ay = $2551
   dim avx = $2552
   dim avy = $2553
   dim alife = $2554
   dim ax_hi = $2555
   dim ay_hi = $2556
   
   ; Aliases for plotsprite usage
   dim bul_x0 = var18 : dim bul_x1 = var19 : dim bul_x2 = var20 : dim bul_x3 = var21
   dim bul_y0 = var22 : dim bul_y1 = var23 : dim bul_y2 = var24 : dim bul_y3 = var25
   dim blife0 = var34 : dim blife1 = var35 : dim blife2 = var36 : dim blife3 = var37

   ; Cached Render Coordinates (Optimization)
   dim px_scr = $2591
   dim py_scr = $2592
   dim ex_scr = $2593 ; 199-202
   dim ey_scr = $2597 ; 203-206
   dim ax_scr = $259B
   dim ay_scr = $259C
   dim e_on   = $259D ; 209-212
   dim a_on   = $25A1

   ; 0 = inactive, >0 = active frames
   
   ; Remainder arrays for bullets (optional, if we want sub-pixel accuracy)
   ; For 4px/frame speed, sub-pixel is less critical, but angles might need it.
   ; Let's try without reminders first for simplicity/RAM saving.


cold_start
   screen_timer = 30 ; 30s timeout (decremented by frame logic)
   music_active = 0 ; Ensure music state is clean
   ; Palette Setup
   P0C1=$26: P0C2=$24: P0C3=$04 ; Background/UI
   P1C1=$C2: P1C2=$C6: P1C3=$CA ; Player Bullets (Green)
   P2C1=$04: P2C2=$08: P2C3=$0C ; Asteroids (Greys)
   P3C1=$B4: P3C2=$46: P3C3=$1C ; Enemy (Green, Red, Yellow)
   P4C1=$08: P4C2=$0C: P4C3=$0F ; Stars
   P5C1=$34: P5C2=$86: P5C3=$0A ; Spaceship
   P6C1=$42: P6C2=$46: P6C3=$4A ; Enemy Bullets (Red)
   P7C1=$C8: P7C2=$46: P7C3=$1C ; Title Screen (Vibrant)

   BACKGRND=$00
   
   ; Initialize difficulty settings (will be overridden by set_level_config)
   enemy_move_mask = 1        ; Default: slow movement
   enemy_fire_cooldown = 60
   
   asteroid_move_mask = 3
   asteroid_base_speed = 1
   
   ; Sound channelst: slow fire

   ; Game State Variables
   dim fighters_remaining = $2548  ; Enemies left to destroy (was score_p)
   dim player_shield = $2549       ; Current shield value 0-99 (was score_e)
   dim bcd_score = $254A           ; Temporary for BCD conversion
   dim current_level = $25A4       ; Current level (1-5) - moved from var166 (collision with eblife array)
   
   ; Prize Collection System (moved to safe zone var223-227)
   dim prize_active0 = $25A5
   dim prize_active1 = $25A6
   dim prize_active2 = $25A7
   dim prize_active3 = $25A8
   dim prize_active4 = $25A9
   
   ; Cached BCD Variables (Optimization)
   dim fighters_bcd = $2557        ; BCD version for display (was score_p_bcd)
   dim shield_bcd = $2558          ; BCD version for display (was score_e_bcd)
   
   ; UI Cache Variables (Bug Fix #3: Optimize plotchars)
   dim cached_lives = $2572        ; Last rendered player_lives value
   dim cached_level = $2573        ; Last rendered current_level value
   
   ; Player High Bytes
   dim px_hi = $2570
   dim py_hi = $2571
   
   ; Camera Removed
   ; Global Coords Only

title_loop
    clearscreen
    ; Reset critical sprite state to hide game objects
    alife=0
    for iter=0 to 3
       elife[iter]=0
    next
    
    ; Draw Title Graphic (Banner)
    plotbanner title_screen_conv 7 0 46
    
    ; Version Text (Bottom of Screen - Zone 11)
    characterset alphabet_8_wide
    ; Corrected alphachars based on user feedback
    alphachars ' ABCDEFGHIJKLMNOPQRSTUVWXYZ.!?,"$():'
    plotchars 'VERSION' 1 20 11
    
    ; Restore scoredigits just in case
    alphachars '0123456789ABCDEF'
    characterset scoredigits_8_wide
    plotchars 'ABCDE' 7 60 3
    plotchars '20260118' 1 84 11
    
    
    ; Play Music
    gosub PlayMusic
    
    drawscreen
    
    if joy0fire0 then goto story_loop
    
    ; Timeout Logic (30 Seconds)
    ; Use frame counter to tick seconds
    frame = frame + 1
    if frame >= 60 then frame = 0 : screen_timer = screen_timer - 1
    if screen_timer = 0 then goto init_game
    
    goto title_loop

story_loop
    screen_timer = 30 ; 30s timeout
    clearscreen
    alife=0
    
    ; Setup Text
    characterset alphabet_8_wide
    alphachars ' ABCDEFGHIJKLMNOPQRSTUVWXYZ.!?,"$():'
    
    ; Premise (Zones 0-11)
    plotchars 'YOU ARE ON A MISSION' 1 0 1
    plotchars 'TO RETRIEVE RELICS' 1 0 2 ; Palette 0 (Grey)
    plotchars 'THAT POWER UP YOUR' 1 0 3
    plotchars 'SHIP' 1 0 4
    
    plotchars 'EACH ARTIFACT WILL' 0 0 6
    plotchars 'INCREASE YOUR POWER' 0 0 7
    
    plotchars 'DESTROY ENEMY WAVES' 1 0 9
    plotchars 'TO GET EACH RELIC' 1 0 10
    plotchars 'AND DEFEAT EVIL' 1 0 11
    
    ; Play Music (Continue from Title)
    gosub PlayMusic
    
    drawscreen
    
    ; Wait for Button Release (Debounce)
    if joy0fire0 then goto story_loop
    
story_wait
    ; Keep Music Playing while waiting
    gosub PlayMusic
    
    ; Timeout Logic (30 Seconds)
    frame = frame + 1
    if frame >= 60 then frame = 0 : screen_timer = screen_timer - 1
    if screen_timer = 0 then goto leave_story
    
    drawscreen
    
    ; Wait for Button Press
    if !joy0fire0 then goto story_wait
    
leave_story
    ; Restore Scoredigits for Main Game
    alphachars '0123456789ABCDEF'
    characterset scoredigits_8_wide
    
    goto init_game

init_game
     ; Clear any previous screen content (title, story, etc)
     clearscreen
     
     ; Stop title music
     gosub StopMusic
     music_ptr_hi = 0 ; Force reset on next PlayMusic call
     ; Initialize Variables (Reset)
     ; Initialize Player at (256+80, 256+90) -> Center of 512x512
     px = 80 : px_hi = 1
     py = 90 : py_hi = 1
     
     
     ; Camera removed (Player Centric)
    
    ; Initialize Lives
    player_lives = 3  ; Start with 3 lives (display will show 2 hearts = 2 extra lives)
    
    ; Initialize Level
    current_level = 6
    
    ; Initialize UI cache (Bug Fix #3)
    ; Set to invalid values to force initial draw
    cached_lives = 255
    cached_level = 255
    
    ; Initialize Game State
    player_shield = 50
    shield_bcd = converttobcd(50)
    
    fighters_remaining = 20  ; Level 1 starting value
    fighters_bcd = converttobcd(20)
    
    gosub set_level_config
    
    ; Initialize boss (Level 6)
    if current_level = 6 then gosub init_boss
    
    ; Initialize prize system (all active)
    prize_active0 = 1
    prize_active1 = 1
    prize_active2 = 1
    prize_active3 = 1
    prize_active4 = 1
    ; Init Camera centered on 80,90 initially? 
    ; Let's start camera at 0,0 for now to match legacy behavior
     ; Init Done
    ; Init Done
    
    ; Init Physics (Prevent Jitter)
    vx_p = 0 : vx_m = 0 : acc_mx = 0
    vy_p = 0 : vy_m = 0 : acc_my = 0
    
    ; Other vars
    angle = 0
    rx = 0
    ry = 0
    temp_bx = 0
    temp_by = 0
    angle = 0
    rot_timer = 0
    shpfr = 0
    frame = 0
    bcooldown = 0
   
   ; Clear bullets
   for iter = 0 to 3
      blife[iter] = 0
   next
   
   alife = 0 ; Asteroid inactive
   ; ecooldown is set by set_level_config
   eblife[0] = 0 : eblife[1] = 0
   
   ; Clear enemies
   elife[0]=0 : elife[1]=0 : elife[2]=0 : elife[3]=0
   
   gosub init_stars
   
   ; Initial UI draw (force first render)
   gosub draw_lives
   gosub draw_treasures
   savescreen  ; Save static UI elements

main_loop
   clearscreen
   restorescreen  ; Restore static UI (lives, treasures)
   
   ; score_p = cam_x ; DEBUG
   ; score_e = px    ; DEBUG

   ; ---- Frame Counter ----
   frame = frame + 1

   ; ---- Rotation Control ----
   if rot_timer > 0 then rot_timer = rot_timer - 1
   if rot_timer = 0 then gosub check_rotation
   shpfr = angle

   ; ---- Thrust Control ----
   if joy0up then gosub apply_thrust

   ; ---- Firing Control ----
   if bcooldown > 0 then bcooldown = bcooldown - 1
   ; joy0fire0 is the first button
   if joy0fire0 && bcooldown = 0 then gosub fire_bullet

   ; ---- Neutralize Forces ----
   gosub neutralize_forces
   
   ; ---- Starfield Update ----
   gosub cycle_stars
   
   ; ---- Physics Update ----

   ; ---- Physics Update (Shifting World) ----
   ; Calculate Global Scroll Deltas (temp_bx, temp_by)
   temp_bx = 0
   temp_by = 0

   ; X Axis
   ; Positive
   temp_v = vx_p + rx
   rx = temp_v & 63
   temp_w = temp_v / 64
   
   if temp_w > 0 then temp_bx = temp_w
   
   ; Negative
   temp_v = vx_m + acc_mx
   acc_mx = temp_v & 63
   temp_w = temp_v / 64
   
   if temp_w > 0 then temp_bx = 0 - temp_w ; Signed result
   
   ; Y Axis
   ; Positive (Down)
   temp_v = vy_p + ry
   ry = temp_v & 63
   temp_w = temp_v / 64
   
   if temp_w > 0 then temp_by = temp_w
   
   ; Negative (Up)
   temp_v = vy_m + acc_my
   acc_my = temp_v & 63
   temp_w = temp_v / 64
   
   if temp_w > 0 then temp_by = 0 - temp_w
   
   ; Apply Shift to Universe
   if temp_bx <> 0 || temp_by <> 0 then gosub shift_universe


   ; ---- Bullet Update ----
   gosub update_bullets

   ; ---- Enemy Update ----
   if ecooldown > 0 then ecooldown = ecooldown - 1
   gosub update_enemy
   
   ; ---- Enemy Bullet Update ----
   gosub update_enemy_bullets
   
   ; ---- Asteroid Update ----
   gosub update_asteroid
   
   ; ---- Boss Update (Level 6) ----
   if current_level = 6 then gosub update_boss

   ; ---- Collisions ----
   gosub check_collisions
   ; Check for Game State Changes (Stack Safe)
   if fighters_remaining <= 0 then goto level_complete
   if player_shield <= 0 then goto lose_life

   ; ---- Friction ----
   gosub apply_friction

   ; ---- Boundaries (REMOVED - World Wraps) ----
   ; if px > 150 then px = 150 ...

   ; ---- Camera Update ----

   gosub update_render_coords

    ; ---- Draw ----
    ; Draw Scores
    ; Player (Left) - Green (Pal 3)
    ; ---- Lives Display (Top Left) ----
    ; Using Palette 3 (Green)
    ; ---- Lives Display (Top Left) ----
    ; Using Palette 5 (Red) per user request
    ; Unrolled Loop for 3 Hearts (Fast)
    ; UI Draw Section - All using scoredigits_8_wide
    ; characterset scoredigits_8_wide

    ; ---- UI Rendering (Optimized) ----
    
    ; Lives Display (only update when changed)
    if player_lives <> cached_lives then gosub draw_lives : savescreen
    
    ; Treasures Display (only update when level changes)
    if current_level <> cached_level then gosub draw_treasures : savescreen
    
    ; Dynamic values (update every frame)
    ; Shield (Left, Green, Palette 3)
    plotvalue scoredigits_8_wide 3 shield_bcd 2 40 0
    
    ; Fighters Remaining (Right, Red, Palette 5)
    plotvalue scoredigits_8_wide 5 fighters_bcd 2 104 0
    
    ; DEBUG: Display World Coords Comparison (Player vs Enemy 0)
    ; Zone 1: PxHi ExHi[0] PyHi EyHi[0]
    ; a = converttobcd(px_hi)
    ; plotvalue scoredigits_8_wide 2 a 1 10 9
    
    ; b = converttobcd(ex_hi) ; ex_hi[0]
    ; plotvalue scoredigits_8_wide 2 b 1 40 9
    
    ; c = converttobcd(py_hi)
    ; plotvalue scoredigits_8_wide 2 c 1 80 9
    
    ; d = converttobcd(ey_hi) ; ey_hi[0]
    ; plotvalue scoredigits_8_wide 2 d 1 110 9

    ; Row 2: Low Bytes (Px Ex[0] Py Ey[0])
    ; v = px 
    ; e   = converttobcd(v)
    ; plotvalue scoredigits_8_wide 3 e 2 10 10
    
    ; v = ex
    ; f = converttobcd(v)
    ; plotvalue scoredigits_8_wide 3 f 2 40 10
    
    ; w = py
    ; e = converttobcd(w)
    ; plotvalue scoredigits_8_wide 3 e 2 80 10
    
    ; w = ey
    ; f = converttobcd(w)
    ; plotvalue scoredigits_8_wide 3 f 2 110 10


    ; Use cached screen position
    plotsprite sprite_spaceship1 5 px_scr py_scr shpfr
     
    gosub draw_stars
    gosub draw_player_bullets
    gosub draw_enemies
    if alife > 0 then gosub draw_asteroid
    if current_level = 6 then gosub draw_boss
    gosub draw_enemy_bullets
    
    ; Update Music
    gosub PlayMusic
 
    drawscreen
   goto main_loop

check_rotation
   if joy0left  then angle = angle - 1 : rot_timer = 4
   if joy0right then angle = angle + 1 : rot_timer = 4
   if angle > 250 then angle = 15
   if angle > 15 then angle = 0
   return

apply_thrust
   ; X Axis
   temp_acc = sin_table[angle]
   if temp_acc < 128 then vx_p = vx_p + temp_acc 
   if temp_acc >= 128 then temp_acc = 0 - temp_acc : vx_m = vx_m + temp_acc

   ; Y Axis (Inverted) - Subtract Cos
   temp_acc = cos_table[angle]
   if temp_acc < 128 then vy_m = vy_m + temp_acc
   if temp_acc >= 128 then temp_acc = 0 - temp_acc : vy_p = vy_p + temp_acc
   
   ; Max speed Logic
   temp_v = 120 ; Slower start
   if current_level >= 3 then temp_v = 190 ; Normal Speed
   
   if vx_p > temp_v then vx_p = temp_v
   if vx_m > temp_v then vx_m = temp_v
   if vy_p > temp_v then vy_p = temp_v
   if vy_m > temp_v then vy_m = temp_v
   return

neutralize_forces
   ; X Axis
   if vx_p = 0 || vx_m = 0 then goto skip_nx
   if vx_p < vx_m then common = vx_p else common = vx_m
   vx_p = vx_p - common
   vx_m = vx_m - common
skip_nx
   ; Y Axis
   if vy_p = 0 || vy_m = 0 then goto skip_ny
   if vy_p < vy_m then common = vy_p else common = vy_m
   vy_p = vy_p - common
   vy_m = vy_m - common
skip_ny
   return

apply_friction
   ; Snap to zero logic
   if vx_p < 2 then vx_p = 0
   if vx_p >= 2 then vx_p = vx_p - 1
   
   if vx_m < 2 then vx_m = 0
   if vx_m >= 2 then vx_m = vx_m - 1
   
   if vy_p < 2 then vy_p = 0
   if vy_p >= 2 then vy_p = vy_p - 1
   
   if vy_m < 2 then vy_m = 0
   if vy_m >= 2 then vy_m = vy_m - 1
   return

update_bullets
   for iter = 0 to 3
      if blife[iter] = 0 then goto skip_bul_move
      ; Screen Space Movement (Simple 8-bit)
      ; X Axis
      temp_v = bul_vx[iter]
      bul_x[iter] = bul_x[iter] + temp_v
      
      ; Bounds Check X (Kill if off screen)
      if bul_x[iter] > 170 then if bul_x[iter] < 240 then blife[iter] = 0

      ; Y Axis
      temp_v = bul_vy[iter]
      bul_y[iter] = bul_y[iter] + temp_v
      
      ; Bounds Check Y
      if bul_y[iter] > 200 then blife[iter] = 0
      
      ; Lifetime Check
      if blife[iter] > 0 then blife[iter] = blife[iter] - 1
skip_bul_move
   next
   return


fire_bullet
   ; Find free slot
   for iter = 0 to 3
      if blife[iter] = 0 then goto spawn_bullet
   next
   return

spawn_bullet
   blife[iter] = 60 ; Last 60 frames ~ 1 sec
   ; Screen Space Bullet Spawn (Tie to Screen)
   ; Center Bullet (Px + 8, Py + 8) -> Center of 16x16 sprite
   
   bul_x[iter] = px 
   bul_y[iter] = py
   
   ; No Hi Bytes needed for Screen Space Bullets

   
   ; Set velocity based on angle
   ; Use sin_table values * factor ~ 10-15?
   ; sin_table current max is 6 (acceleration). 
   ; We want 4px/frame. 4 / 6 is not right.
   ; Let's just create a quick separate scaling or just use the table * 1 (too slow)
   ; The table 'sin_table' has values like 0,2,4,6.
   ; If we treat them as pixel speed, 6px/frame is very fast. 4px/frame is target.
   ; Let's assume table values are roughly "direction * magnitude".
   ; We can divide by 2? 6/2 = 3px/frame. Close enough.
   
   ; Set velocity based on angle
   ; Use sin_table values directly (Max 6px/frame)
   ; Previous logic divided by 2 (Max 3px/frame) which was slower than player.
   
   temp_v = sin_table[angle]
   if temp_v >= 128 then temp_v = 0 - temp_v : temp_v = 0 - temp_v ; Keep sign? No, bul_vx expects 0-255 format.
   ; Wait, 7800Basic doesn't handle negative assignment well in one line?
   ; Let's respect the table format.
   
   temp_v = sin_table[angle]
   ; Table: 0, 2, 4, 6... 254(-2), 252(-4)...
   ; Just copy it directly?
   ; Yes, table is already in signed byte format.
   bul_vx[iter] = temp_v
   
   temp_v = cos_table[angle]
   ; Invert logic for Y? 
   ; Cos Table: Pos (0-127) = Down. Neg (128-255) = Up.
   ; We want "Forward" to be "Up" if angle is 0?
   ; Angle 0: Sin=0, Cos=6.
   ; If we face UP, we want Vy to be Negative.
   ; So if Cos is Positive, we want Negative Velocity.
   ; So we Negate the Cos table value.
   
   if temp_v < 128 then bul_vy[iter] = 0 - temp_v
   
   if temp_v >= 128 then temp_v = 0 - temp_v : bul_vy[iter] = temp_v
   
   ; Play sound
   playsfx sfx_laser 0
   
   bcooldown = 25 ; Slow (Level 1)
   if current_level >= 2 then bcooldown = 15 ; Normal (Level 2-4)
   if current_level >= 5 then bcooldown = 8  ; Fast (Level 5+)
   return

update_enemy
    ; Loop through all potential enemies
    for iter = 0 to 3
       if elife[iter] = 0 then goto try_spawn_enemy
       if elife[iter] > 1 then goto update_explosion_state
       
       ; --- Movement Logic (per enemy) ---
       ; Move based on level difficulty (mask checks frame bits)
       temp_v = frame & enemy_move_mask
       if temp_v > 0 then goto enemy_logic_done
       
       ; --- Inertia Logic (Strategy A) ---
       ; --- Inertia Logic (Strategy A + Squad Formation + Rotation) ---
       ; Calculate Circular Target Index (Changes every ~2s)
       temp_v = frame / 128
       temp_v = temp_v + iter
       temp_v = temp_v & 3
       
       ; Gray Code for Circular Path (0->1->3->2 : TL->TR->BR->BL)
       temp_acc = temp_v / 2
       temp_v = temp_v ^ temp_acc
       rand_val = temp_v ; Store Target Index in temp var
       
       ; Calculate Target X with Offset using Target Index
       ; Use 16-bit aware targeting: check high bytes first
       temp_w = px
       temp_v = rand_val & 1
       if temp_v > 0 then temp_w = temp_w + 30 else temp_w = temp_w - 30
       
       ; Check if in same X segment (high bytes match)
       if px_hi = ex_hi[iter] then goto same_x_segment
       
       ; Different segments - determine direction from high byte difference
       temp_acc = px_hi - ex_hi[iter]
       ; Handle 4-segment wrap: 
       ; Right direction: 1, 2 (wrap?), no.. 1 or 253 (-3) which is 3->0
       ; Left direction: 255 (-1), 254 (-2), 3 (0->3)
       
       if temp_acc = 1 then goto want_right_hb
       if temp_acc = 2 then goto want_right_hb ; Chase right if far
       if temp_acc = 253 then goto want_right_hb ; 3 -> 0 Wrap
       
       goto want_left
       
want_right_hb
       ; High bytes say go right
       temp_acc = 64  ; Positive delta to trigger right movement
       goto do_x_accel

same_x_segment
       ; Same segment - use low byte difference
       temp_acc = temp_w - ex[iter]
       
do_x_accel
       ; Accelerate every 4th frame (mask 3)
       if (frame & 3) > 0 then goto skip_accel
       
       ; X Acceleration
       if temp_acc >= 128 then goto want_left
       ; Want Right (Target +3)
       ; Increment if < 3 OR Negative (>128)
       if evx[iter] < 3 || evx[iter] > 128 then evx[iter] = evx[iter] + 1
       goto check_y_accel
want_left
       ; Want Left (Target -3 ie 253)
       ; Decrement if > 253 OR Positive (<128)
       if evx[iter] > 253 || evx[iter] < 128 then evx[iter] = evx[iter] - 1

check_y_accel
       ; Y Acceleration with Offset using Target Index (16-bit aware)
       temp_w = py
       temp_v = rand_val & 2
       if temp_v > 0 then temp_w = temp_w + 55 else temp_w = temp_w - 55
       
       ; Check if in same Y segment (high bytes match)
       if py_hi = ey_hi[iter] then goto same_y_segment
       
       ; Different segments - determine direction from high byte difference
       temp_acc = py_hi - ey_hi[iter]
       ; Handle 4-segment wrap: if diff is 1-2, go down; if diff is 254-255 (or 3), go up
       ; Down: 1, 2, 253 (3->0)
       ; Up: 255 (-1), 254 (-2), 3 (0->3)
       
       if temp_acc = 1 then goto want_down_hb
       if temp_acc = 2 then goto want_down_hb
       if temp_acc = 253 then goto want_down_hb
       
       goto want_up
       
want_down_hb
       ; High bytes say go down
       temp_acc = 64  ; Positive delta to trigger down movement
       goto do_y_accel

same_y_segment
       ; Same segment - use low byte difference
       temp_acc = temp_w - ey[iter]
       
do_y_accel
       if temp_acc >= 128 then goto want_up
       ; Want Down (Target +3)
       ; Increment if < 3 OR Negative (>128)
       if evy[iter] < 3 || evy[iter] > 128 then evy[iter] = evy[iter] + 1
       goto skip_accel
want_up
       ; Want Up (Target -3 ie 253)
       ; Decrement if > 253 OR Positive (<128)
       if evy[iter] > 253 || evy[iter] < 128 then evy[iter] = evy[iter] - 1

skip_accel
       ; Apply Velocity X
       temp_v = evx[iter]
       if temp_v >= 128 then goto apply_neg_x
       ; Pos
       ex[iter] = ex[iter] + temp_v
       if ex[iter] < temp_v then ex_hi[iter] = ex_hi[iter] + 1
       goto apply_x_done
apply_neg_x
       temp_w = 0 - temp_v
       temp_acc = ex[iter]
       ex[iter] = ex[iter] - temp_w
       if ex[iter] > temp_acc then ex_hi[iter] = ex_hi[iter] - 1
apply_x_done
       ; Wrap World X (4 segments = 1024)
       if ex_hi[iter] = 255 then ex_hi[iter] = 1
       if ex_hi[iter] >= 2 then ex_hi[iter] = 0

       ; Apply Velocity Y
       temp_v = evy[iter]
       if temp_v >= 128 then goto apply_neg_y
       ; Pos
       ey[iter] = ey[iter] + temp_v
       if ey[iter] < temp_v then ey_hi[iter] = ey_hi[iter] + 1
       goto apply_y_done
apply_neg_y
       temp_w = 0 - temp_v
       temp_acc = ey[iter]
       ey[iter] = ey[iter] - temp_w
       if ey[iter] > temp_acc then ey_hi[iter] = ey_hi[iter] - 1
apply_y_done
       ; Wrap World Y (4 segments = 1024)
       if ey_hi[iter] = 255 then ey_hi[iter] = 1
       if ey_hi[iter] >= 2 then ey_hi[iter] = 0
       
       ; Firing Chance (Global Cooldown)
       if ecooldown > 0 then goto skip_firing_chance
       
       ; Chance to fire (1 in 16 per frame)
       rand_val = frame + iter
       rand_val = rand_val & 15
       if rand_val = 0 then gosub fire_enemy_bullet
          
skip_firing_chance
       goto enemy_logic_done


   
update_explosion_state
   elife[iter] = elife[iter] - 1
   if elife[iter] = 1 then elife[iter] = 0 ; Done, set to Dead
   goto enemy_logic_done

try_spawn_enemy
       ; Random spawn chance (1 in 128 per frame)
       rand_val = frame & 127
       if rand_val > 5 then goto enemy_logic_done
       
do_spawn
       
       ; Spawn logic inline
       elife[iter] = 1
       evx[iter] = 0 : evy[iter] = 0 ; Reset velocity
       
       ; Set High Byte to Camera High Byte (Spawn locally initially)
       ; Set High Byte to Px High Byte (Locally)
       ex_hi[iter] = px_hi
       
       ; Randomize Side (L/R) using rand
       temp_v = rand
       if temp_v < 128 then goto spawn_left
       goto spawn_right

spawn_left
       ; Spawn Left (Px - 90)
       ; 80 center + 10 margin
       temp_v = px - 90
       ex[iter] = temp_v
       if temp_v > px then ex_hi[iter] = ex_hi[iter] - 1 ; Underflow
       if ex_hi[iter] = 255 then ex_hi[iter] = 1 ; Wrap Down
       goto spawn_set_y

spawn_right
       ; Spawn Right (Px + 90)
       temp_v = px + 90
       ex[iter] = temp_v
       if temp_v < px then ex_hi[iter] = ex_hi[iter] + 1 ; Overflow
       if ex_hi[iter] >= 2 then ex_hi[iter] = 0 ; Wrap Up
       if ex_hi[iter] = 255 then ex_hi[iter] = 1 ; Wrap Down (Safety)

spawn_set_y
       ; Random Y (10 to 180) -> Screen Space
       ; Convert to World: Ey = Py + (ScreenY - 90)
       temp_v = rand
       if temp_v < 10 then temp_v = 10
       if temp_v > 180 then temp_v = 180
       
       ; Calculate Offset from Center (90)
       temp_acc = temp_v - 90
       
       ; Default to same High Byte
       ey_hi[iter] = py_hi
       
       ; Add Offset to Py
       if temp_acc < 128 then goto add_pos_offset
       
       ; Negative Offset (ScreenY < 90)
       ; ey = py + neg_offset
       temp_w = py + temp_acc
       ey[iter] = temp_w
       if temp_w > py then ey_hi[iter] = ey_hi[iter] - 1 ; Borrow
       goto check_wrap_y_spawn

add_pos_offset
       ; Positive Offset (ScreenY > 90)
       temp_w = py + temp_acc
       ey[iter] = temp_w
       if temp_w < py then ey_hi[iter] = ey_hi[iter] + 1 ; Carry

check_wrap_y_spawn
       if ey_hi[iter] = 255 then ey_hi[iter] = 1
       if ey_hi[iter] >= 2 then ey_hi[iter] = 0
       
enemy_logic_done
    next
    return

fire_enemy_bullet
   ; ITER holds current enemy index
   ; Find free bullet slot
   for temp_acc = 0 to 3
      if eblife[temp_acc] = 0 then goto spawn_ebul
   next
   return

spawn_ebul
   ; temp_acc is bullet index
   ; iter is enemy index
   if e_on[iter] = 0 then return ; Use cached visibility
   
   eblife[temp_acc] = 120 ; Increased lifetime
   
   temp_v = ex_scr[iter]
   temp_w = ey_scr[iter]
   ebul_x[temp_acc] = temp_v
   ebul_y[temp_acc] = temp_w
   
   ; Aim at player (already in screen space)
   ; Speed set to 3px/frame
   ; temp_bx = delta X
   temp_bx = px_scr + 8 ; Target Center Screen X
   temp_bx = temp_bx - temp_v ; Delta Screen X
   
   if temp_bx >= 128 then ebul_vx[temp_acc] = 253 : temp_bx = 0 - temp_bx else ebul_vx[temp_acc] = 3
   
   temp_by = py_scr + 8 ; Target Center Screen Y
   temp_by = temp_by - temp_w ; Delta Screen Y

   if temp_by >= 128 then ebul_vy[temp_acc] = 253 : temp_by = 0 - temp_by else ebul_vy[temp_acc] = 3
   
   ; 8-way logic
   temp_v = temp_bx / 2
   if temp_v > temp_by then ebul_vy[temp_acc] = 0
   
   temp_v = temp_by / 2
   if temp_v > temp_bx then ebul_vx[temp_acc] = 0
   
   ecooldown = enemy_fire_cooldown ; Set from level config
   
   ; Play enemy fire sound
   playsfx sfx_enemyfire 0
   
   return

update_enemy_bullets
   for iter = 0 to 3
      if eblife[iter] = 0 then goto skip_ebul_update
      
      eblife[iter] = eblife[iter] - 1
      
      ; Move X (screen space - simple addition)
      temp_v = ebul_vx[iter]
      if temp_v >= 128 then goto ebul_x_neg
      
      ; Positive X
      ebul_x[iter] = ebul_x[iter] + temp_v
      goto ebul_x_done

ebul_x_neg
      temp_v = 0 - temp_v
      ebul_x[iter] = ebul_x[iter] - temp_v

ebul_x_done
      ; Move Y (screen space - simple addition)
      temp_v = ebul_vy[iter]
      if temp_v >= 128 then goto ebul_y_neg
      
      ; Positive Y
      ebul_y[iter] = ebul_y[iter] + temp_v
      goto ebul_y_done

ebul_y_neg
      temp_v = 0 - temp_v
      ebul_y[iter] = ebul_y[iter] - temp_v

ebul_y_done
      ; Off-Screen Culling (screen space)
      temp_v = ebul_x[iter]
      if temp_v > 165 then if temp_v < 240 then eblife[iter] = 0
      
      temp_v = ebul_y[iter]
      if temp_v > 200 then eblife[iter] = 0

skip_ebul_update
   next
   return

update_asteroid
   if alife = 0 then gosub spawn_asteroid
   if alife = 0 then return
   
   ; Move Asteroid (Variable Speed via Mask)
   if (frame & asteroid_move_mask) > 0 then return
   
   ; Move Asteroid (16-bit)
   temp_v = avx
   if temp_v < 128 then goto ast_move_pos_x
   
   ; Negative X
   temp_v = 0 - temp_v
   temp_w = ax
   ax = ax - temp_v
   if ax > temp_w then ax_hi = ax_hi - 1
   goto ast_x_done

ast_move_pos_x
   ax = ax + temp_v
   if ax < temp_v then ax_hi = ax_hi + 1

ast_x_done
   ; Wrap X (0-3, 4 segments = 1024)
   if ax_hi = 255 then ax_hi = 1
   if ax_hi >= 2 then ax_hi = 0

   ; Y Axis
   temp_v = avy
   if temp_v < 128 then goto ast_move_pos_y
   
   ; Negative Y
   temp_v = 0 - temp_v
   temp_w = ay
   ay = ay - temp_v
   if ay > temp_w then ay_hi = ay_hi - 1
   goto ast_y_done

ast_move_pos_y
   ay = ay + temp_v
   if ay < temp_v then ay_hi = ay_hi + 1

ast_y_done
   ; Wrap Y (0-3, 4 segments = 1024)
   if ay_hi = 255 then ay_hi = 1
   if ay_hi >= 2 then ay_hi = 0
   
   return

spawn_asteroid
   ; Spawn chance
   rand_val = frame & 127
   if rand_val > 5 then return
   
   alife = 1
   ; Random edge
   rand_val = frame & 3
   if rand_val = 0 then ax = 5 : ay = 90
   if rand_val = 1 then ax = 155 : ay = 90
   if rand_val = 2 then ax = 80 : ay = 5
   if rand_val = 3 then ax = 80 : ay = 175
   
    ; Convert to World Coordinates
    ; AX starts as Screen X (5, 155, 80). Center is 80.
    ; Offset = AX - 80.
    ; WorldX = Px + Offset.
    temp_acc = ax - 80
    temp_v = px + temp_acc
    ax = temp_v
    ax_hi = px_hi
    if temp_acc >= 128 then if temp_v > px then ax_hi = ax_hi - 1
    if temp_acc < 128 then if temp_v < px then ax_hi = ax_hi + 1
    if ax_hi = 255 then ax_hi = 3  ; Handle -1 wrap FIRST
    if ax_hi >= 4 then ax_hi = 0
    
    ; AY starts as Screen Y await (90, 5, 175). Center is 90.
    ; Offset = AY - 90.
    temp_acc = ay - 90
    temp_v = py + temp_acc
    ay = temp_v
    ay_hi = py_hi
    if temp_acc >= 128 then if temp_v > py then ay_hi = ay_hi - 1
    if temp_acc < 128 then if temp_v < py then ay_hi = ay_hi + 1
    if ay_hi >= 4 then ay_hi = 0
   
   ; Random Velocity using sin/cos lookup tables for varied angles
   ; Pick random angle (0-15) from frame counter
   rand_val = frame & 15  ; 0-15 for full angle range
   
   ; Use sin_table for X velocity component
   temp_v = sin_table[rand_val]
   ; Scale up for faster asteroids: multiply by 2 (shift values are -6..6 → -12..12)
   ; But 7800Basic doesn't have easy multiply, so just use table directly
   avx = temp_v
   
   ; Use cos_table for Y velocity component  
   temp_v = cos_table[rand_val]
   avy = temp_v
   
   ; Optionally boost speed based on level or randomness
   ; Add slight speed variance (50% chance to be 50% faster)
   if frame & 16 then avx = avx + avx / 2 : avy = avy + avy / 2
   
   return

check_collisions
   ; 1. Bullets vs Enemies
   for iter = 0 to 3 ; Bullets
      if blife[iter] = 0 then goto skip_bullet_coll
      
      for temp_acc = 0 to 3 ; Enemies
         if e_on[temp_acc] = 0 then goto skip_enemy_coll
         if elife[temp_acc] <> 1 then goto skip_enemy_coll
         
         ; Check X Collision (Screen Space)
         ; Bullet (4) vs Fighter (16). Center bullet (+6)
         temp_w = ex_scr[temp_acc]
         temp_v = bul_x[iter] - temp_w
         temp_v = temp_v - 6 ; Center Offset
         if temp_v >= 128 then temp_v = 0 - temp_v
         if temp_v >= 10 then goto skip_enemy_coll ; Half Fighter Width + Bullet
         
         ; Check Y Collision
         temp_w = ey_scr[temp_acc]
         temp_v = bul_y[iter] - temp_w
         temp_v = temp_v - 6 ; Center Offset
         if temp_v >= 128 then temp_v = 0 - temp_v
         if temp_v >= 10 then goto skip_enemy_coll
         
         ; Hit!
         blife[iter] = 0
         elife[temp_acc] = 18 ; Start Explosion (18 frames)
         playsfx sfx_damage 0 ; Destruction sound
         
         ; Decrement Fighters Remaining
         fighters_remaining = fighters_remaining - 1
         fighters_bcd = converttobcd(fighters_remaining)
         if fighters_remaining <= 0 then goto coll_done
         
         goto skip_enemy_coll ; Bullet used up
         
skip_enemy_coll
      next
      
skip_bullet_coll
   next
   
   ; 2. Player vs Enemies
   for iter = 0 to 3
      if e_on[iter] = 0 then goto skip_p_e
      if elife[iter] <> 1 then goto skip_p_e
      
      ; X Check (Screen Space)
      temp_v = px_scr - ex_scr[iter]
      temp_v = temp_v + 4 ; Offset to shrink left side
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 11 then goto skip_p_e
      
      ; Y Check
      temp_v = py_scr - ey_scr[iter]
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 11 then goto skip_p_e
      
      ; Hit Player
      elife[iter] = 18 ; Explode
      playsfx sfx_damage 0 ; Crash sound for player-fighter collision
      
      ; Decrement Shields
      if player_shield < 2 then player_shield = 0 else player_shield = player_shield - 2
      shield_bcd = converttobcd(player_shield)
      
      ; Also decrement fighter count (fighter destroyed)
      fighters_remaining = fighters_remaining - 1
      fighters_bcd = converttobcd(fighters_remaining)
      if fighters_remaining <= 0 then goto coll_done
      
      ; Check for death
      if player_shield <= 0 then goto coll_done
      
skip_p_e
   next
   
   ; Fall through to check_asteroid_coll
   
check_asteroid_coll
   ; Only check if visible
   if a_on = 0 then goto check_player_ebul

   ; 3. Bullets vs Asteroid (Indestructible)
   for iter = 0 to 3
      if blife[iter] = 0 then goto skip_bul_ast

      ; X Check
      temp_v = bul_x[iter] - ax_scr
      temp_v = temp_v - 6 ; Center Offset (+6)
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 12 then goto skip_bul_ast ; Match Asteroid Box (12)
      
      ; Y Check
      temp_v = bul_y[iter] - ay_scr
      temp_v = temp_v - 6
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 22 then goto skip_bul_ast ; Match Asteroid Box (22)
      
      ; Hit! Bullet dies, Asteroid lives.
      blife[iter] = 0
      ; playsfx sfx_ping ?

skip_bul_ast
   next
   
   ; 4. Player vs Asteroid
   temp_w = px_scr - ax_scr
   ; Center-to-center check
   if temp_w >= 128 then temp_v = 0 - temp_w else temp_v = temp_w
   if temp_v >= 12 then goto check_enemy_ast_coll ; Tuned Width ~16+Player (Tight)
   
   ; Y Check
   temp_acc = py_scr - ay_scr
   if temp_acc >= 128 then temp_v = 0 - temp_acc else temp_v = temp_acc
   if temp_v >= 22 then goto check_enemy_ast_coll ; Tuned Height ~32+Player (Tight)
   
   ; Hit Player!
   ; 1. Damage Shield (-10)
   if player_shield < 10 then player_shield = 0 else player_shield = player_shield - 10
   shield_bcd = converttobcd(player_shield)
   if player_shield <= 0 then goto coll_done
   
   ; 2. Bounce Logic (Large bounce to avoid multiple collisions)
   ; If Player is Left of Ast (temp_w < 0 -> >128), Bounce Left.
   ; px_scr < ax_scr -> temp_w is "negative" (high byte)
   if temp_w >= 128 then vx_m = 128 : vx_p = 0 else vx_p = 128 : vx_m = 0
   
   ; Y Bounce
   if temp_acc >= 128 then vy_m = 128 : vy_p = 0 else vy_p = 128 : vy_m = 0
   
   ; Play crash sound for collision
   playsfx sfx_damage 0
   
   ; 3. Push asteroid away to prevent re-collision
   ; Push asteroid velocity in opposite direction of player bounce
   ; If player bounced left (vx_m=128), push asteroid right (avx=positive)
   if temp_w >= 128 then avx = 3 else avx = 253  ; 253 = -3 in signed byte
   if temp_acc >= 128 then avy = 3 else avy = 253
   
   ; Sound Effect?
   
check_enemy_ast_coll
   ; 5. Enemy vs Asteroid (Strategic Kill)
   for iter = 0 to 3
      if elife[iter] = 0 then goto skip_e_ast
      if elife[iter] > 1 then goto skip_e_ast ; Don't hit if already exploding
      if e_on[iter] = 0 then goto skip_e_ast
      
      ; X Check
      temp_v = ex_scr[iter] - ax_scr
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 14 then goto skip_e_ast ; Tightened (Was 20)

      ; Y Check
      temp_v = ey_scr[iter] - ay_scr
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 24 then goto skip_e_ast ; Tightened (Was 20 - adjusted for height)
      
      ; Hit! Destroy Enemy
      elife[iter] = 18 ; Explode
      playsfx sfx_damage 0 ; Destruction sound (Enemy hits Asteroid)
      ; Grant points?
      
      ; Decrement fighter count
      fighters_remaining = fighters_remaining - 1
      fighters_bcd = converttobcd(fighters_remaining)
      if fighters_remaining <= 0 then goto coll_done

skip_e_ast
   next

   ; 6. Enemy Bullet vs Asteroid (Missing)
   for iter = 0 to 3
      if eblife[iter] = 0 then goto skip_ebul_ast
      if a_on = 0 then goto skip_ebul_ast
      
      ; X Check
      temp_v = ebul_x[iter] - ax_scr
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 12 then goto skip_ebul_ast
      
      ; Y Check
      temp_v = ebul_y[iter] - ay_scr
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 22 then goto skip_ebul_ast
      
      ; Hit! Bullet dies. Asteroid lives.
      eblife[iter] = 0

skip_ebul_ast
   next
   
check_player_ebul
   ; Check vs Enemy Bullets (Screen Space)
   for iter = 0 to 3
      if eblife[iter] = 0 then goto skip_ebul_coll
      
      ; --- Screen Space Collision ---
      temp_w = px_scr - ebul_x[iter]
      temp_w = temp_w + 7 ; Offset Check
      
      if temp_w >= 128 then temp_w = 0 - temp_w
      if temp_w >= 8 then goto skip_ebul_coll ; Widen to ~8 (Size 16)
      
      ; Y Check
      temp_w = py_scr - ebul_y[iter]
      temp_w = temp_w + 7 
      
      if temp_w >= 128 then temp_w = 0 - temp_w
      if temp_w >= 8 then goto skip_ebul_coll
      
      ; Hit Player
      eblife[iter] = 0
      playsfx sfx_damage 0 ; Harsh damage feedback for player hit
      
      ; Decrement Shields
      if player_shield < 1 then player_shield = 0 else player_shield = player_shield - 1
      shield_bcd = converttobcd(player_shield)
      if player_shield <= 0 then goto coll_done
      
skip_ebul_coll
   next

coll_done
   return

init_stars
   for iter = 0 to 3
      ; Random X (0-159)
      rand_val = frame & 127 : temp_v = rand_val
      rand_val = frame & 32 : temp_v = temp_v + rand_val
      if temp_v > 159 then temp_v = 159
      star_x[iter] = temp_v
      
      ; Random Y (0-190)
      rand_val = frame & 127
      rand_val = rand_val + 50 ; padding?
      if rand_val > 180 then rand_val = rand_val - 100
      star_y[iter] = rand_val
      
      ; Random Color (1-3)
      rand_val = frame & 3
      if rand_val = 0 then rand_val = 1
      star_c[iter] = rand_val
      
      ; Advance frame to mix RNG
      frame = frame + 1
   next
   return

draw_stars
   ; Unrolled loop for performance (4 stars)
   ; Star X is world coordinate. Screen X = StarX - PX + 80
   temp_v = star_x[0] - px + 80
   if temp_v > 165 then goto skip_s0
   temp_w = star_y[0] - py + 90
   if temp_w > 200 then goto skip_s0
   plotsprite bullet_conv 4 temp_v temp_w
skip_s0
   temp_v = star_x[1] - px + 80
   if temp_v > 165 then goto skip_s1
   temp_w = star_y[1] - py + 90
   if temp_w > 200 then goto skip_s1
   plotsprite bullet_conv 4 temp_v temp_w
skip_s1
   temp_v = star_x[2] - px + 80
   if temp_v > 165 then goto skip_s2
   temp_w = star_y[2] - py + 90
   if temp_w > 200 then goto skip_s2
   plotsprite bullet_conv 4 temp_v temp_w
skip_s2
   temp_v = star_x[3] - px + 80
   if temp_v > 165 then goto skip_s3
   temp_w = star_y[3] - py + 90
   if temp_w > 200 then goto skip_s3
   plotsprite bullet_conv 4 temp_v temp_w
skip_s3
   return



...

cycle_stars
   ; Twinkle every 8 frames
   if (frame & 7) > 0 then return
   
   cycle_state = cycle_state + 1
   if cycle_state > 2 then cycle_state = 0
   
   if cycle_state = 0 then P4C1=$08: P4C2=$0C: P4C3=$0F
   if cycle_state = 1 then P4C1=$0C: P4C2=$0F: P4C3=$08
   if cycle_state = 2 then P4C1=$0F: P4C2=$08: P4C3=$0C
   return



update_render_coords
   ; Simple Window Logic with Edge Handling (Hi=1 and Hi=2)
   ; Player (Center) is at Hi=2.
   ; Neighbors: Hi=1 (Left/Top) and Hi=2 (Right/Bottom/Center)
   
   px_scr = 80 - 4
   py_scr = 90 - 8
   
   for iter = 0 to 3
      if elife[iter] = 0 then e_on[iter] = 0 : goto next_r_simple
      
      ; --- X Axis --- 
      if ex_hi[iter] = 1 then goto check_x_center
      if ex_hi[iter] = 0 then goto check_x_left
      e_on[iter] = 0 : goto next_r_simple

check_x_center
      ; Hi=1 (Center): Use Low Byte directly.
      ex_scr[iter] = ex[iter]
      if ex_scr[iter] > 170 then e_on[iter] = 0 : goto next_r_simple
      goto x_ok

check_x_left
      ; Hi=0 (Left): Use Low Byte. Must be escaping left (255..240)
      ex_scr[iter] = ex[iter]
      if ex_scr[iter] < 240 then e_on[iter] = 0 : goto next_r_simple

x_ok
      
      ; --- Y Axis ---
      if ey_hi[iter] = 1 then goto check_y_center
      if ey_hi[iter] = 0 then goto check_y_top
      e_on[iter] = 0 : goto next_r_simple

check_y_center
      ; Hi=1: Center/Bottom
      ey_scr[iter] = ey[iter]
      if ey_scr[iter] > 210 then e_on[iter] = 0 : goto next_r_simple
      goto y_ok

check_y_top
      ; Hi=0: Top Edge
      ey_scr[iter] = ey[iter]
      if ey_scr[iter] < 240 then e_on[iter] = 0 : goto next_r_simple

y_ok
      
      e_on[iter] = 1
next_r_simple
   next
   
   if alife = 0 then a_on = 0 : goto boss_coords_check
   
   ; --- Asteroid X ---
   if ax_hi = 1 then goto ax_center
   if ax_hi = 0 then goto ax_left
   a_on = 0 : goto boss_coords_check

ax_center
   ax_scr = ax
   if ax_scr > 176 then a_on = 0 : goto boss_coords_check
   goto ax_ok
   
ax_left
   ax_scr = ax
   if ax_scr < 240 then a_on = 0 : goto boss_coords_check

ax_ok

   ; --- Asteroid Y ---
   if ay_hi = 1 then goto ay_center
   if ay_hi = 0 then goto ay_top
   a_on = 0 : goto boss_coords_check

ay_center
   ay_scr = ay
   if ay_scr > 210 then a_on = 0 : goto boss_coords_check
   goto ay_valid

ay_top
   ay_scr = ay
   if ay_scr < 224 then a_on = 0 : goto boss_coords_check  ; Allow 32px sprite to fully enter (240-16=224 for safety)

ay_valid
   
   a_on = 1
   goto boss_coords_check
   
   ; Just use primitive following for now.
   ; screen_y = py - cam_y (approx)
   goto boss_coords_check

; --- Boss (Level 6) ---
boss_coords_check
   if current_level <> 6 then boss_on = 0 : return
   if boss_state = 0 then boss_on = 0 : return
   
   ; Boss X
   if boss_x_hi = 1 then goto boss_x_center
   if boss_x_hi = 0 then goto boss_x_left
   boss_on = 0 : return
   
boss_x_center
   boss_scr_x = boss_x
   ; Right edge: hide when fully offscreen (x > 160)
   if boss_scr_x > 160 then boss_on = 0 : return
   goto boss_x_ok
   
boss_x_left
   boss_scr_x = boss_x
   ; Left edge: allow partial (32px wide), hide below 224 (256-32)
   if boss_scr_x < 224 then boss_on = 0 : return
   
boss_x_ok
   ; Boss Y
   if boss_y_hi = 1 then goto boss_y_center
   if boss_y_hi = 0 then goto boss_y_top
   boss_on = 0 : return
   
boss_y_center
   boss_scr_y = boss_y
   ; Bottom edge: prevent zone wrap (64px tall), hide when y > 120
   if boss_scr_y > 172 then boss_on = 0 : return
   goto boss_y_ok
   
boss_y_top
   boss_scr_y = boss_y
   ; Top edge: allow partial (64px tall), hide below 192 (256-64)
   if boss_scr_y < 192 then boss_on = 0 : return
   
boss_y_ok
   boss_on = 1
   return

shift_universe
   ; temp_bx = Scroll X, temp_by = Scroll Y
   
   ; --- X Shift ---
   if temp_bx = 0 then goto skip_shift_x
   
   ; Enemies
   for iter = 0 to 3
      if elife[iter] = 0 then goto next_shift_x_e
      temp_v = ex[iter]
      ex[iter] = ex[iter] - temp_bx
      
      if temp_bx >= 128 then goto shift_add_x_e
      ; Subtraction (Pos Scroll)
      if ex[iter] > temp_v then ex_hi[iter] = ex_hi[iter] - 1
      goto check_wrap_x_e
shift_add_x_e
      ; Addition (Neg Scroll)
      if ex[iter] < temp_v then ex_hi[iter] = ex_hi[iter] + 1
check_wrap_x_e
      if ex_hi[iter] = 255 then ex_hi[iter] = 1
      if ex_hi[iter] >= 2 then ex_hi[iter] = 0
next_shift_x_e
   next
   
   ; Asteroid
   if alife = 0 then goto skip_shift_x_a
      temp_v = ax
      ax = ax - temp_bx
      if temp_bx >= 128 then goto shift_add_x_a
      if ax > temp_v then ax_hi = ax_hi - 1
      goto check_wrap_x_a
shift_add_x_a
      if ax < temp_v then ax_hi = ax_hi + 1
check_wrap_x_a
      if ax_hi = 255 then ax_hi = 1
      if ax_hi >= 2 then ax_hi = 0
skip_shift_x_a

   ; Boss (Level 6)
   if boss_state = 0 then goto skip_shift_x_boss
      temp_v = boss_x
      boss_x = boss_x - temp_bx
      if temp_bx >= 128 then goto shift_add_x_boss
      if boss_x > temp_v then boss_x_hi = boss_x_hi - 1
      goto check_wrap_x_boss
shift_add_x_boss
      if boss_x < temp_v then boss_x_hi = boss_x_hi + 1
check_wrap_x_boss
      if boss_x_hi = 255 then boss_x_hi = 1
      if boss_x_hi >= 2 then boss_x_hi = 0
skip_shift_x_boss
   
   ; Player Bullets (Screen Space - Do NOT shift, they have absolute velocity)
   ; Bullets move independently and are not affected by universe shift
   
   ; Enemy Bullets (still shift with world)
   for iter = 0 to 3
      if eblife[iter] > 0 then ebul_x[iter] = ebul_x[iter] - temp_bx
   next

   ; Stars (Screen Wrap 0-160)
   for iter = 0 to 19
      star_x[iter] = star_x[iter] - temp_bx
      if star_x[iter] > 160 && star_x[iter] < 240 then star_x[iter] = 0
      if star_x[iter] >= 240 then star_x[iter] = 159
   next

skip_shift_x

   ; --- Y Shift ---
   if temp_by = 0 then return
   
   ; Enemies
   for iter = 0 to 3
      if elife[iter] = 0 then goto next_shift_y_e
      temp_v = ey[iter]
      ey[iter] = ey[iter] - temp_by
      
      if temp_by >= 128 then goto shift_add_y_e
      if ey[iter] > temp_v then ey_hi[iter] = ey_hi[iter] - 1
      goto check_wrap_y_e
shift_add_y_e
      if ey[iter] < temp_v then ey_hi[iter] = ey_hi[iter] + 1
check_wrap_y_e
      if ey_hi[iter] = 255 then ey_hi[iter] = 3
      if ey_hi[iter] >= 4 then ey_hi[iter] = 0
next_shift_y_e
   next
   
   ; Asteroid
   if alife = 0 then goto skip_shift_y_a
      temp_v = ay
      ay = ay - temp_by
      if temp_by >= 128 then goto shift_add_y_a
      if ay > temp_v then ay_hi = ay_hi - 1
      goto check_wrap_y_a
shift_add_y_a
      if ay < temp_v then ay_hi = ay_hi + 1
check_wrap_y_a
      if ay_hi = 255 then ay_hi = 3
      if ay_hi >= 4 then ay_hi = 0
skip_shift_y_a

   ; Boss (Level 6)
   if boss_state = 0 then goto skip_shift_y_boss
      temp_v = boss_y
      boss_y = boss_y - temp_by
      if temp_by >= 128 then goto shift_add_y_boss
      if boss_y > temp_v then boss_y_hi = boss_y_hi - 1
      goto check_wrap_y_boss
shift_add_y_boss
      if boss_y < temp_v then boss_y_hi = boss_y_hi + 1
check_wrap_y_boss
      if boss_y_hi = 255 then boss_y_hi = 1
      if boss_y_hi >= 2 then boss_y_hi = 0
skip_shift_y_boss
   
   ; Player Bullets (Screen Space - No shift needed for independent velocity)
   ; Bullets already have their own velocity and should not inherit player movement
   
   ; Enemy Bullets (still shift with world)
   for iter = 0 to 3
      if eblife[iter] > 0 then ebul_y[iter] = ebul_y[iter] - temp_by
   next
   
   ; Stars (Screen Wrap 0-192)
   for iter = 0 to 19
      star_y[iter] = star_y[iter] - temp_by
      if star_y[iter] > 192 && star_y[iter] < 240 then star_y[iter] = 0
      if star_y[iter] >= 240 then star_y[iter] = 191
   next
   
   return

; ---- UI Rendering Subroutines (Bug Fix #3: Optimization) ----

draw_lives
   ; Update lives display and cache
   ; Hearts (Lives) as 'F' (Index 15), Palette 5 (Red)
   ; Draw current lives (savescreen will handle persistence)
   ; Display hearts as (lives - 1) to show remaining extra lives
   if player_lives >= 2 then plotchars 'F' 5 10 11
   if player_lives >= 3 then plotchars 'F' 5 20 11
   if player_lives >= 4 then plotchars 'F' 5 30 11
   
   ; Update cache
   cached_lives = player_lives
   return

draw_treasures
   ; Update treasure display and cache
   ; Draw Treasures based on Level Completion (Index 10/'A'), Palette 7
   ; Draw completed level treasures (savescreen will handle persistence)
   if current_level > 1 then plotchars 'A' 7 60 0
   if current_level > 2 then plotchars 'B' 7 68 0
   if current_level > 3 then plotchars 'C' 7 76 0
   if current_level > 4 then plotchars 'D' 7 84 0
   if current_level > 5 then plotchars 'E' 7 92 0
   
   ; Update cache
   cached_level = current_level
   return


   ; ---- Data Tables (ROM) ----
   ; Boosted max acceleration to 6 (was 3) to fix crawling
   data sin_table
   0, 2, 3, 4, 4, 4, 3, 2, 0, 254, 253, 252, 252, 252, 253, 254
end

   data cos_table
   6, 6, 4, 2, 0, 254, 252, 250, 250, 250, 252, 254, 0, 2, 4, 6
end
   
   ; Player Laser Sound - High-pitched pew for player shots
   data sfx_laser
   16, 1, 3 ; version, priority, frames per chunk (3 frames = very quick)
   $1F,$04,$04 ; freq (high pitch), channel 4 (pure tone), volume (quiet)
   $1C,$04,$03 ; slight pitch bend down
   $00,$00,$00
end

   ; Enemy Fire Sound - Lower F# tone for enemy shots
   data sfx_enemyfire
   16, 1, 3 ; version, priority, frames per chunk
   $0C,$04,$05 ; freq ~F# (lower tone), channel 4, volume (medium)
   $0A,$04,$04
   $00,$00,$00
end

   ; Player Damage Sound - Harsh descending buzz for pain feedback
   data sfx_damage
   16, 1, 5 ; version, priority, frames per chunk (longer for impact)
   $08,$08,$0A ; freq (mid-low), channel 8 (harsh/buzz), volume (loud)
   $0A,$08,$08 ; descending pitch
   $0C,$08,$06 ; fade out
   $0E,$08,$04
   $00,$00,$00
end

draw_player_bullets
   for iter = 0 to 3
      if blife[iter] = 0 then goto skip_draw_bul
      
      ; Screen Space: Coordinates are already relative.
      temp_v = bul_x[iter]
      temp_w = bul_y[iter]
      
      ; Manual Culling (Redundant but safe)
      if temp_v > 165 then if temp_v < 240 then goto skip_draw_bul
      if temp_w > 200 then goto skip_draw_bul
      
      plotsprite bullet_conv 1 temp_v temp_w
      
skip_draw_bul
   next
   return
draw_enemy_bullets
   for iter = 0 to 3
      if eblife[iter] = 0 then goto skip_draw_ebul
      
      temp_v = ebul_x[iter]
      temp_w = ebul_y[iter]
      plotsprite bullet_conv 6 temp_v temp_w
      
skip_draw_ebul
   next
   return
draw_enemies
   ; Loop 0-3
   for iter = 0 to 3
      if e_on[iter] = 0 then goto skip_draw_enemy
      temp_v = ex_scr[iter]
      temp_w = ey_scr[iter]
      if elife[iter] > 1 then goto draw_explosion
      plotsprite fighter_conv 3 temp_v temp_w
      goto skip_draw_enemy

draw_explosion
      ; Frame = (18 - elife[iter]) / 2 + offset
      temp_acc = 18 - elife[iter]
      temp_acc = temp_acc / 2
      if temp_acc > 7 then temp_acc = 7
      
      plotsprite fighter_explode_00_conv 3 temp_v temp_w temp_acc

skip_draw_enemy
   next
   return

draw_asteroid
   if a_on = 0 then return
   ; Offset by half height (16px) for proper centering
   ; Use temp variable to avoid negative values causing syntax errors
   temp_v = ay_scr
   if temp_v >= 16 then temp_v = temp_v - 16 else temp_v = 0
   plotsprite asteroid_M_conv 2 ax_scr temp_v
   return

draw_boss
   if boss_on = 0 then return
   plotsprite Boss_conv 6 boss_scr_x boss_scr_y
   return

init_boss
   ; Initialize Boss for Level 6
   boss_x = 80 : boss_x_hi = 1      ; Center of world
   boss_y = 50 : boss_y_hi = 1
   boss_hp = 100                     ; Boss health
   boss_state = 1                    ; Active state
   
   ; Set diagonal velocity (Down-Right by default)
   ; Direction Testing:
   ; Down-Right: bvx=2, bvy=2
   ; Down-Left:  bvx=254, bvy=2
   ; Up-Right:   bvx=2, bvy=254
   ; Up-Left:    bvx=254, bvy=254
   bvx = 2   ; Right (+)
   bvy = 2   ; Down (+)
   
   boss_on = 0  ; Calculated by update_render_coords
   
   ; Set Boss Palette (P6)
   P6C1 = $46 ; Red
   P6C2 = $96 ; Blue
   P6C3 = $0A ; Gray
   return

update_boss
   if boss_state = 0 then return  ; Boss inactive
   
   ; Move Boss (16-bit World Coordinates)
   ; X Axis
   temp_v = bvx
   if temp_v < 128 then goto boss_move_pos_x
   
   ; Negative X
   temp_v = 0 - temp_v
   temp_w = boss_x
   boss_x = boss_x - temp_v
   if boss_x > temp_w then boss_x_hi = boss_x_hi - 1
   goto boss_x_done
   
boss_move_pos_x
   boss_x = boss_x + temp_v
   if boss_x < temp_v then boss_x_hi = boss_x_hi + 1
   
boss_x_done
   ; Wrap X (0-1, 2 segments = 512)
   if boss_x_hi = 255 then boss_x_hi = 1
   if boss_x_hi >= 2 then boss_x_hi = 0
   
   ; Y Axis
   temp_v = bvy
   if temp_v < 128 then goto boss_move_pos_y
   
   ; Negative Y
   temp_v = 0 - temp_v
   temp_w = boss_y
   boss_y = boss_y - temp_v
   if boss_y > temp_w then boss_y_hi = boss_y_hi - 1
   goto boss_y_done
   
boss_move_pos_y
   boss_y = boss_y + temp_v
   if boss_y < temp_v then boss_y_hi = boss_y_hi + 1
   
boss_y_done
   ; Wrap Y (0-1, 2 segments = 512)
   if boss_y_hi = 255 then boss_y_hi = 1
   if boss_y_hi >= 2 then boss_y_hi = 0
   
   return


level_complete
   ; All fighters destroyed - level won!
   gosub StopMusic
   clearscreen
   BACKGRND=$00
   
   screen_timer = 30 ; 30s timeout
   
   characterset alphabet_8_wide
   alphachars ' ABCDEFGHIJKLMNOPQRSTUVWXYZ.!?,"$():'
   
   plotchars 'YOU DID IT' 1 40 2
   
   ; Reward Logic
   plotchars 'REWARD:' 0 20 4
   
   if current_level = 1 then plotchars 'INCREASED FIREPOWER' 1 0 6
   if current_level = 2 then plotchars 'INCREASED SPEED'     1 0 6
   if current_level = 3 then plotchars 'MAX HEALTH UP'       1 0 6
   if current_level = 4 then plotchars 'FASTER RECHARGE'     1 0 6
   if current_level = 5 then plotchars 'EXTRA LIFE'          1 0 6
   
   ; Draw Prize Icon
   characterset scoredigits_8_wide
   alphachars '0123456789ABCDEF'
   
   if current_level = 1 then plotchars 'A' 7 80 4
   if current_level = 2 then plotchars 'B' 7 80 4
   if current_level = 3 then plotchars 'C' 7 80 4
   if current_level = 4 then plotchars 'D' 7 80 4
   if current_level = 5 then plotchars 'E' 7 80 4
   
   drawscreen
   
   ; Wait for button release
level_complete_release
   if joy0fire0 then goto level_complete_release
   
   ; Wait for button press with timeout
level_complete_wait
   drawscreen ; Sync to 60Hz
   
   frame = frame + 1
   if frame >= 60 then frame = 0 : screen_timer = screen_timer - 1
   if screen_timer = 0 then goto level_next_restore
   
   if !joy0fire0 then goto level_complete_wait

level_next_restore
   ; Restore standard scoredigits mapping just in case
   alphachars '0123456789ABCDEF'
   characterset scoredigits_8_wide

level_next
   
   ; Reward Check
   if current_level = 5 then player_lives = player_lives + 1

   ; Advance to next level
   ; Advance to next level
   current_level = current_level + 1
   cached_level = current_level  ; Update cache for optimized UI (Bug Fix #3)
   if current_level > 6 then goto you_win_game
   
   ; Reset music to trigger new song selection for this level
   gosub StopMusic
   music_ptr_hi = 0
   
   ; Partial shield refill (diminishes each level)
   temp_v = 50 - (current_level * 10)
   if temp_v < 0 then temp_v = 0
   player_shield = player_shield + temp_v
   if player_shield > 99 then player_shield = 99
   shield_bcd = converttobcd(player_shield)
   
   BACKGRND=$00
   goto init_level

lose_life
   ; Shields depleted - lose a life
   player_lives = player_lives - 1
   if player_lives <= 0 then goto you_lose
   
   ; Flash effect
   BACKGRND=$44  ; Red = death
   clearscreen
   drawscreen
   
   ; Brief pause
   temp_v = 0
lose_life_pause
   temp_v = temp_v + 1
   if temp_v < 60 then goto lose_life_pause
   
   BACKGRND=$00
   goto restart_level

restart_level
   ; Reset level state after death
   
   temp_v = 50
   if current_level >= 4 then temp_v = 99
   player_shield = temp_v
   shield_bcd = converttobcd(temp_v)
   
   ; Reset fighters based on current level
   gosub set_level_fighters
   fighters_bcd = converttobcd(fighters_remaining)
   
   ; Reset prizes
   prize_active0 = 1
   prize_active1 = 1
   prize_active2 = 1
   prize_active3 = 1
   prize_active4 = 1
   
   ; Clear screen from level complete/death displays
   clearscreen
   
   ; Redraw and save static UI elements (hearts, treasures)
   gosub draw_lives
   gosub draw_treasures
   savescreen
   
   ; Reset player position - Segment 1 (Center of 512x512)
   px = 80 : py = 90
   px_hi = 1 : py_hi = 1
   ; Camera removed
   
   ; Clear enemies/bullets/asteroids
   for iter = 0 to 3
      elife[iter] = 0
      blife[iter] = 0
      eblife[iter] = 0
   next
   alife = 0
   
   goto main_loop

init_level
   ; Initialize new level
   gosub set_level_fighters
   fighters_bcd = converttobcd(fighters_remaining)
   
   ; Set level difficulty (speed/fire rate)
   gosub set_level_config
   
   ; Reset prizes
   prize_active0 = 1
   prize_active1 = 1
   prize_active2 = 1
   prize_active3 = 1
   prize_active4 = 1
   
   goto restart_level

set_level_fighters
   ; Set fighter count based on level
   if current_level = 1 then fighters_remaining = 20
   if current_level = 2 then fighters_remaining = 40
   if current_level = 3 then fighters_remaining = 60
   if current_level = 4 then fighters_remaining = 80
   if current_level >= 5 then fighters_remaining = 99
   
   ; Level 6: Boss Level (Keep enemies active for now as requested)
   if current_level = 6 then fighters_remaining = 99
   return

set_level_config
   ; Configure enemy speed and fire rate based on level
   ; 
   ; enemy_move_mask: Controls movement speed via frame masking
   ;   Mask = 1: Move 1px per 2 frames (slow)
   ;   Mask = 0: Move 1px per frame (fast)
   ;
   ; enemy_fire_cooldown: Frames between enemy shots
   ;   Higher = slower fire rate, Lower = rapid fire
   
   if current_level = 1 then enemy_move_mask = 2 : enemy_fire_cooldown = 60 : asteroid_move_mask = 3 : asteroid_base_speed = 1
   if current_level = 2 then enemy_move_mask = 1 : enemy_fire_cooldown = 45 : asteroid_move_mask = 1 : asteroid_base_speed = 1
   if current_level = 3 then enemy_move_mask = 1 : enemy_fire_cooldown = 30 : asteroid_move_mask = 1 : asteroid_base_speed = 1
   if current_level = 4 then enemy_move_mask = 0 : enemy_fire_cooldown = 25 : asteroid_move_mask = 0 : asteroid_base_speed = 1
   if current_level >= 5 then enemy_move_mask = 0 : enemy_fire_cooldown = 20 : asteroid_move_mask = 0 : asteroid_base_speed = 2
   return

you_win_game
   ; Won all levels!
   gosub StopMusic
   clearscreen
   BACKGRND=$00  ; Black (was Green)
   ; Flash celebration
   drawscreen
   ; Wait for button release first
you_win_release
   if joy0fire0 then goto you_win_release
   
   ; Now wait for new press
   screen_timer = 250
you_win_wait
   screen_timer = screen_timer - 1
   if screen_timer = 0 then goto cold_start
   drawscreen
   if !joy0fire0 then goto you_win_wait
   goto cold_start

loose_life_check
   ; Legacy - redirects to lose_life
   goto lose_life

round_reset
   ; Legacy - redirects to restart_level
   goto restart_level

you_lose
   ; Game Over - no lives left
   gosub StopMusic
   clearscreen
   BACKGRND=$00
   
   screen_timer = 30 ; 30s timeout
   
   characterset alphabet_8_wide
   alphachars ' ABCDEFGHIJKLMNOPQRSTUVWXYZ.!?,"$():'
   
   plotchars 'DO NOT GIVE UP' 1 30 4
   plotchars 'TRY AGAIN' 0 1 6
   plotchars 'YOUR FATE AWAITS' 1 1 8
   
   drawscreen
   
   ; Wait for button release
you_lose_release
   if joy0fire0 then goto you_lose_release
   
   ; Wait for button press with timeout
you_lose_wait
   drawscreen ; Sync to 60Hz
   
   frame = frame + 1
   if frame >= 60 then frame = 0 : screen_timer = screen_timer - 1
   if screen_timer = 0 then goto game_over_restore
   
   if !joy0fire0 then goto you_lose_wait

game_over_restore
   ; Restore standard scoredigits mapping just in case
   alphachars '0123456789ABCDEF'
   characterset scoredigits_8_wide
   
   goto cold_start

   ; ============================================
   ; POKEY VGM Register Stream Driver (ASM)
   ; ============================================

StopMusic
   asm
   lda #0
   sta $0451 ; AUDC1
   sta $0453 ; AUDC2
   sta $0455 ; AUDC3
   sta $0457 ; AUDC4
end
   return

PlayMusic
   asm
   ; Check if initialized (high byte != 0)
   lda music_ptr_hi
   bne .SetupPtr
   
   ; Initialize pointer based on current_level
   ; Song_01: Title (level 0), Levels 2, 5
   ; Song_02: Levels 1, 3, 4
   ; Song_03: Level 6 (Boss)
   
   lda current_level
   cmp #6
   beq .UseSong3
   cmp #1
   beq .UseSong2
   cmp #3
   beq .UseSong2
   cmp #4
   beq .UseSong2
   
   ; Use Song_01 (Title, Level 2, Level 5)
.UseSong1:
   lda #1
   sta current_song     ; Track which song is playing
   lda #<Song_01_Data
   sta music_ptr_lo
   lda #>Song_01_Data
   sta music_ptr_hi
   jmp .SetupPtr

.UseSong3:
   lda #3
   sta current_song
   lda #<Song_03_Data
   sta music_ptr_lo
   lda #>Song_03_Data
   sta music_ptr_hi
   jmp .SetupPtr
   
.UseSong2:
   lda #2
   sta current_song     ; Track which song is playing
   lda #<Song_02_Data
   sta music_ptr_lo
   lda #>Song_02_Data
   sta music_ptr_hi

.SetupPtr:
   ; Copy persistent pointer to ZP for indirect access
   lda music_ptr_lo
   sta $E2 ; music_zp_lo (var98)
   lda music_ptr_hi
   sta $E3 ; music_zp_hi (var99)

   ; Process Frame
   ldy #0
.Loop:
   lda ($E2),y
   cmp #$FF       ; End of Frame?
   beq .EndFrame
   cmp #$FE       ; End of Song?
   beq .EndSong
   
   ; It is a Register Address
   tax            ; X = Register
   iny
   lda ($E2),y  ; A = Value
   sta $0450,x    ; Write to POKEY
   iny
   cpy #64        ; Safety: Prevent infinite processing (Max 64 bytes/frame)
   bcs .EndFrame  ; Force exit if too many bytes
   bne .Loop      ; Continue if not 0

.EndFrame:
   ; Advance pointer past the 0xFF
   iny
   tya
   clc
   adc music_ptr_lo
   sta music_ptr_lo
   lda music_ptr_hi
   adc #0
   sta music_ptr_hi
   rts

.EndSong:
   ; Reset pointer based on current_song variable
   lda current_song
   cmp #3
   beq .LoopSong3
   cmp #2
   beq .LoopSong2
   
.LoopSong1:
   lda #<Song_01_Data
   sta music_ptr_lo
   lda #>Song_01_Data
   sta music_ptr_hi
   rts
   
.LoopSong2:
   lda #<Song_02_Data
   sta music_ptr_lo
   lda #>Song_02_Data
   sta music_ptr_hi
   rts

.LoopSong3:
   lda #<Song_03_Data
   sta music_ptr_lo
   lda #>Song_03_Data
   sta music_ptr_hi
   rts
end

   ; Music Data - Two Songs
   ; Song_01: Title/Levels 2,5
   ; Song_02: Levels 1,3,4
   asm
Song_01_Data:
   incbin "music/Song_01.bin"
   .byte $FE ; Safety Terminator (Loop Song)
   
Song_02_Data:
   incbin "music/Song_02.bin"

Song_03_Data:
   incbin "music/Boss.bin"
   .byte $FE ; Safety Terminator (Loop Song)
end
