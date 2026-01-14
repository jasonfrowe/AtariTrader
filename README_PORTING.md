# RPMegaFighter Porting Notes

## Overview
This document tracks the process of porting RPMegaFighter from the RP6502 (C/Assembly) to the Atari 7800 (7800Basic).

## Lessons Learned

### Architecture Differences
- **RP6502**: 6502 CPU @ 8MHz, VGA graphics, Affine Sprites (Hardware Rotation).
- **Atari 7800**: 6502 CPU @ 1.79MHz, MARIA graphics, No Hardware Rotation.

### 7800Basic Specifics
1.  **Fixed Point Math**:
    - 7800Basic does not support 16-bit `word` math natively in all contexts (assignment values > 255 cause errors).
    - **Solution**: Use explicit high/low byte variables or "Remainder" logic for sub-pixel movement.
    - **Velocity**: We switched to a "Dual-Variable" velocity system (`vx_p` for plus, `vx_m` for minus) to handle signed momentum using only unsigned 8-bit bytes. This avoids complex 16-bit signed math emulation.

2.  **Sprite Rotation**:
    - No hardware rotation.
    - **Solution**: Pre-rendered sprite frames (16 angles). `incgraphic` handles importing them sequence. Logic simply maps `angle` (0-15) to `sprite_frame`.

3.  **ROM vs RAM**:
    - Arrays defined with `dim array[16]` consume valuable RAM.
    - **Solution**: For static lookup tables (Sine/Cosine), use `data` statements (ROM) and read them using `table[index]` syntax.

4.  **Graphics Import**:
    - syntax: `incgraphic [label] [filename] [mode]`
    - `incgraphic spaceship.png 160A` automatically creates label `spaceship` and can be used with `plotsprite spaceship ...`.

## Current Status (Physics)
- **Momentum**: Implemented using the Dual-Variable system.
- **Thrust**: "Asteroids-style" thrust using a 16-entry Sine/Cosine lookup table.
- **Friction**: Implemented frame-based drag (velocity decay).
- **Issue**: Initial acceleration was too high (4px/frame^2), causing uncontrollable speed and "cardinal-only" feel.
- **Fix**: Retuned tables for lower acceleration (max 1-2px) and increased friction.

## To-Do
- [ ] Add enemy / asteroid placeholders.
- [ ] Implement collision detection (Hitboxes).
- [ ] Add sound effects.
