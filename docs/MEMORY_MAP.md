# Astro Wing Memory Map

## 1. Zero Page / Direct Variables
The 7800basic `var0` - `var99` block (approx `$80` - `$E3`) is fully allocated as follows. Multibyte arrays use contiguous variables.

| Variable(s) | Alias | Description | Notes |
| :--- | :--- | :--- | :--- |
| `var0` | `px` | Player World X (Low) | |
| `var1` | `py` | Player World Y (Low) | |
| `var2` | `vx_p` | Player Velocity X (Plus) | Dual-variable physics |
| `var3` | `vx_m` | Player Velocity X (Minus) | |
| `var4` | `vy_p` | Player Velocity Y (Plus) | |
| `var5` | `vy_m` | Player Velocity Y (Minus) | |
| `var6` | `rx` | Sub-pixel X Accumulator | |
| `var7` | `ry` | Sub-pixel Y Accumulator | |
| `var8` | `angle` | Player Angle | (0-31) |
| `var9` | `shpfr` | Player Sprite Frame | |
| `var10` | `rot_timer` | Rotation Timer | |
| `var11` | `move_step` | Movement Step | |
| `var12` | `temp_acc`, `temp1` | Temporary Accumulator | Scratch / Music Driver |
| `var13` | `frame` | Global Frame Counter | |
| `var14` | `common` | Common Iterator/Temp | |
| `var15` | `temp_v`, `temp2` | Temporary Value | Scratch / Music Driver |
| `var16` | `bcooldown` | Bullet Cooldown Timer | |
| `var17` | `iter` | Loop Iterator | |
| `var18-21` | `bul_x` | Player Bullet X (Low) | Array [4] |
| `var22-25` | `bul_y` | Player Bullet Y (Low) | Array [4] |
| `var26-29` | `bul_vx` | Player Bullet Velocities X | Array [4] |
| `var30-33` | `bul_vy` | Player Bullet Velocities Y | Array [4] |
| `var34-37` | `blife` | Player Bullet Lifetimes | Array [4] |
| `var38` | `temp_bx` | Shift Universe Delta X | |
| `var39` | `temp_by` | Shift Universe Delta Y | |
| `var40-43` | `ex` | Enemy X (Low) | Array [4] |
| `var44-47` | `ey` | Enemy Y (Low) | Array [4] |
| `var48-51` | `evx` | Enemy Velocities X | Array [4] |
| `var52-55` | `evy` | Enemy Velocities Y | Array [4] |
| `var56-59` | `elife` | Enemy Lifetimes | Array [4] |
| `var60-63` | `ebul_x` | Enemy Bullet X (Low) | Array [4] |
| `var64-67` | `ebul_y` | Enemy Bullet Y (Low) | Array [4] |
| `var68-71` | `ebul_vx` | Enemy Bullet Vel X | Array [4] |
| `var72` | `ecooldown` | Enemy Cooldown (Global) | |
| `var73` | `temp_w` | Temporary Word/Byte | Scratch usage |
| `var74-77` | `ex_hi` | Enemy X (High Byte) | Array [4] |
| `var78` | `acc_mx` | Physics Acc X | |
| `var79` | `acc_my` | Physics Acc Y | |
| `var80-83` | `star_x` | Starfield X Coords | Array [4] |
| `var98` | `music_zp_lo` | Music Pointer (Low) | Dedicated ZP for ASM Driver |
| `var99` | `music_zp_hi` | Music Pointer (High) | Dedicated ZP for ASM Driver |

---

## 2. Extended RAM ($2200 - $27FF)
Variables manually allocated to the upper RAM block using `dim var = $Address`.

| Address | Alias | Description | Notes |
| :--- | :--- | :--- | :--- |
| `$2500-2513` | `star_y` | Starfield Y Coords | Array [20] |
| `$2520-2533` | `star_c` | Starfield Colors | Array [20] |
| `$2540-2543` | `ey_hi` | Enemy Y (High Byte) | Array [4] |
| `$2544` | `sc1` | Star Color 1 | |
| `$2545` | `sc2` | Star Color 2 | |
| `$2546` | `sc3` | Star Color 3 | |
| `$2547` | `cycle_state` | Star Cycle State | |
| `$2548` | `fighters_remaining` | Fighters Remaining | |
| `$2549` | `player_shield` | Player Shield | 0-99 |
| `$254A` | `bcd_score` | Temp BCD Score | Scratch for conversion |
| `$254B` | `player_lives` | Player Lives | |
| `$254C` | `rand_val` | Random Seed/Val | |
| `$254D` | `screen_timer` | generic timeout timer | |
| `$254E` | `ready_flag` | Level Start Ready Flag | |
| `$2550` | `ax` | Asteroid X (Low) | |
| `$2551` | `ay` | Asteroid Y (Low) | |
| `$2552` | `avx` | Asteroid Vel X | |
| `$2553` | `avy` | Asteroid Vel Y | |
| `$2554` | `alife` | Asteroid Life | |
| `$2555` | `ax_hi` | Asteroid X (High Byte) | |
| `$2556` | `ay_hi` | Asteroid Y (High Byte) | |
| `$2557` | `fighters_bcd` | Fighters Remaining (BCD) | |
| `$2558` | `game_difficulty` | Difficulty Setting | 0=Pro, 1=Easy |
| `$2559` | `asteroid_timer` | Asteroid Despawn Timer | |
| `$255A` | `boss_asteroid_cooldown`, `boss_attack_timer`| Boss throw/fire cooldown | |
| `$255B` | `ast_acc_x` | Asteroid Accumulator X | |
| `$255C` | `ast_acc_y` | Asteroid Accumulator Y | |
| `$255D-255F` | (Reserved) | | |
| `$2560-2563` | `ebul_vy` | Enemy Bullet Vel Y | Array [4] |
| `$2564-2567` | `eblife` | Enemy Bullet Lifes | Array [4] |
| `$2568` | `boss_osc_x` | Boss Oscillation X | |
| `$2569` | `boss_osc_y` | Boss Oscillation Y | |
| `$256A` | `boss_acc_x` | Boss Accumulator X | |
| `$256B` | `boss_acc_y` | Boss Accumulator Y | |
| `$256C` | `boss_checkpoint` | Boss Health Gate | Trigger phases at 50% HP |
| `$2570` | `px_hi` | Player X (High Byte) | |
| `$2571` | `py_hi` | Player Y (High Byte) | |
| `$2572` | `cached_lives` | Cached rendered lives | |
| `$2573` | `cached_level` | Cached rendered level | |
| `$2574` | `cached_boss_hp` | Cached rendered boss HP | |
| `$2575` | `cached_shield` | Cached rendered shield | |
| `$2580-2583` | `bul_x_hi` | Player Bullet X (High) | (Unused/Shadow) |
| `$2584-2587` | `bul_y_hi` | Player Bullet Y (High) | (Unused/Shadow) |
| `$2588-258B` | `ebul_x_hi` | Enemy Bullet X (High) | |
| `$258C-258F` | `ebul_y_hi` | Enemy Bullet Y (High) | |
| `$2590` | `temp_val_hi` | Temp High Byte | |
| `$2591` | `px_scr` | Player Screen X | Cached Render |
| `$2592` | `py_scr` | Player Screen Y | Cached Render |
| `$2593-2596` | `ex_scr` | Enemy Screen X | Array [4] Cached |
| `$2597-259A` | `ey_scr` | Enemy Screen Y | Array [4] Cached |
| `$259B` | `ax_scr` | Asteroid Screen X | Cached |
| `$259C` | `ay_scr` | Asteroid Screen Y | Cached |
| `$259D-25A0` | `e_on` | Enemy Visible Flag | Array [4] |
| `$25A1` | `a_on` | Asteroid Visible Flag | |
| `$25A2` | `enemy_move_mask` | AI Config | |
| `$25A3` | `enemy_fire_cooldown`| AI Config | |
| `$25A4` | `current_level` | Current Level | |
| `$25A5-25A9` | `prize_active0-4` | Prize Flags | Individual bytes (5) |
| `$25AA` | `music_ptr_lo` | Music Pointer (Low) | |
| `$25AB` | `music_ptr_hi` | Music Pointer (High) | |
| `$25AC` | `music_active` | Music Playing Flag | |
| `$25AD` | `asteroid_move_mask` | Asteroid Speed Mask | |
| `$25AE` | `asteroid_base_speed` | Asteroid Base Speed | |
| `$25AF` | `current_song` | Current Song Index | |
| `$25B0` | `boss_x` | Boss World X (Low) | |
| `$25B1` | `boss_y` | Boss World Y (Low) | |
| `$25B2` | `boss_hp` | Boss Health | |
| `$25B3` | `boss_state` | Boss State | |
| `$25B4` | `bvx` | Boss Velocity X | |
| `$25B5` | `bvy` | Boss Velocity Y | |
| `$25B6` | `boss_x_hi` | Boss World X (High) | |
| `$25B7` | `boss_y_hi` | Boss World Y (High) | |
| `$25B8` | `boss_scr_x` | Boss Screen X | |
| `$25B9` | `boss_scr_y` | Boss Screen Y | |
| `$25BA` | `boss_on` | Boss Visible Flag | |
| `$25BB` | `boss_fighter_timer`| Boss Spawn Timer | |
| `$25BC` | `boss_move_phase` | Boss Oscillation Phase | |
| `$25BD-25D7` | (Reserved) | | |
| `$25D8-25D9` | `bfx` | Blue Fighter X (Low) | Array [2] |
| `$25DA-25DB` | `bfy` | Blue Fighter Y (Low) | Array [2] |
| `$25DC-25DD` | `bflife` | Blue Fighter Life | Array [2] |
| `$25DE-25DF` | `bfx_hi` | Blue Fighter X (High) | Array [2] |
| `$25E0-25E1` | `bfy_hi` | Blue Fighter Y (High) | Array [2] |
| `$25E2-25E3` | `bfby` | Blue Fighter Base Y | Array [2] |
| `$25E4-25E5` | `bfx_scr` | Blue Fighter Screen X | Array [2] |
| `$25E6-25E7` | `bfy_scr` | Blue Fighter Screen Y | Array [2] |
| `$25E8-25E9` | `bf_on` | Blue Fighter Visible | Array [2] |
| `$25EA-25EB` | `bfx_acc` | Blue Fighter X Acc | Array [2] |
| `$25EC-25ED` | `bfy_acc` | Blue Fighter Y Acc | Array [2] |
| `$25EE` | `bf_bul_x` | Blue Fighter Bul X | |
| `$25EF` | `bf_bul_y` | Blue Fighter Bul Y | |
| `$25F0` | `bf_bul_vx` | Blue Fighter Bul VX | |
| `$25F1` | `bf_bul_vy` | Blue Fighter Bul VY | |
| `$25F2` | `bf_bul_life` | Blue Fighter Bul Life | |
| `$25F3` | `bf_fire_cooldown`| BF Fire Cooldown | |
| `$25F4-25FF` | (Reserved) | | |

---

## 3. POKEY / ASM Hardware Usage
The custom POKEY driver at the end of `astrowing.bas` uses the following resources:

### Hardware Registers
| Address | Name | Usage |
| :--- | :--- | :--- |
| `$0450` | `AUDF1` | Base POKEY register address |
| `$0451` | `AUDC1` | Explicitly cleared in `StopMusic` |
| `$0453` | `AUDC2` | Explicitly cleared in `StopMusic` |
| `$0455` | `AUDC3` | Explicitly cleared in `StopMusic` |
| `$0457` | `AUDC4` | Explicitly cleared in `StopMusic` |

### Internal ASM Variables
| Variable | Usage |
| :--- | :--- |
| `temp1` | Zero Page Pointer (Low) to Music Data |
| `temp2` | Zero Page Pointer (High) to Music Data |
| `music_ptr_lo/hi` | Game state variable holding current playback position |

### Logic
-   **StopMusic**: Zeros out POKEY volume/control registers.
-   **PlayMusic**: Reads byte stream from music data. Handles frame delimiters `$FF` and song loop `$FE`.