import Foundation
import SwiftUI

// MARK: - 2D & 3D Vector Math

struct Vec2: Codable, Equatable {
    var x: Double
    var y: Double

    static let zero = Vec2(x: 0, y: 0)

    func length() -> Double {
        sqrt(x * x + y * y)
    }

    func normalized() -> Vec2 {
        let len = length()
        guard len > 1e-6 else { return .zero }
        return Vec2(x: x / len, y: y / len)
    }

    func distance(to other: Vec2) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        return sqrt(dx * dx + dy * dy)
    }

    func dot(_ other: Vec2) -> Double {
        x * other.x + y * other.y
    }

    static func + (lhs: Vec2, rhs: Vec2) -> Vec2 {
        Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: Vec2, rhs: Vec2) -> Vec2 {
        Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (lhs: Vec2, rhs: Double) -> Vec2 {
        Vec2(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static prefix func - (v: Vec2) -> Vec2 {
        Vec2(x: -v.x, y: -v.y)
    }

    func lerp(to target: Vec2, t: Double) -> Vec2 {
        Vec2(x: x + (target.x - x) * t, y: y + (target.y - y) * t)
    }
}

struct Vec3: Codable, Equatable {
    var x: Double
    var y: Double
    var z: Double

    static let zero = Vec3(x: 0, y: 0, z: 0)

    var xy: Vec2 {
        Vec2(x: x, y: y)
    }

    func length() -> Double {
        sqrt(x * x + y * y + z * z)
    }

    func distance(to other: Vec3) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        let dz = z - other.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }

    static func + (lhs: Vec3, rhs: Vec3) -> Vec3 {
        Vec3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    static func - (lhs: Vec3, rhs: Vec3) -> Vec3 {
        Vec3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }

    static func * (lhs: Vec3, rhs: Double) -> Vec3 {
        Vec3(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }

    static prefix func - (v: Vec3) -> Vec3 {
        Vec3(x: -v.x, y: -v.y, z: -v.z)
    }
}

// MARK: - Pitch Geometry Constants

enum PitchConstants {
    static let halfWidth: Double = 32.0          // x in [-32, +32]
    static let minY: Double = -4.0               // Slightly behind midfield line
    static let goalLineY: Double = 52.0          // Goal line Y coordinate
    static let netBackY: Double = 56.2           // Back of the goal net
    static let goalHalfWidth: Double = 7.4       // Goalposts at x = -7.4 and +7.4
    static let crossbarHeight: Double = 4.8      // Crossbar at z = 4.8
    static let postRadius: Double = 0.28         // Post cylinder radius
    static let penaltyBoxMinY: Double = 35.5
    static let penaltyBoxHalfWidth: Double = 19.5
    static let sixYardMinY: Double = 46.5
    static let sixYardHalfWidth: Double = 9.4
    static let penaltySpotY: Double = 41.0
    static let ballRadius: Double = 0.48
}

// MARK: - Navigation & Game Modes

enum AppScreen: Equatable {
    case mainMenu
    case levelSelect
    case careerHub
    case settings
    case tutorial
    case matchPlay(levelId: Int)
}

enum DifficultyLevel: String, CaseIterable, Codable, Identifiable {
    case rookie = "Anfänger"
    case pro = "Profi"
    case legend = "Weltklasse"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .rookie:
            return "Größeres Zeitfenster beim Passen, moderates Torwart-Reaktionstempo."
        case .pro:
            return "Authentisches Soccer Super Star Spielgefühl mit kluger Raumdeckung."
        case .legend:
            return "Schnelles Pressing, reflexstarke Torhüter und präzise Flugbahnen nötig."
        }
    }

    var defenderSpeedMultiplier: Double {
        switch self {
        case .rookie: return 0.82
        case .pro: return 1.0
        case .legend: return 1.20
        }
    }

    var keeperReactionMultiplier: Double {
        switch self {
        case .rookie: return 0.80
        case .pro: return 1.0
        case .legend: return 1.22
        }
    }

    var coinBonusMultiplier: Double {
        switch self {
        case .rookie: return 1.0
        case .pro: return 1.25
        case .legend: return 1.6
        }
    }
}

enum ScenarioType: String, Codable, CaseIterable {
    case finishing = "Torschuss"
    case throughBall = "Steilpass"
    case freeKick = "Freistoß"
    case counterAttack = "Konter"
    case tikiTaka = "Tiki-Taka"
    case championshipFinal = "Finale"

    var iconName: String {
        switch self {
        case .finishing: return "flame.fill"
        case .throughBall: return "arrow.triangle.turn.up.right.diamond.fill"
        case .freeKick: return "wind"
        case .counterAttack: return "bolt.fill"
        case .tikiTaka: return "point.3.connected.trianglepath.dotted"
        case .championshipFinal: return "trophy.fill"
        }
    }

    var badgeColor: Color {
        switch self {
        case .finishing: return Color(red: 1.0, green: 0.38, blue: 0.22)
        case .throughBall: return Color(red: 0.18, green: 0.78, blue: 0.98)
        case .freeKick: return Color(red: 0.68, green: 0.42, blue: 1.0)
        case .counterAttack: return Color(red: 1.0, green: 0.78, blue: 0.15)
        case .tikiTaka: return Color(red: 0.22, green: 0.90, blue: 0.52)
        case .championshipFinal: return Color(red: 1.0, green: 0.84, blue: 0.0)
        }
    }
}

// MARK: - Players & AI Roles

enum TeamSide: String, Codable {
    case home
    case away
}

enum PlayerRole: String, Codable {
    case ballCarrier      // Starts with the ball or currently controls it
    case striker          // Central forward looking for finishing space
    case winger           // Wide runner sprinting down the flank or cutting inside
    case midfielder       // Playmaker supporting passing triangles
    case defender         // Marks attackers or presses the ball carrier
    case wallDefender     // Stands in a free-kick wall and jumps on shot
    case sweeper          // Covers deep through-balls
    case goalkeeper       // Guards the goal mouth and dives in 3D
}

enum PlayerAnimState: String, Codable {
    case idle
    case running
    case sprinting
    case windingUp
    case kicking
    case sliding
    case jumpingWall
    case divingLeft
    case divingRight
    case divingHigh
    case celebrating
    case disappointed
}

struct PlayerSpawn: Codable, Identifiable {
    var id: String
    var name: String
    var shirtNumber: Int
    var side: TeamSide
    var role: PlayerRole
    var position: Vec2
    var runWaypoints: [Vec2]       // Tactical path the AI wants to run
    var speed: Double              // Base movement speed (units/sec)
    var reactionDelay: Double      // AI reaction delay (sec)
    var hairColorHex: UInt32
    var skinToneIndex: Int         // 0..3
}

struct FieldPlayer: Identifiable, Codable {
    var id: String
    var name: String
    var shirtNumber: Int
    var side: TeamSide
    var role: PlayerRole
    var position: Vec2
    var velocity: Vec2 = .zero
    var facingAngle: Double        // Radians; 0 = facing +Y (toward goal)
    var zHeight: Double = 0        // Jump / dive elevation above grass
    var runWaypoints: [Vec2]
    var currentWaypointIndex: Int = 0
    var baseSpeed: Double
    var reactionDelay: Double
    var reactionTimer: Double = 0
    var animState: PlayerAnimState = .idle
    var animPhase: Double = 0      // Continuous stride / animation cycle
    var stateTimer: Double = 0
    var hasBall: Bool = false
    var isOpenForPass: Bool = false
    var passCalloutText: String? = nil
    var diveTarget: Vec3? = nil
    var hairColorHex: UInt32
    var skinToneIndex: Int
    var tackleCooldown: Double = 0
}

// MARK: - Ball State & Trajectory

struct BallTrailPoint: Codable {
    var position: Vec3
    var timestamp: Double
    var spinIntensity: Double
}

struct BallState: Codable {
    var position: Vec3
    var velocity: Vec3
    var spinZ: Double = 0          // Side spin (Magnus curve left/right)
    var spinX: Double = 0          // Topspin / backspin
    var rotationAngle: Double = 0  // Visual roll rotation
    var rotationAxisAngle: Double = 0
    var isAirborne: Bool = false
    var lastTouchedBySide: TeamSide = .home
    var lastKickerId: String? = nil
    var trail: [BallTrailPoint] = []
}

struct TrajectoryPreviewPoint: Identifiable {
    let id: Int
    let position: Vec3
    let progress: Double // 0.0 ... 1.0
}

struct SwipeShotParameters {
    var startPitchPos: Vec2
    var targetPitchPos: Vec2
    var controlPitchPos: Vec2
    var launchVelocity: Vec3
    var spinZ: Double              // Curvature (rad/s)
    var spinX: Double              // Topspin
    var powerNormalized: Double    // 0.0 ... 1.0
    var curveNormalized: Double    // -1.0 (left bend) ... +1.0 (right bend)
    var loftNormalized: Double     // 0.0 ... 1.0
    var intendedReceiverId: String?
    var isShotOnGoal: Bool
    var previewPoints: [TrajectoryPreviewPoint]
}

// MARK: - Match Phase & Replay

enum PlayPhase: Equatable {
    case tacticalAiming            // Time slowed/paused while player draws pass or shot
    case ballInFlight              // Ball is moving; AI players sprint, intercept, or dive
    case teammateControlling       // Brief control touch before transitioning back to tacticalAiming
    case goalCelebration           // Goal scored! Players celebrate, confetti bursts, net ripples
    case instantReplay             // Slow-motion TV broadcast replay of the winning play
    case playFailed(reason: String)// Saved, intercepted, or out of bounds
    case levelComplete(stars: Int, coinsEarned: Int, hitStarTarget: Bool)
}

struct ReplayFrame {
    var timestamp: Double
    var ball: BallState
    var players: [FieldPlayer]
    var cameraCenter: Vec2
    var cameraZoom: Double
    var netImpactPos: Vec3?
    var netImpactStrength: Double
}

// MARK: - Level & Chapter Definitions

struct StarTargetZone: Codable {
    var x: Double                  // Goal line X coordinate (-6.8 ... +6.8)
    var z: Double                  // Height Z coordinate (0.8 ... 4.3)
    var radius: Double             // Target ring radius (e.g. 1.65)
}

struct LevelDefinition: Identifiable, Codable {
    var id: Int
    var chapterId: Int
    var levelNumberInChapter: Int
    var title: String
    var subtitle: String
    var matchMinute: String        // e.g. "89'"
    var scoreContext: String       // e.g. "1 : 1"
    var homeTeamName: String
    var awayTeamName: String
    var awayKitPrimaryHex: UInt32
    var awayKitSecondaryHex: UInt32
    var scenarioType: ScenarioType
    var tacticalHint: String
    var recommendedPasses: Int
    var parAttempts: Int
    var windSpeed: Double          // Lateral wind (-3.0 ... +3.0)
    var starTarget: StarTargetZone
    var ballStart: Vec2
    var players: [PlayerSpawn]
    var rewardCoins: Int
}

struct CareerChapter: Identifiable {
    var id: Int
    var title: String
    var leagueName: String
    var badgeIcon: String
    var themeColorHex: UInt32
    var requiredStarsToUnlock: Int
    var description: String
}

// MARK: - Customization & Progression

struct JerseyKit: Identifiable, Codable {
    var id: String
    var name: String
    var clubTitle: String
    var primaryHex: UInt32
    var secondaryHex: UInt32
    var shortsHex: UInt32
    var priceCoins: Int
}

struct BallDesign: Identifiable, Codable {
    var id: String
    var name: String
    var subtitle: String
    var panelColorHex: UInt32
    var accentColorHex: UInt32
    var trailColorHex: UInt32
    var priceCoins: Int
}

struct CareerStats: Codable {
    var totalGoals: Int = 0
    var totalAssists: Int = 0
    var totalPassesCompleted: Int = 0
    var curvedGoals: Int = 0
    var starTargetsHit: Int = 0
    var woodworkHits: Int = 0
    var firstTryWins: Int = 0
    var totalAttempts: Int = 0
    var currentStreak: Int = 0
    var bestStreak: Int = 0

    var careerTitle: String {
        switch totalGoals {
        case 0..<5: return "Jugend-Talent"
        case 5..<15: return "Nachwuchs-Star"
        case 15..<30: return "Stammspieler"
        case 30..<50: return "Spielführer & Kapitän"
        case 50..<80: return "Nationalspieler"
        default: return "Weltfußballer-Legende"
        }
    }
}

struct AchievementItem: Identifiable {
    var id: String
    var title: String
    var description: String
    var icon: String
    var isUnlocked: Bool
    var progressText: String
}

// MARK: - Visual Particles

struct PitchParticle: Identifiable {
    let id = UUID()
    var position: Vec3
    var velocity: Vec3
    var color: Color
    var size: Double
    var life: Double
    var maxLife: Double
}

// MARK: - Color Helper Extension

extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}
