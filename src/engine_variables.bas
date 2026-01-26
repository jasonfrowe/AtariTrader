; ---- GLOBAL VARIABLES ----
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
dim temp_w = var73
dim bcooldown = var16
dim iter = var17
dim temp_bx = var38
dim temp_by = var39

dim bul_x = var18
dim bul_y = var22
dim bul_vx = var26
dim bul_vy = var30
dim blife = var34

dim player_lives = $254B
dim player_shield = $2549
dim fighters_remaining = $2548
dim fighters_bcd = $2557
dim current_level = $25A4
dim current_song = $25AF
dim music_active = $25AC
dim music_ptr_lo = $25AA
dim music_ptr_hi = $25AB
dim screen_timer = $254D
dim asteroid_timer = $2559
dim boss_asteroid_cooldown = $255A
dim ready_flag = $254E
dim score0 = score

dim px_scr = $2591
dim py_scr = $2592
dim px_hi = $2570
dim py_hi = $2571

dim ex = var40
dim ey = var44
dim evx = var48
dim evy = var52
dim elife = var56
dim ex_hi = var74
dim ey_hi = $2540
dim ex_scr = $2593
dim ey_scr = $2597
dim e_on = $259D
dim ecooldown = var72

dim ebul_x = var60
dim ebul_y = var64
dim ebul_vx = var68
dim ebul_vy = $2560
dim eblife = $2564

dim star_x = var80
dim star_y = $2500
dim star_c = $2520
dim scale_score = $254A
dim cycle_state = $2547

dim ax = $2550
dim ay = $2551
dim avx = $2552
dim avy = $2553
dim alife = $2554
dim ax_hi = $2555
dim ay_hi = $2556
dim ax_scr = $259B
dim ay_scr = $259C
dim a_on = $25A1

dim bfx = $25D8
dim bfy = $25DA
dim bflife = $25DC
dim bfx_hi = $25DE
dim bfy_hi = $25E0
dim bfby = $25E2
dim bfx_scr = $25E4
dim bfy_scr = $25E6
dim bf_on = $25E8
dim bfx_acc = $25EA
dim bfy_acc = $25EC
dim bf_bul_x = $25EE
dim bf_bul_y = $25EF
dim bf_bul_vx = $25F0
dim bf_bul_vy = $25F1
dim bf_bul_life = $25F2
dim bf_fire_cooldown = $25F3

dim energy_x = $25F4
dim energy_y = $25F5
dim energy_x_hi = $25F6
dim energy_y_hi = $25F7
dim energy_on = $25F8
dim bf_kill_count = $25F9

dim enemy_move_mask = $25A2
dim enemy_fire_cooldown = $25A3
dim game_difficulty = $2558
dim cached_lives = $2572
dim cached_level = $2573
dim cached_shield = $2575

dim acc_mx = var78
dim acc_my = var79
