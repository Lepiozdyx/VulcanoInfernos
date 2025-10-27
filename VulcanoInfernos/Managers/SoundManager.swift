import SwiftUI
import Combine
import AVFoundation

@MainActor
class SoundManager: ObservableObject {
    
    static let shared = SoundManager()
    
    @Published var isSoundOn: Bool {
        didSet {
            defaults.set(isSoundOn, forKey: soundKey)
            
            if !isSoundOn && isMusicOn {
                isMusicOn = false
            }
        }
    }
    
    @Published var isMusicOn: Bool {
        didSet {
            defaults.set(isMusicOn, forKey: musicKey)
            
            if isMusicOn {
                if isSoundOn {
                    playMusic()
                } else {
                    isMusicOn = false
                }
            } else {
                stopMusic()
            }
        }
    }
    
    private let defaults = UserDefaults.standard
    private var audioPlayer: AVAudioPlayer?
    private var soundPlayer: AVAudioPlayer?
    private var movingStonePlayer: AVAudioPlayer?
    private var winSoundPlayer: AVAudioPlayer?
    
    private let soundKey = "appsound"
    private let musicKey = "appmusic"
    
    private let buttonSoundName = "click"
    private let musicName = "music"
    private let movingStoneSoundName = "movingstone"
    private let winSoundName = "win"
    
    private init() {
        self.isSoundOn = true
        self.isMusicOn = true
        
        if defaults.object(forKey: soundKey) != nil {
            self.isSoundOn = defaults.bool(forKey: soundKey)
        } else {
            defaults.set(true, forKey: soundKey)
        }
        
        if defaults.object(forKey: musicKey) != nil {
            self.isMusicOn = defaults.bool(forKey: musicKey)
        } else {
            defaults.set(true, forKey: musicKey)
        }
        
        setupAudio()
        fetchMusic()
        fetchSound()
        fetchMovingStoneSound()
        fetchWinSound()
    }
    
    func toggleSound() {
        isSoundOn.toggle()
    }
    
    func toggleMusic() {
        if !isSoundOn && !isMusicOn {
            return
        }
        isMusicOn.toggle()
    }
    
    func play() {
        guard isSoundOn, let player = soundPlayer else { return }
        player.currentTime = 0
        player.play()
    }
    
    func playMovingStoneSound() {
        guard isSoundOn, let player = movingStonePlayer else { return }
        player.currentTime = 0
        player.play()
    }
    
    func playWinSound() {
        guard isSoundOn, let player = winSoundPlayer else { return }
        player.currentTime = 0
        player.play()
    }
    
    func playMusic() {
        guard isSoundOn, isMusicOn, let player = audioPlayer, !player.isPlaying else { return }
        player.play()
    }
    
    func stopMusic() {
        audioPlayer?.pause()
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    private func fetchSound() {
        guard let url = Bundle.main.url(
            forResource: buttonSoundName,
            withExtension: "mp3"
        ) else { return }
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func fetchMusic() {
        guard let url = Bundle.main.url(
            forResource: musicName,
            withExtension: "mp3"
        ) else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func fetchMovingStoneSound() {
        guard let url = Bundle.main.url(
            forResource: movingStoneSoundName,
            withExtension: "wav"
        ) else { return }
        
        do {
            movingStonePlayer = try AVAudioPlayer(contentsOf: url)
            movingStonePlayer?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func fetchWinSound() {
        guard let url = Bundle.main.url(
            forResource: winSoundName,
            withExtension: "wav"
        ) else { return }
        
        do {
            winSoundPlayer = try AVAudioPlayer(contentsOf: url)
            winSoundPlayer?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
}
