   displaymode 160A
   set zoneheight 16 

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
   incgraphic asteroid_L_conv.png

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
   dim ebul_x  = var60 ; 60, 61
   dim ebul_y  = var62 ; 62, 63
   dim ebul_vx = var64 ; 64, 65
   dim ebul_vy = var66 ; 66, 67
   dim eblife  = var68 ; 68, 69
   dim ecooldown = var70
   dim temp_w = var71
   
   ; Safety Buffer 72-79
   
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
   dim ex = var40
   dim ey = var41
   dim evx = var42
   dim evy = var43
   dim elife = var44
   ; Removed duplicate elife
   dim rand_val = var45
   
   ; Asteroid Variables (Single Large Asteroid)
   dim ax = var50
   dim ay = var51
   dim avx = var52
   dim avy = var53
   dim alife = var54
   
   ; Aliases for plotsprite usage
   dim bul_x0 = var18 : dim bul_x1 = var19 : dim bul_x2 = var20 : dim bul_x3 = var21
   dim bul_y0 = var22 : dim bul_y1 = var23 : dim bul_y2 = var24 : dim bul_y3 = var25
   dim blife0 = var34 : dim blife1 = var35 : dim blife2 = var36 : dim blife3 = var37
 ; 0 = inactive, >0 = active frames
   
   ; Remainder arrays for bullets (optional, if we want sub-pixel accuracy)
   ; For 4px/frame speed, sub-pixel is less critical, but angles might need it.
   ; Let's try without reminders first for simplicity/RAM saving.

   ; Palette Setup
   P0C1=$26: P0C2=$24: P0C3=$04
   P1C1=$0E: P1C2=$38: P1C3=$FC ; Bullets (Yellow/White)
   P2C1=$94: P2C2=$98: P2C3=$9C ; Asteroids (Blue for debug distinction)
   P3C1=$B4: P3C2=$46: P3C3=$1C ; Enemy (Green, Red, Yellow)
   P4C1=$08: P4C2=$0C: P4C3=$0F ; Stars (Dim Grey, Light Grey, White)
   P5C1=$34: P5C2=$86: P5C3=$0A ; Spaceship
   
   BACKGRND=$00 ; Set Background to Black

   ; Initialize Variables
   px = 80
   py = 90
   vx_p = 0
   vx_m = 0
   vy_p = 0
   vy_m = 0
   rx = 0
   ry = 0
   angle = 0
   rot_timer = 0
   shpfr = 0
   frame = 0
   bcooldown = 0
   
   ; Clear bullets
   for iter = 0 to 3
      blife[iter] = 0
   next
   
   elife = 0 ; Enemy inactive initially
   alife = 0 ; Asteroid inactive
   ecooldown = 0
   eblife[0] = 0 : eblife[1] = 0
   
   gosub init_stars

main_loop
   clearscreen

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
   move_step = (vx_p + rx) / 64
   rx = (vx_p + rx) & 63
   px = px + move_step

   move_step = (vx_m + rx) / 64
   rx = (vx_m + rx) & 63
   if px >= move_step then px = px - move_step else px = 0

   ; Y Axis
   move_step = (vy_p + ry) / 64
   ry = (vy_p + ry) & 63
   py = py + move_step

   move_step = (vy_m + ry) / 64
   ry = (vy_m + ry) & 63
   if py >= move_step then py = py - move_step else py = 0

   ; ---- Bullet Update ----
   gosub update_bullets

   ; ---- Enemy Update ----
   gosub update_enemy
   
   ; ---- Enemy Bullet Update ----
   gosub update_enemy_bullets
   
   ; ---- Asteroid Update ----
   gosub update_asteroid

   ; ---- Collisions ----
   gosub check_collisions

   ; ---- Friction ----
   gosub apply_friction

   ; ---- Boundaries ----
   if px > 150 then px = 150
   if px < 4 then px = 4
   if py > 180 then py = 180
   if py < 4 then py = 4

   ; ---- Draw ----
   plotsprite sprite_spaceship1 5 px py shpfr
   
   gosub draw_stars

   if blife0 > 0 then plotsprite bullet_conv 1 bul_x0 bul_y0
   if blife1 > 0 then plotsprite bullet_conv 1 bul_x1 bul_y1
   if blife2 > 0 then plotsprite bullet_conv 1 bul_x2 bul_y2
   if blife3 > 0 then plotsprite bullet_conv 1 bul_x3 bul_y3
   
   if elife > 0 then plotsprite fighter_conv 3 ex ey
   if alife > 0 then plotsprite asteroid_L_conv 2 ax ay
   
   if eblife[0] > 0 then temp_v = ebul_x[0] : temp_w = ebul_y[0] : plotsprite bullet_conv 3 temp_v temp_w
   if eblife[1] > 0 then temp_v = ebul_x[1] : temp_w = ebul_y[1] : plotsprite bullet_conv 3 temp_v temp_w

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
   
   ; Max speed 95 (approx 1.5 px/frame)
   if vx_p > 95 then vx_p = 95
   if vx_m > 95 then vx_m = 95
   if vy_p > 95 then vy_p = 95
   if vy_m > 95 then vy_m = 95
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
   if vx_p < 4 then vx_p = 0
   if vx_p >= 4 then vx_p = vx_p - 1
   
   if vx_m < 4 then vx_m = 0
   if vx_m >= 4 then vx_m = vx_m - 1
   
   if vy_p < 4 then vy_p = 0
   if vy_p >= 4 then vy_p = vy_p - 1
   
   if vy_m < 4 then vy_m = 0
   if vy_m >= 4 then vy_m = vy_m - 1
   return

update_bullets
   for iter = 0 to 3
      if blife[iter] > 0 then gosub move_one_bullet
   next
   return

move_one_bullet
   ; Move based on bvx/bvy (simple signed integers 0-255 where 128+ is negative)
   ; X Axis
   temp_v = bul_vx[iter]
   if temp_v < 128 then bul_x[iter] = bul_x[iter] + temp_v
   if temp_v >= 128 then temp_v = 0 - temp_v : bul_x[iter] = bul_x[iter] - temp_v
   
   ; Y Axis
   temp_v = bul_vy[iter]
   if temp_v < 128 then bul_y[iter] = bul_y[iter] + temp_v
   if temp_v >= 128 then temp_v = 0 - temp_v : bul_y[iter] = bul_y[iter] - temp_v
   
   ; Bounds Check
   if bul_x[iter] > 160 then blife[iter] = 0
   if bul_x[iter] > 240 then blife[iter] = 0 ; Catch underflow wrapping (e.g. 255)
   if bul_y[iter] > 192 then blife[iter] = 0
   if bul_y[iter] > 240 then blife[iter] = 0 ; Catch underflow wrapping
   
   ; Lifetime Check (Optional, but safe)
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
   bul_x[iter] = px
   bul_y[iter] = py
   
   ; Set velocity based on angle
   ; Use sin_table values * factor ~ 10-15?
   ; sin_table current max is 6 (acceleration). 
   ; We want 4px/frame. 4 / 6 is not right.
   ; Let's just create a quick separate scaling or just use the table * 1 (too slow)
   ; The table 'sin_table' has values like 0,2,4,6.
   ; If we treat them as pixel speed, max 6 is SUPER FAST.
   ; NOTE: Player physics uses table as ACCELERATION (added to velocity).
   ; Check table: 0, 2, 4, 6...
   ; If we use these directly as speed, 6px/frame is very fast. 4px/frame is target.
   ; Let's assume table values are roughly "direction * magnitude".
   ; We can divide by 2? 6/2 = 3px/frame. Close enough.
   
   temp_v = sin_table[angle]
   if temp_v < 128 then temp_v = temp_v / 2
   if temp_v >= 128 then temp_v = (0 - temp_v) / 2 : temp_v = 0 - temp_v
   bul_vx[iter] = temp_v
   
   ; Y Axis (Cos, inverted)
   ; cos_table is positive for "down" usually?
   ; Acceleration logic: vy_m += cos (if cos < 128). Means cos<128 is "Up" force (adding to minus).
   ; So Negative Cos is Up.
   ; Let's interpret table directly. 
   ; Cos[0] = 6 (Pos). In player logic: vy_m = vy_m + 6. Moves UP.
   ; So Table Positive = UP. 
   ; In screen coords, UP is Negative Y.
   ; So we want bullet velocity to be Negative.
   ; If Table is Pos, Set Vel to Neg.
   
   temp_v = cos_table[angle]
   ; If table is positive (0-127), we want negative velocity (128-255).
   ; Value 6 -> -3 (253).
   if temp_v < 128 then temp_v = temp_v / 2 : bul_vy[iter] = 0 - temp_v
   ; If table is negative (128-255), we want positive velocity.
   ; Value -6 (250) -> +3.
   if temp_v >= 128 then temp_v = (0 - temp_v) / 2 : bul_vy[iter] = temp_v
   
   if temp_v >= 128 then temp_v = (0 - temp_v) / 2 : bul_vy[iter] = temp_v
   
   ; Play sound
   playsfx sfx_laser 0
   
   bcooldown = 15 ; Can fire every 15 frames
   return

update_enemy
   if elife = 0 then gosub spawn_enemy
   if elife = 0 then return
   
   ; Simple AI: Slowly adjust velocity towards player
   ; Check X diff
   ; (temp_acc logic removed as we use direct movement below)
   ; Add to velocity (with cap)
   ; Use simple logic: if ex < px, increase evx. if ex > px, decrease evx.
   ; Max speed ~1 px/frame (value 64 in 6.2 fixed? No, using simple integer for enemy initially? 
   ; Let's use 8.8 fixed point for enemy too? Or just simple integers?
   ; Let's stick to simple integers for enemy position to save vars, but slow movement is hard with integers.
   ; Let's use a "timer" to move every N frames instead.
   
   ; Move every 2nd frame
   if (frame & 1) = 0 then goto move_enemy_step
   
   ; Try to fire?
   if ecooldown > 0 then ecooldown = ecooldown - 1
   if ecooldown = 0 then gosub fire_enemy_bullet

   return
   
move_enemy_step
   ; Chase Logic
   if ex < px then ex = ex + 1
   if ex > px then ex = ex - 1
   if ey < py then ey = ey + 1
   if ey > py then ey = ey - 1
   
   return

spawn_enemy
   ; Random spawn chance 1/100
   rand_val = frame & 127
   if rand_val > 5 then return
   
   elife = 1
   ; Spawn at random edge
   rand_val = frame & 3
   if rand_val = 0 then ex = 5 : ey = 90 ; Left
   if rand_val = 1 then ex = 155 : ey = 90 ; Right
   if rand_val = 2 then ex = 80 : ey = 5 ; Top
   if rand_val = 3 then ex = 80 : ey = 175 ; Bottom
   
   return

fire_enemy_bullet
   ; Find free slot
   for iter = 0 to 1
      if eblife[iter] = 0 then goto spawn_ebul
   next
   return

spawn_ebul
   eblife[iter] = 60 ; frames
   ebul_x[iter] = ex   ; Center alignment
   ebul_y[iter] = ey + 6 ; Moved up 2 pixels as requested
   
   ; Aim at player: Determine signs and magnitude
   ; dx in temp_bx, dy in temp_by
   if px < ex then ebul_vx[iter] = 253 : temp_bx = ex - px else ebul_vx[iter] = 3 : temp_bx = px - ex
   if py < ey then ebul_vy[iter] = 253 : temp_by = ey - py else ebul_vy[iter] = 3 : temp_by = py - ey
   
   ; 8-Way Logic: Zero out the minor axis if the major axis is > 2x larger
   ; Check Horizontal Dominance: if dx > 2*dy
   ; Safe check: if dx/2 > dy
   temp_v = temp_bx / 2
   if temp_v > temp_by then ebul_vy[iter] = 0
   
   ; Check Vertical Dominance: if dy > 2*dx
   ; Safe check: if dy/2 > dx
   temp_v = temp_by / 2
   if temp_v > temp_bx then ebul_vx[iter] = 0
   
   ecooldown = 60 ; 2 seconds
   return
   
   ; Crude Vector Logic:
   ; If abs(dx) > abs(dy)*2 -> Move X only
   ; If abs(dy) > abs(dx)*2 -> Move Y only
   ; Else Move Diagonal
   
   ; Just use the signs for now (Diagonal always)
   
   ecooldown = 60 ; 2 seconds
   return

update_enemy_bullets
   for iter = 0 to 1
      if eblife[iter] = 0 then goto skip_ebul_update
      
      eblife[iter] = eblife[iter] - 1
      
      ; Move X
      temp_v = ebul_vx[iter]
      if temp_v < 128 then ebul_x[iter] = ebul_x[iter] + temp_v
      if temp_v >= 128 then temp_v = 0 - temp_v : ebul_x[iter] = ebul_x[iter] - temp_v
      
      ; Move Y
      temp_v = ebul_vy[iter]
      if temp_v < 128 then ebul_y[iter] = ebul_y[iter] + temp_v
      if temp_v >= 128 then temp_v = 0 - temp_v : ebul_y[iter] = ebul_y[iter] - temp_v

skip_ebul_update
   next
   return

update_asteroid
   if alife = 0 then gosub spawn_asteroid
   if alife = 0 then return
   
   ; Move Asteroid (Slow drift - every 4th frame)
   if (frame & 3) > 0 then return
   
   ; Move Asteroid (Integer math for now, might be fast)
   ; Use simple wrapping
   temp_v = avx
   if temp_v < 128 then ax = ax + temp_v
   if temp_v >= 128 then temp_v = 0 - temp_v : ax = ax - temp_v
   
   temp_v = avy
   if temp_v < 128 then ay = ay + temp_v
   if temp_v >= 128 then temp_v = 0 - temp_v : ay = ay - temp_v
   
   ; Screen Wrapping
   if ax > 160 then ax = 1
   if ax = 0 then ax = 159
   if ay > 190 then ay = 1
   if ay = 0 then ay = 189
   
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
   
   ; Random Velocity (Slow drift)
   ; 1 or -1 (255)
   rand_val = frame & 1
   if rand_val = 0 then avx = 1 else avx = 255
   rand_val = frame & 2
   if rand_val = 0 then avy = 1 else avy = 255
   
   return

check_collisions
   ; 1. Bullets vs Enemy
   if elife = 0 then goto check_player_enemy
   
   for iter = 0 to 3
      if blife[iter] = 0 then goto skip_bullet_coll
      
      ; Check X overlap (Box 6px approx for smaller sprites)
      temp_v = bul_x[iter] - ex
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 6 then goto skip_bullet_coll
      
      ; Check Y overlap
      temp_v = bul_y[iter] - ey
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 6 then goto skip_bullet_coll
      
      ; Hit!
      blife[iter] = 0
      elife = 0
      goto check_player_enemy

skip_bullet_coll
   next

   
check_player_enemy
   if elife = 0 then goto check_asteroid_coll

   ; 2. Player vs Enemy
   ; Check X overlap
   temp_v = px - ex
   if temp_v >= 128 then temp_v = 0 - temp_v
   if temp_v >= 8 then goto check_asteroid_coll
   
   ; Check Y overlap
   temp_v = py - ey
   if temp_v >= 128 then temp_v = 0 - temp_v
   if temp_v >= 8 then goto check_asteroid_coll
   
   ; Hit Player!
   elife = 0
   ; TODO: Player Death

check_asteroid_coll
   if alife = 0 then goto coll_done

   ; 3. Bullets vs Asteroid (Large 32x64 sprite)
   ; Center alignment strategy:
   ; Bullet Center is Bx+8. Asteroid Center is Ax+16.
   ; Perfect alignment: Bx+8 = Ax+16 => Bx = Ax+8.
   ; Check: abs(Bx - Ax - 8) < ThreadholdX (20)
   
   for iter = 0 to 3
      if blife[iter] = 0 then goto skip_bul_ast
      
      ; X Check
      temp_v = bul_x[iter] - ax
      temp_v = temp_v - 8
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 20 then goto skip_bul_ast
      
      ; Y Check
      ; Bullet Center By+8. Asteroid Center Ay+32.
      ; Perfect: By+8 = Ay+32 => By = Ay+24.
      ; Check: abs(By - Ay - 24) < ThresholdY (32)
      temp_v = bul_y[iter] - ay
      temp_v = temp_v - 24
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 30 then goto skip_bul_ast ; Slightly tighter than 32
      
      ; Hit!
      blife[iter] = 0
      alife = 0
      ; TODO: Split asteroid
      goto coll_done

skip_bul_ast
   next
   
   ; 4. Player vs Asteroid
   ; Player Center Px. Asteroid Center Ax+16.
   ; Check abs(Px - Ax - 16) < 16 + 8 = 24
   temp_v = px - ax
   temp_v = temp_v - 16
   if temp_v >= 128 then temp_v = 0 - temp_v
   if temp_v >= 20 then goto coll_done ; 20px overlap
   
   temp_v = py - ay
   temp_v = temp_v - 32
   if temp_v >= 128 then temp_v = 0 - temp_v
   if temp_v >= 28 then goto coll_done
   
   ; Hit Player!
   alife = 0
   ; TODO: Player Death

check_player_ebul
   ; Check vs Enemy Bullets (2 of them)
   for iter = 0 to 1
      if eblife[iter] = 0 then goto skip_ebul_coll
      
      ; X Check
      temp_v = ebul_x[iter] - px
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 6 then goto skip_ebul_coll
      
      ; Y Check
      temp_v = ebul_y[iter] - py
      if temp_v >= 128 then temp_v = 0 - temp_v
      if temp_v >= 6 then goto skip_ebul_coll
      
      ; Hit Player
      eblife[iter] = 0
      ; TODO: Player Death
      
skip_ebul_coll
   next

coll_done
   return

init_stars
   for iter = 0 to 19
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
   for iter = 0 to 19
      ; Reuse bullet_conv sprite (2x2 pixel)
      ; Use Palette 4
      temp_v = star_x[iter]
      temp_w = star_y[iter]
      plotsprite bullet_conv 4 temp_v temp_w
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

   ; ---- Data Tables (ROM) ----
   ; Boosted max acceleration to 6 (was 3) to fix crawling
   data sin_table
   0, 2, 4, 6, 6, 6, 4, 2, 0, 254, 252, 250, 250, 250, 252, 254
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
