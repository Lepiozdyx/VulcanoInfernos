# DEVELOPMENT STAGES - Vulcano Infernos

## STAGE 1: Project Setup & Core Architecture
**Goal:** Initialize project structure, coordinator pattern, and basic managers

- [x] Setup folder structure:
  - [x] Models/
  - [x] Managers/
  - [x] ViewModels/
  - [x] Views/
  - [x] Extensions/
  - [x] Utilities/
- [x] Create `AppCoordinator.swift` with `AppScreen` enum
- [x] Implement `AppCoordinator` class with `@Published var currentScreen`
- [x] Create `AppManager.swift` (ObservableObject) for global state
- [x] Setup `UserDefaultsManager.swift` for persistence
- [x] Create main `ContentView.swift` with coordinator integration

---

## STAGE 2: Data Models
**Goal:** Implement all data structures

- [x] Create `Ring.swift` model:
  - [x] id: Int
  - [x] scale: CGFloat
  - [x] currentAngle: Double
  - [x] runeSequence: [Int] (fixed array [0,1,2...11])
  - [x] minRotation, maxRotation, animationDuration
  - [x] rotationDirection: Int (1 or -1)
- [x] Create `Level.swift` model:
  - [x] id: Int (1-20)
  - [x] energyRequired: Int
  - [x] isUnlocked: Bool
- [x] Create `GameBackground.swift` model:
  - [x] id: Int (1-4)
  - [x] unlockLevel: Int
  - [x] isUnlocked: Bool
  - [x] imageName: String
- [x] Create `Artifact.swift` model:
  - [x] id: Int
  - [x] name: String
  - [x] legend: String
  - [x] energyRequired: Int
  - [x] isUnlocked: Bool
  - [x] imageName: String
- [x] Create `Achievement.swift` model:
  - [x] id: Int
  - [x] title: String
  - [x] description: String
  - [x] isCompleted: Bool
  - [x] iconName: String
- [x] Test: Verify all models conform to Identifiable

---

## STAGE 3: AppManager & Game Data
**Goal:** Setup global state management and initial game data

- [x] In `AppManager.swift` add @Published properties:
  - [x] totalEnergy: Int = 0
  - [x] levels: [Level]
  - [x] backgrounds: [GameBackground]
  - [x] artifacts: [Artifact]
  - [x] achievements: [Achievement]
  - [x] selectedBackgroundId: Int = 1
  - [x] currentLevel: Int = 1
- [x] Create `init()` method to initialize game data:
  - [x] Generate 20 levels with energy requirements (exponential)
  - [x] Create 4 backgrounds with unlock levels
  - [x] Create 10 artifacts with energy milestones
  - [x] Create 5 achievements
- [x] Implement methods:
  - [x] `addEnergy(_ amount: Int)`
  - [x] `checkUnlocks()` - update unlocked levels/backgrounds/artifacts
  - [x] `checkAchievements()` - update achievement completion
  - [x] `selectBackground(_ id: Int)`
  - [x] `resetProgress()`
- [x] Implement UserDefaults persistence:
  - [x] `saveState()` method
  - [x] `loadState()` method in init
- [ ] Test: Verify state persists across app restarts

---

## STAGE 4: GameLogic Manager
**Goal:** Implement ring rotation logic and match detection

- [x] Create `GameLogic.swift` class
- [x] Define fixed rune sequence:
  - [x] `let runeSequence = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]`
  - [x] Document which rune ID corresponds to each position on PNG
- [x] Implement `initializeRings() -> [Ring]`:
  - [x] Create 5 rings with scales (1.0, 0.85, 0.7, 0.55, 0.4)
  - [x] Assign rotation parameters per ring
  - [x] Set rotation directions (odd: +1, even: -1)
  - [x] Assign random initial angles (0-359°)
  - [x] All rings share same runeSequence
- [x] Implement `getRuneAtTop(ring: Ring) -> Int`:
  - [x] Normalize angle to 0-360
  - [x] Calculate segment index at 12 o'clock position
  - [x] Return rune ID from runeSequence
- [x] Implement `detectMatches(rings: [Ring]) -> Int`:
  - [x] Get rune ID at 12 o'clock for each ring
  - [x] Count consecutive matches from Ring 1
  - [x] Return match count (0-5)
- [x] Implement `calculateEnergy(matchCount: Int) -> Int`:
  - [x] 0-1 rings: 0 energy
  - [x] 2 rings: +10
  - [x] 3 rings: +50
  - [x] 4 rings: +150
  - [x] 5 rings: +500
- [ ] Test: Verify match detection with mock ring data

---

## STAGE 5: Reusable UI Components
**Goal:** Create standard UI components for consistent styling

- [x] Create `PrimaryButton.swift`:
  - [x] Capsule shape with text
  - [x] Action closure
  - [x] Scale animation on press
- [x] Create `CircleButton.swift`:
  - [x] Circle shape with content
  - [x] Disabled state styling
  - [x] Action closure
- [x] Create `BackButton.swift`:
  - [x] Circle with back icon
  - [x] Positioned top-left
  - [x] Action closure
- [x] Create `EnergyBar.swift`:
  - [x] Horizontal progress bar
  - [x] Current/max energy parameters
  - [x] Gradient fill with animation
- [x] Create `CardView.swift`:
  - [x] RoundedRectangle container
  - [x] Shadow and padding
  - [x] Generic content
- [x] Create `ToggleRow.swift`:
  - [x] HStack with label and Toggle
  - [x] Binding parameter
- [x] Test: Preview each component in Xcode

---

## STAGE 6: Main Menu Screen
**Goal:** Build main menu with navigation to all sections

- [x] Create `MainMenuView.swift`
- [x] Add @EnvironmentObject for AppCoordinator
- [x] Layout VStack with 5 PrimaryButtons:
  - [x] "Start Eruption" → .levelSelect
  - [x] "Upgrades" → .upgrades
  - [x] "Achievements" → .achievements
  - [x] "Artifacts" → .artifacts
  - [x] "Settings" → .settings
- [x] Add background placeholder (Color or Image)
- [x] Add `.onAppear` to initialize background music (placeholder)
- [x] Test: Verify all navigation buttons work

---

## STAGE 7: Level Select Screen
**Goal:** Build level grid with unlock logic

- [x] Create `LevelSelectView.swift`
- [x] Add @EnvironmentObject for AppManager and AppCoordinator
- [x] Add BackButton → .mainMenu
- [x] Add energy display (top-right):
  - [x] Energy icon + total energy Text
  - [x] EnergyBar showing progress to next level
- [x] Create LazyVGrid (5 columns x 4 rows):
  - [x] CircleButton for each level (1-20)
  - [x] Show level number if unlocked
  - [x] Show lock icon if locked
  - [x] Disabled state for locked levels
- [x] Implement tap actions:
  - [x] Unlocked → navigate to .game(levelId)
  - [x] Locked → shake animation + message
- [x] Create ViewExtensions.swift with shake modifier
- [x] Test: Verify only Level 1 is unlocked initially

---

## STAGE 8: Game Screen - UI Layout
**Goal:** Build game screen structure without rotation logic

- [x] Create `GameView.swift`
- [x] Add @EnvironmentObject for AppManager
- [x] Add @State for rings: [Ring]
- [x] Add @State for isSpinning: Bool
- [x] Add BackButton (top-left) → back to level select
- [x] Add energy display (top-right):
  - [x] Session energy counter
  - [x] Total energy counter
- [x] Add center ZStack for rings area:
  - [x] Placeholder circles for 5 rings
  - [x] Red marker line at 12 o'clock
- [x] Add "SPIN" button (bottom-center):
  - [x] Large PrimaryButton
  - [x] Disabled during spin
- [x] Add background from selectedBackgroundId
- [x] Initialize rings via GameLogic.initializeRings()
- [x] Test: Verify layout renders correctly

---

## STAGE 9: Game Screen - Ring Rendering
**Goal:** Render rings using PNG image with rotation

- [x] Add `ring.png` asset to project (or use placeholder)
- [x] Create `RingView.swift` component:
  - [x] Input: Ring model
  - [x] Use `Image("ring")` with `.resizable()` and `.scaledToFit()`
  - [x] Apply `.scaleEffect(ring.scale)`
  - [x] Apply `.rotationEffect(.degrees(ring.currentAngle))`
- [x] In `GameView.swift`:
  - [x] Replace placeholder circles with RingView
  - [x] ZStack with 5 RingViews (largest to smallest)
  - [x] Pass each ring from rings array
- [x] Add red marker overlay:
  - [x] Rectangle or Image at 12 o'clock position
  - [x] Layer above all rings (last in ZStack)
  - [x] Static (does not rotate)
- [x] Test: Verify all 5 rings render at correct sizes
- [x] Test: Verify rings don't overlap (all runes visible)

---

## STAGE 10: Game Screen - Rotation Animation
**Goal:** Implement spin button logic and ring rotation

- [x] In `GameView.swift` implement `spinRings()` method:
  - [x] Set `isSpinning = true`
  - [x] For each ring:
    - [x] Calculate random rotation angle (min...max)
    - [x] Apply direction multiplier (ring.rotationDirection)
    - [x] Apply animation with spring and duration
    - [x] Update `ring.currentAngle += randomAngle * direction`
  - [x] Wait for longest animation to complete (~2.2s)
  - [x] Call match detection
  - [x] Set `isSpinning = false`
- [x] Use `withAnimation(.interpolatingSpring(stiffness: 50, damping: 10))`
- [x] Implement different durations per ring (1.2s - 2.0s)
- [x] Connect "SPIN" button to `spinRings()` method
- [x] Disable button when `isSpinning == true`
- [x] Test: Verify rings rotate in alternating directions
- [x] Test: Verify smooth animations with different speeds

---

## STAGE 11: Game Screen - Match Detection & Energy
**Goal:** Detect matches and award energy

- [x] After rotation completes in `spinRings()`:
  - [x] Call `GameLogic.detectMatches(rings: rings)`
  - [x] Call `GameLogic.calculateEnergy(matchCount: matchCount)`
  - [x] Call `appManager.addEnergy(earnedEnergy)`
- [x] Create win overlay (ZStack):
  - [x] Semi-transparent background
  - [x] Show "+X energy" text
  - [x] Show matched rune icons
  - [x] Auto-dismiss after 1.5s
- [x] Show overlay only if matchCount >= 2
- [x] Animate energy bar fill
- [x] Test: Verify energy increases and unlocks update

---

## STAGE 12: Upgrades Screen
**Goal:** Build background shop with selection

- [x] Create `UpgradesView.swift`
- [x] Add @EnvironmentObject for AppManager
- [x] Add BackButton → .mainMenu
- [x] Add title "Upgrades"
- [x] Create HStack:
  - [x] ForEach backgrounds
  - [x] CardView for each background:
    - [x] Preview image
    - [x] Background name/number
    - [x] Status button:
      - [x] "Selected" (green) if selected
      - [x] "Select" (blue) if unlocked
      - [x] "Locked" (gray) if locked
- [x] Implement tap action:
  - [x] If unlocked → call `appManager.selectBackground(id)`

---

## STAGE 13: Achievements Screen
**Goal:** Display achievement list with progress

- [ ] Create `AchievementsView.swift`
- [ ] Add @EnvironmentObject for AppManager
- [ ] Add BackButton → .mainMenu
- [ ] Add title "Achievements"
- [ ] Add energy display (top-right)
- [ ] Create HStack:
  - [ ] ForEach achievements
  - [ ] CardView for each:
    - [ ] Icon (Circle with SF Symbol placeholder)
    - [ ] Title (bold)
    - [ ] Description
    - [ ] Status: "Collected" or progress text

---

## STAGE 14: Artifacts Screen
**Goal:** Build artifact gallery with lore overlay

- [ ] Create `ArtifactsView.swift`
- [ ] Add @EnvironmentObject for AppManager
- [ ] Add BackButton → .mainMenu
- [ ] Add title "Artifacts"
- [ ] Add energy display + bar (top-right)
- [ ] Create LazyVGrid (5 columns x 2 rows):
  - [ ] ForEach artifacts
  - [ ] CardView for each:
    - [ ] Artifact image (placeholder)
    - [ ] Artifact name below
    - [ ] Grayscale if locked
    - [ ] Lock icon if locked
- [ ] Add @State for selectedArtifact: Artifact?
- [ ] Implement tap action → set selectedArtifact
- [ ] Create overlay ZStack:
  - [ ] Semi-transparent black background
  - [ ] Modal CardView with:
    - [ ] Large artifact image
    - [ ] Artifact name
    - [ ] Legend text
    - [ ] Add tap to close action
- [ ] Show overlay when selectedArtifact != nil

---

## STAGE 15: Settings Screen
**Goal:** Build settings with sound/music toggles and reset

- [ ] Create `SettingsView.swift`
- [ ] Add @EnvironmentObject for AppManager
- [ ] Add BackButton → .mainMenu
- [ ] Add title "Settings"
- [ ] Add @State for soundEnabled: Bool
- [ ] Add @State for musicEnabled: Bool
- [ ] Create CardView with:
  - [ ] ToggleRow "Sounds" → soundEnabled
  - [ ] ToggleRow "Music" → musicEnabled
  - [ ] "Reset Progress" button with confirmation
- [ ] Add @State for showResetAlert: Bool
- [ ] Implement alert:
  - [ ] Title: "Reset Progress?"
  - [ ] Message: "This will delete all progress. Continue?"
  - [ ] Buttons: "Cancel" | "Reset" (destructive)
- [ ] On confirm → call `appManager.resetProgress()`
- [ ] Test: Verify reset clears all progress

---

## STAGE 16: Audio System
**Goal:** Implement background music and sound effects

- [ ] Create `AudioManager.swift` (ObservableObject)
- [ ] Add @Published properties:
  - [ ] isMusicEnabled: Bool
  - [ ] isSoundEnabled: Bool
- [ ] Add AVAudioPlayer properties:
  - [ ] backgroundMusicPlayer
  - [ ] soundEffectPlayer
- [ ] Implement methods:
  - [ ] `playBackgroundMusic()` - loops indefinitely
  - [ ] `stopBackgroundMusic()`
  - [ ] `playSound(_ name: String)` - plays once
- [ ] Add placeholder audio files to project:
  - [ ] background_music.mp3
  - [ ] button_click.wav
  - [ ] spin_sound.wav
  - [ ] win_sound.wav
  - [ ] miss_sound.wav
- [ ] Integrate with AppManager:
  - [ ] Pass AudioManager as @EnvironmentObject
- [ ] Add lifecycle observers:
  - [ ] Pause music on `.scenePhase(.background)`
  - [ ] Resume music on `.scenePhase(.active)`
- [ ] Connect Settings toggles to AudioManager
- [ ] Add button sounds to all buttons
- [ ] Add spin sound in `spinRings()`
- [ ] Add win sounds based on match count

---

## STAGE 17: Polish & Animations
**Goal:** Add final touches and smooth animations

- [ ] Add haptic feedback:
  - [ ] Button taps
  - [ ] Spin complete
  - [ ] Win matches
- [ ] Fine-tune animation timings:
  - [ ] Button scale animations
  - [ ] Screen transitions
  - [ ] Energy bar fill speed

---

## STAGE 18: Testing & Bug Fixes
**Goal:** Comprehensive testing and issue resolution

- [ ] Test energy system:
  - [ ] Verify correct energy awards for matches
  - [ ] Verify level unlocks at correct thresholds
  - [ ] Verify artifact unlocks at correct energy
  - [ ] Verify background unlocks at correct levels
- [ ] Test persistence:
  - [ ] Force quit app and relaunch
  - [ ] Verify all progress restores
  - [ ] Verify selected background persists
- [ ] Test achievement tracking:
  - [ ] Manually trigger each achievement
  - [ ] Verify completion states
- [ ] Test edge cases:
  - [ ] Rapid button tapping
  - [ ] Rotation during background
  - [ ] Reset progress flow
- [ ] Performance testing:
  - [ ] Check for memory leaks
  - [ ] Verify smooth 60fps animations
  - [ ] Profile with Instruments
- [ ] Code review:
  - [ ] Remove unused code
  - [ ] Add critical comments
  - [ ] Verify naming conventions

---

## COMPLETION CHECKLIST

### Core Features
- [ ] All 5 screens implemented and functional
- [ ] Navigation flow works correctly
- [ ] Ring rotation mechanic works smoothly
- [ ] Match detection is accurate
- [ ] Energy system awards correctly
- [ ] All unlocks trigger at correct thresholds

### Data Persistence
- [ ] All progress saves to UserDefaults
- [ ] Progress restores on app restart
- [ ] Reset progress works correctly

### Audio
- [ ] Background music plays and loops
- [ ] All sound effects play correctly
- [ ] Settings toggles control audio
- [ ] Music pauses/resumes with app lifecycle

### Polish
- [ ] All animations are smooth
- [ ] No crashes or major bugs
- [ ] Code is clean

---

**END OF STAGES**
