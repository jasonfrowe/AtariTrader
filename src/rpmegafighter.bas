   displaymode 160A
   set doublewide on
 
   ; Import graphics
   incgraphic sprite_spaceship1.png
   incgraphic sprite_spaceship2.png
   incgraphic sprite_spaceship3.png
   incgraphic sprite_spaceship4.png
   incgraphic sprite_spaceship5.png
   incgraphic sprite_spaceship6.png
   incgraphic sprite_spaceship7.png
   incgraphic sprite_spaceship8.png
   incgraphic sprite_spaceship9.png
   incgraphic sprite_spaceship10.png
   incgraphic sprite_spaceship11.png
   incgraphic sprite_spaceship12.png
   incgraphic sprite_spaceship13.png
   incgraphic sprite_spaceship14.png
   incgraphic sprite_spaceship15.png
   incgraphic sprite_spaceship16.png
   
   incgraphic bullet_conv.png
   incgraphic fighter_conv.png
   ; Explosion Frames (Split for animation)
   incgraphic fighter_explode_00_conv.png
   incgraphic fighter_explode_01_conv.png
   incgraphic fighter_explode_02_conv.png
   incgraphic fighter_explode_03_conv.png
   incgraphic fighter_explode_04_conv.png
   incgraphic fighter_explode_05_conv.png
   incgraphic fighter_explode_06_conv.png
   incgraphic fighter_explode_07_conv.png
   incgraphic asteroid_L_conv.png
   incgraphic asteroid_M_conv.png
   incgraphic tileset_blanks.png 160A 3 0 1 2
   incgraphic scoredigits_8_wide.png

   characterset tileset_blanks

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

   ; Enemy Bullet Variables (Pool of 2)
   ; Using var60+
   dim ebul_x  = var60 ; 60-63 ... Need High Bytes for these too?
   ; For now, keep bullets/enemies strictly Screen Space?
   ; User said "Infinite World". Everything needs to be World Space eventually.
   ; Let's keep them Screen Space temporarily to confirm Player scrolling first.
   dim ebul_y  = var64
   dim ebul_vx = var68 ; 68-71
   dim ebul_vy = var160 ; Moved to 160 safe zone
   dim eblife  = var164 ; 164-167

   ; High Byte Arrays for Bullets (World Coords)
   dim bul_x_hi = var180 ; 180-183
   dim bul_y_hi = var184 ; 184-187
   dim ebul_x_hi = var188 ; 188-191
   dim ebul_y_hi = var192 ; 192-195
   dim temp_val_hi = var196
   dim ecooldown = var72
   dim temp_w = var73
   
   ; Safety Buffer 74-79
   
   ; Starfield Variables (20 stars)
   ; Moved to var80+ to prevent memory corruption from scratch vars
   dim star_x = var80 ; 80-99
   dim star_y = var100 ; 100-119
   dim star_c = var120 ; 120-139
   dim sc1 = var140
   dim sc2 = var141
   dim sc3 = var142
   dim cycle_state = var143

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
   
   ; Physics Accumulators (Dedicated)
   dim acc_mx = var78
   dim acc_my = var79
   
   dim rand_val = var148
   
   ; Asteroid Variables (Single Large Asteroid)
   ; Moved to var150 to make room for enemy arrays
   dim ax = var150
   dim ay = var151
   dim avx = var152
   dim avy = var153
   dim alife = var154
   dim ax_hi = var155
   dim ay_hi = var156
   
   ; Aliases for plotsprite usage
   dim bul_x0 = var18 : dim bul_x1 = var19 : dim bul_x2 = var20 : dim bul_x3 = var21
   dim bul_y0 = var22 : dim bul_y1 = var23 : dim bul_y2 = var24 : dim bul_y3 = var25
   dim blife0 = var34 : dim blife1 = var35 : dim blife2 = var36 : dim blife3 = var37

   ; 0 = inactive, >0 = active frames
   
   ; Remainder arrays for bullets (optional, if we want sub-pixel accuracy)
   ; For 4px/frame speed, sub-pixel is less critical, but angles might need it.
   ; Let's try without reminders first for simplicity/RAM saving.


cold_start
   ; Palette Setup
   P0C1=$26: P0C2=$24: P0C3=$04
   P1C1=$0E: P1C2=$38: P1C3=$FC ; Bullets (Yellow/White)
   P2C1=$94: P2C2=$98: P2C3=$9C ; Asteroids (Blue for debug distinction)
   P3C1=$B4: P3C2=$46: P3C3=$1C ; Enemy (Green, Red, Yellow)
   P4C1=$08: P4C2=$0C: P4C3=$0F ; Stars (Dim Grey, Light Grey, White)
   P5C1=$34: P5C2=$86: P5C3=$0A ; Spaceship
   
   BACKGRND=$00 ; Set Background to Black

    ; Initialize Variables
    px = 80             ; Low byte (0-255)
    dim px_hi = var170  ; High byte (0-4 for 1024)
    px_hi = 0
    py = 90
    dim py_hi = var171
    py_hi = 0
    
    ; Scoring Variables
    ; Scoring Variables
    dim score_p = var144
    dim score_e = var145
    dim bcd_score = var146
    
    ; Initialize Scores
    score_p = 0
    score_e = 0
    
    ; Camera Vars
    dim cam_x = var172
    dim cam_x_hi = var173
    dim cam_y = var174
    dim cam_y_hi = var175
    ; Init Camera centered on 80,90 initially? 
    ; Let's start camera at 0,0 for now to match legacy behavior
    cam_x = 0 : cam_x_hi = 0
    cam_y = 0 : cam_y_hi = 0
    
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
   ecooldown = 0
   eblife[0] = 0 : eblife[1] = 0
   
   ; Clear enemies
   elife[0]=0 : elife[1]=0 : elife[2]=0 : elife[3]=0
   
   gosub init_stars

main_loop
   clearscreen
   
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
   ; Scaling factor 64 (6 bits fraction)
   ; X Axis
   temp_v = vx_p - vx_m
   
   ; 16-bit Add: px = px + temp_v (signed scale?)
   ; Current Logic: temp_v is "sub-pixels" effectively.
   ; Let's assume temp_v is ~ 32 = 0.5px?
   ; Old logic: px = px + (temp_v / 64)
   ; New Logic: We want to accumulate sub-pixels.
   ; We'll treat px/px_hi as 8.8 Fixed Point? No, px is integer pixel.
   ; ---- Physics Update ----
   ; X Axis
   ; Positive
   temp_v = vx_p + rx
   rx = temp_v & 63
   temp_w = temp_v / 64
   
   if temp_w = 0 then goto skip_pos_x
      px = px + temp_w
      if px < temp_w then px_hi = px_hi + 1
skip_pos_x

   ; Negative
   ; Using dedicated accumulator
   temp_v = vx_m + acc_mx
   acc_mx = temp_v & 63
   temp_w = temp_v / 64
   
   if temp_w = 0 then goto skip_neg_x
      temp_v = px
      px = px - temp_w
      if px > temp_v then px_hi = px_hi - 1
skip_neg_x

   ; Wrap X
   if px_hi >= 4 then px_hi = 0
   if px_hi = 255 then px_hi = 3
   
   ; Y Axis
   ; Positive (Down)
   temp_v = vy_p + ry
   ry = temp_v & 63
   temp_w = temp_v / 64
   
   if temp_w = 0 then goto skip_pos_y
      py = py + temp_w
      if py < temp_w then py_hi = py_hi + 1
skip_pos_y
   
   ; Negative (Up) (using temp_by accumulator)
   temp_v = vy_m + acc_my
   acc_my = temp_v & 63
   temp_w = temp_v / 64
   
   if temp_w = 0 then goto skip_neg_y
      temp_v = py
      py = py - temp_w
      if py > temp_v then py_hi = py_hi - 1
skip_neg_y

   ; Wrap Y
   if py_hi >= 4 then py_hi = 0
   if py_hi = 255 then py_hi = 3

   ; ---- Bullet Update ----
   gosub update_bullets

   ; ---- Enemy Update ----
   if ecooldown > 0 then ecooldown = ecooldown - 1
   gosub update_enemy
   
   ; ---- Enemy Bullet Update ----
   gosub update_enemy_bullets
   
   ; ---- Asteroid Update ----
   gosub update_asteroid

   ; ---- Collisions ----
   gosub check_collisions

   ; ---- Friction ----
   gosub apply_friction

   ; ---- Boundaries (REMOVED - World Wraps) ----
   ; if px > 150 then px = 150 ...

   ; ---- Camera Update ----
   gosub update_camera

    ; ---- Draw ----
    ; Draw Scores
    bcd_score = converttobcd(score_p)
    plotvalue scoredigits_8_wide 5 bcd_score 2 10 10
    
    bcd_score = converttobcd(score_e)
    plotvalue scoredigits_8_wide 3 bcd_score 2 130 10

    ; Calculate Player Screen Position (relative to camera)
    temp_v = px - cam_x
    temp_w = py - cam_y
    plotsprite sprite_spaceship1 5 temp_v temp_w shpfr
     
    gosub draw_stars
    gosub draw_player_bullets
    gosub draw_enemies
    if alife > 0 then gosub draw_asteroid
    gosub draw_enemy_bullets
 
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
   
   ; Max speed 190 (approx 3 px/frame)
   if vx_p > 190 then vx_p = 190
   if vx_m > 190 then vx_m = 190
   if vy_p > 190 then vy_p = 190
   if vy_m > 190 then vy_m = 190
   return

neutralize_forces
   ; X Axis
   if vx_p > 0 && vx_m > 0 then gosub cancel_x
   ; Y Axis
   if vy_p > 0 && vy_m > 0 then gosub cancel_y
   return

cancel_x
   if vx_p < vx_m then common = vx_p else common = vx_m
   vx_p = vx_p - common
   vx_m = vx_m - common
   return

cancel_y
   if vy_p < vy_m then common = vy_p else common = vy_m
   vy_p = vy_p - common
   vy_m = vy_m - common
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
      if blife[iter] > 0 then gosub move_one_bullet
   next
   return

move_one_bullet
   ; Screen Space Movement (Simple 8-bit)
   ; X Axis
   temp_v = bul_vx[iter]
   bul_x[iter] = bul_x[iter] + temp_v
   
   ; Bounds Check X (Kill if off screen)
   ; Valid: 0-160. Margins: 240-255 (-16) and 160-170.
   ; Kill if > 170 and < 240
   if bul_x[iter] > 170 then if bul_x[iter] < 240 then blife[iter] = 0

   ; Y Axis
   temp_v = bul_vy[iter]
   bul_y[iter] = bul_y[iter] + temp_v
   
   ; Bounds Check Y
   if bul_y[iter] > 200 then blife[iter] = 0
   
   ; Lifetime Check
   if blife[iter] > 0 then blife[iter] = blife[iter] - 1
   return
   ; --- Dead Code Below ---

bul_x_neg
   temp_v = 0 - temp_v
   temp_w = bul_x[iter]
   bul_x[iter] = bul_x[iter] - temp_v
   if bul_x[iter] > temp_w then bul_x_hi[iter] = bul_x_hi[iter] - 1

bul_x_done
   ; Wrap X
   if bul_x_hi[iter] >= 4 then bul_x_hi[iter] = 0
   if bul_x_hi[iter] = 255 then bul_x_hi[iter] = 3
   
   ; Y Axis
   temp_v = bul_vy[iter]
   if temp_v >= 128 then goto bul_y_neg
   
   ; Positive Y
   bul_y[iter] = bul_y[iter] + temp_v
   if bul_y[iter] < temp_v then bul_y_hi[iter] = bul_y_hi[iter] + 1
   goto bul_y_done

bul_y_neg
   temp_v = 0 - temp_v
   temp_w = bul_y[iter]
   bul_y[iter] = bul_y[iter] - temp_v
   if bul_y[iter] > temp_w then bul_y_hi[iter] = bul_y_hi[iter] - 1

bul_y_done
   ; Wrap Y
   if bul_y_hi[iter] >= 4 then bul_y_hi[iter] = 0
   if bul_y_hi[iter] = 255 then bul_y_hi[iter] = 3
   
   ; Off-Screen Culling (Screen Space Check)
   temp_v = bul_x[iter] - cam_x
   if temp_v > 165 then if temp_v < 240 then blife[iter] = 0 ; 160 + margin
   
   temp_v = bul_y[iter] - cam_y
   if temp_v > 200 then blife[iter] = 0 ; 192 + margin
   
   ; Lifetime Check (Backup cleanup)
   if blife[iter] > 0 then blife[iter] = blife[iter] - 1
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
   ; Center Bullet (Px+7, Py+7) relative to Camera
   temp_v = px - cam_x
   bul_x[iter] = temp_v + 7
   
   temp_w = py - cam_y
   bul_y[iter] = temp_w + 7
   
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
   
   bcooldown = 15 ; Can fire every 15 frames
   return

update_enemy
    ; Loop through all potential enemies
    for iter = 0 to 3
       if elife[iter] = 0 then goto try_spawn_enemy
       if elife[iter] > 1 then goto update_explosion_state
       
       ; --- Movement Logic (per enemy) ---
       ; Move every 2nd frame
       if (frame & 1) > 0 then goto enemy_logic_done
       
       ; Chase Logic using temp vars
       temp_v = ex[iter]
       temp_w = ey[iter]
       
       ; Wrap Safe Chase Logic (X)
       temp_acc = px + 8 ; Center
       temp_acc = temp_acc - temp_v
       if temp_acc = 0 then goto skip_ex_move
       if temp_acc >= 128 then temp_v = temp_v - 1 else temp_v = temp_v + 1
skip_ex_move

       ; Wrap Safe Chase Logic (Y)
       temp_acc = py + 8 ; Center
       temp_acc = temp_acc - temp_w
       if temp_acc = 0 then goto skip_ey_move
       if temp_acc >= 128 then temp_w = temp_w - 1 else temp_w = temp_w + 1
skip_ey_move
       
       ex[iter] = temp_v
       ey[iter] = temp_w
       
       ; Firing Chance (Global Cooldown)
       if ecooldown > 0 then goto skip_firing_chance
       
       ; Chance to fire (1 in 16 per frame)
       rand_val = frame + iter
       rand_val = rand_val & 15
       if rand_val = 0 then gosub fire_enemy_bullet
          
skip_firing_chance
       goto enemy_logic_done

   P2C1=$04: P2C2=$08: P2C3=$0C ; Asteroids (Greys)
   
update_explosion_state
   elife[iter] = elife[iter] - 1
   if elife[iter] = 1 then elife[iter] = 0 ; Done, set to Dead
   goto enemy_logic_done

try_spawn_enemy
       ; Random Spawn Chance
       rand_val = frame & 127
       if rand_val > 5 then goto enemy_logic_done
       
       ; Spawn logic inline
       elife[iter] = 1
       ; Mix iter into randomness so they don't all spawn at same spot
       temp_v = frame + iter
       rand_val = temp_v & 3
       if rand_val = 0 then ex[iter] = 5 : ey[iter] = 90
       if rand_val = 1 then ex[iter] = 155 : ey[iter] = 90
       if rand_val = 2 then ex[iter] = 80 : ey[iter] = 5
       if rand_val = 3 then ex[iter] = 80 : ey[iter] = 175
       
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
   eblife[temp_acc] = 120 ; Increased lifetime
   ebul_x[temp_acc] = ex[iter]
   ebul_x_hi[temp_acc] = cam_x_hi ; Approx (assuming local enemy)
   ebul_y[temp_acc] = ey[iter]
   ebul_y_hi[temp_acc] = cam_y_hi ; Approx
   
   temp_v = ex[iter] ; Store ex in temp for logic
   temp_w = ey[iter] ; Store ey
   
   ; Aim at player
   ; using temp_v/w instead of array access for speed/clarity
   ; Speed set to 2px/frame
   ; Aim at player (Wrap Safe)
   ; temp_bx = delta X
   temp_bx = px + 8 ; Target Center
   temp_bx = temp_bx - temp_v
   if temp_bx >= 128 then ebul_vx[temp_acc] = 254 : temp_bx = 0 - temp_bx else ebul_vx[temp_acc] = 2
   
   temp_by = py + 8 ; Target Center
   temp_by = temp_by - temp_w
   if temp_by >= 128 then ebul_vy[temp_acc] = 254 : temp_by = 0 - temp_by else ebul_vy[temp_acc] = 2
   
   ; 8-way logic
   temp_v = temp_bx / 2
   if temp_v > temp_by then ebul_vy[temp_acc] = 0
   
   temp_v = temp_by / 2
   if temp_v > temp_bx then ebul_vx[temp_acc] = 0
   
   ecooldown = 15 ; Reduced from 60 to allow multiple bullets on screen
   return

update_enemy_bullets
   for iter = 0 to 3
      if eblife[iter] = 0 then goto skip_ebul_update
      
      eblife[iter] = eblife[iter] - 1
      
      ; Move X
      temp_v = ebul_vx[iter]
      if temp_v >= 128 then goto ebul_x_neg
      
      ; Positive X
      ebul_x[iter] = ebul_x[iter] + temp_v
      if ebul_x[iter] < temp_v then ebul_x_hi[iter] = ebul_x_hi[iter] + 1
      goto ebul_x_done

ebul_x_neg
      temp_v = 0 - temp_v
      temp_w = ebul_x[iter]
      ebul_x[iter] = ebul_x[iter] - temp_v
      if ebul_x[iter] > temp_w then ebul_x_hi[iter] = ebul_x_hi[iter] - 1

ebul_x_done
      ; Wrap X
      if ebul_x_hi[iter] >= 4 then ebul_x_hi[iter] = 0
      if ebul_x_hi[iter] = 255 then ebul_x_hi[iter] = 3
      
      ; Move Y
      temp_v = ebul_vy[iter]
      if temp_v >= 128 then goto ebul_y_neg
      
      ; Positive Y
      ebul_y[iter] = ebul_y[iter] + temp_v
      if ebul_y[iter] < temp_v then ebul_y_hi[iter] = ebul_y_hi[iter] + 1
      goto ebul_y_done

ebul_y_neg
      temp_v = 0 - temp_v
      temp_w = ebul_y[iter]
      ebul_y[iter] = ebul_y[iter] - temp_v
      if ebul_y[iter] > temp_w then ebul_y_hi[iter] = ebul_y_hi[iter] - 1

ebul_y_done
      ; Wrap Y
      if ebul_y_hi[iter] >= 4 then ebul_y_hi[iter] = 0
      if ebul_y_hi[iter] = 255 then ebul_y_hi[iter] = 3

      ; Off-Screen Culling
      temp_v = ebul_x[iter] - cam_x
      if temp_v > 165 then if temp_v < 240 then eblife[iter] = 0
      
      temp_v = ebul_y[iter] - cam_y
      if temp_v > 200 then eblife[iter] = 0

skip_ebul_update
   next
   return

update_asteroid
   if alife = 0 then gosub spawn_asteroid
   if alife = 0 then return
   
   ; Move Asteroid (Slow drift - every 4th frame)
   if (frame & 3) > 0 then return
   
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
   ; Wrap X (0-3)
   if ax_hi >= 4 then ax_hi = 0
   if ax_hi = 255 then ax_hi = 3

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
   ; Wrap Y (0-3)
   if ay_hi >= 4 then ay_hi = 0
   if ay_hi = 255 then ay_hi = 3
   
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
   temp_v = ax + cam_x
   ax = temp_v
   ax_hi = cam_x_hi
   if ax < temp_v then ax_hi = ax_hi + 1 ; Carry
   if ax_hi >= 4 then ax_hi = 0 ; Wrap Safe
   
   temp_v = ay + cam_y
   ay = temp_v
   ay_hi = cam_y_hi
   if ay < temp_v then ay_hi = ay_hi + 1
   if ay_hi >= 4 then ay_hi = 0
   
   ; Random Velocity (Slow drift)
   ; 1 or -1 (255)
   rand_val = frame & 1
   if rand_val = 0 then avx = 1 else avx = 255
   rand_val = frame & 2
   if rand_val = 0 then avy = 1 else avy = 255
   
   return

check_collisions
   ; 1. Bullets vs Enemies (Loop both)
   for iter = 0 to 3 ; Bullets
      if blife[iter] = 0 then goto skip_bullet_coll
      
      for temp_acc = 0 to 3 ; Enemies
         if elife[temp_acc] <> 1 then goto skip_enemy_coll ; Only collide with Alive (1). Ignore 0 (Dead) and >1 (Exploding)
         
          ; Is Enemy On Screen? (Check High Byte)
          temp_val_hi = ex_hi[temp_acc] - cam_x_hi
          if temp_val_hi = 3 then temp_val_hi = 255
          if temp_val_hi = 253 then temp_val_hi = 1
          if temp_val_hi > 1 && temp_val_hi < 255 then goto skip_enemy_coll
          
          ; Enemy Screen X
          temp_w = ex[temp_acc] - cam_x
          
          ; Check X Collision (Screen Space)
          temp_v = bul_x[iter] - temp_w
          if temp_v >= 128 then temp_v = 0 - temp_v
          if temp_v >= 4 then goto skip_enemy_coll
          
          ; Enemy Screen Y
          temp_w = ey[temp_acc] - cam_y
          
          ; Check Y Collision
          temp_v = bul_y[iter] - temp_w
          if temp_v >= 128 then temp_v = 0 - temp_v
          if temp_v >= 6 then goto skip_enemy_coll
          
          ; Hit!
          blife[iter] = 0
          elife[temp_acc] = 18 ; Start Explosion (18 frames)
          
          ; Increase Player Score
          score_p = score_p + 1 
          if score_p >= 100 then goto you_win
          
          goto skip_enemy_coll ; Bullet used up
         
skip_enemy_coll
      next
      
skip_bullet_coll
   next
   
   ; 2. Player vs Enemies
   for iter = 0 to 3
      if elife[iter] <> 1 then goto skip_p_e
      
      ; Is Enemy On Screen?
      temp_val_hi = ex_hi[iter] - cam_x_hi
      if temp_val_hi = 3 then temp_val_hi = 255
      if temp_val_hi = 253 then temp_val_hi = 1
      if temp_val_hi > 1 && temp_val_hi < 255 then goto skip_p_e
      
      ; X Check (Screen Space)
      temp_v = px - cam_x
      temp_w = ex[iter] - cam_x
      temp_v = temp_v - temp_w
      temp_v = temp_v + 4 ; Offset to shrink left side
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 11 then goto skip_p_e
      
      ; Y Check
      temp_v = py - cam_y
      temp_w = ey[iter] - cam_y
      temp_v = temp_v - temp_w
      ; temp_v = temp_v + 6 ; REMOVED OFFSET
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 11 then goto skip_p_e
      
      ; Hit Player
      elife[iter] = 18 ; Explode
      score_e = score_e + 1
       if score_e >= 100 then goto you_lose
      
skip_p_e
   next
   
   goto check_asteroid_coll
   
check_asteroid_coll
   if alife = 0 then goto check_player_ebul

   ; 3. Bullets vs Asteroid (Large 32x64 sprite)
   ; Center alignment strategy:
   ; Bullet Center is Bx+8. Asteroid Center is Ax+16.
   ; Perfect alignment: Bx+8 = Ax+16 => Bx = Ax+8.
   ; Check: abs(Bx - Ax - 8) < ThreadholdX (20)
   
   for iter = 0 to 3
      if blife[iter] = 0 then goto skip_bul_ast
      
      ; Check Dist High Byte
      temp_val_hi = ax_hi - cam_x_hi
      if temp_val_hi = 3 then temp_val_hi = 255
      if temp_val_hi = 253 then temp_val_hi = 1
      if temp_val_hi > 1 && temp_val_hi < 255 then goto skip_bul_ast

      ; Calculate Screen Space Ax
      temp_w = ax - cam_x ; Screen Ax

      ; X Check
      ; Medium Asteroid (16x16 approx). Center at +8. Screen Ax is Top-Left.
      ; Bullet X is Center.
      temp_v = bul_x[iter] - temp_w
      temp_v = temp_v - 8
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 10 then goto skip_bul_ast
      
      ; Y Check
      temp_w = ay - cam_y ; Screen Ay
      temp_v = bul_y[iter] - temp_w
      temp_v = temp_v - 8
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 10 then goto skip_bul_ast
      
      ; Hit!
      blife[iter] = 0
      alife = 0
      ; TODO: Split asteroid
      goto check_player_ebul

skip_bul_ast
   next
   
   ; 4. Player vs Asteroid (Screen Space)
   ; Check Dist High Byte
   temp_val_hi = ax_hi - cam_x_hi
   if temp_val_hi = 3 then temp_val_hi = 255
   if temp_val_hi = 253 then temp_val_hi = 1
   if temp_val_hi > 1 && temp_val_hi < 255 then goto check_player_ebul

   ; Px - Cam vs Ax - Cam  => Px vs Ax (Screen)
   temp_v = px - cam_x
   temp_w = ax - cam_x
   
   temp_w = temp_v - temp_w
   if temp_w >= 128 then temp_w = 0 - temp_w
   if temp_w >= 14 then goto check_player_ebul
   
   ; Y Check
   temp_v = py - cam_y
   temp_w = ay - cam_y
   temp_w = temp_v - temp_w
   if temp_w >= 128 then temp_w = 0 - temp_w
   if temp_w >= 14 then goto check_player_ebul
   
   ; Hit Player!
   alife = 0
   ; TODO: Play Death
   
check_player_ebul
   ; Check vs Enemy Bullets
   for iter = 0 to 3
      if eblife[iter] = 0 then goto skip_ebul_coll
      
      ; --- High Byte / Visibility Check (X) ---
      temp_val_hi = ebul_x_hi[iter] - cam_x_hi
      ; Wrap Correction
      if temp_val_hi = 3 then temp_val_hi = 255
      if temp_val_hi = 253 then temp_val_hi = 1
      ; IF not 0, 1, or -1 (255), then it's too far.
      if temp_val_hi > 1 && temp_val_hi < 255 then goto skip_ebul_coll

      ; --- X Collision ---
      ; Calculate Screen Coords
      temp_v = px - cam_x       ; Player Screen X
      temp_w = ebul_x[iter] - cam_x ; Bullet Screen X
      
      ; Delta = Px - Bx
      temp_v = temp_v - temp_w
      
      ; Center Offset: Px+8 vs Bx+1 implies Px needs to be +7 vs Bx to match.
      ; Logic: Px - Bx + 7 should be near 0.
      temp_v = temp_v + 7
      
      if temp_v >= 128 then temp_v = 0 - temp_v ; Abs
      if temp_v >= 6 then goto skip_ebul_coll   ; Hitbox Width 12
      
      ; --- High Byte / Visibility Check (Y) ---
      temp_val_hi = ebul_y_hi[iter] - cam_y_hi
      ; Wrap Correction
      if temp_val_hi = 3 then temp_val_hi = 255
      if temp_val_hi = 253 then temp_val_hi = 1
      if temp_val_hi > 1 && temp_val_hi < 255 then goto skip_ebul_coll
      
      ; --- Y Collision ---
      temp_v = py - cam_y       ; Player Screen Y
      temp_w = ebul_y[iter] - cam_y ; Bullet Screen Y
      
      temp_v = temp_v - temp_w
      temp_v = temp_v + 7 ; Center align (16 vs 2)
      
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 10 then goto skip_ebul_coll
      
      ; Hit Player
      eblife[iter] = 0
      playsfx sfx_laser 0 ; Reuse sound for hit confirm
      
      score_e = score_e + 1
      if score_e >= 100 then goto you_lose
      
skip_ebul_coll
   next

coll_done
   return

init_stars
   for iter = 0 to 9
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
   for iter = 0 to 9 ; Reduced from 20 to 10 for performance
      ; Debugging: 1:1 Scrolling to verify camera smoothness
      temp_v = star_x[iter] - cam_x
      
      ; Manual Culling
      if temp_v > 165 then goto skip_star_draw
      
      temp_w = star_y[iter] - cam_y
      if temp_w > 200 then goto skip_star_draw
      
      ; Reuse bullet_conv sprite (2x2 pixel)
      plotsprite bullet_conv 4 temp_v temp_w
      
skip_star_draw
   next
   return

   dim sc1 = var140
   dim sc2 = var141
   dim sc3 = var142
   dim cycle_state = var143 ; 0, 1, 2

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

update_camera
   ; Simple Center Lock
   ; cam_x = px - 80
   
   temp_v = px
   cam_x = px - 80
   cam_x_hi = px_hi
   if cam_x > temp_v then cam_x_hi = cam_x_hi - 1 ; Borrow
   
   ; Wrap Cam X
   if cam_x_hi = 255 then cam_x_hi = 3
   if cam_x_hi >= 4 then cam_x_hi = 0

   ; cam_y = py - 90
   temp_v = py
   cam_y = py - 90
   cam_y_hi = py_hi
   if cam_y > temp_v then cam_y_hi = cam_y_hi - 1
   
   ; Wrap Cam Y
   if cam_y_hi = 255 then cam_y_hi = 3
   if cam_y_hi >= 4 then cam_y_hi = 0
   
   return

   ; Y Axis Deadzone (70 - 110)
   ; Note: py and cam_y are Low Bytes. Need Hi Byte support? Yes.
   ; But screen is only 192 high. World is 1024.
   
   ; Just use primitive following for now.
   ; screen_y = py - cam_y (approx)
   return

   ; ---- Data Tables (ROM) ----
   ; Boosted max acceleration to 6 (was 3) to fix crawling
   data sin_table
   0, 2, 3, 4, 4, 4, 3, 2, 0, 254, 253, 252, 252, 252, 253, 254
end

   data cos_table
   6, 6, 4, 2, 0, 254, 252, 250, 250, 250, 252, 254, 0, 2, 4, 6
end
   
   data sfx_laser
   16, 1, 4 ; version, priority, frames per chunk
   $18,$02,$06 ; freq, channel, volume
   $15,$02,$06
   $12,$02,$06
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
      
      ; 16-bit Distance Check (High Byte)
      temp_val_hi = ebul_x_hi[iter] - cam_x_hi
      if temp_val_hi = 0 then goto draw_ebul_fast
      
      if temp_val_hi = 3 then temp_val_hi = 255 ; Wrap 3->0 (-1)
      if temp_val_hi = 253 then temp_val_hi = 1 ; Wrap 0->3 (1)
      
      ; Filter Far
      if temp_val_hi > 1 && temp_val_hi < 255 then goto skip_draw_ebul
      
draw_ebul_fast
      ; Screen X
      temp_v = ebul_x[iter] - cam_x
      
      ; Filter Ghosts
      ; Hi=1 (Right of Cam): Expect Bul < Cam.
      if temp_val_hi = 1 then if ebul_x[iter] >= cam_x then goto skip_draw_ebul
      
      ; Hi=-1 (Left of Cam): Expect Bul > Cam.
      if temp_val_hi = 255 then if ebul_x[iter] <= cam_x then goto skip_draw_ebul

      ; Manual Culling
      if temp_v > 165 then if temp_v < 240 then goto skip_draw_ebul

      temp_w = ebul_y[iter] - cam_y
      if temp_w > 200 then goto skip_draw_ebul
      
      plotsprite bullet_conv 3 temp_v temp_w
      
skip_draw_ebul
   next
   return
draw_enemies
   ; Loop 0-3
   for iter = 0 to 3
      if elife[iter] = 0 then goto skip_draw_enemy
      
      ; Calculate Screen X
      temp_v = ex[iter] - cam_x
      
      ; Manual Culling (Relaxed)
      if temp_v > 170 then if temp_v < 220 then goto skip_draw_enemy
      
      temp_w = ey[iter] - cam_y
      
      ; Y Culling (Relaxed)
      if temp_w > 200 then if temp_w < 220 then goto skip_draw_enemy
      
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
   ; --- X Visibility ---
   temp_val_hi = ax_hi - cam_x_hi
   
   ; Correct for World Wrap (0-1024)
   if temp_val_hi = 3 then temp_val_hi = 255  ; 3 -> -1
   if temp_val_hi = 253 then temp_val_hi = 1  ; -3 -> 1
   
   if temp_val_hi > 1 && temp_val_hi < 255 then return

   temp_v = ax - cam_x
   
   ; Local culling X (Relaxed: 170 to 220)
   if temp_v > 170 then if temp_v < 220 then return
   
   ; --- Y Visibility ---
   temp_val_hi = ay_hi - cam_y_hi
   
   ; Correct for World Wrap (0-1024)
   if temp_val_hi = 3 then temp_val_hi = 255
   if temp_val_hi = 253 then temp_val_hi = 1
   
   if temp_val_hi > 1 && temp_val_hi < 255 then return

   temp_w = ay - cam_y
   
   ; Local culling Y (Relaxed: 200 to 220)
   if temp_w > 200 then if temp_w < 220 then return
   
   plotsprite asteroid_M_conv 2 temp_v temp_w
   return

you_win
   ;clearscreen
   ;BACKGRND=$B4 ; Greenish Blue
   ;drawscreen
   ;if joy0fire0 then goto cold_start
   ;goto you_win
   goto cold_start

you_lose
   ;clearscreen
   ;BACKGRND=$44 ; Red
   ;drawscreen
   ;if joy0fire0 then goto cold_start
   ;goto you_lose
   goto cold_start
