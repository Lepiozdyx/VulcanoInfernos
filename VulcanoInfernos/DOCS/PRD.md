# PRD.md - Vulcano Infernos iOS Game

## PROJECT OVERVIEW

**App Name:** Vulcano Infernos  
**Type:** Arcade slot-style game with rotating stone rings  
**Platform:** iOS 16+  
**Framework:** SwiftUI  
**Orientation:** Landscape only  
**Architecture:** MVVM + Coordinator pattern

### Core Concept
Player taps "Spin" button to rotate 5 concentric stone rings with runes. When symbols align at 12 o'clock position, player earns volcano energy (points). Goal: accumulate maximum energy to unlock new levels, backgrounds, and artifacts.

---

## TECHNICAL ENVIRONMENT

### Requirements
- iOS 16.0+
- SwiftUI (no SpriteKit needed)
- Horizontal orientation only
- Support all iPhone screen sizes
- Modular architecture

### Architecture Layers
1. **Models** - data structures
2. **Managers** - business logic (AppManager, AudioManager, etc.)
3. **Extensions** - utility extensions
4. **ViewModels** - screen logic
5. **Views** - UI components

### State Management
- Global state via `AppManager` (ObservableObject)
- Passed through `.environmentObject()`
- Persistent storage via UserDefaults

---

## DATA MODELS

### Ring Model
```swift
struct Ring: Identifiable {
    let id: Int              // 1-5 (outer to inner)
    let scale: CGFloat       // ring size scale (1.0, 0.85, 0.7, 0.55, 0.4)
    var currentAngle: Double // current rotation angle
    let runeSequence: [Int]  // fixed order of runes on image [0-11]
    let minRotation: Double  // minimum rotation degrees
    let maxRotation: Double  // maximum rotation degrees
    let animationDuration: Double
    let rotationDirection: Int // 1 for clockwise, -1 for counter-clockwise
}
```

### Rune System (Simplified PNG-based)
Instead of rendering segments programmatically, we use a **single pre-made PNG image** (`ring.png`) with 12 runes already drawn on it.

**How it works:**
1. Use the same `ring.png` for all 5 rings
2. Scale each ring differently (1.0 → 0.85 → 0.7 → 0.55 → 0.4)
3. Each ring gets a random initial `currentAngle` when level starts
4. Apply `.rotationEffect(.degrees(currentAngle))` to rotate entire PNG

**Rune ID mapping (manual):**
We manually define the rune order on the PNG image clockwise from 12 o'clock:
```swift
let runeSequence = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
```
- Position 0 (0° / 12 o'clock): Rune ID 0
- Position 1 (30°): Rune ID 1
- Position 2 (60°): Rune ID 2
- ... and so on

This array is **identical for all rings** since we use the same image. Randomness comes from:
- Different initial angles (set randomly when level starts)
- Different rotation speeds/ranges per ring
- Alternating rotation directions (clockwise vs counter-clockwise)
- Random rotation amounts on each spin

**Example scenario:**
```
Initial state:
Ring 1: angle = 45°  → Rune ID 2 at top
Ring 2: angle = 180° → Rune ID 6 at top
Ring 3: angle = 270° → Rune ID 9 at top
Ring 4: angle = 15°  → Rune ID 1 at top
Ring 5: angle = 330° → Rune ID 11 at top

After spin (rings rotate different amounts in different directions):
Ring 1: angle = 135° → Rune ID 5 at top
Ring 2: angle = 60°  → Rune ID 2 at top (counter-clockwise)
Ring 3: angle = 510° → Rune ID 5 at top (clockwise, multiple rotations)
Ring 4: angle = -120° → Rune ID 9 at top (counter-clockwise)
Ring 5: angle = 1410° → Rune ID 11 at top (clockwise, 4 full spins)

Result: No consecutive matches → 0 energy
```

### Level Model
```swift
struct Level: Identifiable {
    let id: Int              // 1-20
    let energyRequired: Int  // energy needed to unlock
    var isUnlocked: Bool
}
```

**Important:** All 20 levels have **identical gameplay mechanics**. The only difference between levels is the background image displayed on the Game screen. Each level does not have unique ring configurations or difficulty - it's purely progression-based unlocking.

### Background Model
```swift
struct GameBackground: Identifiable {
    let id: Int              // 1-4
    let unlockLevel: Int     // level required
    var isUnlocked: Bool
    let imageName: String
}
```

### Artifact Model
```swift
struct Artifact: Identifiable {
    let id: Int
    let name: String
    let legend: String       // lore text
    let energyRequired: Int
    var isUnlocked: Bool
    let imageName: String
}
```

### Achievement Model
```swift
struct Achievement: Identifiable {
    let id: Int
    let title: String
    let description: String
    var isCompleted: Bool
    let iconName: String
}
```

---

## ENERGY & PROGRESSION SYSTEM

### Energy Earning (Match at 12 o'clock)
- **2 rings match:** +10 energy
- **3 rings match:** +50 energy
- **4 rings match:** +150 energy
- **5 rings match (JACKPOT):** +500 energy

### Level Unlock Requirements (Exponential Growth)
```
Level 1: 0 (default unlocked)
Level 2: 100
Level 3: 250
Level 4: 500
Level 5: 850
Level 6: 1,300
Level 7: 2,000
Level 8: 3,000
Level 9: 4,500
Level 10: 6,500
Level 11: 9,000
Level 12: 12,500
Level 13: 17,000
Level 14: 23,000
Level 15: 30,000
Level 16: 38,000
Level 17: 44,000
Level 18: 50,000
Level 19: 57,000
Level 20: 65,000
```

### Background Unlock System (4 backgrounds)
- **Background 1:** Default (0 energy)
- **Background 2:** Unlocks at Level 2 (100 energy)
- **Background 3:** Unlocks at Level 3 (250 energy)
- **Background 4:** Unlocks at Level 4 (500 energy)

### Artifact Unlock System (10 artifacts)
Artifacts unlock at specific energy milestones:
```
Artifact 1: 1,000 energy
Artifact 2: 3,000 energy
Artifact 3: 6,000 energy
Artifact 4: 10,000 energy
Artifact 5: 15,000 energy
Artifact 6: 22,000 energy
Artifact 7: 30,000 energy
Artifact 8: 40,000 energy
Artifact 9: 52,000 energy
Artifact 10: 65,000 energy
```

### Achievements (5 total)
1. **First Spark:** Complete level 1 (reach 100 energy)
2. **Eruption Master:** Unlock first artifact (1,000 energy)
3. **Core Igniter:** Unlock all backgrounds (500 energy, level 4)
4. **Titan Awakened:** Unlock all artifacts (65,000 energy)
5. **Collector of Ashes:** Unlock all 20 levels (65,000 energy)

### Persistent Storage (UserDefaults)
```swift
Keys:
- "totalEnergy": Int
- "unlockedLevels": [Int]
- "currentLevel": Int
- "selectedBackgroundId": Int
- "unlockedArtifacts": [Int]
- "completedAchievements": [Int]
- "soundEnabled": Bool
- "musicEnabled": Bool
```

---

## ASSET REQUIREMENTS

### Ring Image
**Required:** Single PNG file with transparency
- **Filename:** `ring.png` (or `ring@2x.png`, `ring@3x.png` for retina)
- **Content:** Pre-drawn ring with 12 rune symbols evenly distributed
- **Layout:** Runes positioned clockwise starting from 12 o'clock
- **Transparency:** Background must be transparent (alpha channel)
- **Size recommendation:** 1024x1024px or larger for high quality

**Rune Order Documentation:**
Developer must document the rune sequence in code:
```swift
// Document which rune appears at each position (clockwise from 12 o'clock)
let runeSequence = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
// Position 0 = 12 o'clock (0°)
// Position 1 = 1 o'clock (30°)
// ... and so on
```

### Other Assets
- Background images for 4 levels (placeholder supported)
- Artifact images (10 total, placeholder supported)
- Achievement icons (5 total, SF Symbols as fallback)
- Audio files (5 total, can be added later)

---

## NAVIGATION & COORDINATOR

### Coordinator Pattern
```swift
enum AppScreen {
    case mainMenu
    case levelSelect
    case game(levelId: Int)
    case upgrades
    case achievements
    case artifacts
    case settings
}

class AppCoordinator: ObservableObject {
    @Published var currentScreen: AppScreen = .mainMenu
    
    func navigate(to screen: AppScreen)
    func goBack()
}
```

### Navigation Flow
```
MainMenu → LevelSelect → Game
MainMenu → Upgrades
MainMenu → Achievements
MainMenu → Artifacts
MainMenu → Settings
```

All screens (except Game) have back button to MainMenu.

---

## GAME MECHANICS - RING ROTATION

### Ring Configuration (5 rings, outer to inner)

All rings use the **same PNG image** (`ring.png`) but with different scales and rotation parameters.

**Ring 1 (Outermost):**
- Scale: 1.0
- Rotation direction: Clockwise (+1)
- Rotation range: 30° - 90°
- Animation duration: 1.2s
- Initial angle: Random (0-359°)

**Ring 2:**
- Scale: 0.85
- Rotation direction: Counter-clockwise (-1)
- Rotation range: 90° - 180°
- Animation duration: 1.4s
- Initial angle: Random (0-359°)

**Ring 3:**
- Scale: 0.7
- Rotation direction: Clockwise (+1)
- Rotation range: 180° - 360°
- Animation duration: 1.6s
- Initial angle: Random (0-359°)

**Ring 4:**
- Scale: 0.55
- Rotation direction: Counter-clockwise (-1)
- Rotation range: 360° - 720°
- Animation duration: 1.8s
- Initial angle: Random (0-359°)

**Ring 5 (Innermost):**
- Scale: 0.4
- Rotation direction: Clockwise (+1)
- Rotation range: 720° - 1440° (2-4 full rotations)
- Animation duration: 2.0s
- Initial angle: Random (0-359°)

**Rotation Direction Logic:**
- Odd-numbered rings (1, 3, 5): Clockwise rotation
- Even-numbered rings (2, 4): Counter-clockwise rotation
- This creates visual variety and unpredictability

**Scale Factor Selection:**
Scale factors are chosen to ensure **no ring overlaps another**:
- Gap between Ring 1 (1.0) and Ring 2 (0.85) = 15% smaller
- Gap between Ring 2 (0.85) and Ring 3 (0.7) = ~18% smaller
- All runes on all rings remain fully visible
- Red marker at 12 o'clock aligns with all rings

### Rotation Implementation (Pure SwiftUI)

**Animation approach:**
```swift
withAnimation(.interpolatingSpring(
    stiffness: 50,
    damping: 10,
    initialVelocity: 0
)) {
    let randomRotation = Double.random(in: ring.minRotation...ring.maxRotation)
    ring.currentAngle += randomRotation * Double(ring.rotationDirection)
}
```

**Direction multiplier:**
- Clockwise (odd rings): `rotationDirection = 1` → angle increases
- Counter-clockwise (even rings): `rotationDirection = -1` → angle decreases

**Visual result:**
- Single PNG image rotates via `.rotationEffect(.degrees(ring.currentAngle))`
- All 12 runes rotate together as one unit
- No complex rendering, just simple 2D transformation

### Spin Button Logic
1. User taps "Spin" button
2. Button becomes disabled during animation
3. All 5 rings rotate simultaneously with different speeds/ranges
4. After all animations complete (~2.2s):
   - Check alignment at 12 o'clock position
   - Calculate matches (2-5 rings)
   - Award energy based on matches
   - Update energy bar with animation
   - Play win sound if match found
   - Re-enable Spin button

### Match Detection Algorithm
```swift
// Step 1: For each ring, calculate which rune is at 12 o'clock position
func getRuneAtTop(ring: Ring) -> Int {
    // Normalize angle to 0-360 range
    let normalized = ring.currentAngle.truncatingRemainder(dividingBy: 360)
    let adjusted = normalized < 0 ? normalized + 360 : normalized
    
    // Calculate which segment (0-11) is at top
    // Each segment spans 30° (360° / 12)
    let segmentIndex = Int(round(adjusted / 30.0)) % 12
    
    // Return the rune ID at this position
    return ring.runeSequence[segmentIndex]
}

// Step 2: Compare rune IDs across all 5 rings
func detectMatches(rings: [Ring]) -> Int {
    let runesAtTop = rings.map { getRuneAtTop(ring: $0) }
    
    var matchCount = 1
    let firstRune = runesAtTop[0]
    
    // Count consecutive matches starting from Ring 1
    for i in 1..<runesAtTop.count {
        if runesAtTop[i] == firstRune {
            matchCount += 1
        } else {
            break
        }
    }
    
    return matchCount >= 2 ? matchCount : 0
}
```

**Match Examples:**
- Rings have rune IDs at 12 o'clock: `[3, 3, 7, 1, 5]` → **2 rings match** → +10 energy
- Rings have rune IDs: `[2, 2, 2, 5, 1]` → **3 rings match** → +50 energy
- Rings have rune IDs: `[0, 0, 0, 0, 0]` → **5 rings match (JACKPOT)** → +500 energy
- Rings have rune IDs: `[5, 3, 8, 1, 0]` → **No match** → +0 energy

### Energy Bar Animation
- Smooth spring animation when energy increases
- Show "+X energy" popup text above bar
- Particle effect for big wins (4-5 matches)

---

## AUDIO SYSTEM

### AudioManager Structure
```swift
class AudioManager: ObservableObject {
    @Published var isMusicEnabled: Bool
    @Published var isSoundEnabled: Bool
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    func playBackgroundMusic()
    func stopBackgroundMusic()
    func playSound(_ soundName: String)
}
```

### Audio Files (mp3/wav format)
1. **background_music.mp3** - main theme, loops
2. **button_click.wav** - all button taps
3. **spin_sound.wav** - ring rotation effect
4. **win_small.wav** - 2-3 ring match
5. **win_big.wav** - 4-5 ring match

### Audio Behavior
- Background music starts on app launch (MainMenuView.onAppear)
- Music pauses when app enters background
- Music resumes when app enters foreground
- All sounds respect settings toggle
- Music loops continuously

---

## SCREEN SPECIFICATIONS

### 1. MAIN MENU SCREEN

**Layout:**
- Centered vertically: 5 large buttons stacked
- Background: volcano/lava theme
- No back button (root screen)

**Buttons (top to bottom):**
1. Start Eruption → Navigate to Level Select
2. Upgrades → Navigate to Upgrades
3. Achievements → Navigate to Achievements
4. Artifacts → Navigate to Artifacts
5. Settings → Navigate to Settings

**Audio:**
- Background music starts here (.onAppear)
- Button click sound on all taps

---

### 2. LEVEL SELECT SCREEN

**Layout:**
- Grid: 5 columns × 4 rows = 20 level buttons
- Top-left: Back button (home icon)
- Top-right: Energy indicator + progress bar

**Level Buttons:**
- Circular buttons with level number (1-20)
- **Unlocked:** bright, tappable, shows number
- **Locked:** dimmed/grayed out, shows lock icon
- Only Level 1 unlocked initially

**Interaction:**
- Tap unlocked level → Navigate to Game(levelId)
- Tap locked level → Shake animation + "Not enough energy" message

**Energy Display:**
- Icon + current total energy number
- Horizontal progress bar showing progress to next unlock

---

### 3. GAME SCREEN

**Layout:**
- Center: 5 concentric rotating stone rings
- Top-left: Home button (exit to Level Select)
- Top-right: Energy icon + bar (current session + total)
- Bottom-center: Large "SPIN" button
- Background: Currently selected background from Upgrades screen (not tied to level number)

**Note:** Background displayed is the one selected by user in Upgrades screen, regardless of which level is being played. Level progression only unlocks access to new backgrounds.

**Ring Display:**
- 5 nested images in ZStack (same `ring.png` for all)
- Each ring scaled differently (1.0, 0.85, 0.7, 0.55, 0.4)
- Red alignment marker at 12 o'clock position (static overlay)
- Smooth rotation animations via `.rotationEffect()`

**Visual Structure:**
```swift
ZStack {
    // Ring 1 (largest, bottom layer)
    Image("ring")
        .resizable()
        .scaledToFit()
        .scaleEffect(1.0)
        .rotationEffect(.degrees(ring1.currentAngle))
    
    // Ring 2
    Image("ring")
        .resizable()
        .scaledToFit()
        .scaleEffect(0.85)
        .rotationEffect(.degrees(ring2.currentAngle))
    
    // ... Ring 3, 4, 5
    
    // Red marker at 12 o'clock (top layer, static)
    Rectangle()
        .fill(.red)
        .frame(width: 4, height: 30)
        .offset(y: -ringRadius)
}
```

**Key Benefits:**
- No complex geometry calculations
- Single PNG rotates as a whole
- All 12 runes visible on each ring
- No overlapping issues (proper scaling ensures visibility)
- High performance (simple 2D transforms)

**Spin Button:**
- Enabled: bright, pulsing glow
- Disabled during spin: dimmed
- Shows cooldown if needed

**Energy Bar:**
- Fills left-to-right
- Shows current level progress
- Animates on energy gain

**Win Overlay:**
- Semi-transparent popup on match
- Shows matched symbols + energy gained
- Auto-dismisses after 1.5s

---

### 4. UPGRADES SCREEN (Backgrounds Shop)

**Layout:**
- Top: "Upgrades" title
- Top-left: Back button
- Center: Horizontal scrollable row of 4 background cards

**Background Card:**
- Preview image of background
- Background number/name
- Status button:
  - **Selected:** "Selected" (green)
  - **Unlocked:** "Select" (blue) 
  - **Locked:** "Locked" + lock icon (gray)

**Interaction:**
- Tap unlocked background → Set as active, update button to "Selected"
- Selected background persists in UserDefaults
- Locked backgrounds show unlock requirement tooltip

---

### 5. ACHIEVEMENTS SCREEN

**Layout:**
- Top: "Achievements" title
- Top-left: Back button
- Top-right: Energy display
- Center: 5 achievement cards (vertical list or grid)

**Achievement Card:**
- Icon (circular)
- Title (bold)
- Description text
- Status indicator:
  - **Completed:** "Collected" (gold badge)
  - **Incomplete:** Progress text (e.g. "3/20 levels")

**5 Achievements:**
1. First Spark (ach_First_Spark@2x.png) - Complete level 1
2. Eruption Master (ach_Eruption_Master@2x.png) - Unlock first artifact
3. Core Igniter (ach_Core_Igniter@2x.png) - Unlock all backgrounds
4. Titan Awakened (ach_Titan_Awakened@2x.png) - Unlock all artifacts
5. Collector of Ashes (ach_Collector_Ashes@2x.png) - Complete all levels

---

### 6. ARTIFACTS SCREEN

**Layout:**
- Top: "Artifacts" title
- Top-left: Back button
- Top-right: Energy display + bar
- Center: 2×5 grid of artifact cards

**Artifact Card:**
- Square card with artifact image
- Artifact name below
- Tap → Show lore overlay

**Lore Overlay (ZStack):**
- Semi-transparent black background
- Centered modal with:
  - Large artifact image
  - Artifact name
  - Legend text (2-3 sentences)
  - Close button (X)

**Artifacts (10 total):**
1. Ember Heart (art_Ember_Hearts@2x.png)
2. Mask of the Molten King (art_Mask_Molten_King@2x.png)
3. Crystal of Eternal Flame (art_Crystal_Eternal_Flame@2x.png)
4. Ashen Feather (art_Ashen_Feather@2x.png)
5. Stone of Whispers (art_Stone_Whispers@2x.png)
6. Core Fragment (art_Core_Fragment@2x.png)
7. Rune of Flow (art_Rune_Flow@2x.png)
8. Molten Skull (art_Molten_Skull@2x.png)
9. Tear of Magma (art_Tear_Magma@2x.png)
10. Titan's Fang (art_Titan_Fang@2x.png)

**Unlock State:**
- Unlocked: full color, tappable
- Grayscale: locked, shows lock + energy requirement

---

### 7. SETTINGS SCREEN

**Layout:**
- Top: "Settings" title
- Top-left: Back button
- Center: Settings options in card

**Options:**
1. **Sounds:** Toggle (on/off icon)
2. **Music:** Toggle (on/off icon)
3. **Reset Progress:** Button (red) → Shows confirmation alert

**Reset Progress Alert:**
- Title: "Reset Progress?"
- Message: "This will delete all progress. Continue?"
- Buttons: "Cancel" | "Reset" (destructive)
- On confirm: Clear UserDefaults, restart app state

---

## UI COMPONENTS (Reusable)

### Standard Components (Template Style)
All UI uses standard SwiftUI views for easy styling later:

1. **PrimaryButton:** Rounded rectangle button with text
2. **CircleButton:** Circular button (level select, artifacts)
3. **EnergyBar:** Custom progress bar with gradient
4. **BackButton:** Consistent back navigation button
5. **CardView:** Rounded container for content sections
6. **ToggleRow:** Setting row with label + toggle

**Styling Approach:**
- Use basic shapes (Rectangle, Circle, Capsule)
- Simple colors (can be replaced with theme later)
- Standard fonts (can be customized)
- No complex custom drawings (developer will add assets)

---

## ANIMATION GUIDELINES

### Standard Animations
- Button press: Scale 0.95 + haptic feedback
- Screen transitions: Slide left/right
- Energy bar fill: Spring animation
- Ring rotation: Interpolating spring (defined above)
- Unlock celebrations: Scale + fade + particles (optional)

### Spring Parameters (Consistent)
```swift
.animation(.interpolatingSpring(
    stiffness: 50,
    damping: 10
), value: ...)
```

---

## TECHNICAL NOTES

### Performance Considerations
- Use `GeometryReader` minimally
- Lazy loading for grids where applicable
- Ring rendering is extremely efficient (5 PNG images with rotation transforms)
- Cache ring image in memory (single asset reused 5 times)
- Debounce rapid button taps during spin animation

### Testing Strategy
- Unit tests for GameLogic (match detection, energy calc)
- Unit tests for progression formulas
- UI tests for critical flows (spin, unlock, navigation)
- Test UserDefaults persistence

### Future Extensibility
- Easy to add new levels (just increase array)
- Easy to add new artifacts (expand model)
- Background system supports more images
- Achievement system is data-driven

### Implementation Benefits (PNG-based approach)
- **Simplicity:** Single PNG image, no complex rendering logic
- **Performance:** Extremely fast (5 images with 2D transforms)
- **Maintainability:** Easy to update visuals (just replace PNG)
- **Predictability:** Simple rotation math, no edge cases
- **Artist-friendly:** Complete visual control over ring appearance

---

**END OF PRD**
