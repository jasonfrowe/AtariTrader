# Development Guide - AtariTrader

## Getting Started with 7800basic Development

### Understanding the Atari 7800 Architecture

The Atari 7800 has some unique characteristics:

- **CPU**: 6502-compatible running at 1.79 MHz
- **Graphics Chip (MARIA)**: Zone-based sprite/character system
- **Display**: 160x192 or 320x192 resolution
- **Colors**: 256 colors available, but limited per sprite/character
- **Sound**: TIA chip (same as 2600) or optional POKEY chip
- **Memory**: Varies by cartridge type (16K-512K ROM)

### Display Zones

MARIA splits the screen into horizontal zones (8 or 16 pixels tall). This affects how you organize graphics:

```basic
   set zoneheight 16  rem Default, 8 is also available
```

### Display Modes

**160A Mode** (Most Common)
- 160x192 resolution
- 4 pixels wide per character
- 3 colors + transparent per palette
- Best for most games

**320A Mode** (High Resolution)
- 320x192 resolution
- 8 pixels wide per character
- 1 color + transparent
- Good for detailed graphics

**320B Mode**
- 320x192 resolution
- 4 pixels wide per character
- 3 colors + transparent
- Palette restrictions apply

## Graphics Workflow

### 1. Creating Sprite Graphics

Use any image editor that supports indexed PNG:
- GIMP (Free)
- Aseprite (Paid, great for pixel art)
- GraphicsGale (Free)

**Requirements:**
- PNG format in indexed color mode
- Width must be multiple of character width (4 or 8 pixels)
- Height should be multiple of zone height (8 or 16 pixels)
- Max 4 colors (including transparent)

**Example: Creating a 16x16 player sprite for 160A mode**

1. Create 16x16 indexed PNG (4 colors max)
2. Color index 0 = transparent
3. Color indexes 1-3 = your sprite colors
4. Save as `gfx/player.png`

### 2. Importing Graphics

```basic
   rem Import sprite (automatically creates palette constants)
   incgraphic gfx/player.png 160A
   
   rem Set the palette colors
   P0C1 = player_color1  rem Uses color from PNG
   P0C2 = player_color2
   P0C3 = player_color3
```

### 3. Drawing Sprites

```basic
   dim playerx = a
   dim playery = b
   
   playerx = 80
   playery = 96
   
   clearscreen
   plotsprite player 0 playerx playery  rem palette 0
   drawscreen
```

## Game Loop Structure

### Basic Loop

```basic
__Main_Loop
   clearscreen           rem Clear display
   
   rem [Game logic here]
   
   drawscreen           rem Wait for vsync and display
   goto __Main_Loop
```

### Optimized Loop with Background

```basic
   rem Setup - run once
   clearscreen
   rem [Draw static background]
   savescreen           rem Save the background
   
__Main_Loop
   restorescreen        rem Restore saved background
   
   rem [Update moving sprites]
   
   drawscreen
   goto __Main_Loop
```

### Double Buffering (for complex scenes)

```basic
   set extradlmemory on  rem Need extra memory
   
   doublebuffer on
   clearscreen
   rem [Draw background]
   savescreen
   
__Main_Loop
   restorescreen
   rem [Game logic and sprite drawing]
   doublebuffer flip
   goto __Main_Loop
```

## Variable Management

### Standard Variables (a-z, var0-var99)

```basic
   dim playerx = a       rem Name your variables
   dim playery = b
   dim score = c
   
   playerx = 80
   playery = 96
```

### Extended Memory ($2200-$27FF)

```basic
   dim enemydata = $2200     rem 1.5K available
   dim levelmap = $2300
```

### Fixed Point Variables (for smooth movement)

```basic
   dim playerx = a.b     rem a=integer, b=decimal
   
   playerx = 80.0
   playerx = playerx + 0.5   rem Smooth movement
```

### Arrays

```basic
   dim enemy0x = a
   dim enemy1x = b
   dim enemy2x = c
   
   rem Access as array
   enemy0x[0] = 10  rem enemy0x
   enemy0x[1] = 20  rem enemy1x
   enemy0x[2] = 30  rem enemy2x
```

## Input Handling

### Joystick

```basic
   if joy0up then playery = playery - 1
   if joy0down then playery = playery + 1
   if joy0left then playerx = playerx - 1
   if joy0right then playerx = playerx + 1
   if joy0fire0 then gosub __Fire
   if joy0fire1 then gosub __Jump
```

### Button Debouncing

```basic
   dim firebutton = a
   dim firepressed = b
   
   firebutton = 0
   if joy0fire0 then firebutton = 1
   
   if firebutton && !firepressed then gosub __Fire
   firepressed = firebutton
```

## Collision Detection

### Simple Bounding Box

```basic
   rem Check if sprites overlap
   if boxcollision(player_x, player_y, 16, 16, enemy_x, enemy_y, 16, 16) then gosub __Hit
```

### Point-in-Box (for bullets)

```basic
   if bulletx > enemyx && bulletx < (enemyx+16) then goto __Check_Y
   goto __No_Hit
   
__Check_Y
   if bullety > enemyy && bullety < (enemyy+16) then gosub __Hit
   
__No_Hit
```

## Sound Effects

### TIA Sound (built-in)

```basic
   rem Direct register access
   AUDC0 = 4      rem Waveform
   AUDF0 = 12     rem Frequency
   AUDV0 = 8      rem Volume
```

### Using Sound Driver

```basic
   rem Define sound effect
   data sfx_shoot
   16, 5, 2           rem version, priority, frames per chunk
   $1E,$04,$08        rem frequency, waveform, volume
   $1B,$04,$06
   $00,$00,$00        rem End marker
   end
   
   rem Play it
   playsfx sfx_shoot
```

## Memory Optimization

### ROM Usage

Check compilation output for free space:
```
7505 bytes of ROM space left in the main area of bank 1.
```

If running low:
1. Use bankswitching (`set romsize 128k`)
2. Compress graphics (share palettes)
3. Use `dmahole` for code placement

### RAM Usage

- 126 named variables (a-z, var0-var99)
- 1.5K extended ($2200-$27FF)
- Can use on-cart RAM (certain ROM formats)

## Best Practices

### Code Organization

```basic
   rem ===========================
   rem = INITIALIZATION
   rem ===========================
   set romsize 48k
   displaymode 160A
   
   rem ===========================
   rem = VARIABLE DEFINITIONS  
   rem ===========================
   dim playerx = a
   dim playery = b
   
   rem ===========================
   rem = GRAPHICS IMPORTS
   rem ===========================
   incgraphic gfx/player.png 160A
   
   rem ===========================
   rem = MAIN GAME LOOP
   rem ===========================
__Main_Loop
   rem ...
   
   rem ===========================
   rem = SUBROUTINES
   rem ===========================
__Fire_Weapon
   rem ...
   return
```

### Comments

```basic
   rem Clear and detailed comments
   playerx = playerx + 1  rem Move right
   
   rem Block comments for sections
   rem ***************************
   rem * Enemy Movement AI
   rem ***************************
```

### Labels

```basic
   rem Use descriptive labels
__Player_Movement     rem Good
__PM                  rem Bad
   
   rem Prefix with purpose
__Init_Game
__Update_Enemies
__Draw_HUD
```

## Testing

### Emulator Testing

**A7800** (Recommended)
- Most accurate
- Debug features
- Cross-platform

**MAME**
- Cycle-accurate
- Multiple systems
- Can be complex

### Real Hardware

- Use flash cartridge (Concerto, UNO Cart)
- Test on PAL and NTSC if possible
- Check for timing issues

## Common Pitfalls

1. **Forgetting `drawscreen`** - Screen won't update
2. **Too many sprites** - MARIA runs out of time, sprites flicker
3. **Wrong color indexes** - Graphics appear wrong/invisible
4. **Zone height mismatch** - Sprites split across zones
5. **Not checking bounds** - Movement off-screen causes glitches

## Performance Tips

1. **Minimize `clearscreen` calls** - Use `savescreen`/`restorescreen`
2. **Batch sprite drawing** - Draw all sprites before `drawscreen`
3. **Use `PLOTSPRITE` macro** - Faster than `plotsprite` function
4. **Limit collision checks** - Only check nearby objects
5. **Profile with `set debug color`** - Shows CPU usage

## Resources for Graphics

### Color Palette
- Use 7800 palette charts online
- Tools: 7800PaletteEditor

### Sprite Editors
- Aseprite (best for animation)
- GraphicsGale (free)
- GIMP (general purpose)

### Map Editors
- Tiled (https://www.mapeditor.org/)
- Works with `incmapfile` command

---

Happy developing! For questions, check:
- [AtariAge Forums](https://forums.atariage.com/forum/63-atari-7800/)
- [7800basic Documentation](https://www.randomterrain.com/7800basic.html)
