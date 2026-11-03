import Foundation
import AVFoundation
import UIKit
import Combine

enum GameSoundEffect: String, CaseIterable {
    case passKick
    case powerShot
    case curveWhip
    case ballTrap
    case postHit
    case whistle
    case goalCheer
    case crowdReaction
    case menuClick
    case starEarned
    case levelComplete
    case levelFail
}

final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    @Published var sfxEnabled: Bool {
        didSet { UserDefaults.standard.set(sfxEnabled, forKey: "soccer_sfx_enabled") }
    }
    @Published var crowdEnabled: Bool {
        didSet {
            UserDefaults.standard.set(crowdEnabled, forKey: "soccer_crowd_enabled")
            updateCrowdLoopState()
        }
    }
    @Published var hapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: "soccer_haptics_enabled") }
    }
    @Published var sfxVolume: Float {
        didSet { UserDefaults.standard.set(sfxVolume, forKey: "soccer_sfx_volume") }
    }

    private var soundDataCache: [GameSoundEffect: Data] = [:]
    private var activePlayers: [AVAudioPlayer] = []
    private var crowdLoopPlayer: AVAudioPlayer?
    private var isMatchActive: Bool = false

    private init() {
        let defaults = UserDefaults.standard
        self.sfxEnabled = defaults.object(forKey: "soccer_sfx_enabled") as? Bool ?? true
        self.crowdEnabled = defaults.object(forKey: "soccer_crowd_enabled") as? Bool ?? true
        self.hapticsEnabled = defaults.object(forKey: "soccer_haptics_enabled") as? Bool ?? true
        self.sfxVolume = defaults.object(forKey: "soccer_sfx_volume") as? Float ?? 0.85

        configureAudioSession()
        synthesizeAllSoundEffects()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Audio session fallback
        }
    }

    // MARK: - Public Playback API

    func play(_ effect: GameSoundEffect, volumeScale: Float = 1.0) {
        triggerHaptic(for: effect)

        if effect == .goalCheer || effect == .crowdReaction {
            guard crowdEnabled else { return }
        } else {
            guard sfxEnabled else { return }
        }

        guard let data = soundDataCache[effect] else { return }
        do {
            let player = try AVAudioPlayer(data: data)
            player.volume = min(1.0, max(0.05, sfxVolume * volumeScale))
            player.prepareToPlay()
            player.play()
            activePlayers.removeAll { !$0.isPlaying }
            activePlayers.append(player)
        } catch {
            // Ignore playback failure on restricted device states
        }
    }

    func startStadiumAmbience() {
        isMatchActive = true
        updateCrowdLoopState()
    }

    func stopStadiumAmbience() {
        isMatchActive = false
        crowdLoopPlayer?.stop()
    }

    private func updateCrowdLoopState() {
        guard isMatchActive && crowdEnabled else {
            crowdLoopPlayer?.stop()
            return
        }
        if crowdLoopPlayer == nil {
            let data = generateCrowdAmbienceWav(duration: 3.6)
            crowdLoopPlayer = try? AVAudioPlayer(data: data)
            crowdLoopPlayer?.numberOfLoops = -1
        }
        crowdLoopPlayer?.volume = 0.16 * sfxVolume
        if crowdLoopPlayer?.isPlaying == false {
            crowdLoopPlayer?.play()
        }
    }

    // MARK: - Haptic Feedback (iPhone 11 Taptic Engine)

    func triggerHaptic(for effect: GameSoundEffect) {
        guard hapticsEnabled else { return }
        switch effect {
        case .passKick:
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred()
        case .powerShot:
            let gen = UIImpactFeedbackGenerator(style: .heavy)
            gen.impactOccurred()
        case .ballTrap, .menuClick:
            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.impactOccurred()
        case .postHit:
            let gen = UIImpactFeedbackGenerator(style: .rigid)
            gen.impactOccurred(intensity: 1.0)
        case .goalCheer, .levelComplete:
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)
        case .crowdReaction:
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.warning)
        case .levelFail:
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.error)
        case .starEarned:
            let gen = UIImpactFeedbackGenerator(style: .soft)
            gen.impactOccurred(intensity: 0.85)
        case .whistle, .curveWhip:
            break
        }
    }

    func triggerAimTickHaptic() {
        guard hapticsEnabled else { return }
        let gen = UISelectionFeedbackGenerator()
        gen.selectionChanged()
    }

    // MARK: - Procedural PCM WAV Synthesizer

    private func synthesizeAllSoundEffects() {
        let sampleRate = 22050

        // 1. Pass Kick (Clean leather thud)
        soundDataCache[.passKick] = buildWav(sampleRate: sampleRate, duration: 0.16) { t in
            let freq = 145.0 * exp(-t * 22.0) + 42.0
            let body = sin(2.0 * .pi * freq * t) * exp(-t * 19.0)
            let leatherSnap = (Double.random(in: -1...1)) * exp(-t * 65.0) * 0.35
            return (body * 0.85 + leatherSnap)
        }

        // 2. Power Shot (Deep stadium cannon boom + air whoosh)
        soundDataCache[.powerShot] = buildWav(sampleRate: sampleRate, duration: 0.28) { t in
            let freq = 185.0 * exp(-t * 18.0) + 38.0
            let punch = sin(2.0 * .pi * freq * t) * exp(-t * 13.0)
            let sub = sin(2.0 * .pi * 52.0 * t) * exp(-t * 11.0) * 0.5
            let whoosh = (Double.random(in: -1...1)) * exp(-t * 16.0) * 0.28
            return min(1.0, max(-1.0, punch * 0.8 + sub + whoosh))
        }

        // 3. Curve Whip (Aerodynamic spin swish)
        soundDataCache[.curveWhip] = buildWav(sampleRate: sampleRate, duration: 0.24) { t in
            let env = sin(.pi * (t / 0.24))
            let sweep = sin(2.0 * .pi * (320.0 + 480.0 * t) * t) * 0.35
            let air = Double.random(in: -1...1) * 0.25
            return (sweep + air) * env * 0.6
        }

        // 4. Ball Trap (Soft boot cushion control)
        soundDataCache[.ballTrap] = buildWav(sampleRate: sampleRate, duration: 0.10) { t in
            let freq = 110.0 * exp(-t * 28.0) + 45.0
            return sin(2.0 * .pi * freq * t) * exp(-t * 32.0) * 0.65
        }

        // 5. Goalpost / Crossbar Metallic Clang
        soundDataCache[.postHit] = buildWav(sampleRate: sampleRate, duration: 0.45) { t in
            let m1 = sin(2.0 * .pi * 465.0 * t) * exp(-t * 9.0)
            let m2 = sin(2.0 * .pi * 738.0 * t) * exp(-t * 13.0) * 0.65
            let m3 = sin(2.0 * .pi * 1185.0 * t) * exp(-t * 18.0) * 0.45
            let thud = sin(2.0 * .pi * 95.0 * t) * exp(-t * 25.0) * 0.5
            return (m1 + m2 + m3 + thud) * 0.55
        }

        // 6. Referee Pea Whistle
        soundDataCache[.whistle] = buildWav(sampleRate: sampleRate, duration: 0.38) { t in
            let env = t < 0.03 ? (t / 0.03) : (t > 0.30 ? max(0, (0.38 - t) / 0.08) : 1.0)
            let peaMod = 0.68 + 0.32 * sin(2.0 * .pi * 32.0 * t)
            let tone = sin(2.0 * .pi * 2840.0 * t) * 0.6 + sin(2.0 * .pi * 2975.0 * t) * 0.3
            let breath = Double.random(in: -1...1) * 0.12
            return (tone * peaMod + breath) * env * 0.48
        }

        // 7. Goal Cheer + Stadium Horn Celebration
        soundDataCache[.goalCheer] = buildWav(sampleRate: sampleRate, duration: 1.45) { t in
            let attack = min(1.0, t / 0.12)
            let decay = t > 0.95 ? max(0.0, (1.45 - t) / 0.50) : 1.0
            let env = attack * decay

            // Triumphant stadium brass chord (C4, E4, G4, C5)
            let c4 = sin(2.0 * .pi * 261.63 * t)
            let e4 = sin(2.0 * .pi * 329.63 * t)
            let g4 = sin(2.0 * .pi * 392.00 * t)
            let c5 = sin(2.0 * .pi * 523.25 * t)
            let horn = (c4 + e4 * 0.8 + g4 * 0.8 + c5 * 0.9) * 0.16

            // Crowd roar texture
            let roarMod = 0.7 + 0.3 * sin(2.0 * .pi * 6.5 * t)
            let crowd = Double.random(in: -1...1) * 0.34 * roarMod
            return (horn + crowd) * env
        }

        // 8. Crowd "Ooh!" Reaction (Close miss or save)
        soundDataCache[.crowdReaction] = buildWav(sampleRate: sampleRate, duration: 0.65) { t in
            let env = sin(.pi * (t / 0.65))
            let voice = sin(2.0 * .pi * (240.0 - 70.0 * t) * t) * 0.22
            let murmur = Double.random(in: -1...1) * 0.25
            return (voice + murmur) * env * 0.65
        }

        // 9. Menu Click
        soundDataCache[.menuClick] = buildWav(sampleRate: sampleRate, duration: 0.055) { t in
            let tone = sin(2.0 * .pi * 880.0 * t) * exp(-t * 55.0)
            let pop = sin(2.0 * .pi * 1760.0 * t) * exp(-t * 85.0) * 0.4
            return (tone + pop) * 0.55
        }

        // 10. Star Earned Chime
        soundDataCache[.starEarned] = buildWav(sampleRate: sampleRate, duration: 0.34) { t in
            let freq: Double = t < 0.11 ? 659.25 : (t < 0.22 ? 830.61 : 987.77)
            let localT = t.truncatingRemainder(dividingBy: 0.11)
            let env = exp(-localT * 10.0)
            let bell = sin(2.0 * .pi * freq * t) + 0.35 * sin(4.0 * .pi * freq * t)
            return bell * env * 0.42
        }

        // 11. Level Complete Fanfare
        soundDataCache[.levelComplete] = buildWav(sampleRate: sampleRate, duration: 0.95) { t in
            let noteFreq: Double
            if t < 0.16 { noteFreq = 523.25 }      // C5
            else if t < 0.32 { noteFreq = 659.25 } // E5
            else if t < 0.48 { noteFreq = 783.99 } // G5
            else { noteFreq = 1046.50 }            // C6
            let decay = t > 0.48 ? exp(-(t - 0.48) * 3.8) : 0.9
            let sig = sin(2.0 * .pi * noteFreq * t) + 0.4 * sin(2.0 * .pi * (noteFreq * 0.5) * t)
            return sig * decay * 0.42
        }

        // 12. Level Fail / Error Tone
        soundDataCache[.levelFail] = buildWav(sampleRate: sampleRate, duration: 0.42) { t in
            let noteFreq: Double = t < 0.18 ? 330.0 : 246.94 // E4 -> B3 descending
            let localT = t < 0.18 ? t : (t - 0.18)
            let env = exp(-localT * 8.5)
            let sig = sin(2.0 * .pi * noteFreq * t) + 0.35 * sin(2.0 * .pi * (noteFreq * 0.5) * t)
            return sig * env * 0.45
        }
    }

    private func generateCrowdAmbienceWav(duration: Double) -> Data {
        let sampleRate = 11025
        var lowPassState = 0.0
        return buildWav(sampleRate: sampleRate, duration: duration) { t in
            let rawNoise = Double.random(in: -1...1)
            lowPassState = lowPassState * 0.92 + rawNoise * 0.08
            // Smooth loop crossfade at start/end
            let fadeIn = min(1.0, t / 0.25)
            let fadeOut = min(1.0, (duration - t) / 0.25)
            let swell = 0.8 + 0.2 * sin(2.0 * .pi * (t / duration))
            return lowPassState * 1.8 * fadeIn * fadeOut * swell
        }
    }

    private func buildWav(sampleRate: Int, duration: Double, generator: (Double) -> Double) -> Data {
        let numSamples = max(1, Int(Double(sampleRate) * duration))
        let bytesPerSample = 2
        let dataSize = numSamples * bytesPerSample
        let fileSize = 36 + dataSize

        var data = Data(capacity: 44 + dataSize)

        // RIFF Header
        data.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
        data.append(contentsOf: uint32LE(UInt32(fileSize)))
        data.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // "WAVE"

        // fmt chunk
        data.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // "fmt "
        data.append(contentsOf: uint32LE(16))                         // Subchunk1Size (16 for PCM)
        data.append(contentsOf: uint16LE(1))                          // AudioFormat = 1 (PCM)
        data.append(contentsOf: uint16LE(1))                          // NumChannels = 1 (Mono)
        data.append(contentsOf: uint32LE(UInt32(sampleRate)))         // SampleRate
        data.append(contentsOf: uint32LE(UInt32(sampleRate * bytesPerSample))) // ByteRate
        data.append(contentsOf: uint16LE(UInt16(bytesPerSample)))     // BlockAlign
        data.append(contentsOf: uint16LE(16))                         // BitsPerSample = 16

        // data chunk
        data.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // "data"
        data.append(contentsOf: uint32LE(UInt32(dataSize)))

        let invRate = 1.0 / Double(sampleRate)
        for i in 0..<numSamples {
            let t = Double(i) * invRate
            let sample = max(-1.0, min(1.0, generator(t)))
            let intSample = Int16(sample * 32000.0)
            data.append(contentsOf: int16LE(intSample))
        }

        return data
    }

    private func uint32LE(_ value: UInt32) -> [UInt8] {
        [
            UInt8(value & 0xFF),
            UInt8((value >> 8) & 0xFF),
            UInt8((value >> 16) & 0xFF),
            UInt8((value >> 24) & 0xFF)
        ]
    }

    private func uint16LE(_ value: UInt16) -> [UInt8] {
        [
            UInt8(value & 0xFF),
            UInt8((value >> 8) & 0xFF)
        ]
    }

    private func int16LE(_ value: Int16) -> [UInt8] {
        let u = UInt16(bitPattern: value)
        return uint16LE(u)
    }
}
