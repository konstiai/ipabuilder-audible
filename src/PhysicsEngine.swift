import Foundation
import SwiftUI
import Combine

final class PhysicsEngine: ObservableObject {
    // MARK: - Published Match State
    @Published var level: LevelDefinition
    @Published var phase: PlayPhase = .tacticalAiming
    @Published var players: [FieldPlayer] = []
    @Published var ball: BallState
    @Published var particles: [PitchParticle] = []

    // Swipe & Aiming State
    @Published var isDraggingSwipe: Bool = false
    @Published var touchPoints: [CGPoint] = []
    @Published var fadingSwipePoints: [CGPoint] = []
    @Published var fadingSwipeAlpha: Double = 0.0
    @Published var currentShotParams: SwipeShotParameters? = nil
    private var swipeStartTime: Double = 0.0

    // Camera State
    @Published var cameraCenter: Vec2 = Vec2(x: 0, y: 30)
    @Published var cameraZoom: Double = 1.0
    @Published var screenShakeOffset: CGSize = .zero

    // Net Ripple State
    @Published var netImpactPos: Vec3? = nil
    @Published var netImpactStrength: Double = 0.0

    // Match Progress Counters
    @Published var passesInCurrentPlay: Int = 0
    @Published var attemptsInLevel: Int = 1
    @Published var lastShotWasCurved: Bool = false
    @Published var hitStarTargetInPlay: Bool = false
    @Published var matchClockSeconds: Double = 0.0
    @Published var statusBannerText: String? = nil

    // Instant Replay State
    @Published var replayFrames: [ReplayFrame] = []
    @Published var replayCursor: Int = 0
    @Published var isPlayingReplay: Bool = false

    // Dependencies & Internal Timers
    private weak var store: GameStore?
    private var phaseTimer: Double = 0.0
    private var flightDuration: Double = 0.0
    private var controlTargetPlayerId: String? = nil
    private var shakeIntensity: Double = 0.0
    private var replayAccumulator: Double = 0.0
    private var frameRecordCounter: Int = 0
    private var pendingFailReason: String? = nil
    private var failAnimTimer: Double = 0.0

    init(level: LevelDefinition, store: GameStore? = nil) {
        self.level = level
        self.store = store
        self.ball = BallState(position: Vec3(x: level.ballStart.x, y: level.ballStart.y, z: 0), velocity: .zero)
        setupPlay(resetAttempts: true)
    }

    func bindStore(_ store: GameStore) {
        self.store = store
    }

    func loadLevel(_ newLevel: LevelDefinition) {
        self.level = newLevel
        setupPlay(resetAttempts: true)
    }

    // MARK: - Setup & Reset Play

    func setupPlay(resetAttempts: Bool) {
        if resetAttempts {
            attemptsInLevel = 1
        }
        phase = .tacticalAiming
        passesInCurrentPlay = 0
        lastShotWasCurved = false
        hitStarTargetInPlay = false
        flightDuration = 0.0
        phaseTimer = 0.0
        isDraggingSwipe = false
        touchPoints = []
        fadingSwipePoints = []
        fadingSwipeAlpha = 0.0
        currentShotParams = nil
        netImpactPos = nil
        netImpactStrength = 0.0
        particles = []
        replayFrames = []
        isPlayingReplay = false
        pendingFailReason = nil
        failAnimTimer = 0.0
        statusBannerText = level.subtitle

        // Spawn ball
        ball = BallState(
            position: Vec3(x: level.ballStart.x, y: level.ballStart.y, z: 0.0),
            velocity: .zero,
            spinZ: 0,
            spinX: 0,
            rotationAngle: 0,
            rotationAxisAngle: 0,
            isAirborne: false,
            lastTouchedBySide: .home,
            lastKickerId: nil,
            trail: []
        )

        // Spawn players
        players = level.players.map { spawn in
            let isCarrier = (spawn.role == .ballCarrier)
            let defaultFacing: Double = (spawn.side == .home) ? 0.0 : .pi
            var callout: String? = nil
            if spawn.side == .home && !isCarrier {
                callout = (spawn.role == .winger) ? "FLÜGEL!" : "HIER!"
            }
            return FieldPlayer(
                id: spawn.id,
                name: spawn.name,
                shirtNumber: spawn.shirtNumber,
                side: spawn.side,
                role: spawn.role,
                position: spawn.position,
                velocity: .zero,
                facingAngle: defaultFacing,
                zHeight: 0,
                runWaypoints: spawn.runWaypoints,
                currentWaypointIndex: 0,
                baseSpeed: spawn.speed,
                reactionDelay: spawn.reactionDelay,
                reactionTimer: 0,
                animState: .idle,
                animPhase: Double.random(in: 0...6.28),
                stateTimer: 0,
                hasBall: isCarrier,
                isOpenForPass: spawn.side == .home && !isCarrier,
                passCalloutText: callout,
                diveTarget: nil,
                hairColorHex: spawn.hairColorHex,
                skinToneIndex: spawn.skinToneIndex,
                tackleCooldown: 0
            )
        }

        // Focus camera on ball carrier and goal context
        let startCenterY = min(40.0, max(16.0, level.ballStart.y + 9.5))
        cameraCenter = Vec2(x: level.ballStart.x * 0.45, y: startCenterY)
        cameraZoom = level.ballStart.y < 18.0 ? 0.92 : 1.02

        SoundManager.shared.play(.whistle, volumeScale: 0.65)
    }

    func retryCurrentLevel() {
        attemptsInLevel += 1
        setupPlay(resetAttempts: false)
    }

    // MARK: - 2.5D Perspective Projection Math

    func perspectiveScale(atY y: Double) -> Double {
        let clampedY = max(-8.0, min(60.0, y))
        // Near midfield (y=0) is larger; near goal (y=52) foreshortens naturally
        let normalizedDepth = (clampedY - cameraCenter.y) / 48.0
        return max(0.54, min(1.38, 1.0 - normalizedDepth * 0.34)) * cameraZoom
    }

    func project(_ world: Vec3, in size: CGSize) -> CGPoint {
        let w = Double(size.width)
        let h = Double(size.height)
        let baseScale = min(w / 44.0, h / 66.0) * cameraZoom

        let relY = world.y - cameraCenter.y
        let depthFactor = max(0.52, min(1.42, 1.0 - (relY / 82.0)))

        let screenX = w * 0.5 + (world.x - cameraCenter.x * 0.75) * baseScale * depthFactor
        // Screen Y: cameraCenter.y maps around 60% down the screen so the goal at top is always visible
        let anchorScreenY = h * 0.60
        let perspectiveY = relY * baseScale * 0.86 * (1.0 - relY * 0.0028)
        let elevationOffset = world.z * baseScale * depthFactor * 1.18

        let screenY = anchorScreenY - perspectiveY - elevationOffset
        return CGPoint(x: screenX, y: screenY)
    }

    func unprojectScreenDelta(from startScreen: CGPoint, to currentScreen: CGPoint, in size: CGSize) -> Vec2 {
        let w = Double(size.width)
        let h = Double(size.height)
        let baseScale = max(1.0, min(w / 44.0, h / 66.0) * cameraZoom)

        let dxScreen = Double(currentScreen.x - startScreen.x)
        let dyScreen = Double(startScreen.y - currentScreen.y) // Upward swipe = +Y on pitch

        let pitchDX = (dxScreen / baseScale) * 1.35
        let pitchDY = (dyScreen / (baseScale * 0.82)) * 1.38
        return Vec2(x: pitchDX, y: pitchDY)
    }

    // MARK: - Touch Swipe / Flick & Curve Control System

    func beginSwipe(at point: CGPoint, in size: CGSize) {
        guard phase == .tacticalAiming else { return }
        isDraggingSwipe = true
        swipeStartTime = Date().timeIntervalSinceReferenceDate
        touchPoints = [point]
        fadingSwipePoints = []
        fadingSwipeAlpha = 0.0
        currentShotParams = nil

        if let idx = players.firstIndex(where: { $0.hasBall }) {
            players[idx].animState = .windingUp
        }
    }

    func updateSwipe(at point: CGPoint, in size: CGSize) {
        guard phase == .tacticalAiming, isDraggingSwipe else { return }

        if let last = touchPoints.last {
            let dist = hypot(point.x - last.x, point.y - last.y)
            if dist > 3.0 {
                touchPoints.append(point)
            }
        } else {
            touchPoints.append(point)
        }

        currentShotParams = computeFlickShotParameters(endPoint: point, predictedEnd: point, in: size)
    }

    func endSwipe(at finalPoint: CGPoint, predictedEnd: CGPoint, in size: CGSize) {
        guard phase == .tacticalAiming, isDraggingSwipe else { return }
        isDraggingSwipe = false

        if let last = touchPoints.last, hypot(finalPoint.x - last.x, finalPoint.y - last.y) > 1.5 {
            touchPoints.append(finalPoint)
        }

        let params = computeFlickShotParameters(endPoint: finalPoint, predictedEnd: predictedEnd, in: size) ?? currentShotParams

        guard let validParams = params else {
            touchPoints = []
            currentShotParams = nil
            if let idx = players.firstIndex(where: { $0.hasBall }) {
                players[idx].animState = .idle
            }
            return
        }

        // Keep swipe trail visible on screen to fade out smoothly after flicking
        fadingSwipePoints = touchPoints
        fadingSwipeAlpha = 1.0

        executeKick(with: validParams)
        touchPoints = []
        currentShotParams = nil
    }

    private func computeFlickShotParameters(endPoint: CGPoint, predictedEnd: CGPoint, in size: CGSize) -> SwipeShotParameters? {
        guard let firstPoint = touchPoints.first else { return nil }

        let directScreenDrag = hypot(Double(endPoint.x - firstPoint.x), Double(endPoint.y - firstPoint.y))
        guard directScreenDrag >= 10.0 else {
            return nil
        }

        // Normalize power purely from drawn line length on screen / pitch distance:
        // Short line = slow, delicate shot / pass.
        // Long line = powerful cannon shot / long ball.
        // 15 pt (short drag) -> 0.05 powerNorm
        // 220 pt (long drag across screen) -> 1.0 powerNorm
        let distFactor = max(0.0, min(1.0, (directScreenDrag - 15.0) / 205.0))
        let powerNorm = max(0.05, min(1.0, distFactor))

        let startPitch = ball.position.xy
        // Always use the exact endPoint of the drawn line so the shot matches the drawn line 1:1
        let rawDelta = unprojectScreenDelta(from: firstPoint, to: endPoint, in: size)
        guard rawDelta.length() > 0.4 else { return nil }

        // Measure finger swipe curvature in pitch-space coordinates (+X right, +Y toward goal)
        // strokeRightUnit points to the RIGHT of the chord (firstPoint -> endPoint)
        let chordDir = rawDelta.normalized()
        let strokeRightUnit = Vec2(x: chordDir.y, y: -chordDir.x)

        var maxSignedRightMeters: Double = 0.0
        for pt in touchPoints {
            let relPitch = unprojectScreenDelta(from: firstPoint, to: pt, in: size)
            let rightDist = relPitch.dot(strokeRightUnit)
            if abs(rightDist) > abs(maxSignedRightMeters) {
                maxSignedRightMeters = rightDist
            }
        }

        // Bulge ratio relative to the drawn line length
        let drawnLengthMeters = max(3.5, rawDelta.length())
        let bulgeRatio = max(-0.42, min(0.42, maxSignedRightMeters / drawnLengthMeters))
        let rawCurveNorm = max(-1.0, min(1.0, bulgeRatio / 0.28))

        let swipeDir = chordDir

        // 1. Check if the swipe points toward an open teammate (or their forward run waypoint)
        var lockedTeammateId: String? = nil
        var bestTeammateScore: Double = 0.85 // Minimum cosine similarity (~31° cone)
        var teammateTargetPos: Vec2 = startPitch

        for mate in players where mate.side == .home && !mate.hasBall {
            let runPos = mate.runWaypoints.first ?? mate.position
            for candidatePos in [runPos, mate.position] {
                let toMate = candidatePos - startPitch
                let distToMate = toMate.length()
                guard distToMate > 2.5 else { continue }
                let cosAngle = swipeDir.dot(toMate.normalized())
                if cosAngle > bestTeammateScore {
                    bestTeammateScore = cosAngle
                    lockedTeammateId = mate.id
                    teammateTargetPos = candidatePos
                }
            }
        }

        // 2. Ray-project forward swipes to the Goal Line (y = 52.0) or directly to where the drawn line ends
        var isGoalShot = false
        var finalTarget: Vec2

        let dyToGoal = max(2.0, PitchConstants.goalLineY - startPitch.y)
        let goalCenterScreen = project(Vec3(x: 0, y: PitchConstants.goalLineY, z: 0), in: size)
        let goalRightPostScreen = project(Vec3(x: PitchConstants.goalHalfWidth, y: PitchConstants.goalLineY, z: 0), in: size)
        let pixelsPerGoalMeterX = max(4.0, Double(goalRightPostScreen.x - goalCenterScreen.x) / PitchConstants.goalHalfWidth)

        // If the user draws the line all the way up near the goal on screen, map endPoint.x directly to the goal line
        let directGoalX = Double(endPoint.x - goalCenterScreen.x) / pixelsPerGoalMeterX
        let rayGoalX = swipeDir.y > 0.18 ? (startPitch.x + (swipeDir.x / swipeDir.y) * dyToGoal) : (startPitch.x + swipeDir.x * 25.0)
        let distFromGoalScreenY = max(0.0, Double(endPoint.y - goalCenterScreen.y))
        let directWeight = max(0.0, min(1.0, 1.0 - (distFromGoalScreenY - 25.0) / 120.0))
        let projectedGoalX = directGoalX * directWeight + rayGoalX * (1.0 - directWeight)

        let aimedAtGoalMouth = (swipeDir.y > 0.25 && abs(projectedGoalX) <= PitchConstants.goalHalfWidth + 6.5)

        if let _ = lockedTeammateId, (!aimedAtGoalMouth || bestTeammateScore > 0.94) {
            // Swipe is a Pass / Through-Ball to the teammate along the swipe ray
            isGoalShot = false
            finalTarget = teammateTargetPos
        } else if swipeDir.y > 0.22 {
            // Swipe is a Shot on Goal (or forward drive toward goal line)
            isGoalShot = true
            let clampedGoalX = max(-PitchConstants.halfWidth + 2.0, min(PitchConstants.halfWidth - 2.0, projectedGoalX))
            finalTarget = Vec2(x: clampedGoalX, y: PitchConstants.goalLineY + 0.6)
            lockedTeammateId = nil
        } else {
            // Sideways / diagonal pass into space
            isGoalShot = false
            let passDist = 10.0 + powerNorm * 16.0
            finalTarget = Vec2(
                x: max(-PitchConstants.halfWidth + 1.5, min(PitchConstants.halfWidth - 1.5, startPitch.x + swipeDir.x * passDist)),
                y: max(PitchConstants.minY + 2.0, min(PitchConstants.goalLineY - 1.0, startPitch.y + swipeDir.y * passDist))
            )
        }

        let effectiveSwipeVec = finalTarget - startPitch
        let effectiveDist = max(2.5, effectiveSwipeVec.length())
        let dirUnit = effectiveSwipeVec.normalized()
        // rightUnit points to the RIGHT of the shot direction (+X when shooting toward the goal)
        let rightUnit = Vec2(x: dirUnit.y, y: -dirUnit.x)

        // Calculate flight speed & height (loftZ) from swipe power
        let horizontalSpeed: Double
        let loftZ: Double
        if isGoalShot {
            // Short line = gentle roller / chip (8.0 m/s), Long line = thunderous shot (31.5 m/s)
            horizontalSpeed = 8.0 + powerNorm * 23.5
            let desiredGoalZ = min(PitchConstants.crossbarHeight - 0.38, max(0.40, 0.30 + powerNorm * 3.70))
            let estTime = max(0.32, effectiveDist / horizontalSpeed)
            let g = 14.8
            loftZ = max(1.2, min(9.6, (desiredGoalZ + 0.5 * g * estTime * estTime) / estTime))
        } else {
            // Short pass (6.5 m/s) to hard driven pass (25.0 m/s)
            horizontalSpeed = 6.5 + powerNorm * 18.5
            loftZ = effectiveDist > 18.0 ? (1.5 + powerNorm * 3.0) : (0.20 + powerNorm * 1.10)
        }

        let estFlightTime = max(0.26, effectiveDist / horizontalSpeed)

        // Scale the user's drawn bulge onto the full shot distance so the ball follows the exact curve of the drawn line!
        // Positive desiredBulgeRightMeters = ball bulges to the RIGHT first, then curves LEFT into finalTarget (spinZ > 0)
        // Negative desiredBulgeRightMeters = ball bulges to the LEFT first, then curves RIGHT into finalTarget (spinZ < 0)
        let desiredBulgeRightMeters = max(-8.0, min(8.0, bulgeRatio * effectiveDist * 1.15))
        let requiredMagnusAccel = (8.0 * desiredBulgeRightMeters) / max(0.12, estFlightTime * estFlightTime)
        let speedScale = min(1.4, horizontalSpeed / 16.0)
        let spinZ = max(-18.5, min(18.5, requiredMagnusAccel / max(0.6, 1.42 * speedScale)))

        // Initial velocity offset so the ball launches along the drawn curve and bends back into finalTarget
        let initialRightOffsetVel = (4.0 * desiredBulgeRightMeters) / estFlightTime
        let dragCompensation = 1.0 + 0.13 * estFlightTime
        var vx = ((effectiveSwipeVec.x / estFlightTime) + rightUnit.x * initialRightOffsetVel) * dragCompensation
        var vy = ((effectiveSwipeVec.y / estFlightTime) + rightUnit.y * initialRightOffsetVel) * dragCompensation

        // Two-pass exact trajectory solver so the curved 3D path always lands precisely on finalTarget
        for _ in 0..<2 {
            var simPos = ball.position
            var simVel = Vec3(x: vx, y: vy, z: loftZ)
            var simSpin = spinZ
            let steps = 20
            let stepDt = estFlightTime / Double(steps)
            for _ in 0..<steps {
                stepBallPhysics(pos: &simPos, vel: &simVel, spinZ: &simSpin, dt: stepDt, isPreview: true)
            }
            let errX = finalTarget.x - simPos.x
            let errY = finalTarget.y - simPos.y
            vx += (errX / estFlightTime) * 0.92
            vy += (errY / estFlightTime) * 0.92
        }

        let launchVel = Vec3(x: vx, y: vy, z: loftZ)
        let loftNorm = max(0.0, min(1.0, loftZ / 9.2))
        let controlMid = (startPitch + finalTarget) * 0.5 + rightUnit * desiredBulgeRightMeters
        let preview = simulatePreviewPoints(startPos: ball.position, launchVel: launchVel, spinZ: spinZ, maxTime: min(1.45, estFlightTime * 1.08))

        if let idx = players.firstIndex(where: { $0.hasBall }) {
            players[idx].facingAngle = atan2(vx, max(0.1, vy))
        }

        return SwipeShotParameters(
            startPitchPos: startPitch,
            targetPitchPos: finalTarget,
            controlPitchPos: controlMid,
            launchVelocity: launchVel,
            spinZ: spinZ,
            spinX: isGoalShot ? 2.5 : 0.8,
            powerNormalized: powerNorm,
            curveNormalized: rawCurveNorm,
            loftNormalized: loftNorm,
            intendedReceiverId: lockedTeammateId,
            isShotOnGoal: isGoalShot,
            previewPoints: preview
        )
    }

    private func simulatePreviewPoints(startPos: Vec3, launchVel: Vec3, spinZ: Double, maxTime: Double) -> [TrajectoryPreviewPoint] {
        var pts: [TrajectoryPreviewPoint] = []
        var pos = startPos
        var vel = launchVel
        var curSpinZ = spinZ
        let steps = 26
        let dt = maxTime / Double(steps)

        for i in 0...steps {
            let progress = Double(i) / Double(steps)
            pts.append(TrajectoryPreviewPoint(id: i, position: pos, progress: progress))
            stepBallPhysics(pos: &pos, vel: &vel, spinZ: &curSpinZ, dt: dt, isPreview: true)
            if pos.y > PitchConstants.netBackY + 1.0 { break }
        }
        return pts
    }

    // MARK: - Kick Execution

    private func executeKick(with params: SwipeShotParameters) {
        // Record initial frame before kick
        recordReplayFrame()

        var kickerId: String? = nil
        if let idx = players.firstIndex(where: { $0.hasBall }) {
            kickerId = players[idx].id
            players[idx].hasBall = false
            players[idx].animState = .kicking
            players[idx].stateTimer = 0.32
            // Give the passer a forward support waypoint if they don't have one (for one-two wall passes!)
            if players[idx].runWaypoints.isEmpty {
                let forwardY = min(PitchConstants.goalLineY - 5.0, players[idx].position.y + 11.0)
                players[idx].runWaypoints = [Vec2(x: players[idx].position.x * 0.8, y: forwardY)]
                players[idx].currentWaypointIndex = 0
            }
        }

        ball.velocity = params.launchVelocity
        ball.spinZ = params.spinZ
        ball.spinX = params.spinX
        ball.isAirborne = params.launchVelocity.z > 1.2
        ball.lastTouchedBySide = .home
        ball.lastKickerId = kickerId

        if abs(params.curveNormalized) >= 0.26 {
            lastShotWasCurved = true
        }

        // Spawn grass kick particles
        spawnKickParticles(at: ball.position, power: params.powerNormalized)

        // Play kick audio
        if params.powerNormalized > 0.62 || params.isShotOnGoal {
            SoundManager.shared.play(.powerShot, volumeScale: Float(0.75 + 0.25 * params.powerNormalized))
        } else {
            SoundManager.shared.play(.passKick, volumeScale: Float(0.7 + 0.3 * params.powerNormalized))
        }
        if abs(params.curveNormalized) > 0.35 {
            SoundManager.shared.play(.curveWhip, volumeScale: 0.7)
        }

        // Trigger Wall Defenders to jump if it's a shot or lofted ball
        for i in players.indices where players[i].role == .wallDefender {
            players[i].animState = .jumpingWall
            players[i].stateTimer = 0.65
        }

        // Lock intended receiver onto the target pass location
        if let targetId = params.intendedReceiverId,
           let rIdx = players.firstIndex(where: { $0.id == targetId }) {
            players[rIdx].runWaypoints = [params.targetPitchPos]
            players[rIdx].currentWaypointIndex = 0
        }

        flightDuration = 0.0
        phase = .ballInFlight
        statusBannerText = nil
    }

    // MARK: - Main 60 FPS Simulation Step

    func update(dt rawDt: Double) {
        let dt = min(0.033, max(0.001, rawDt))
        matchClockSeconds += dt

        // Update screen shake decay
        if shakeIntensity > 0.01 {
            shakeIntensity *= exp(-dt * 12.0)
            screenShakeOffset = CGSize(
                width: Double.random(in: -shakeIntensity...shakeIntensity),
                height: Double.random(in: -shakeIntensity...shakeIntensity)
            )
        } else {
            shakeIntensity = 0
            screenShakeOffset = .zero
        }

        // Update net ripple decay
        if netImpactStrength > 0.01 {
            netImpactStrength *= exp(-dt * 4.5)
        } else {
            netImpactStrength = 0.0
        }

        // Update fading swipe slash trail
        if fadingSwipeAlpha > 0.01 {
            fadingSwipeAlpha = max(0.0, fadingSwipeAlpha - dt * 2.8)
        } else {
            fadingSwipeAlpha = 0.0
            if !fadingSwipePoints.isEmpty {
                fadingSwipePoints = []
            }
        }

        // Update particles
        updateParticles(dt: dt)

        // Handle Instant Replay playback mode
        if phase == .instantReplay {
            updateInstantReplay(dt: dt)
            return
        }

        switch phase {
        case .tacticalAiming:
            updateTacticalAiming(dt: dt)

        case .ballInFlight:
            updateBallInFlight(dt: dt)

        case .teammateControlling:
            updateTeammateControlling(dt: dt)

        case .goalCelebration:
            updateGoalCelebration(dt: dt)

        case .playFailed, .levelComplete, .instantReplay:
            // Keep idle/celebration animations running smoothly
            for i in players.indices {
                players[i].animPhase += dt * 4.0
            }
        }

        updateCamera(dt: dt)
    }

    // MARK: - Phase Updates

    private func updateTacticalAiming(dt: Double) {
        // Gentle idle animation and open pass callout pulsing
        for i in players.indices {
            players[i].animPhase += dt * 3.5
            if players[i].side == .home && !players[i].hasBall {
                // Orient slightly toward ball carrier
                let toBall = ball.position.xy - players[i].position
                let runTarget = players[i].runWaypoints.first ?? Vec2(x: players[i].position.x, y: players[i].position.y + 6.0)
                let toRun = runTarget - players[i].position
                let blendDir = (toBall.normalized() * 0.35 + toRun.normalized() * 0.65)
                players[i].facingAngle = atan2(blendDir.x, blendDir.y)
            }
        }
    }

    private func updateBallInFlight(dt: Double) {
        flightDuration += dt

        // Sub-step ball physics for accurate post/crossbar/player collision
        let subSteps = 3
        let subDt = dt / Double(subSteps)
        for _ in 0..<subSteps {
            let prevPos = ball.position
            var pos = ball.position
            var vel = ball.velocity
            var spinZ = ball.spinZ
            stepBallPhysics(pos: &pos, vel: &vel, spinZ: &spinZ, dt: subDt, isPreview: false)
            ball.position = pos
            ball.velocity = vel
            ball.spinZ = spinZ
            checkGoalpostAndNetCollisions(prevPos: prevPos)

            // Check if ball crossed goal line inside goal mouth!
            if checkGoalScored(prevPos: prevPos, currentPos: ball.position) {
                triggerGoalScored()
                return
            }
        }

        // Update visual ball rotation & trail
        let horizontalSpeed = ball.velocity.xy.length()
        ball.rotationAngle += (horizontalSpeed * 1.8 + abs(ball.spinZ) * 2.2) * dt
        ball.rotationAxisAngle = atan2(ball.velocity.x, ball.velocity.y)
        ball.trail.append(BallTrailPoint(position: ball.position, timestamp: matchClockSeconds, spinIntensity: abs(ball.spinZ)))
        if ball.trail.count > 26 {
            ball.trail.removeFirst(ball.trail.count - 26)
        }

        // Update all AI players (teammates sprinting, defenders pressing/jumping, keeper diving)
        updateAIPlayersDuringFlight(dt: dt)

        // Record frame for Instant Replay every 2 ticks (~30fps replay buffer)
        frameRecordCounter += 1
        if frameRecordCounter % 2 == 0 {
            recordReplayFrame()
        }

        // If a tackle/save/miss already happened, let the physical rebound & animations play out for 0.85s!
        if let reason = pendingFailReason {
            failAnimTimer -= dt
            for i in players.indices {
                if players[i].side == .home {
                    players[i].animState = .disappointed
                    players[i].velocity = players[i].velocity * 0.85
                } else if players[i].animState == .sliding {
                    // Sliding tackle deceleration on turf
                    players[i].position = players[i].position + players[i].velocity * (dt * 0.45)
                    players[i].velocity = players[i].velocity * max(0.0, 1.0 - 4.0 * dt)
                }
            }
            if failAnimTimer <= 0 {
                pendingFailReason = nil
                phase = .playFailed(reason: reason)
                store?.recordAttemptFailure()
            }
            return
        }

        // Check out-of-bounds or stalled ball
        if ball.position.y > PitchConstants.goalLineY + 1.2 &&
            (abs(ball.position.x) > PitchConstants.goalHalfWidth + 0.3 || ball.position.z > PitchConstants.crossbarHeight + 0.35) {
            triggerPlayFailed(reason: "Knapp am Tor vorbei!")
            return
        }

        if abs(ball.position.x) > PitchConstants.halfWidth + 1.2 || ball.position.y < PitchConstants.minY - 1.0 {
            triggerPlayFailed(reason: "Ball im Seitenaus!")
            return
        }

        if flightDuration > 1.2 && ball.velocity.length() < 0.85 {
            triggerPlayFailed(reason: "Spielzug gestoppt – kein Mitspieler erreicht!")
            return
        }

        if flightDuration > 5.5 {
            triggerPlayFailed(reason: "Zeit abgelaufen!")
            return
        }
    }

    private func updateTeammateControlling(dt: Double) {
        phaseTimer -= dt
        updateAIPlayersDuringFlight(dt: dt * 0.45)

        if let id = controlTargetPlayerId,
           let idx = players.firstIndex(where: { $0.id == id }) {
            let forwardDir = Vec2(x: sin(players[idx].facingAngle), y: cos(players[idx].facingAngle))
            let targetBallPos = players[idx].position + forwardDir * 0.75
            ball.position = Vec3(
                x: ball.position.x + (targetBallPos.x - ball.position.x) * min(1.0, dt * 14.0),
                y: ball.position.y + (targetBallPos.y - ball.position.y) * min(1.0, dt * 14.0),
                z: 0.0
            )
            ball.velocity = .zero
        }

        recordReplayFrame()

        if phaseTimer <= 0 {
            phase = .tacticalAiming
            statusBannerText = "Stark angenommen! Ziehe jetzt für den nächsten Pass oder Torschuss."
        }
    }

    private func updateGoalCelebration(dt: Double) {
        phaseTimer += dt

        // Keep ball settling inside the goal net
        let subDt = dt * 0.5
        for _ in 0..<2 {
            let prev = ball.position
            var pos = ball.position
            var vel = ball.velocity
            var spinZ = ball.spinZ
            stepBallPhysics(pos: &pos, vel: &vel, spinZ: &spinZ, dt: subDt, isPreview: false)
            ball.position = pos
            ball.velocity = vel
            ball.spinZ = spinZ
            containBallInsideNet(prevPos: prev)
        }

        // Home players celebrate, away players look disappointed
        for i in players.indices {
            players[i].animPhase += dt * 7.5
            if players[i].side == .home {
                players[i].animState = .celebrating
                let celDir = Vec2(x: players[i].position.x < 0 ? -1.0 : 1.0, y: -0.4).normalized()
                players[i].position = players[i].position + celDir * (2.6 * dt)
                players[i].zHeight = max(0, sin(players[i].animPhase * 1.4) * 0.45)
            } else if players[i].role != .goalkeeper {
                players[i].animState = .disappointed
                players[i].zHeight = 0
            }
        }

        if frameRecordCounter % 2 == 0 && phaseTimer < 1.1 {
            recordReplayFrame()
        }
        frameRecordCounter += 1

        // Periodically spawn stadium confetti
        if Double.random(in: 0...1) < 0.45 {
            spawnConfettiBurst()
        }

        if phaseTimer >= 1.95 {
            if store?.autoReplayGoals == true && replayFrames.count > 12 {
                startInstantReplay()
            } else {
                completeLevelWithSummary()
            }
        }
    }

    // MARK: - 3D Ball Physics Integrator (Gravity, Drag, Magnus Spin, Wind, Turf Friction)

    private func stepBallPhysics(pos: inout Vec3, vel: inout Vec3, spinZ: inout Double, dt: Double, isPreview: Bool) {
        let gravity = 14.8
        let airDrag = 0.24
        let turfFriction = 1.65

        // Lateral Magnus acceleration perpendicular to XY velocity: a_magnus = (-vy, vx) / |v_xy| * spinZ * k
        let speedXY = hypot(vel.x, vel.y)
        var magnusAx = 0.0
        var magnusAy = 0.0
        if speedXY > 0.5 {
            let nx = -vel.y / speedXY
            let ny = vel.x / speedXY
            let magnusFactor = 1.42 * spinZ * min(1.4, speedXY / 16.0)
            magnusAx = nx * magnusFactor
            magnusAy = ny * magnusFactor
        }

        // Wind acceleration (stronger when ball is airborne)
        let windFactor = pos.z > 0.25 ? 0.85 : 0.25
        let windAx = level.windSpeed * windFactor

        // Integrate velocity
        vel.x += (magnusAx + windAx - vel.x * airDrag) * dt
        vel.y += (magnusAy - vel.y * airDrag) * dt

        if pos.z > 0.001 || vel.z > 0.0 {
            vel.z -= gravity * dt
        }

        // Integrate position
        pos.x += vel.x * dt
        pos.y += vel.y * dt
        pos.z += vel.z * dt

        // Ground collision & turf rolling friction
        if pos.z <= 0.0 {
            pos.z = 0.0
            if vel.z < -1.4 {
                vel.z = -vel.z * 0.46 // Elastic turf bounce
                spinZ *= 0.78
            } else {
                vel.z = 0.0
                // Apply grass friction while rolling
                let damping = max(0.0, 1.0 - turfFriction * dt)
                vel.x *= damping
                vel.y *= damping
                spinZ *= max(0.0, 1.0 - 1.8 * dt)
            }
        } else {
            spinZ *= max(0.0, 1.0 - 0.22 * dt)
        }
    }

    // MARK: - Goalposts, Crossbar & Goal Net Physics

    private func checkGoalpostAndNetCollisions(prevPos: Vec3) {
        let goalY = PitchConstants.goalLineY
        let halfW = PitchConstants.goalHalfWidth
        let crossbarZ = PitchConstants.crossbarHeight
        let combinedRadius = PitchConstants.postRadius + PitchConstants.ballRadius

        // 1. Left & Right Vertical Goalposts (at x = -halfW and x = +halfW, y = goalY, z in 0...crossbarZ)
        if ball.position.z <= crossbarZ + combinedRadius {
            for postX in [-halfW, halfW] {
                let dx = ball.position.x - postX
                let dy = ball.position.y - goalY
                let dist = hypot(dx, dy)
                if dist < combinedRadius && dist > 1e-5 {
                    let nx = dx / dist
                    let ny = dy / dist
                    ball.position.x = postX + nx * (combinedRadius + 0.02)
                    ball.position.y = goalY + ny * (combinedRadius + 0.02)

                    let dot = ball.velocity.x * nx + ball.velocity.y * ny
                    if dot < 0 {
                        ball.velocity.x = (ball.velocity.x - 2.0 * dot * nx) * 0.72
                        ball.velocity.y = (ball.velocity.y - 2.0 * dot * ny) * 0.72
                        triggerWoodworkImpact(at: ball.position)
                    }
                }
            }
        }

        // 2. Horizontal Crossbar (at y = goalY, z = crossbarZ, x in -halfW...halfW)
        if abs(ball.position.x) <= halfW + combinedRadius {
            let dy = ball.position.y - goalY
            let dz = ball.position.z - crossbarZ
            let dist = hypot(dy, dz)
            if dist < combinedRadius && dist > 1e-5 {
                let ny = dy / dist
                let nz = dz / dist
                ball.position.y = goalY + ny * (combinedRadius + 0.02)
                ball.position.z = max(0, crossbarZ + nz * (combinedRadius + 0.02))

                let dot = ball.velocity.y * ny + ball.velocity.z * nz
                if dot < 0 {
                    ball.velocity.y = (ball.velocity.y - 2.0 * dot * ny) * 0.70
                    ball.velocity.z = (ball.velocity.z - 2.0 * dot * nz) * 0.70
                    triggerWoodworkImpact(at: ball.position)
                }
            }
        }

        // 3. Exterior Side Netting collision if ball approaches goal from outside the posts
        if prevPos.y >= goalY && abs(prevPos.x) > halfW && abs(ball.position.x) <= halfW && ball.position.z <= crossbarZ {
            ball.position.x = prevPos.x > 0 ? (halfW + 0.35) : -(halfW + 0.35)
            ball.velocity.x = -ball.velocity.x * 0.35
        }
    }

    private func containBallInsideNet(prevPos: Vec3) {
        let halfW = PitchConstants.goalHalfWidth - 0.35
        let backY = PitchConstants.netBackY
        let topZ = PitchConstants.crossbarHeight - 0.25

        if ball.position.y > backY {
            if netImpactStrength < 0.2 {
                netImpactPos = ball.position
                netImpactStrength = min(1.4, max(0.55, ball.velocity.length() / 16.0))
            }
            ball.position.y = backY
            ball.velocity.y = -ball.velocity.y * 0.18
            ball.velocity.x *= 0.55
            ball.velocity.z *= 0.45
        }

        if abs(ball.position.x) > halfW && ball.position.y >= PitchConstants.goalLineY {
            if netImpactStrength < 0.2 {
                netImpactPos = ball.position
                netImpactStrength = 0.75
            }
            ball.position.x = ball.position.x > 0 ? halfW : -halfW
            ball.velocity.x = -ball.velocity.x * 0.20
            ball.velocity.y *= 0.65
        }

        if ball.position.z > topZ && ball.position.y >= PitchConstants.goalLineY {
            ball.position.z = topZ
            ball.velocity.z = -abs(ball.velocity.z) * 0.25
        }
    }

    private func triggerWoodworkImpact(at pos: Vec3) {
        SoundManager.shared.play(.postHit)
        store?.recordWoodworkHit()
        shakeIntensity = 9.0
        for _ in 0..<12 {
            let vel = Vec3(
                x: Double.random(in: -8...8),
                y: Double.random(in: -8...4),
                z: Double.random(in: 1...7)
            )
            particles.append(PitchParticle(
                position: pos,
                velocity: vel,
                color: .white,
                size: Double.random(in: 3...6),
                life: 0,
                maxLife: 0.45
            ))
        }
    }

    private func checkGoalScored(prevPos: Vec3, currentPos: Vec3) -> Bool {
        let goalY = PitchConstants.goalLineY
        guard prevPos.y < goalY && currentPos.y >= goalY else { return false }

        let t = max(0.0, min(1.0, (goalY - prevPos.y) / max(1e-5, currentPos.y - prevPos.y)))
        let crossX = prevPos.x + (currentPos.x - prevPos.x) * t
        let crossZ = prevPos.z + (currentPos.z - prevPos.z) * t

        let insideWidth = abs(crossX) <= (PitchConstants.goalHalfWidth - 0.18)
        let underCrossbar = crossZ <= (PitchConstants.crossbarHeight - 0.12)

        if insideWidth && underCrossbar {
            // Check if the ball hit the Golden Star Target Ring!
            let dxStar = crossX - level.starTarget.x
            let dzStar = crossZ - level.starTarget.z
            if hypot(dxStar, dzStar) <= (level.starTarget.radius + 0.55) {
                hitStarTargetInPlay = true
                spawnStarBurstParticles(at: Vec3(x: crossX, y: goalY, z: crossZ))
                SoundManager.shared.play(.starEarned)
            }
            return true
        }
        return false
    }

    // MARK: - AI Player & Goalkeeper State Machine

    private func updateAIPlayersDuringFlight(dt: Double) {
        let diff = store?.difficulty ?? .pro
        let defSpeedScale = diff.defenderSpeedMultiplier
        let gkScale = diff.keeperReactionMultiplier

        for i in players.indices {
            players[i].animPhase += dt * (players[i].animState == .sprinting ? 11.5 : 8.5)
            if players[i].tackleCooldown > 0 {
                players[i].tackleCooldown -= dt
            }
            if players[i].stateTimer > 0 {
                players[i].stateTimer -= dt
            }

            switch players[i].side {
            case .home:
                updateHomeTeammateAI(index: i, dt: dt)

            case .away:
                if players[i].role == .goalkeeper {
                    updateGoalkeeperAI(index: i, dt: dt, skillScale: gkScale)
                } else if players[i].role == .wallDefender {
                    updateWallDefenderAI(index: i, dt: dt)
                } else {
                    updateFieldDefenderAI(index: i, dt: dt, speedScale: defSpeedScale)
                }
            }
        }
    }

    private func updateHomeTeammateAI(index i: Int, dt: Double) {
        // Kicker finishing kick animation before making support run
        if players[i].animState == .kicking && players[i].stateTimer > 0 {
            return
        }

        // Determine target position: if ball is heading toward this teammate, chase the ball interception point;
        // otherwise sprint along tactical runWaypoints
        var targetPos: Vec2? = nil
        let distToBall = players[i].position.distance(to: ball.position.xy)
        let ballToPlayer = players[i].position - ball.position.xy
        let ballMovingTowardMe = ball.velocity.xy.dot(ballToPlayer.normalized()) > 2.5

        if players[i].id != ball.lastKickerId && (distToBall < 9.5 || ballMovingTowardMe) && ball.position.y < PitchConstants.goalLineY - 0.5 {
            // Predict ball position 0.25s ahead
            let leadPos = ball.position.xy + ball.velocity.xy * 0.22
            if leadPos.distance(to: players[i].position) < 11.5 {
                targetPos = Vec2(
                    x: max(-PitchConstants.halfWidth + 1.5, min(PitchConstants.halfWidth - 1.5, leadPos.x)),
                    y: max(PitchConstants.minY + 1.0, min(PitchConstants.goalLineY - 1.8, leadPos.y))
                )
            }
        }

        if targetPos == nil, players[i].currentWaypointIndex < players[i].runWaypoints.count {
            let wp = players[i].runWaypoints[players[i].currentWaypointIndex]
            if players[i].position.distance(to: wp) < 1.1 {
                players[i].currentWaypointIndex += 1
            } else {
                targetPos = wp
            }
        }

        if let target = targetPos {
            let toTarget = target - players[i].position
            let dist = toTarget.length()
            if dist > 0.25 {
                let dir = toTarget.normalized()
                let moveSpeed = players[i].baseSpeed
                players[i].velocity = dir * moveSpeed
                players[i].position = players[i].position + players[i].velocity * dt
                players[i].facingAngle = atan2(dir.x, dir.y)
                players[i].animState = .sprinting
            } else {
                players[i].velocity = .zero
                players[i].animState = .idle
            }
        } else {
            players[i].velocity = .zero
            players[i].animState = .idle
        }

        // Check if teammate can trap and control the pass!
        if phase == .ballInFlight,
           pendingFailReason == nil,
           players[i].id != ball.lastKickerId,
           flightDuration > 0.14,
           ball.position.z < 2.25,
           players[i].position.distance(to: ball.position.xy) < 1.62 {

            // Teammate successfully receives the pass!
            passesInCurrentPlay += 1
            for j in players.indices {
                players[j].hasBall = (j == i)
                if players[j].side == .home {
                    players[j].isOpenForPass = (j != i)
                }
            }

            players[i].velocity = .zero
            players[i].animState = .idle
            // Turn toward the goal
            let toGoal = Vec2(x: 0.0, y: PitchConstants.goalLineY) - players[i].position
            players[i].facingAngle = atan2(toGoal.x, toGoal.y)

            ball.lastKickerId = players[i].id
            ball.velocity = .zero
            ball.spinZ = 0
            ball.position.z = 0
            controlTargetPlayerId = players[i].id
            phaseTimer = 0.22
            phase = .teammateControlling

            SoundManager.shared.play(.ballTrap)
        }
    }

    private func updateWallDefenderAI(index i: Int, dt: Double) {
        if players[i].animState == .jumpingWall {
            let progress = max(0.0, min(1.0, (0.65 - players[i].stateTimer) / 0.65))
            players[i].zHeight = sin(.pi * progress) * 2.15
            if players[i].stateTimer <= 0 {
                players[i].zHeight = 0
                players[i].animState = .idle
            }
        } else {
            players[i].zHeight = 0
        }

        // Balanced physical collision: slightly smaller than original (0.78 -> 0.68), larger than 0.54
        let distXY = players[i].position.distance(to: ball.position.xy)
        let defenderTopZ = 1.80 + players[i].zHeight * 0.88
        if phase == .ballInFlight && pendingFailReason == nil && distXY < 0.68 && ball.position.z <= defenderTopZ {
            ball.velocity.y = -abs(ball.velocity.y) * 0.48
            ball.velocity.x += Double.random(in: -5.5...5.5)
            ball.velocity.z = max(1.5, ball.velocity.z * 0.5)
            shakeIntensity = 4.5
            spawnKickParticles(at: ball.position, power: 0.65)
            SoundManager.shared.play(.passKick)
            SoundManager.shared.play(.crowdReaction)
            triggerPlayFailed(reason: "Freistoß prallt von der Mauer ab!")
        }
    }

    private func updateFieldDefenderAI(index i: Int, dt: Double, speedScale: Double) {
        if players[i].animState == .sliding {
            return
        }
        players[i].reactionTimer += dt
        guard players[i].reactionTimer >= players[i].reactionDelay else { return }

        // Choose target: intercept ball if close, otherwise follow waypoint or close down nearest attacker/ball
        var target = ball.position.xy
        let distToBall = players[i].position.distance(to: ball.position.xy)

        if distToBall > 9.5, players[i].currentWaypointIndex < players[i].runWaypoints.count {
            let wp = players[i].runWaypoints[players[i].currentWaypointIndex]
            if players[i].position.distance(to: wp) < 1.2 {
                players[i].currentWaypointIndex += 1
            } else {
                target = wp
            }
        } else {
            // Predict ball movement slightly
            target = ball.position.xy + ball.velocity.xy * 0.16
        }

        let toTarget = target - players[i].position
        if toTarget.length() > 0.25 {
            let dir = toTarget.normalized()
            let moveSpeed = players[i].baseSpeed * speedScale
            players[i].velocity = dir * moveSpeed
            players[i].position = players[i].position + players[i].velocity * dt
            players[i].facingAngle = atan2(dir.x, dir.y)
            players[i].animState = distToBall < 4.5 ? .sprinting : .running
        }

        // Balanced physical tackle hitbox: slightly smaller than original (0.92 -> 0.78), larger than 0.56
        if phase == .ballInFlight && pendingFailReason == nil && flightDuration > 0.12 {
            let hitDist = players[i].position.distance(to: ball.position.xy)
            if hitDist < 0.78 && ball.position.z < 1.58 {
                players[i].animState = .sliding
                players[i].stateTimer = 0.85
                // Realistic deflection off the defender's sliding boot
                let deflectDir = (ball.position.xy - players[i].position).normalized()
                ball.velocity = Vec3(
                    x: deflectDir.x * 7.5 + Double.random(in: -3...3),
                    y: -abs(ball.velocity.y) * 0.38 - 3.0,
                    z: Double.random(in: 1.8...3.8)
                )
                shakeIntensity = 5.0
                spawnKickParticles(at: ball.position, power: 0.75)
                SoundManager.shared.play(.passKick)
                SoundManager.shared.play(.crowdReaction)
                triggerPlayFailed(reason: "Grätsche! Von \(players[i].name) (#\(players[i].shirtNumber)) fair geklärt!")
            }
        }
    }

    private func updateGoalkeeperAI(index i: Int, dt: Double, skillScale: Double) {
        let goalY = 51.2
        players[i].reactionTimer += dt

        // Is the ball flying toward the goal?
        let ballHeadingToGoal = (ball.velocity.y > 4.5 && ball.position.y > 20.0)

        if ballHeadingToGoal && players[i].reactionTimer >= (players[i].reactionDelay / skillScale) {
            // Predict X and Z where ball will cross y = goalY
            let remainingY = max(0.05, goalY - ball.position.y)
            let timeToGoal = remainingY / max(4.0, ball.velocity.y)
            let predictedX = max(-PitchConstants.goalHalfWidth + 0.5, min(PitchConstants.goalHalfWidth - 0.5, ball.position.x + ball.velocity.x * timeToGoal * 0.88))
            let predictedZ = max(0.0, min(PitchConstants.crossbarHeight, ball.position.z + ball.velocity.z * timeToGoal - 0.5 * 14.8 * timeToGoal * timeToGoal))

            let dx = predictedX - players[i].position.x
            let diveSpeed = players[i].baseSpeed * skillScale * 1.15
            let stepX = max(-diveSpeed * dt, min(diveSpeed * dt, dx))
            players[i].position.x += stepX
            players[i].position.y = goalY

            if abs(dx) > 1.1 && timeToGoal < 0.55 {
                if predictedZ > 2.6 {
                    players[i].animState = .divingHigh
                    players[i].zHeight = min(1.75, players[i].zHeight + dt * 5.0)
                } else {
                    players[i].animState = dx < 0 ? .divingLeft : .divingRight
                    players[i].zHeight = min(0.90, players[i].zHeight + dt * 3.2)
                }
            } else {
                players[i].animState = .running
            }
        } else if pendingFailReason == nil {
            // Track ball laterally along the goal line during build-up play
            let desiredX = max(-4.2, min(4.2, ball.position.x * 0.36))
            let dx = desiredX - players[i].position.x
            let trackSpeed = players[i].baseSpeed * 0.65 * dt
            players[i].position.x += max(-trackSpeed, min(trackSpeed, dx))
            players[i].position.y = max(49.2, min(51.3, players[i].position.y))
            players[i].zHeight = max(0, players[i].zHeight - dt * 4.0)
            players[i].animState = .idle
        } else {
            // Settle to ground after diving parry
            players[i].zHeight = max(0, players[i].zHeight - dt * 2.8)
        }

        players[i].facingAngle = .pi

        // Uniform Goalkeeper Save Zone: the exact same hitbox size everywhere in the goal
        // (center, sides and corners) - independent of dive state or dive height.
        if phase == .ballInFlight && pendingFailReason == nil {
            let dx = abs(ball.position.x - players[i].position.x)
            let dy = abs(ball.position.y - players[i].position.y)
            let keeperReachX = 2.4
            let keeperReachZ = 3.1

            if dy < 1.0 && dx < keeperReachX && ball.position.z <= keeperReachZ {
                // Keeper parries the shot outward with realistic glove deflection!
                let sidePush = (ball.position.x >= players[i].position.x) ? 7.5 : -7.5
                ball.velocity.y = -abs(ball.velocity.y) * 0.36 - 2.5
                ball.velocity.x = sidePush
                ball.velocity.z = 3.6
                shakeIntensity = 5.5
                spawnKickParticles(at: ball.position, power: 0.85)
                SoundManager.shared.play(.powerShot, volumeScale: 0.75)
                SoundManager.shared.play(.crowdReaction)
                triggerPlayFailed(reason: "Glanzparade von Torwart \(players[i].name)!")
            }
        }
    }

    // MARK: - Goal, Failure & Level Complete Transitions

    private func triggerGoalScored() {
        pendingFailReason = nil
        phase = .goalCelebration
        phaseTimer = 0.0
        shakeIntensity = 7.5
        netImpactPos = Vec3(x: ball.position.x, y: PitchConstants.netBackY, z: ball.position.z)
        netImpactStrength = 1.25
        statusBannerText = hitStarTargetInPlay ? "TRAUMTOR IN DEN STERN-WINKEL!" : "TOOOOR! UNHALTBAR VERWANDELT!"

        SoundManager.shared.play(.goalCheer)
        spawnConfettiBurst()
        recordReplayFrame()
    }

    private func triggerPlayFailed(reason: String) {
        guard phase == .ballInFlight, pendingFailReason == nil else { return }
        pendingFailReason = reason
        failAnimTimer = 0.85
        statusBannerText = reason
        for i in players.indices where players[i].side == .home {
            players[i].animState = .disappointed
        }
    }

    func startInstantReplay() {
        guard !replayFrames.isEmpty else {
            completeLevelWithSummary()
            return
        }
        phase = .instantReplay
        isPlayingReplay = true
        replayCursor = 0
        replayAccumulator = 0.0
        applyReplayFrame(replayFrames[0])
    }

    func skipInstantReplay() {
        isPlayingReplay = false
        completeLevelWithSummary()
    }

    private func updateInstantReplay(dt: Double) {
        guard isPlayingReplay, !replayFrames.isEmpty else { return }
        replayAccumulator += dt
        // Play back at 0.55x slow-motion broadcast speed
        let frameInterval = 0.055
        if replayAccumulator >= frameInterval {
            replayAccumulator -= frameInterval
            replayCursor += 1
            if replayCursor < replayFrames.count {
                applyReplayFrame(replayFrames[replayCursor])
            } else {
                isPlayingReplay = false
                completeLevelWithSummary()
            }
        }
    }

    private func recordReplayFrame() {
        let frame = ReplayFrame(
            timestamp: matchClockSeconds,
            ball: ball,
            players: players,
            cameraCenter: cameraCenter,
            cameraZoom: cameraZoom,
            netImpactPos: netImpactPos,
            netImpactStrength: netImpactStrength
        )
        replayFrames.append(frame)
        if replayFrames.count > 160 {
            replayFrames.removeFirst()
        }
    }

    private func applyReplayFrame(_ frame: ReplayFrame) {
        self.ball = frame.ball
        self.players = frame.players
        self.cameraCenter = frame.cameraCenter
        self.cameraZoom = frame.cameraZoom
        self.netImpactPos = frame.netImpactPos
        self.netImpactStrength = frame.netImpactStrength
    }

    private func completeLevelWithSummary() {
        // Compute 1 - 3 Stars:
        // 1 Star: Goal scored
        // 2 Stars: Goal scored within parAttempts OR with recommended passes
        // 3 Stars: Hit the Golden Star Target Ring OR (1st attempt + recommended passes / curve shot)
        var stars = 1
        let metPassGoal = passesInCurrentPlay >= level.recommendedPasses
        let withinPar = attemptsInLevel <= level.parAttempts

        if withinPar || metPassGoal {
            stars = 2
        }
        if hitStarTargetInPlay || (attemptsInLevel == 1 && metPassGoal && (lastShotWasCurved || level.recommendedPasses > 0)) {
            stars = 3
        }

        let coinsEarned = store?.recordLevelWin(
            levelId: level.id,
            earnedStars: stars,
            attemptsUsed: attemptsInLevel,
            passesCompleted: passesInCurrentPlay,
            wasCurvedGoal: lastShotWasCurved,
            hitStarTarget: hitStarTargetInPlay
        ) ?? level.rewardCoins

        SoundManager.shared.play(.levelComplete)
        phase = .levelComplete(stars: stars, coinsEarned: coinsEarned, hitStarTarget: hitStarTargetInPlay)
    }

    // MARK: - Dynamic Camera System

    private func updateCamera(dt: Double) {
        var desiredCenter = Vec2(x: ball.position.x * 0.45, y: min(42.0, max(15.0, ball.position.y + 8.5)))
        var desiredZoom: Double = 1.0

        switch phase {
        case .tacticalAiming:
            if let params = currentShotParams {
                let midY = (ball.position.y + params.targetPitchPos.y) * 0.5 + 4.5
                desiredCenter = Vec2(
                    x: (ball.position.x + params.targetPitchPos.x) * 0.25,
                    y: min(43.5, max(16.0, midY))
                )
                desiredZoom = params.isShotOnGoal ? 1.04 : 0.96
            } else {
                desiredZoom = ball.position.y < 18.0 ? 0.92 : 1.02
            }

        case .ballInFlight:
            desiredCenter = Vec2(
                x: ball.position.x * 0.48,
                y: min(44.5, max(16.0, ball.position.y + 6.5))
            )
            desiredZoom = ball.position.y > 36.0 ? 1.12 : 1.0

        case .teammateControlling:
            desiredCenter = Vec2(
                x: ball.position.x * 0.45,
                y: min(42.5, max(16.0, ball.position.y + 8.0))
            )
            desiredZoom = 1.04

        case .goalCelebration, .levelComplete:
            desiredCenter = Vec2(x: ball.position.x * 0.35, y: 44.5)
            desiredZoom = 1.18

        case .playFailed:
            desiredZoom = 1.0

        case .instantReplay:
            return
        }

        let lerpSpeed = min(1.0, dt * 5.2)
        cameraCenter = cameraCenter.lerp(to: desiredCenter, t: lerpSpeed)
        cameraZoom += (desiredZoom - cameraZoom) * lerpSpeed
    }

    // MARK: - Particle Effects

    private func updateParticles(dt: Double) {
        for i in particles.indices.reversed() {
            particles[i].life += dt
            if particles[i].life >= particles[i].maxLife {
                particles.remove(at: i)
            } else {
                particles[i].position = particles[i].position + particles[i].velocity * dt
                particles[i].velocity.z -= 12.0 * dt
                if particles[i].position.z < 0 {
                    particles[i].position.z = 0
                    particles[i].velocity.z = -particles[i].velocity.z * 0.3
                }
            }
        }
    }

    private func spawnKickParticles(at pos: Vec3, power: Double) {
        let count = Int(6 + power * 10)
        for _ in 0..<count {
            let vel = Vec3(
                x: Double.random(in: -4.5...4.5),
                y: Double.random(in: -2.5...5.5),
                z: Double.random(in: 1.5...5.0)
            )
            let isGold = power > 0.72 && Bool.random()
            particles.append(PitchParticle(
                position: pos,
                velocity: vel,
                color: isGold ? .yellow : Color(red: 0.35, green: 0.88, blue: 0.38),
                size: Double.random(in: 3.0...5.5),
                life: 0,
                maxLife: Double.random(in: 0.28...0.52)
            ))
        }
    }

    private func spawnStarBurstParticles(at pos: Vec3) {
        for _ in 0..<22 {
            let vel = Vec3(
                x: Double.random(in: -9...9),
                y: Double.random(in: -5...5),
                z: Double.random(in: -4...8)
            )
            particles.append(PitchParticle(
                position: pos,
                velocity: vel,
                color: Color(red: 1.0, green: 0.85, blue: 0.1),
                size: Double.random(in: 4.5...8.0),
                life: 0,
                maxLife: Double.random(in: 0.55...0.95)
            ))
        }
    }

    private func spawnConfettiBurst() {
        let colors: [Color] = [.yellow, .cyan, .green, .orange, .pink, .white]
        for _ in 0..<8 {
            let pos = Vec3(
                x: Double.random(in: -14...14),
                y: Double.random(in: 44...54),
                z: Double.random(in: 5.5...9.5)
            )
            let vel = Vec3(
                x: Double.random(in: -3...3),
                y: Double.random(in: -2...2),
                z: Double.random(in: -1.5...1.0)
            )
            particles.append(PitchParticle(
                position: pos,
                velocity: vel,
                color: colors.randomElement() ?? .yellow,
                size: Double.random(in: 4.0...7.0),
                life: 0,
                maxLife: Double.random(in: 0.9...1.5)
            ))
        }
    }
}
