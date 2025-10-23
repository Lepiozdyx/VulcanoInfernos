import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let totalEnergy = "totalEnergy"
        static let unlockedLevels = "unlockedLevels"
        static let currentLevel = "currentLevel"
        static let selectedBackgroundId = "selectedBackgroundId"
        static let unlockedArtifacts = "unlockedArtifacts"
        static let completedAchievements = "completedAchievements"
        static let soundEnabled = "soundEnabled"
        static let musicEnabled = "musicEnabled"
    }
    
    // MARK: - Total Energy
    func getTotalEnergy() -> Int {
        defaults.integer(forKey: Keys.totalEnergy)
    }
    
    func setTotalEnergy(_ value: Int) {
        defaults.set(value, forKey: Keys.totalEnergy)
    }
    
    // MARK: - Unlocked Levels
    func getUnlockedLevels() -> [Int] {
        defaults.array(forKey: Keys.unlockedLevels) as? [Int] ?? [1]
    }
    
    func setUnlockedLevels(_ value: [Int]) {
        defaults.set(value, forKey: Keys.unlockedLevels)
    }
    
    // MARK: - Current Level
    func getCurrentLevel() -> Int {
        let level = defaults.integer(forKey: Keys.currentLevel)
        return level == 0 ? 1 : level
    }
    
    func setCurrentLevel(_ value: Int) {
        defaults.set(value, forKey: Keys.currentLevel)
    }
    
    // MARK: - Selected Background
    func getSelectedBackgroundId() -> Int {
        let id = defaults.integer(forKey: Keys.selectedBackgroundId)
        return id == 0 ? 1 : id
    }
    
    func setSelectedBackgroundId(_ value: Int) {
        defaults.set(value, forKey: Keys.selectedBackgroundId)
    }
    
    // MARK: - Unlocked Artifacts
    func getUnlockedArtifacts() -> [Int] {
        defaults.array(forKey: Keys.unlockedArtifacts) as? [Int] ?? []
    }
    
    func setUnlockedArtifacts(_ value: [Int]) {
        defaults.set(value, forKey: Keys.unlockedArtifacts)
    }
    
    // MARK: - Completed Achievements
    func getCompletedAchievements() -> [Int] {
        defaults.array(forKey: Keys.completedAchievements) as? [Int] ?? []
    }
    
    func setCompletedAchievements(_ value: [Int]) {
        defaults.set(value, forKey: Keys.completedAchievements)
    }
    
    // MARK: - Sound Enabled
    func isSoundEnabled() -> Bool {
        let value = defaults.value(forKey: Keys.soundEnabled)
        return value as? Bool ?? true
    }
    
    func setSoundEnabled(_ value: Bool) {
        defaults.set(value, forKey: Keys.soundEnabled)
    }
    
    // MARK: - Music Enabled
    func isMusicEnabled() -> Bool {
        let value = defaults.value(forKey: Keys.musicEnabled)
        return value as? Bool ?? true
    }
    
    func setMusicEnabled(_ value: Bool) {
        defaults.set(value, forKey: Keys.musicEnabled)
    }
    
    // MARK: - Reset All
    func resetAll() {
        if let bundleId = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleId)
        }
    }
}
