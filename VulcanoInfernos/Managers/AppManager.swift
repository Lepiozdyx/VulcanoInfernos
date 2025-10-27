import SwiftUI
import Combine

class AppManager: ObservableObject {
    @Published var totalEnergy: Int = 0
    @Published var levels: [Level] = []
    @Published var backgrounds: [GameBackground] = []
    @Published var artifacts: [Artifact] = []
    @Published var achievements: [Achievement] = []
    @Published var selectedBackgroundId: Int = 1
    @Published var currentLevel: Int = 1
    
    private let userDefaults = UserDefaultsManager.shared
    
    init() {
        initializeGameData()
        loadState()
    }
    
    // MARK: - Initialize Game Data
    
    private func initializeGameData() {
        initializeLevels()
        initializeBackgrounds()
        initializeArtifacts()
        initializeAchievements()
    }
    
    private func initializeLevels() {
        let energyRequirements = [
            0, 100, 250, 500, 850, 1300, 2000, 3000, 4500, 6500,
            9000, 12500, 17000, 23000, 30000, 38000, 44000, 50000, 57000, 65000
        ]
        
        levels = (1...20).map { id in
            Level(
                id: id,
                energyRequired: energyRequirements[id - 1],
                isUnlocked: id == 1
            )
        }
    }
    
    private func initializeBackgrounds() {
        backgrounds = [
            GameBackground(id: 1, unlockLevel: 1, isUnlocked: true, imageName: "bg1"),
            GameBackground(id: 2, unlockLevel: 2, isUnlocked: false, imageName: "bg2"),
            GameBackground(id: 3, unlockLevel: 3, isUnlocked: false, imageName: "bg3"),
            GameBackground(id: 4, unlockLevel: 4, isUnlocked: false, imageName: "bg4")
        ]
    }
    
    private func initializeArtifacts() {
        let artifactData: [(name: String, legend: String, energy: Int, image: String)] = [
            ("Ember Heart", "Burns with eternal flames, granting warmth to all who seek it.", 100, "art_Ember_Hearts"),
            ("Mask of the Molten King", "Ancient relic of a forgotten ruler, carved from obsidian and magma.", 300, "art_Mask_Molten_King"),
            ("Crystal of Eternal Flame", "A precious gem that holds the essence of the volcano's heart.", 600, "art_Crystal_Eternal_Flame"),
            ("Ashen Feather", "Fallen from the skies during the great eruption, light yet unbreakable.", 1000, "art_Ashen_Feather"),
            ("Stone of Whispers", "Ancient stone that carries the voices of the volcano's past.", 1500, "art_Stone_Whispers"),
            ("Core Fragment", "A piece of the volcano's core, radiating immense power.", 2200, "art_Core_Fragment"),
            ("Rune of Flow", "Mystical rune that guides the flow of molten rivers.", 3000, "art_Rune_Flow"),
            ("Molten Skull", "Guardian of the deep, protecting the secrets of the earth.", 4000, "art_Molten_Skull"),
            ("Tear of Magma", "A crystallized tear from the volcano, precious beyond measure.", 5200, "art_Tear_Magma"),
            ("Titan's Fang", "The ultimate treasure, a fang from the titan of the volcano itself.", 6500, "art_Titan_Fang")
        ]
        
        artifacts = artifactData.enumerated().map { index, data in
            Artifact(
                id: index + 1,
                name: data.name,
                legend: data.legend,
                energyRequired: data.energy,
                isUnlocked: false,
                imageName: data.image
            )
        }
    }
    
    private func initializeAchievements() {
        achievements = [
            Achievement(
                id: 1,
                title: "First Spark",
                description: "Unlock Level 2 (100 energy)",
                isCompleted: false,
                iconName: "ach_First_Spark"
            ),
            Achievement(
                id: 2,
                title: "Eruption Master",
                description: "Unlock first artifact (1,000 energy)",
                isCompleted: false,
                iconName: "ach_Eruption_Master"
            ),
            Achievement(
                id: 3,
                title: "Core Igniter",
                description: "Unlock all backgrounds (Level 4)",
                isCompleted: false,
                iconName: "ach_Core_Igniter"
            ),
            Achievement(
                id: 4,
                title: "Titan Awakened",
                description: "Unlock all artifacts (65,000 energy)",
                isCompleted: false,
                iconName: "ach_Titan_Awakened"
            ),
            Achievement(
                id: 5,
                title: "Collector of Ashes",
                description: "Unlock all 20 levels (65,000 energy)",
                isCompleted: false,
                iconName: "ach_Collector_Ashes"
            )
        ]
    }
    
    // MARK: - Game Logic Methods
    
    func addEnergy(_ amount: Int) {
        totalEnergy += amount
        checkUnlocks()
        checkAchievements()
        saveState()
    }
    
    func checkUnlocks() {
        for i in 0..<levels.count {
            if totalEnergy >= levels[i].energyRequired && !levels[i].isUnlocked {
                levels[i].isUnlocked = true
            }
        }
        
        for i in 0..<backgrounds.count {
            if levels.count >= backgrounds[i].unlockLevel,
               levels[backgrounds[i].unlockLevel - 1].isUnlocked,
               !backgrounds[i].isUnlocked {
                backgrounds[i].isUnlocked = true
            }
        }
        
        for i in 0..<artifacts.count {
            if totalEnergy >= artifacts[i].energyRequired && !artifacts[i].isUnlocked {
                artifacts[i].isUnlocked = true
            }
        }
    }
    
    func checkAchievements() {
        // First Spark: Unlock Level 2 (100 energy)
        if totalEnergy >= 100 && !achievements[0].isCompleted {
            achievements[0].isCompleted = true
        }
        
        // Eruption Master: Unlock first artifact
        if artifacts.count > 0 && artifacts[0].isUnlocked && !achievements[1].isCompleted {
            achievements[1].isCompleted = true
        }
        
        // Core Igniter: Unlock all backgrounds
        if backgrounds.allSatisfy({ $0.isUnlocked }) && !achievements[2].isCompleted {
            achievements[2].isCompleted = true
        }
        
        // Titan Awakened: Unlock all artifacts
        if artifacts.allSatisfy({ $0.isUnlocked }) && !achievements[3].isCompleted {
            achievements[3].isCompleted = true
        }
        
        // Collector of Ashes: Unlock all 20 levels
        if levels.allSatisfy({ $0.isUnlocked }) && !achievements[4].isCompleted {
            achievements[4].isCompleted = true
        }
    }
    
    func selectBackground(_ id: Int) {
        if backgrounds.first(where: { $0.id == id && $0.isUnlocked }) != nil {
            selectedBackgroundId = id
            saveState()
        }
    }
    
    func setCurrentLevel(_ id: Int) {
        if levels.first(where: { $0.id == id && $0.isUnlocked }) != nil {
            currentLevel = id
            saveState()
        }
    }
    
    func resetProgress() {
        userDefaults.resetAll()
        totalEnergy = 0
        selectedBackgroundId = 1
        currentLevel = 1
        initializeGameData()
    }
    
    // MARK: - Persistence
    
    func saveState() {
        userDefaults.setTotalEnergy(totalEnergy)
        userDefaults.setUnlockedLevels(levels.filter { $0.isUnlocked }.map { $0.id })
        userDefaults.setCurrentLevel(currentLevel)
        userDefaults.setSelectedBackgroundId(selectedBackgroundId)
        userDefaults.setUnlockedArtifacts(artifacts.filter { $0.isUnlocked }.map { $0.id })
        userDefaults.setCompletedAchievements(achievements.filter { $0.isCompleted }.map { $0.id })
    }
    
    private func loadState() {
        totalEnergy = userDefaults.getTotalEnergy()
        currentLevel = userDefaults.getCurrentLevel()
        selectedBackgroundId = userDefaults.getSelectedBackgroundId()
        
        let unlockedLevelIds = userDefaults.getUnlockedLevels()
        for i in 0..<levels.count {
            if unlockedLevelIds.contains(levels[i].id) {
                levels[i].isUnlocked = true
            }
        }
        
        let unlockedArtifactIds = userDefaults.getUnlockedArtifacts()
        for i in 0..<artifacts.count {
            if unlockedArtifactIds.contains(artifacts[i].id) {
                artifacts[i].isUnlocked = true
            }
        }
        
        let completedAchievementIds = userDefaults.getCompletedAchievements()
        for i in 0..<achievements.count {
            if completedAchievementIds.contains(achievements[i].id) {
                achievements[i].isCompleted = true
            }
        }
        
        for i in 0..<backgrounds.count {
            let levelAtIndex = backgrounds[i].unlockLevel - 1
            if levelAtIndex >= 0 && levelAtIndex < levels.count && levels[levelAtIndex].isUnlocked {
                backgrounds[i].isUnlocked = true
            }
        }
    }
}

