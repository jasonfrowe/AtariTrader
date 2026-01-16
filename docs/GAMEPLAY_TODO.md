# AtariTrader Game Development TODO

## Summary

### ✅ Completed Features (Phase 1-3)
- **Core Mechanics**: Shield/Fighter/Lives system fully operational
- **Level Progression**: 5 levels with progressive difficulty (fighters, refills, enemy speed, fire rate)
- **HUD**: Displays shields, fighters, lives, prizes
- **Win/Loss Flow**: Level complete, level restart, game over screens
- **Difficulty Scaling**: Enemy movement speed and fire rate increase per level
- **Memory Management**: Fixed 4 critical variable collisions (documented in MEMORY_MAP.md)

### 🎯 Next Priorities (Phase 2)
1. **Prize Collection**: Proximity detection, collection logic, display update
2. **Asteroid Hazards**: Bounce physics, shield damage (-10 on collision)
3. **Enemy AI**: Asteroid avoidance behavior

---

## Asset Creation (User Tasks)
- [ ] Compose music tracks for levels
- [ ] Create title cards for story
- [x] Design prize/treasure graphics (replace ABCDE placeholders)
- [x] Create shield/fighter UI indicators

---

## Core Gameplay Mechanics

### Prize Collection System
**Status: Graphics already implemented (ABCDE tiles in scoredigits_8_wide.png)**

- [ ] Define prize spawn locations (5 prizes per level)
- [ ] Create prize collection logic
  - [ ] Detect player collision with prize
  - [ ] Remove collected prize from screen (set `prize_active[i] = 0`)
  - [ ] Track collected prizes count (`prizes_collected++`)
  - [ ] Play collection sound effect
- [ ] Update prize display to show/hide based on `prize_active[]`
- [ ] Reset prizes when level restarts (after death)

### Shield/Fighter System Redesign

#### Player Shield System
- [x] Shield variable already exists as `player_shield` (starts at 99)
- [x] Update shield depletion on hits:
  - [x] Enemy bullet hit: -1 shield
  - [x] Enemy collision: -2 shields + -1 fighter (fighter destroyed)
  - [ ] Asteroid collision: -10 shields
- [x] Shield display already in HUD (update to use current shield value)
- [x] When shields reach 0:
  - [x] Lose one life (`player_lives--`)
  - [x] If lives > 0: restart level (full shields, full fighter pool)
  - [x] If lives = 0: game over

#### Lives System
- [x] Lives already tracked with `player_lives` variable
- [x] Lives already displayed in HUD (hearts/icons)
- [x] Implement level restart logic:
  - [x] Reset shields to 99
  - [x] Reset fighter count to level's starting value
  - [x] Reset prizes (all active again)
  - [x] Reset player position
  - [x] Reset enemy positions
- [x] Game over when lives reach 0

#### Fighter Pool System
- [x] `fighters_remaining` variable (starts based on level)
- [x] Display fighter count in HUD (already positioned)
- [x] Decrement when enemy destroyed
- [x] Player wins level when all fighters destroyed

#### Win/Loss Conditions
- [x] **Level Win**: All fighters destroyed → advance to next level
- [x] **Level Restart**: Shields reach 0, lives > 0 → restart level
- [x] **Game Over**: Lives reach 0
- [x] Remove old score-based logic (already deprecated)

---

## Asteroid Hazard System

### Player vs Asteroid
- [ ] Implement bounce physics
  - [ ] Detect asteroid collision (already exists)
  - [ ] Calculate bounce vector (reverse player direction)
  - [ ] Apply bounce velocity to player
  - [ ] Decrease shields on impact
- [ ] Prevent player from "sticking" to asteroid
- [ ] Add collision sound effect
- [ ] Visual feedback (flash, shake effect)

### Enemy Avoidance AI
- [ ] Add asteroid proximity detection for enemies
  - [ ] Check distance to asteroid before movement
  - [ ] Threshold: if within 24 pixels, trigger avoidance
- [ ] Implement avoidance behavior
  - [ ] Set `avoiding_asteroid` flag for enemy
  - [ ] Choose perpendicular direction to asteroid
  - [ ] Maintain avoidance for 30-60 frames
  - [ ] Resume player pursuit after avoidance timer
- [ ] Smooth transition between pursuit and avoidance

---

## Level Progression System

### Level Variables
- [x] Add `current_level` variable (1-5 or more)
- [x] Add `level_config` for difficulty scaling:
  - [x] `enemy_move_mask` - enemy movement speed per level (mask-based)
  - [x] `enemy_fire_cooldown` - frames between shots
  - [x] `level_fighter_count` - total fighters to destroy (via `set_level_fighters`)
  - [x] `level_shield_refill` - partial shield restore amount (hardcoded formula)

### Level Initialization
- [x] Create `init_level` subroutine
  - [x] Set fighter count from current level
  - [x] Refill shields (partial based on level)
  - [x] Set enemy speed from level config (via `set_level_config`)
  - [x] Set fire cooldown from level config (via `set_level_config`)
- [x] Reset prize locations
- [x] Reset asteroid position

### Level Transition
- [x] Create `level_complete` subroutine
  - [x] Show level complete screen
  - [x] Partial shield refill
  - [x] Increment `current_level`
  - [x] Wait for button press to continue
- [x] Call `init_level` for next level

### Difficulty Scaling
**Status: ✅ COMPLETE - All levels have progressive difficulty**
- [x] **Level 1**: Speed=1px/2frames, Cooldown=60, Fighters=20, Shield Refill=50%
- [x] **Level 2**: Speed=1px/2frames, Cooldown=45, Fighters=40, Shield Refill=40%
- [x] **Level 3**: Speed=1px/frame, Cooldown=30, Fighters=60, Shield Refill=30%
- [x] **Level 4**: Speed=1px/frame, Cooldown=25, Fighters=80, Shield Refill=20%
- [x] **Level 5**: Speed=1px/frame, Cooldown=20, Fighters=99, Shield Refill=10%

**Implementation Notes:**
- Movement speed controlled by `enemy_move_mask` (1=slow, 0=fast)
- Fire rate controlled by `enemy_fire_cooldown` (higher=slower)
- All settings applied via `set_level_config` subroutine

---

## UI/UX Improvements

### HUD Updates
**Status: Basic HUD already positioned and functional**

- [ ] Update shield display to use actual `player_shield` value
- [ ] Update fighter count to use `fighters_remaining`
- [ ] Prize indicators already showing (ABCDE), add active/collected state
- [ ] Lives display already functional (hearts)
- [ ] Add level indicator (optional)

### Visual Feedback
- [ ] Flash effect when player hit
- [ ] Screen shake on asteroid collision
- [ ] Prize collection sparkle/animation
- [ ] Fighter destruction animation (already in progress with explosions)
- [ ] Shield low warning (flash red when < 25%)

### Sound Effects
- [ ] Prize collection sound
- [ ] Shield hit sound
- [ ] Asteroid bounce sound
- [ ] Shield depleted death sound
- [ ] Level complete fanfare

---

## Code Organization

### New Variables Needed
- [ ] `player_shield` - already exists (var144 or update from score_e)
- [ ] `fighters_remaining` (use score_p location or new var)
- [ ] `prizes_collected` (var150)
- [ ] `prize_x[5]` array (var151-155)
- [ ] `prize_y[5]` array (var156-160)
- [ ] `prize_active[5]` array (var161-165) - 0=collected, 1=active
- [ ] `current_level` (var166)
- [ ] Enemy avoidance flags: `enemy_avoiding[4]` (var167-170)
- [ ] Enemy avoidance timers: `avoid_timer[4]` (var171-174)

### Subroutines to Create/Update
- [ ] `init_level` - Initialize level configuration (new level)
- [ ] `restart_level` - Reset level state (after death)
- [ ] `check_prize_collision` - Detect prize collection
- [ ] `apply_bounce` - Handle asteroid bounce physics
- [ ] `enemy_avoid_asteroid` - Enemy avoidance logic
- [ ] `update_shield_display` - Update shield HUD
- [ ] `level_complete` - Level transition screen
- [ ] `lose_life` - Handle death, check game over, or restart level

---

## Testing & Balancing

### Playtest Checklist
- [ ] Shield depletion feels fair (not too fast/slow)
- [ ] Asteroid bounce feels responsive
- [ ] Enemy avoidance looks natural
- [ ] Level difficulty progression feels balanced
- [ ] Prize collection is rewarding
- [ ] Win/loss conditions are clear

### Balance Tuning
- [ ] Adjust shield damage values
- [ ] Tune enemy speed per level
- [ ] Adjust fire cooldown per level
- [ ] Balance fighter count per level
- [ ] Test asteroid avoidance threshold

---

## Integration with Bank Switching (Later)
- [ ] Move level music to banked data
- [ ] Move title cards to banked data
- [ ] Pre-load level assets from banks
- [ ] Test bank switching during level transitions

---

## Priority Order (Suggested)

### Phase 1: Core Mechanics (High Priority)
1. Shield/Fighter/Lives system integration
2. Win/Loss/Restart condition updates
3. Prize collection logic
4. HUD value updates (shield, fighters, prizes)

### Phase 2: Hazards & AI (Medium Priority)
5. Asteroid bounce physics
6. Enemy asteroid avoidance

### Phase 3: Progression (Medium Priority)
7. Level system variables and arrays
8. Level initialization and restart logic
9. Difficulty scaling implementation

### Phase 4: Polish (Lower Priority)
10. Visual feedback improvements
11. Sound effects integration
12. Final balancing
