   ; ---- SHARED ENGINE ROUTINES (Fixed Bank 8) ----

StopMusic
   asm
   lda #0
   sta $0450
   sta $0451
   sta $0452
   sta $0453 
   sta $0454
   sta $0455
   sta $0456
   sta $0457
   sta music_active
   rts
end

check_rotation
   if joy0left  then angle = angle - 1 : rot_timer = 4
   if joy0right then angle = angle + 1 : rot_timer = 4
   if angle > 250 then angle = 15
   if angle > 15 then angle = 0
   return

apply_thrust
   temp_acc = sin_table[angle]
   if temp_acc < 128 then vx_p = vx_p + temp_acc 
   if temp_acc >= 128 then temp_acc = 0 - temp_acc : vx_m = vx_m + temp_acc
   temp_acc = cos_table[angle]
   if temp_acc < 128 then vy_m = vy_m + temp_acc
   if temp_acc >= 128 then temp_acc = 0 - temp_acc : vy_p = vy_p + temp_acc
   if vx_p > 120 then vx_p = 120
   if vx_m > 120 then vx_m = 120
   if vy_p > 120 then vy_p = 120
   if vy_m > 120 then vy_m = 120
   return

neutralize_forces
   if vx_p <> 0 && vx_m <> 0 then if vx_p < vx_m then common = vx_p else common = vx_m : vx_p = vx_p - common : vx_m = vx_m - common
   if vy_p <> 0 && vy_m <> 0 then if vy_p < vy_m then common = vy_p else common = vy_m : vy_p = vy_p - common : vy_m = vy_m - common
   return

apply_friction
   if vx_p < 2 then vx_p = 0 else vx_p = vx_p - 1
   if vx_m < 2 then vx_m = 0 else vx_m = vx_m - 1
   if vy_p < 2 then vy_p = 0 else vy_p = vy_p - 1
   if vy_m < 2 then vy_m = 0 else vy_m = vy_m - 1
   return

update_bullets
   for iter = 0 to 3
      if blife[iter] = 0 then goto nb
      bul_x[iter] = bul_x[iter] + bul_vx[iter]
      bul_y[iter] = bul_y[iter] + bul_vy[iter]
      if bul_x[iter] > 170 then if bul_x[iter] < 240 then blife[iter] = 0
      if bul_y[iter] > 200 then blife[iter] = 0
      if blife[iter] > 0 then blife[iter] = blife[iter] - 1
nb
   next
   return

fire_bullet
   for iter = 0 to 3 : if blife[iter] = 0 then goto sb
   next
   return
sb
   blife[iter] = 60 : bul_x[iter] = px + 6 : bul_y[iter] = py + 6
   bul_vx[iter] = sin_table[angle]
   temp_v = cos_table[angle] : if temp_v < 128 then bul_vy[iter] = 0 - temp_v else temp_v = 0 - temp_v : bul_vy[iter] = temp_v
   bcooldown = 25
   return

fire_enemy_bullet
   for temp_acc = 0 to 3 : if eblife[temp_acc] = 0 then goto seb
   next
   return
seb
   eblife[temp_acc] = 120 : ebul_x[temp_acc] = ex_scr[iter] : ebul_y[temp_acc] = ey_scr[iter]
   if px_scr + 8 > ebul_x[temp_acc] then ebul_vx[temp_acc] = 4 else ebul_vx[temp_acc] = 252
   if py_scr + 8 > ebul_y[temp_acc] then ebul_vy[temp_acc] = 4 else ebul_vy[temp_acc] = 252
   ecooldown = 60
   return

update_enemy_bullets
   for iter = 0 to 3
      if eblife[iter] = 0 then goto neb2
      eblife[iter] = eblife[iter] - 1
      ebul_x[iter] = ebul_x[iter] + ebul_vx[iter]
      ebul_y[iter] = ebul_y[iter] + ebul_vy[iter]
      if ebul_x[iter] > 165 then if ebul_x[iter] < 240 then eblife[iter] = 0
      if ebul_y[iter] > 200 then eblife[iter] = 0
neb2
   next
   return

shift_universe
   for iter = 0 to 3
      if elife[iter] then ex[iter]=ex[iter]-temp_bx : ey[iter]=ey[iter]-temp_by
      if eblife[iter] then ebul_x[iter]=ebul_x[iter]-temp_bx : ebul_y[iter]=ebul_y[iter]-temp_by
   next
   if alife then ax=ax-temp_bx : ay=ay-temp_by
   for iter = 0 to 3 : star_x[iter]=star_x[iter]-temp_bx : if star_x[iter]>160 then star_x[iter]=0
   next
   return

update_render_coords
   px_scr = 72 : py_scr = 90
   for iter = 0 to 3
      if elife[iter]=0 then e_on[iter]=0 : goto nrc
      if ex_hi[iter]=px_hi then ex_scr[iter]=ex[iter] : e_on[iter]=1 else e_on[iter]=0
      if ey_hi[iter]=py_hi then ey_scr[iter]=ey[iter] else e_on[iter]=0
nrc
   next
   if ax_hi=px_hi && ay_hi=py_hi then a_on=1 : ax_scr=ax : ay_scr=ay else a_on=0
   return

init_stars
   for iter = 0 to 3 : star_x[iter]=rand : star_y[iter]=rand : star_c[iter]=(rand&3)+1
   next
   return

draw_stars
   for iter = 0 to 3
      temp_v = star_x[iter] : temp_w = star_y[iter]
      plotsprite bullet_conv 4 temp_v temp_w
   next
   return

cycle_stars
   if (frame & 7) = 0 then cycle_state = cycle_state + 1
   if cycle_state > 2 then cycle_state = 0
   return

refresh_static_ui
   clearscreen
   if player_lives >= 2 then plotchars '>>' 5 16 0
   plotchars 'SHIELD' 5 0 11
   cached_lives = player_lives : cached_shield = player_shield
   savescreen
   return

set_level_config
   enemy_move_mask = 2 : enemy_fire_cooldown = 60
   return

draw_player_bullets
   for iter = 0 to 3
      if blife[iter] then temp_v = bul_x[iter] : temp_w = bul_y[iter] : plotsprite bullet_conv 1 temp_v temp_w
   next
   return

draw_enemy_bullets
   for iter = 0 to 3
      if eblife[iter] then temp_v = ebul_x[iter] : temp_w = ebul_y[iter] : plotsprite bullet_conv 6 temp_v temp_w
   next
   return

draw_bf_bullet
   if bf_bul_life then temp_v = bf_bul_x : temp_w = bf_bul_y : plotsprite bullet_conv 6 temp_v temp_w
   return

   ; ---- SHARED DATA ----
   data sin_table
   0, 2, 3, 4, 4, 4, 3, 2, 0, 254, 253, 252, 252, 252, 253, 254
   end
   data cos_table
   6, 6, 4, 2, 0, 254, 252, 250, 250, 250, 252, 254, 0, 2, 4, 6
   end
