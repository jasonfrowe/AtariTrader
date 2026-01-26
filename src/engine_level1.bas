   ; ---- LEVEL 1 LOGIC (Bank 4) ----

level_1_entry
   ready_flag = 2

level_1_loop
   clearscreen
   restorescreen
   frame = frame + 1

   if ready_flag > 0 then plotchars 'PRESS FIRE' 5 40 8 : plotchars 'TO START' 5 48 9
   if ready_flag = 2 then if !joy0fire1 then ready_flag = 1
   if ready_flag = 1 then if joy0fire1 then ready_flag = 0
   if ready_flag > 0 then goto skip_updates

   if switchreset then goto cold_start bank1
   
   if rot_timer > 0 then rot_timer = rot_timer - 1
   if rot_timer = 0 then gosub check_rotation
   shpfr = angle
   if joy0up then gosub apply_thrust
   if joy0fire1 && bcooldown = 0 then gosub fire_bullet
   if bcooldown > 0 then bcooldown = bcooldown - 1
   
   gosub neutralize_forces
   gosub cycle_stars
   
   temp_bx = 0 : temp_by = 0
   temp_v = vx_p + rx : rx = temp_v & 63 : temp_w = temp_v / 64 : if temp_w > 0 then temp_bx = temp_w
   temp_v = vx_m + acc_mx : acc_mx = temp_v & 63 : temp_w = temp_v / 64 : if temp_w > 0 then temp_bx = 0 - temp_w
   temp_v = vy_p + ry : ry = temp_v & 63 : temp_w = temp_v / 64 : if temp_w > 0 then temp_by = temp_w
   temp_v = vy_m + acc_my : acc_my = temp_v & 63 : temp_w = temp_v / 64 : if temp_w > 0 then temp_by = 0 - temp_w

   if temp_bx <> 0 || temp_by <> 0 then gosub shift_universe
   gosub update_bullets
   gosub update_enemy_bullets
   
   if ecooldown > 0 then ecooldown = ecooldown - 1
   gosub update_enemy
   gosub update_asteroid
   gosub check_collisions
   gosub apply_friction

skip_updates
   gosub update_render_coords
   if player_lives <> cached_lives then gosub refresh_static_ui
   if player_shield <> cached_shield then gosub refresh_static_ui
   plotvalue unified_font 0 score0 6 56 0
   plotchars 'E' 5 120 0
   plotvalue unified_font 5 fighters_bcd 2 128 0

   temp_v = px_scr : temp_w = py_scr
   plotsprite sprite_spaceship1 5 temp_v temp_w shpfr
   gosub draw_stars
   gosub draw_player_bullets
   gosub draw_enemies
   gosub draw_asteroid
   gosub draw_enemy_bullets
   gosub draw_blue_fighters
   gosub draw_bf_bullet
   
   if player_shield <= 0 then goto cold_start bank1
   if fighters_remaining <= 0 then goto cold_start bank1

   drawscreen
   goto level_1_loop

update_enemy
    for iter = 0 to 3
       if elife[iter] = 0 then goto try_spawn
       if elife[iter] > 1 then elife[iter] = elife[iter] - 1 : if elife[iter]=1 then elife[iter]=0 : goto next_e
       temp_v = frame & enemy_move_mask : if temp_v > 0 then goto next_e
       if px_hi = ex_hi[iter] then temp_acc = px - ex[iter] else temp_acc = 64
       if (frame & 3) = 0 then if temp_acc >= 128 then evx[iter]=evx[iter]-1 else evx[iter]=evx[iter]+1
       if py_hi = ey_hi[iter] then temp_acc = py - ey[iter] else temp_acc = 64
       if (frame & 3) = 0 then if temp_acc >= 128 then evy[iter]=evy[iter]-1 else evy[iter]=evy[iter]+1
       ex[iter] = ex[iter] + evx[iter] : ey[iter] = ey[iter] + evy[iter]
       if ecooldown = 0 then if rand < 16 then gosub fire_enemy_bullet
       goto next_e
try_spawn
       if (frame & 127) < 5 then elife[iter]=1 : ex[iter]=rand : ey[iter]=rand : ex_hi[iter]=px_hi : ey_hi[iter]=py_hi
next_e
    next
    return

update_asteroid
    if alife = 0 then if (frame & 127) < 5 then alife=1 : ax=rand : ay=rand : ax_hi=px_hi : ay_hi=py_hi : avx=1 : avy=1
    if alife then ax = ax + avx : ay = ay + avy
    return

draw_enemies
   for iter = 0 to 3
      if e_on[iter] = 0 then goto next_de
      temp_v = ex_scr[iter] : temp_w = ey_scr[iter]
      if elife[iter] > 1 then temp_acc = (18-elife[iter])/2 : plotsprite fighter_explode_00_conv 3 temp_v temp_w temp_acc else plotsprite fighter 3 temp_v temp_w
next_de
   next
   return

draw_asteroid
   if a_on then temp_v = ax_scr : temp_w = ay_scr : plotsprite asteroid_M_conv 2 temp_v temp_w
   return

draw_blue_fighters
   for iter = 0 to 1
      if bf_on[iter] then temp_v = bfx_scr[iter] : temp_w = bfy_scr[iter] : plotsprite blue_fighter 3 temp_v temp_w
   next
   return

check_collisions
   for iter = 0 to 3
      if blife[iter] = 0 then goto next_bc
      for temp_acc = 0 to 3
         if e_on[temp_acc] = 0 then goto next_ec
         if elife[temp_acc] <> 1 then goto next_ec
         temp_v = bul_x[iter] : temp_w = ex_scr[temp_acc] : temp_v = temp_v - temp_w : if temp_v >= 128 then temp_v = 0 - temp_v
         if temp_v >= 10 then goto next_ec
         temp_v = bul_y[iter] : temp_w = ey_scr[temp_acc] : temp_v = temp_v - temp_w : if temp_v >= 128 then temp_v = 0 - temp_v
         if temp_v >= 10 then goto next_ec
         elife[temp_acc]=18 : blife[iter]=0 : fighters_remaining = fighters_remaining - 1 : score0 = score0 + 100 : fighters_bcd = converttobcd(fighters_remaining)
next_ec
      next
next_bc
   next
   for iter = 0 to 3
      if e_on[iter] then if elife[iter]=1 then temp_v = px_scr : temp_w = ex_scr[iter] : temp_v = temp_v - temp_w : if temp_v >= 128 then temp_v = 0 - temp_v : if temp_v < 10 then player_shield = player_shield - 10 : elife[iter] = 18
   next
   return
