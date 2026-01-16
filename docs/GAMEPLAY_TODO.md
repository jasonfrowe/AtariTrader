# AtariTrader Game Development TODO

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
- [ ] Shield variable already exists as `player_shield` (starts at 99)
- [ ] Update shield depletion on hits:
  - [ ] Enemy bullet hit: -1 shield
  - [ ] Enemy collision: -2 shields
  - [ ] Asteroid collision: -10 shields
- [ ] Shield display already in HUD (update to use current shield value)
- [ ] When shields reach 0:
  - [ ] Lose one life (`player_lives--`)
  - [ ] If lives > 0: restart level (full shields, full fighter pool)
  - [ ] If lives = 0: game over

#### Lives System
- [ ] Lives already tracked with `player_lives` variable
- [ ] Lives already displayed in HUD (hearts/icons)
- [ ] Implement level restart logic:
  - [ ] Reset shields to 99
  - [ ] Reset fighter count to level's starting value
  - [ ] Reset prizes (all active again)
  - [ ] Reset player position
  - [ ] Reset enemy positions
- [ ] Game over when lives reach 0

#### Fighter Pool System
- [ ] `fighters_remaining` variable (starts based on level)
- [ ] Display fighter count in HUD (already positioned)
- [ ] Decrement when enemy destroyed
- [ ] Player wins level when all fighters destroyed

#### Win/Loss Conditions
- [ ] **Level Win**: All fighters destroyed → advance to next level
- [ ] **Level Restart**: Shields reach 0, lives > 0 → restart level
- [ ] **Game Over**: Lives reach 0
- [ ] Remove old score-based logic (already deprecated)

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
- [ ] Add `current_level` variable (1-5 or more)
- [ ] Add `level_config` arrays for difficulty scaling:
  - [ ] `level_enemy_speed[5]` - enemy movement speed per level
  - [ ] `level_fire_cooldown[5]` - frames between shots
  - [ ] `level_fighter_count[5]` - total fighters to destroy
  - [ ] `level_shield_refill[5]` - partial shield restore amount

### Level Initialization
- [ ] Create `init_level` subroutine
  - [ ] Load level-specific configuration
  - [ ] Set enemy speed from `level_enemy_speed[current_level]`
  - [ ] Set fire cooldown from `level_fire_cooldown[current_level]`
  - [ ] Set fighter count from `level_fighter_count[current_level]`
  - [ ] Refill shields (partial or full based on level)
- [ ] Reset prize locations
- [ ] Reset asteroid position

### Level Transition
- [ ] Create `level_complete` subroutine
  - [ ] Show level complete screen
  - [ ] Display stats (fighters destroyed, shields remaining)
  - [ ] Partial shield refill
  - [ ] Increment `current_level`
  - [ ] Wait for button press to continue
- [ ] Call `init_level` for next level

### Difficulty Scaling (Example Values)
- [ ] **Level 1**: Speed=1px/2frames, Cooldown=60, Fighters=20, Shield Refill=50%
- [ ] **Level 2**: Speed=1px/frame, Cooldown=45, Fighters=40, Shield Refill=40%
- [ ] **Level 3**: Speed=2px/frame, Cooldown=30, Fighters=60, Shield Refill=30%
- [ ] **Level 4**: Speed=2px/frame, Cooldown=25, Fighters=80, Shield Refill=20%
- [ ] **Level 5**: Speed=3px/frame, Cooldown=20, Fighters=99, Shield Refill=10%

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
