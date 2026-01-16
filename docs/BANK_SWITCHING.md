# Bank Switching Implementation Plan

Plan to add bank switching support for multi-level music and title cards.

## Current ROM Status

Based on recent build output:
- **ROM Size**: 32K (default)
- **Space Remaining**: ~10KB in main area
- **Graphics Space**: 2 GFX blocks with limited remaining space

## Bank Switching Overview

### What is Bank Switching?
Bank switching allows the Atari 7800 to access more than 48K of ROM by swapping different "banks" of memory in and out of the addressable space. This is essential for:
- Large graphics assets (title screens, backgrounds)
- Multiple music tracks
- Level-specific data

### 7800basic Implementation
7800basic uses **banksets** with these features:
- Main ROM remains fixed (code, common graphics)
- Banked data uses `bset_` prefix
- Automatic bank management during data access
- Maximum ROM size: 144K, 256K, or 512K

## Proposed ROM Configuration

### ROM Size: 144K
- **Main ROM** (48K): Game code, common sprites, sound effects
- **Bank 1** (48K): Level 1-2 music + title cards
- **Bank 2** (48K): Level 3-4 music + additional graphics

## Implementation Steps

### Phase 1: Enable Bank Switching

[MODIFY] [rpmegafighter.bas](file:///Users/jasonrowe/Software/Atari7800/AtariTrader/src/rpmegafighter.bas)

Add after `displaymode 160A`:
```basic
set romsize 144k
set banksets on
```

### Phase 2: Organize Title Card Graphics

Create banked title card data:

[NEW] `src/title_cards.bas`
```basic
; Banked title card data

alphadata bset_level1_title title_screen_conv
'LEVEL 1'
'ASTEROID FIELD'
end

alphadata bset_level2_title title_screen_conv  
'LEVEL 2'
'ENEMY SWARM'
end

alphadata bset_level3_title title_screen_conv
'LEVEL 3' 
'THE GAUNTLET'
end
```

### Phase 3: Music Track Organization

#### Music File Structure
```
src/music/
  ├── level1_music.rmt.asm (generated from RMT tracker)
  ├── level2_music.rmt.asm
  ├── level3_music.rmt.asm
  └── title_music.rmt.asm
```

#### Include Banked Music
```basic
; In main file, after banksets enabled
include bset_level1_music.rmt.asm
include bset_level2_music.rmt.asm
include bset_level3_music.rmt.asm
```

### Phase 4: Runtime Bank Management

Add level/music switching logic:

```basic
dim current_level = var214
dim current_music_bank = var215

init_level
   ; Set based on level number
   if current_level = 1 then gosub load_level1_assets
   if current_level = 2 then gosub load_level2_assets
   if current_level = 3 then gosub load_level3_assets
   return

load_level1_assets
   ; Title card display uses bset_ automatically
   plotchars bset_level1_title 7 40 80
   
   ; Music switching (RMT tracker handles bank switching internally)
   playrmt bset_level1_music
   return

load_level2_assets
   plotchars bset_level2_title 7 40 80
   playrmt bset_level2_music
   return
```

## Memory Budget

### Main ROM (48K)
- Game code: ~22K
- Player/enemy/asteroid sprites: ~8K
- Common UI elements (scoredigits, etc.): ~2K
- Sound effects: ~2K
- **Reserved**: ~14K buffer

### Bank 1 (48K)
- Title screen graphics (full banner): ~16K
- Level 1 music (RMT): ~8K
- Level 2 music (RMT): ~8K
- Level title cards: ~2K
- **Reserved**: ~14K

### Bank 2 (48K)
- Level 3 music: ~8K
- Level 4 music: ~8K
- Additional backgrounds/animations: ~16K
- **Reserved**: ~16K

## Migration Strategy

### Step 1: Test Banksets (Minimal)
1. Enable `set banksets on`
2. Move ONE title card to `bset_` prefix
3. Verify build succeeds
4. Test display works correctly

### Step 2: Add Music Support
1. Set up RMT music tracker
2. Create placeholder music files
3. Include as `bset_music1`, `bset_music2`
4. Test music switching between levels

### Step 3: Full Implementation
1. Create all title cards
2. Import all music tracks
3. Add level progression logic
4. Optimize bank usage

## Build System Changes

No CMake changes needed - 7800basic handles banksets automatically during compilation.

## Testing Checklist

- [ ] Build succeeds with `set banksets on`
- [ ] Title screen displays correctly
- [ ] Banked title cards display
- [ ] Music plays from banked data
- [ ] Music switches between levels
- [ ] No crashes during bank switches
- [ ] ROM size stays under 144K limit

## Alternative: Simpler 48K Approach

If bank switching proves complex, consider:
- Use compressed graphics (lzsa compression)
- Shorter music loops
- Procedurally generated title cards
- Stay within 48K ROM limit

This avoids bank switching complexity but limits content.
