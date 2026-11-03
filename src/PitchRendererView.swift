import SwiftUI

struct PitchRendererView: View {
    @ObservedObject var engine: PhysicsEngine
    @EnvironmentObject var store: GameStore

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                drawStadiumBackdrop(context: &context, size: size)
                drawTurfAndStripes(context: &context, size: size)
                drawPitchMarkings(context: &context, size: size)
                drawAdBoardsAndFlags(context: &context, size: size)

                if engine.phase == .tacticalAiming {
                    drawTacticalRunIndicators(context: &context, size: size)
                }

                if store.showTrajectoryHelper, let shot = engine.currentShotParams {
                    drawTrajectoryPreview(context: &context, size: size, shot: shot)
                }

                // Draw Goal Net Back & Star Target before Goal Frame & Depth-Sorted Entities
                drawGoalNetMesh(context: &context, size: size)
                drawStarTargetZone(context: &context, size: size)

                // Depth-sort players and ball (higher Y = further away = drawn first)
                drawDepthSortedEntities(context: &context, size: size)

                // Draw Front Goalposts & Crossbar so ball passing under crossbar looks authentic
                drawGoalFramePosts(context: &context, size: size)

                // Draw Particles (grass sparks, star burst, confetti)
                drawParticles(context: &context, size: size)

                // Draw Dynamic Finger Swipe / Flick Slash
                drawFingerSwipeSlash(context: &context)
            }
            .offset(engine.screenShakeOffset)
        }
    }

    // MARK: - 1. Stadium Backdrop & Floodlights

    private func drawStadiumBackdrop(context: inout GraphicsContext, size: CGSize) {
        let bgRect = CGRect(origin: .zero, size: size)
        let skyGradient = Gradient(colors: [
            Color(red: 0.04, green: 0.07, blue: 0.14),
            Color(red: 0.07, green: 0.14, blue: 0.22),
            Color(red: 0.06, green: 0.22, blue: 0.14)
        ])
        context.fill(
            Path(bgRect),
            with: .linearGradient(skyGradient, startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height * 0.45))
        )

        // Stadium upper stands silhouette behind goal line
        let standLeft = engine.project(Vec3(x: -44, y: 58, z: 0), in: size)
        let standRight = engine.project(Vec3(x: 44, y: 58, z: 0), in: size)
        let standTopY = max(0, standLeft.y - 95)

        var standPath = Path()
        standPath.move(to: CGPoint(x: 0, y: 0))
        standPath.addLine(to: CGPoint(x: size.width, y: 0))
        standPath.addLine(to: CGPoint(x: size.width, y: standRight.y + 18))
        standPath.addLine(to: CGPoint(x: 0, y: standLeft.y + 18))
        standPath.closeSubpath()

        context.fill(
            standPath,
            with: .linearGradient(
                Gradient(colors: [Color(red: 0.05, green: 0.08, blue: 0.15), Color(red: 0.10, green: 0.15, blue: 0.24)]),
                startPoint: CGPoint(x: 0, y: standTopY),
                endPoint: CGPoint(x: 0, y: standLeft.y + 18)
            )
        )

        // Animated stadium crowd dots & camera flashes
        let crowdRows = 4
        let cols = 28
        let pulse = sin(engine.matchClockSeconds * 5.0)
        for r in 0..<crowdRows {
            let rowY = Double(standLeft.y) - Double(r) * 14.0 - 8.0
            guard rowY > 0 else { continue }
            for c in 0..<cols {
                let frac = Double(c) / Double(cols - 1)
                let cx = frac * Double(size.width)
                let bob = sin(Double(c * 7 + r * 13) + engine.matchClockSeconds * 6.0) * 1.8
                let dotRect = CGRect(x: cx - 2.5, y: rowY + bob - 2.5, width: 5.0, height: 5.0)
                let isHomeFan = (c + r) % 3 != 0
                let fanColor = isHomeFan
                    ? Color(hex: store.activeKit.primaryHex, opacity: 0.55)
                    : Color(hex: engine.level.awayKitPrimaryHex, opacity: 0.45)
                context.fill(Path(ellipseIn: dotRect), with: .color(fanColor))
            }
        }

        // Floodlight glow cones at top corners
        context.fill(Path(bgRect), with: .radialGradient(
            Gradient(colors: [Color.white.opacity(0.16 + 0.03 * pulse), Color.clear]),
            center: CGPoint(x: size.width * 0.15, y: 10),
            startRadius: 5,
            endRadius: size.width * 0.45
        ))
        context.fill(Path(bgRect), with: .radialGradient(
            Gradient(colors: [Color.white.opacity(0.16 - 0.03 * pulse), Color.clear]),
            center: CGPoint(x: size.width * 0.85, y: 10),
            startRadius: 5,
            endRadius: size.width * 0.45
        ))
    }

    // MARK: - 2. Perspective Turf & Mowed Stripes

    private func drawTurfAndStripes(context: inout GraphicsContext, size: CGSize) {
        let outerHalfW = PitchConstants.halfWidth + 6.5
        let stripeCount = 13
        let minY = -8.0
        let maxY = 57.5
        let stripeStep = (maxY - minY) / Double(stripeCount)

        for i in 0..<stripeCount {
            let y0 = minY + Double(i) * stripeStep
            let y1 = y0 + stripeStep + 0.15

            let bl = engine.project(Vec3(x: -outerHalfW, y: y0, z: 0), in: size)
            let br = engine.project(Vec3(x: outerHalfW, y: y0, z: 0), in: size)
            let tr = engine.project(Vec3(x: outerHalfW, y: y1, z: 0), in: size)
            let tl = engine.project(Vec3(x: -outerHalfW, y: y1, z: 0), in: size)

            var quad = Path()
            quad.move(to: bl)
            quad.addLine(to: br)
            quad.addLine(to: tr)
            quad.addLine(to: tl)
            quad.closeSubpath()

            let isLightStripe = (i % 2 == 0)
            let turfColor = isLightStripe
                ? Color(red: 0.11, green: 0.56, blue: 0.25)
                : Color(red: 0.09, green: 0.48, blue: 0.21)
            context.fill(quad, with: .color(turfColor))
        }
    }

    // MARK: - 3. White Pitch Markings

    private func drawPitchMarkings(context: inout GraphicsContext, size: CGSize) {
        let lineColor = Color.white.opacity(0.82)
        let hw = PitchConstants.halfWidth
        let goalY = PitchConstants.goalLineY

        // Outer pitch boundary (from y = 0 midfield line to y = 52 goal line)
        drawPitchPolyLine(
            context: &context,
            size: size,
            points: [
                Vec2(x: -hw, y: 0),
                Vec2(x: -hw, y: goalY),
                Vec2(x: hw, y: goalY),
                Vec2(x: hw, y: 0),
                Vec2(x: -hw, y: 0)
            ],
            color: lineColor,
            lineWidth: 2.4
        )

        // Center Circle at (0, 0)
        drawPitchCircle(context: &context, size: size, center: Vec2(x: 0, y: 0), radius: 9.15, startAngle: 0, endAngle: 2 * .pi, color: lineColor, lineWidth: 2.0)

        // Penalty Box (16-Meter-Raum)
        let pBoxHW = PitchConstants.penaltyBoxHalfWidth
        let pBoxMinY = PitchConstants.penaltyBoxMinY
        drawPitchPolyLine(
            context: &context,
            size: size,
            points: [
                Vec2(x: -pBoxHW, y: goalY),
                Vec2(x: -pBoxHW, y: pBoxMinY),
                Vec2(x: pBoxHW, y: pBoxMinY),
                Vec2(x: pBoxHW, y: goalY)
            ],
            color: lineColor,
            lineWidth: 2.2
        )

        // 6-Yard Box (Fünfmeterraum)
        let sixHW = PitchConstants.sixYardHalfWidth
        let sixMinY = PitchConstants.sixYardMinY
        drawPitchPolyLine(
            context: &context,
            size: size,
            points: [
                Vec2(x: -sixHW, y: goalY),
                Vec2(x: -sixHW, y: sixMinY),
                Vec2(x: sixHW, y: sixMinY),
                Vec2(x: sixHW, y: goalY)
            ],
            color: lineColor,
            lineWidth: 2.0
        )

        // Penalty Spot (Elfmeterpunkt)
        let penSpot = engine.project(Vec3(x: 0, y: PitchConstants.penaltySpotY, z: 0), in: size)
        context.fill(Path(ellipseIn: CGRect(x: penSpot.x - 3.5, y: penSpot.y - 2.5, width: 7.0, height: 5.0)), with: .color(lineColor))

        // Penalty Arc (Halbkreis am Strafraum)
        drawPitchCircle(
            context: &context,
            size: size,
            center: Vec2(x: 0, y: PitchConstants.penaltySpotY),
            radius: 9.15,
            startAngle: 0.65 * .pi,
            endAngle: 1.35 * .pi,
            color: lineColor,
            lineWidth: 2.0
        )
    }

    private func drawPitchPolyLine(context: inout GraphicsContext, size: CGSize, points: [Vec2], color: Color, lineWidth: CGFloat) {
        guard let first = points.first else { return }
        var path = Path()
        path.move(to: engine.project(Vec3(x: first.x, y: first.y, z: 0), in: size))
        for pt in points.dropFirst() {
            path.addLine(to: engine.project(Vec3(x: pt.x, y: pt.y, z: 0), in: size))
        }
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
    }

    private func drawPitchCircle(
        context: inout GraphicsContext,
        size: CGSize,
        center: Vec2,
        radius: Double,
        startAngle: Double,
        endAngle: Double,
        color: Color,
        lineWidth: CGFloat
    ) {
        let segments = 28
        var path = Path()
        for i in 0...segments {
            let t = Double(i) / Double(segments)
            let angle = startAngle + (endAngle - startAngle) * t
            let wx = center.x + sin(angle) * radius
            let wy = center.y + cos(angle) * radius
            if wy <= PitchConstants.penaltyBoxMinY + 0.05 || startAngle == 0 {
                let pt = engine.project(Vec3(x: wx, y: wy, z: 0), in: size)
                if path.isEmpty {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
            }
        }
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }

    // MARK: - 4. Stadium Ad Boards & Corner Flags

    private func drawAdBoardsAndFlags(context: inout GraphicsContext, size: CGSize) {
        let boardY = 56.8
        let boards: [(x0: Double, x1: Double, bg: Color, accent: Color)] = [
            (-32.0, -16.5, Color(red: 0.08, green: 0.18, blue: 0.42), .cyan),
            (-16.2, -7.8, Color(red: 0.55, green: 0.08, blue: 0.14), .yellow),
            (7.8, 16.2, Color(red: 0.06, green: 0.38, blue: 0.24), .green),
            (16.5, 32.0, Color(red: 0.28, green: 0.10, blue: 0.48), .orange)
        ]

        for b in boards {
            let bl = engine.project(Vec3(x: b.x0, y: boardY, z: 0), in: size)
            let br = engine.project(Vec3(x: b.x1, y: boardY, z: 0), in: size)
            let tr = engine.project(Vec3(x: b.x1, y: boardY, z: 1.15), in: size)
            let tl = engine.project(Vec3(x: b.x0, y: boardY, z: 1.15), in: size)

            var path = Path()
            path.move(to: bl)
            path.addLine(to: br)
            path.addLine(to: tr)
            path.addLine(to: tl)
            path.closeSubpath()

            context.fill(path, with: .color(b.bg))
            context.stroke(path, with: .color(b.accent.opacity(0.75)), lineWidth: 1.2)
        }

        // Corner Flags at (-32, 52) and (+32, 52)
        for sign in [-1.0, 1.0] {
            let cx = sign * PitchConstants.halfWidth
            let base = engine.project(Vec3(x: cx, y: PitchConstants.goalLineY, z: 0), in: size)
            let top = engine.project(Vec3(x: cx, y: PitchConstants.goalLineY, z: 1.6), in: size)
            var pole = Path()
            pole.move(to: base)
            pole.addLine(to: top)
            context.stroke(pole, with: .color(.white), lineWidth: 2.0)

            let flutter = sin(engine.matchClockSeconds * 8.0 + sign) * 2.5
            let tx = Double(top.x)
            let ty = Double(top.y)
            var flag = Path()
            flag.move(to: top)
            flag.addLine(to: CGPoint(x: tx + 9.0, y: ty + 3.0 + flutter))
            flag.addLine(to: CGPoint(x: tx, y: ty + 7.0))
            flag.closeSubpath()
            context.fill(flag, with: .color(.yellow))
        }
    }

    // MARK: - 5. Tactical Run Arrows & Open Teammate Highlights

    private func drawTacticalRunIndicators(context: inout GraphicsContext, size: CGSize) {
        let lockedId = engine.currentShotParams?.intendedReceiverId
        let pulse = 0.5 + 0.5 * sin(engine.matchClockSeconds * 6.0)

        for player in engine.players where player.side == .home {
            if player.hasBall {
                // Draw pulsing ring under current ball carrier
                let pos = engine.project(Vec3(x: player.position.x, y: player.position.y, z: 0), in: size)
                let r = 18.0 * engine.perspectiveScale(atY: player.position.y)
                let px = Double(pos.x)
                let py = Double(pos.y)
                let rect = CGRect(x: px - r, y: py - r * 0.58, width: r * 2, height: r * 1.16)
                context.stroke(Path(ellipseIn: rect), with: .color(.cyan.opacity(0.75)), lineWidth: 2.2)
                continue
            }

            let isLocked = (player.id == lockedId)
            let ringColor: Color = isLocked ? .yellow : Color(red: 0.2, green: 0.95, blue: 0.65)

            // Draw pulsing open-pass ring under teammate
            let pScreen = engine.project(Vec3(x: player.position.x, y: player.position.y, z: 0), in: size)
            let r = (16.0 + pulse * 3.5) * engine.perspectiveScale(atY: player.position.y)
            let px = Double(pScreen.x)
            let py = Double(pScreen.y)
            let ringRect = CGRect(x: px - r, y: py - r * 0.58, width: r * 2, height: r * 1.16)
            context.stroke(Path(ellipseIn: ringRect), with: .color(ringColor.opacity(isLocked ? 0.95 : 0.65)), lineWidth: isLocked ? 3.0 : 2.0)

            // Draw dashed tactical run arrow along player.runWaypoints
            if let firstWP = player.runWaypoints.first {
                let wpScreen = engine.project(Vec3(x: firstWP.x, y: firstWP.y, z: 0), in: size)
                var runPath = Path()
                runPath.move(to: pScreen)
                runPath.addLine(to: wpScreen)
                context.stroke(
                    runPath,
                    with: .color(ringColor.opacity(isLocked ? 0.92 : 0.55)),
                    style: StrokeStyle(lineWidth: isLocked ? 3.0 : 2.2, lineCap: .round, dash: [6, 5])
                )

                // Target run circle at waypoint
                let wpR = 9.0 * engine.perspectiveScale(atY: firstWP.y)
                let wx = Double(wpScreen.x)
                let wy = Double(wpScreen.y)
                let wpRect = CGRect(x: wx - wpR, y: wy - wpR * 0.6, width: wpR * 2, height: wpR * 1.2)
                context.fill(Path(ellipseIn: wpRect), with: .color(ringColor.opacity(0.35)))
                context.stroke(Path(ellipseIn: wpRect), with: .color(ringColor.opacity(0.85)), lineWidth: 1.6)
            }
        }
    }

    // MARK: - 6. Real-Time 3D Trajectory Preview Arc

    private func drawTrajectoryPreview(context: inout GraphicsContext, size: CGSize, shot: SwipeShotParameters) {
        let pts = shot.previewPoints
        guard pts.count >= 2 else { return }

        // 1. Ground Shadow Path (z = 0) so height & curve are unmistakable
        var shadowPath = Path()
        for (idx, pt) in pts.enumerated() {
            let groundPt = engine.project(Vec3(x: pt.position.x, y: pt.position.y, z: 0), in: size)
            if idx == 0 {
                shadowPath.move(to: groundPt)
            } else {
                shadowPath.addLine(to: groundPt)
            }
        }
        context.stroke(
            shadowPath,
            with: .color(.black.opacity(0.32)),
            style: StrokeStyle(lineWidth: 3.0, lineCap: .round, dash: [5, 5])
        )

        // 2. 3D Elevated Curved Flight Ribbon
        var airPath = Path()
        for (idx, pt) in pts.enumerated() {
            let screenPt = engine.project(pt.position, in: size)
            if idx == 0 {
                airPath.move(to: screenPt)
            } else {
                airPath.addLine(to: screenPt)
            }
        }

        let isHighCurve = abs(shot.curveNormalized) > 0.25
        let primaryColor: Color = shot.isShotOnGoal
            ? (isHighCurve ? Color(red: 1.0, green: 0.62, blue: 0.12) : Color(red: 1.0, green: 0.85, blue: 0.18))
            : Color(red: 0.22, green: 0.95, blue: 0.72)

        // Outer glow stroke
        context.stroke(
            airPath,
            with: .color(primaryColor.opacity(0.38)),
            style: StrokeStyle(lineWidth: 9.0, lineCap: .round, lineJoin: .round)
        )

        // Inner bright trajectory line
        context.stroke(
            airPath,
            with: .color(.white.opacity(0.92)),
            style: StrokeStyle(lineWidth: 3.2, lineCap: .round, lineJoin: .round, dash: [8, 6])
        )

        // 3. Animated spheres traveling along the trajectory preview
        let phaseShift = (engine.matchClockSeconds * 3.5).truncatingRemainder(dividingBy: 1.0)
        for i in stride(from: 2, to: pts.count, by: 3) {
            let pt = pts[i]
            let sPt = engine.project(pt.position, in: size)
            let radius = max(2.5, (6.5 - pt.progress * 3.0) * engine.perspectiveScale(atY: pt.position.y))
            let sx = Double(sPt.x)
            let sy = Double(sPt.y)
            let dotRect = CGRect(x: sx - radius, y: sy - radius, width: radius * 2, height: radius * 2)
            let alpha = 0.95 - pt.progress * 0.45
            context.fill(Path(ellipseIn: dotRect), with: .color(primaryColor.opacity(alpha)))
        }
        _ = phaseShift

        // 4. Target Reticle at end of preview
        if let lastPt = pts.last {
            let endScreen = engine.project(lastPt.position, in: size)
            let r: CGFloat = 11.0
            let targetRect = CGRect(x: endScreen.x - r, y: endScreen.y - r, width: r * 2, height: r * 2)
            context.stroke(Path(ellipseIn: targetRect), with: .color(primaryColor), lineWidth: 2.5)
            context.fill(Path(ellipseIn: targetRect.insetBy(dx: 6, dy: 6)), with: .color(.white))
        }
    }

    // MARK: - 7. 3D Goal Net Mesh with Dynamic Impact Ripple & Star Target

    private func drawGoalNetMesh(context: inout GraphicsContext, size: CGSize) {
        let hw = PitchConstants.goalHalfWidth
        let goalY = PitchConstants.goalLineY
        let backY = PitchConstants.netBackY
        let topZ = PitchConstants.crossbarHeight

        // Helper that applies dynamic net displacement when the ball hits the net
        func netVertex(_ v: Vec3) -> CGPoint {
            var displaced = v
            if let impact = engine.netImpactPos, engine.netImpactStrength > 0.01 {
                let d = v.distance(to: impact)
                let influence = exp(-d * 0.42) * engine.netImpactStrength
                let wave = cos(d * 2.2 - engine.matchClockSeconds * 18.0)
                displaced.y += influence * (0.95 + 0.35 * wave)
                displaced.x += (v.x - impact.x) * 0.12 * influence
                displaced.z += (v.z - impact.z) * 0.08 * influence
            }
            return engine.project(displaced, in: size)
        }

        let netColor = Color.white.opacity(0.32)

        // Back Net Vertical & Horizontal Mesh Lines
        let cols = 14
        let rows = 6
        for c in 0...cols {
            let x = -hw + (2.0 * hw * Double(c) / Double(cols))
            var path = Path()
            for r in 0...rows {
                let z = topZ * Double(r) / Double(rows)
                let pt = netVertex(Vec3(x: x, y: backY, z: z))
                if r == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            context.stroke(path, with: .color(netColor), lineWidth: 1.0)
        }

        for r in 0...rows {
            let z = topZ * Double(r) / Double(rows)
            var path = Path()
            for c in 0...cols {
                let x = -hw + (2.0 * hw * Double(c) / Double(cols))
                let pt = netVertex(Vec3(x: x, y: backY, z: z))
                if c == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            context.stroke(path, with: .color(netColor), lineWidth: 1.0)
        }

        // Left & Right Side Netting
        for sideX in [-hw, hw] {
            for r in 0...rows {
                let z = topZ * Double(r) / Double(rows)
                var path = Path()
                path.move(to: engine.project(Vec3(x: sideX, y: goalY, z: z), in: size))
                path.addLine(to: netVertex(Vec3(x: sideX, y: backY, z: z)))
                context.stroke(path, with: .color(netColor), lineWidth: 1.0)
            }
            for depthStep in 1...3 {
                let y = goalY + (backY - goalY) * (Double(depthStep) / 4.0)
                var path = Path()
                path.move(to: netVertex(Vec3(x: sideX, y: y, z: 0)))
                path.addLine(to: netVertex(Vec3(x: sideX, y: y, z: topZ)))
                context.stroke(path, with: .color(netColor), lineWidth: 1.0)
            }
        }

        // Top Roof Netting
        for c in stride(from: 0, through: cols, by: 2) {
            let x = -hw + (2.0 * hw * Double(c) / Double(cols))
            var path = Path()
            path.move(to: engine.project(Vec3(x: x, y: goalY, z: topZ), in: size))
            path.addLine(to: netVertex(Vec3(x: x, y: backY, z: topZ)))
            context.stroke(path, with: .color(netColor), lineWidth: 1.0)
        }

        // Dark back-stanchion support frame
        for sideX in [-hw, hw] {
            var stanchion = Path()
            stanchion.move(to: engine.project(Vec3(x: sideX, y: goalY, z: topZ), in: size))
            stanchion.addLine(to: engine.project(Vec3(x: sideX, y: backY, z: topZ), in: size))
            stanchion.addLine(to: engine.project(Vec3(x: sideX, y: backY, z: 0), in: size))
            context.stroke(stanchion, with: .color(Color.white.opacity(0.55)), lineWidth: 2.2)
        }
    }

    private func drawStarTargetZone(context: inout GraphicsContext, size: CGSize) {
        let target = engine.level.starTarget
        let center3D = Vec3(x: target.x, y: PitchConstants.goalLineY + 0.15, z: target.z)
        let centerScreen = engine.project(center3D, in: size)
        let edgeScreen = engine.project(Vec3(x: target.x + target.radius, y: PitchConstants.goalLineY + 0.15, z: target.z), in: size)
        let r = max(12.0, abs(Double(edgeScreen.x - centerScreen.x)))

        let pulse = 1.0 + 0.08 * sin(engine.matchClockSeconds * 5.0)
        let outerR = r * pulse
        let cx = Double(centerScreen.x)
        let cy = Double(centerScreen.y)
        let outerRect = CGRect(x: cx - outerR, y: cy - outerR, width: outerR * 2.0, height: outerR * 2.0)
        let innerRect = outerRect.insetBy(dx: CGFloat(outerR * 0.32), dy: CGFloat(outerR * 0.32))

        let ringColor: Color = engine.hitStarTargetInPlay
            ? Color(red: 0.2, green: 1.0, blue: 0.5)
            : Color(red: 1.0, green: 0.84, blue: 0.0)

        context.fill(Path(ellipseIn: outerRect), with: .color(ringColor.opacity(0.18)))
        context.stroke(
            Path(ellipseIn: outerRect),
            with: .color(ringColor.opacity(0.92)),
            style: StrokeStyle(lineWidth: 2.6, dash: [5, 3])
        )
        context.stroke(Path(ellipseIn: innerRect), with: .color(.white.opacity(0.8)), lineWidth: 1.5)

        // Draw ★ symbol in the center of the target zone
        let starText = Text("★")
            .font(.system(size: CGFloat(max(11.0, outerR * 0.72)), weight: .black))
            .foregroundColor(ringColor)
        context.draw(starText, at: centerScreen)
    }

    private func drawGoalFramePosts(context: inout GraphicsContext, size: CGSize) {
        let hw = PitchConstants.goalHalfWidth
        let goalY = PitchConstants.goalLineY
        let topZ = PitchConstants.crossbarHeight

        let bl = engine.project(Vec3(x: -hw, y: goalY, z: 0), in: size)
        let tl = engine.project(Vec3(x: -hw, y: goalY, z: topZ), in: size)
        let tr = engine.project(Vec3(x: hw, y: goalY, z: topZ), in: size)
        let br = engine.project(Vec3(x: hw, y: goalY, z: 0), in: size)

        var framePath = Path()
        framePath.move(to: bl)
        framePath.addLine(to: tl)
        framePath.addLine(to: tr)
        framePath.addLine(to: br)

        // Subtle outer drop shadow for 3D cylindrical depth
        context.stroke(
            framePath,
            with: .color(.black.opacity(0.45)),
            style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round)
        )
        // Crisp white post & crossbar
        context.stroke(
            framePath,
            with: .color(.white),
            style: StrokeStyle(lineWidth: 5.5, lineCap: .round, lineJoin: .round)
        )
    }

    // MARK: - 8. Depth-Sorted Players & 3D Ball

    private enum RenderableEntity {
        case player(FieldPlayer)
        case ball(BallState)

        var depthY: Double {
            switch self {
            case .player(let p): return p.position.y
            case .ball(let b): return b.position.y - 0.15
            }
        }
    }

    private func drawDepthSortedEntities(context: inout GraphicsContext, size: CGSize) {
        var entities: [RenderableEntity] = engine.players.map { .player($0) }
        entities.append(.ball(engine.ball))
        // Higher Y (closer to goal/background) draws first; lower Y (closer to camera) draws on top
        entities.sort { $0.depthY > $1.depthY }

        for item in entities {
            switch item {
            case .player(let player):
                drawArticulatedPlayer(context: &context, size: size, player: player)
            case .ball(let ballState):
                draw3DBall(context: &context, size: size, ball: ballState)
            }
        }
    }

    // MARK: - 9. Realistic Multi-Jointed 2.5D Football Player Renderer

    private func drawArticulatedPlayer(context: inout GraphicsContext, size: CGSize, player: FieldPlayer) {
        let scale = engine.perspectiveScale(atY: player.position.y)
        let groundScreen = engine.project(Vec3(x: player.position.x, y: player.position.y, z: 0), in: size)
        let bodyBaseScreen = engine.project(Vec3(x: player.position.x, y: player.position.y, z: player.zHeight), in: size)

        // Directional vectors (dirY > 0 = facing goal/away; dirY < 0 = facing camera)
        let dirX = sin(player.facingAngle)
        let dirY = cos(player.facingAngle)
        let facingCamera = (dirY < -0.25)

        // 1. Multi-layer Soft Ground Shadow
        let shadowScale = max(0.45, 1.0 - player.zHeight * 0.22)
        let shadowW = (player.animState == .sliding ? 27.0 : 21.0) * scale * shadowScale
        let shadowH = 9.2 * scale * shadowScale
        let gx = Double(groundScreen.x)
        let gy = Double(groundScreen.y)
        let shadowRect = CGRect(x: gx - shadowW * 0.5, y: gy - shadowH * 0.5, width: shadowW, height: shadowH)
        context.fill(Path(ellipseIn: shadowRect), with: .color(.black.opacity(0.38)))
        context.fill(Path(ellipseIn: shadowRect.insetBy(dx: CGFloat(shadowW * 0.18), dy: CGFloat(shadowH * 0.18))), with: .color(.black.opacity(0.24)))

        // Determine kit colors
        let primaryColor: Color
        let secondaryColor: Color
        let shortsColor: Color

        if player.side == .home {
            let kit = store.activeKit
            primaryColor = Color(hex: kit.primaryHex)
            secondaryColor = Color(hex: kit.secondaryHex)
            shortsColor = Color(hex: kit.shortsHex)
        } else if player.role == .goalkeeper {
            primaryColor = Color(red: 0.95, green: 0.55, blue: 0.12)
            secondaryColor = Color(red: 0.15, green: 0.18, blue: 0.24)
            shortsColor = Color(red: 0.12, green: 0.15, blue: 0.20)
        } else {
            primaryColor = Color(hex: engine.level.awayKitPrimaryHex)
            secondaryColor = Color(hex: engine.level.awayKitSecondaryHex)
            shortsColor = Color(red: 0.14, green: 0.16, blue: 0.22)
        }

        let skinColors: [Color] = [
            Color(red: 0.96, green: 0.80, blue: 0.68),
            Color(red: 0.88, green: 0.68, blue: 0.52),
            Color(red: 0.70, green: 0.48, blue: 0.34),
            Color(red: 0.44, green: 0.29, blue: 0.20)
        ]
        let skinColor = skinColors[player.skinToneIndex % skinColors.count]
        let hairColor = Color(hex: player.hairColorHex)
        let bootColor: Color = (player.side == .home) ? Color(red: 0.98, green: 0.84, blue: 0.15) : Color(red: 0.95, green: 0.28, blue: 0.22)

        // Handle Goalkeeper horizontal dive & Defender sliding tackle offsets
        var diveAngle: Double = 0
        if player.animState == .divingLeft {
            diveAngle = -1.05
        } else if player.animState == .divingRight {
            diveAngle = 1.05
        } else if player.animState == .divingHigh {
            diveAngle = (player.position.x < engine.ball.position.x) ? 0.72 : -0.72
        } else if player.animState == .sliding {
            diveAngle = (dirX >= 0) ? -0.62 : 0.62
        }

        let isMoving = (player.animState == .running || player.animState == .sprinting)
        let isSprinting = (player.animState == .sprinting)
        let phase = player.animPhase

        // Vertical running bounce (twice per stride cycle) & forward sprint lean
        let runBounce = isMoving ? abs(sin(phase)) * (isSprinting ? 2.6 : 1.7) * scale : 0.0
        let sprintLeanX = isMoving ? dirX * (isSprinting ? 4.2 : 2.4) * scale : 0.0
        let slideDropY = (player.animState == .sliding) ? 7.5 * scale : 0.0
        let disappointedSlouchY = (player.animState == .disappointed) ? 2.2 * scale : 0.0

        let baseCx = Double(bodyBaseScreen.x) + sin(diveAngle) * 12.5 * scale
        let footY = Double(bodyBaseScreen.y)
        let hipX = baseCx + sprintLeanX * 0.45
        let hipY = footY - 14.5 * scale - runBounce + slideDropY

        // 2. Articulated 2-Segment Legs (Hip -> Knee -> Ankle/Boot)
        let hipSpread = 3.8 * scale
        let leftHip = CGPoint(x: hipX - hipSpread, y: hipY)
        let rightHip = CGPoint(x: hipX + hipSpread, y: hipY)

        // Biomechanical leg helper
        func computeLegJoints(isRight: Bool) -> (knee: CGPoint, ankle: CGPoint) {
            let hipPt = isRight ? rightHip : leftHip
            let hx = Double(hipPt.x)
            let hy = Double(hipPt.y)

            if player.animState == .sliding {
                // Sliding tackle: one leg extended far forward along tackle direction, other leg tucked
                let slideDir = (dirX >= 0) ? 1.0 : -1.0
                if isRight {
                    let kx = hx + slideDir * 7.5 * scale
                    let ky = hy + 3.5 * scale
                    let ax = hx + slideDir * 15.5 * scale
                    let ay = footY - 1.0 * scale
                    return (CGPoint(x: kx, y: ky), CGPoint(x: ax, y: ay))
                } else {
                    let kx = hx - slideDir * 3.5 * scale
                    let ky = hy + 5.0 * scale
                    let ax = hx - slideDir * 7.5 * scale
                    let ay = footY - 1.5 * scale
                    return (CGPoint(x: kx, y: ky), CGPoint(x: ax, y: ay))
                }
            }

            if player.animState == .kicking && isRight {
                let kx = hx + dirX * 5.0 * scale + 2.0 * scale
                let ky = hy + 3.5 * scale
                let ax = hx + dirX * 10.5 * scale + 3.5 * scale
                let ay = hy + 5.5 * scale
                return (CGPoint(x: kx, y: ky), CGPoint(x: ax, y: ay))
            } else if player.animState == .windingUp && isRight {
                let kx = hx - dirX * 3.0 * scale + 1.5 * scale
                let ky = hy + 6.5 * scale
                let ax = hx - dirX * 5.5 * scale + 2.5 * scale
                let ay = hy + 4.5 * scale
                return (CGPoint(x: kx, y: ky), CGPoint(x: ax, y: ay))
            }

            if isMoving {
                let legPhase = isRight ? (phase + .pi) : phase
                let swing = sin(legPhase) // -1 (back) to +1 (forward)
                let kneeDrive = max(0.0, cos(legPhase)) // Knee lifts as leg swings forward
                let heelKick = max(0.0, -sin(legPhase)) // Heel kicks up behind when pushing off
                let strideAmp = (isSprinting ? 7.2 : 5.0) * scale

                // Lateral & depth projection of stride
                let swingX = swing * dirX * strideAmp
                let swingY = -swing * dirY * strideAmp * 0.58

                let kx = hx + swingX * 0.55 + dirX * kneeDrive * 2.2 * scale
                let ky = hy + 7.2 * scale + swingY * 0.45 - kneeDrive * 3.8 * scale
                let ax = hx + swingX - dirX * heelKick * 2.8 * scale
                let ay = footY - runBounce * 0.3 + swingY - kneeDrive * 2.4 * scale - heelKick * 5.2 * scale
                return (CGPoint(x: kx, y: ky), CGPoint(x: ax, y: ay))
            } else {
                // Athletic ready stance
                let stanceShift = isRight ? 1.0 : -1.0
                let kx = hx + stanceShift * 0.8 * scale
                let ky = hy + 7.2 * scale
                let ax = hx + stanceShift * 1.2 * scale
                let ay = footY
                return (CGPoint(x: kx, y: ky), CGPoint(x: ax, y: ay))
            }
        }

        let leftLegJoints = computeLegJoints(isRight: false)
        let rightLegJoints = computeLegJoints(isRight: true)

        func drawSingleLeg(hip: CGPoint, knee: CGPoint, ankle: CGPoint) {
            // Upper thigh (Shorts leg + Skin knee)
            var thigh = Path()
            thigh.move(to: hip)
            thigh.addLine(to: knee)
            context.stroke(thigh, with: .color(skinColor), style: StrokeStyle(lineWidth: CGFloat(4.4 * scale), lineCap: .round))

            // Lower leg (Team Sock / Stutzen)
            var calf = Path()
            calf.move(to: knee)
            calf.addLine(to: ankle)
            context.stroke(calf, with: .color(primaryColor), style: StrokeStyle(lineWidth: CGFloat(3.9 * scale), lineCap: .round))

            // Sock top stripe just below knee
            let sockTop = CGPoint(
                x: Double(knee.x) * 0.78 + Double(ankle.x) * 0.22,
                y: Double(knee.y) * 0.78 + Double(ankle.y) * 0.22
            )
            var sockBand = Path()
            sockBand.move(to: knee)
            sockBand.addLine(to: sockTop)
            context.stroke(sockBand, with: .color(secondaryColor), style: StrokeStyle(lineWidth: CGFloat(4.1 * scale), lineCap: .round))

            // Cleated Football Boot
            let ax = Double(ankle.x)
            let ay = Double(ankle.y)
            let bootToeOffset = (abs(dirX) > 0.25 ? (dirX >= 0 ? 3.4 : -3.4) : 1.8) * scale
            var bootPath = Path()
            bootPath.move(to: CGPoint(x: ax - 1.8 * scale, y: ay))
            bootPath.addLine(to: CGPoint(x: ax + bootToeOffset, y: ay + 0.6 * scale))
            context.stroke(bootPath, with: .color(bootColor), style: StrokeStyle(lineWidth: CGFloat(3.4 * scale), lineCap: .round))
        }

        // Draw back leg first based on facing direction
        if dirX >= 0 {
            drawSingleLeg(hip: leftHip, knee: leftLegJoints.knee, ankle: leftLegJoints.ankle)
            drawSingleLeg(hip: rightHip, knee: rightLegJoints.knee, ankle: rightLegJoints.ankle)
        } else {
            drawSingleLeg(hip: rightHip, knee: rightLegJoints.knee, ankle: rightLegJoints.ankle)
            drawSingleLeg(hip: leftHip, knee: leftLegJoints.knee, ankle: leftLegJoints.ankle)
        }

        // 3. Athletic Shorts with Side Trim
        let shortsW = 14.8 * scale
        let shortsH = 7.8 * scale
        let shortsRect = CGRect(x: hipX - shortsW * 0.5, y: hipY - 3.6 * scale, width: shortsW, height: shortsH)
        let shortsPath = Path(roundedRect: shortsRect, cornerRadius: CGFloat(2.8 * scale))
        context.fill(shortsPath, with: .color(shortsColor))
        // Side trim stripes on shorts
        let trimRectL = CGRect(x: hipX - shortsW * 0.48, y: hipY - 3.0 * scale, width: 1.8 * scale, height: shortsH - 1.2 * scale)
        let trimRectR = CGRect(x: hipX + shortsW * 0.48 - 1.8 * scale, y: hipY - 3.0 * scale, width: 1.8 * scale, height: shortsH - 1.2 * scale)
        context.fill(Path(trimRectL), with: .color(secondaryColor.opacity(0.85)))
        context.fill(Path(trimRectR), with: .color(secondaryColor.opacity(0.85)))

        // 4. Sculpted Athletic V-Tapered Torso & Jersey
        let shoulderW = 17.8 * scale
        let waistW = 13.6 * scale
        let torsoH = 16.5 * scale
        let shoulderCx = hipX + sprintLeanX * 0.55
        let shoulderY = hipY - torsoH + disappointedSlouchY
        let waistY = hipY - 1.0 * scale

        var torsoPath = Path()
        torsoPath.move(to: CGPoint(x: shoulderCx - shoulderW * 0.5, y: shoulderY + 2.2 * scale))
        torsoPath.addQuadCurve(
            to: CGPoint(x: shoulderCx + shoulderW * 0.5, y: shoulderY + 2.2 * scale),
            control: CGPoint(x: shoulderCx, y: shoulderY - 1.2 * scale)
        )
        torsoPath.addLine(to: CGPoint(x: hipX + waistW * 0.5, y: waistY))
        torsoPath.addLine(to: CGPoint(x: hipX - waistW * 0.5, y: waistY))
        torsoPath.closeSubpath()

        context.fill(torsoPath, with: .color(primaryColor))

        // Vertical Jersey Center Stripe & Collar
        let stripeW = shoulderW * 0.22
        var stripePath = Path()
        stripePath.move(to: CGPoint(x: shoulderCx - stripeW * 0.5, y: shoulderY + 1.0 * scale))
        stripePath.addLine(to: CGPoint(x: shoulderCx + stripeW * 0.5, y: shoulderY + 1.0 * scale))
        stripePath.addLine(to: CGPoint(x: hipX + stripeW * 0.45, y: waistY))
        stripePath.addLine(to: CGPoint(x: hipX - stripeW * 0.45, y: waistY))
        stripePath.closeSubpath()
        context.fill(stripePath, with: .color(secondaryColor.opacity(0.88)))

        // Jersey Collar rim
        let collarRect = CGRect(x: shoulderCx - 3.8 * scale, y: shoulderY - 0.4 * scale, width: 7.6 * scale, height: 3.0 * scale)
        context.stroke(Path(ellipseIn: collarRect), with: .color(secondaryColor), lineWidth: CGFloat(1.6 * scale))
        context.stroke(torsoPath, with: .color(.black.opacity(0.38)), lineWidth: 1.0)

        // 5. Squad Number (Large on back when facing goal, small chest badge when facing camera)
        let numFontSize = facingCamera ? max(6.5, 7.8 * scale) : max(8.5, 10.4 * scale)
        let numY = facingCamera ? (shoulderY + torsoH * 0.42) : (shoulderY + torsoH * 0.50)
        let numText = Text("\(player.shirtNumber)")
            .font(.system(size: CGFloat(numFontSize), weight: .black, design: .rounded))
            .foregroundColor(.white)
        context.draw(numText, at: CGPoint(x: (shoulderCx + hipX) * 0.5, y: numY))

        // 6. Articulated 2-Segment Arms (Shoulder -> Elbow -> Hand/Glove) with Jersey Sleeves
        let leftShoulder = CGPoint(x: shoulderCx - shoulderW * 0.48, y: shoulderY + 2.8 * scale)
        let rightShoulder = CGPoint(x: shoulderCx + shoulderW * 0.48, y: shoulderY + 2.8 * scale)

        let headR = 6.2 * scale
        let headCx = shoulderCx + sprintLeanX * 0.25
        let headCy = shoulderY - headR * 0.92 + disappointedSlouchY * 0.6

        func drawSingleArm(isRight: Bool) {
            let sh = isRight ? rightShoulder : leftShoulder
            let sx = Double(sh.x)
            let sy = Double(sh.y)
            let sideSign = isRight ? 1.0 : -1.0

            let elbow: CGPoint
            let hand: CGPoint

            if player.animState == .celebrating || player.animState == .divingHigh || player.animState == .divingLeft || player.animState == .divingRight {
                // Arms raised high in celebration or full-stretch goalkeeper dive
                elbow = CGPoint(x: sx + sideSign * 4.2 * scale, y: sy - 5.5 * scale)
                hand = CGPoint(x: sx + sideSign * 7.2 * scale, y: sy - 12.2 * scale)
            } else if player.animState == .disappointed {
                // Disappointed: Both hands raised onto the top of the head in disbelief!
                elbow = CGPoint(x: sx + sideSign * 5.2 * scale, y: sy - 4.0 * scale)
                hand = CGPoint(x: headCx + sideSign * 2.8 * scale, y: headCy - headR * 0.65)
            } else if isMoving {
                // Counter-swinging sprinter arms with bent elbows (~85 degrees)
                let armPhase = isRight ? phase : (phase + .pi)
                let armSwing = sin(armPhase)
                let amp = (isSprinting ? 5.5 : 3.8) * scale
                let ex = sx + sideSign * 2.2 * scale - armSwing * dirX * amp * 0.55
                let ey = sy + 5.8 * scale + armSwing * 2.6 * scale
                let hx = ex + sideSign * 0.6 * scale + armSwing * dirX * amp * 0.75
                let hy = ey + 2.2 * scale - max(0.0, armSwing) * 4.6 * scale
                elbow = CGPoint(x: ex, y: ey)
                hand = CGPoint(x: hx, y: hy)
            } else {
                elbow = CGPoint(x: sx + sideSign * 2.4 * scale, y: sy + 5.8 * scale)
                hand = CGPoint(x: sx + sideSign * 3.0 * scale, y: sy + 10.5 * scale)
            }

            // Jersey Short Sleeve (Shoulder -> halfway to Elbow)
            let sleeveEnd = CGPoint(
                x: (sx + Double(elbow.x)) * 0.55,
                y: (sy + Double(elbow.y)) * 0.55
            )
            var sleevePath = Path()
            sleevePath.move(to: sh)
            sleevePath.addLine(to: sleeveEnd)
            context.stroke(sleevePath, with: .color(primaryColor), style: StrokeStyle(lineWidth: CGFloat(4.4 * scale), lineCap: .round))

            // Forearm (Skin)
            var armPath = Path()
            armPath.move(to: sleeveEnd)
            armPath.addLine(to: elbow)
            armPath.addLine(to: hand)
            context.stroke(armPath, with: .color(skinColor), style: StrokeStyle(lineWidth: CGFloat(3.4 * scale), lineCap: .round, lineJoin: .round))

            // Hand or Goalkeeper Glove
            let handR = (player.role == .goalkeeper ? 3.0 : 1.9) * scale
            let handColor: Color = (player.role == .goalkeeper) ? .white : skinColor
            let handRect = CGRect(x: Double(hand.x) - handR, y: Double(hand.y) - handR, width: handR * 2, height: handR * 2)
            context.fill(Path(ellipseIn: handRect), with: .color(handColor))
        }

        drawSingleArm(isRight: false)
        drawSingleArm(isRight: true)

        // 7. Neck, Head, Face & Sculpted Hairstyle
        let neckRect = CGRect(x: headCx - 2.2 * scale, y: shoulderY - 3.2 * scale, width: 4.4 * scale, height: 4.2 * scale)
        context.fill(Path(roundedRect: neckRect, cornerRadius: CGFloat(1.5 * scale)), with: .color(skinColor))

        let headCenter = CGPoint(x: headCx, y: headCy)
        let headRect = CGRect(x: headCx - headR, y: headCy - headR, width: headR * 2, height: headR * 2)

        // Ears
        let earR = 1.6 * scale
        context.fill(Path(ellipseIn: CGRect(x: headCx - headR - earR * 0.4, y: headCy - earR, width: earR * 2, height: earR * 2)), with: .color(skinColor))
        context.fill(Path(ellipseIn: CGRect(x: headCx + headR - earR * 1.6, y: headCy - earR, width: earR * 2, height: earR * 2)), with: .color(skinColor))

        // Head Sphere
        context.fill(Path(ellipseIn: headRect), with: .color(skinColor))

        if facingCamera {
            // Facial features (eyes & brow) when player faces the camera
            let eyeY = headCy + 0.4 * scale
            let eyeSpread = 2.2 * scale
            let eyeR = 0.85 * scale
            context.fill(Path(ellipseIn: CGRect(x: headCx - eyeSpread - eyeR, y: eyeY - eyeR, width: eyeR * 2, height: eyeR * 2)), with: .color(.black.opacity(0.8)))
            context.fill(Path(ellipseIn: CGRect(x: headCx + eyeSpread - eyeR, y: eyeY - eyeR, width: eyeR * 2, height: eyeR * 2)), with: .color(.black.opacity(0.8)))

            // Top hair crown when facing camera
            var hairFront = Path()
            hairFront.addArc(center: headCenter, radius: CGFloat(headR * 1.04), startAngle: .degrees(190), endAngle: .degrees(350), clockwise: false)
            hairFront.closeSubpath()
            context.fill(hairFront, with: .color(hairColor))
        } else {
            // Full back-of-head athletic haircut when facing toward the goal
            var hairBack = Path()
            hairBack.addArc(center: headCenter, radius: CGFloat(headR * 1.04), startAngle: .degrees(155), endAngle: .degrees(25), clockwise: false)
            hairBack.closeSubpath()
            context.fill(hairBack, with: .color(hairColor))
        }

        // 8. Player Name / Tactical Callout Pill above head
        if engine.phase == .tacticalAiming && player.side == .home && !player.hasBall,
           let callout = player.passCalloutText {
            let isLocked = (engine.currentShotParams?.intendedReceiverId == player.id)
            let pillY = headCy - headR - 11.0 * scale
            let pillW: Double = isLocked ? 54.0 : 44.0
            let pillH: Double = 15.0
            let pillRect = CGRect(x: headCx - pillW * 0.5, y: pillY - pillH * 0.5, width: pillW, height: pillH)
            context.fill(Path(roundedRect: pillRect, cornerRadius: 7.5), with: .color(isLocked ? .yellow : Color.black.opacity(0.72)))
            let label = Text(isLocked ? "PASS!" : callout)
                .font(.system(size: 8.5, weight: .heavy))
                .foregroundColor(isLocked ? .black : .white)
            context.draw(label, at: CGPoint(x: headCx, y: pillY))
        }
    }

    // MARK: - 10. 3D Ball with Shadow, Motion Trail & Rotating Panels

    private func draw3DBall(context: inout GraphicsContext, size: CGSize, ball: BallState) {
        let ballDesign = store.activeBall
        let trailColor = Color(hex: ballDesign.trailColorHex)

        // 1. Flight Motion Trail
        if ball.trail.count >= 2 {
            for i in 1..<ball.trail.count {
                let p0 = engine.project(ball.trail[i - 1].position, in: size)
                let p1 = engine.project(ball.trail[i].position, in: size)
                let frac = Double(i) / Double(ball.trail.count)
                var seg = Path()
                seg.move(to: p0)
                seg.addLine(to: p1)
                context.stroke(
                    seg,
                    with: .color(trailColor.opacity(frac * 0.65)),
                    style: StrokeStyle(lineWidth: CGFloat(frac * 7.5), lineCap: .round)
                )
            }
        }

        let scale = engine.perspectiveScale(atY: ball.position.y)
        let groundShadowPt = engine.project(Vec3(x: ball.position.x, y: ball.position.y, z: 0), in: size)
        let ballScreenPt = engine.project(ball.position, in: size)

        // 2. Ground Shadow (shrinks and softens with height z)
        let heightFactor = max(0.35, 1.0 - ball.position.z * 0.14)
        let shadowR = 8.0 * scale * heightFactor
        let sx = Double(groundShadowPt.x)
        let sy = Double(groundShadowPt.y)
        let shadowRect = CGRect(x: sx - shadowR, y: sy - shadowR * 0.55, width: shadowR * 2, height: shadowR * 1.1)
        context.fill(Path(ellipseIn: shadowRect), with: .color(.black.opacity(0.42 * heightFactor)))

        // 3. Ball Sphere & Rotating Pentagon Panels
        let r = max(5.5, 8.2 * scale)
        let bx = Double(ballScreenPt.x)
        let by = Double(ballScreenPt.y)
        let ballRect = CGRect(x: bx - r, y: by - r, width: r * 2, height: r * 2)

        // Spin Aura when ball has strong Magnus curve
        if abs(ball.spinZ) > 2.6 && engine.phase == .ballInFlight {
            let auraRect = ballRect.insetBy(dx: -3.5, dy: -3.5)
            context.stroke(Path(ellipseIn: auraRect), with: .color(trailColor.opacity(0.75)), lineWidth: 2.0)
        }

        // Base white leather sphere
        context.fill(Path(ellipseIn: ballRect), with: .color(.white))

        // Rotating panel spots inside the sphere
        let panelColor = Color(hex: ballDesign.panelColorHex)
        let accentColor = Color(hex: ballDesign.accentColorHex)
        for pIdx in 0..<4 {
            let angle = ball.rotationAngle + Double(pIdx) * (.pi * 0.5)
            let px = bx + cos(angle) * r * 0.46
            let py = by + sin(angle * 0.8) * r * 0.46
            let pR = r * 0.34
            let pRect = CGRect(x: px - pR, y: py - pR, width: pR * 2, height: pR * 2)
            context.fill(Path(ellipseIn: pRect), with: .color(pIdx % 2 == 0 ? panelColor : accentColor))
        }

        // Outer rim stroke
        context.stroke(Path(ellipseIn: ballRect), with: .color(.black.opacity(0.65)), lineWidth: 1.3)
    }

    // MARK: - 11. Particles Renderer

    private func drawParticles(context: inout GraphicsContext, size: CGSize) {
        for p in engine.particles {
            let pt = engine.project(p.position, in: size)
            let alpha = max(0.0, 1.0 - (p.life / p.maxLife))
            let s = p.size * alpha
            let px = Double(pt.x)
            let py = Double(pt.y)
            let rect = CGRect(x: px - s * 0.5, y: py - s * 0.5, width: s, height: s)
            context.fill(Path(ellipseIn: rect), with: .color(p.color.opacity(alpha)))
        }
    }

    // MARK: - 12. Dynamic Finger Swipe / Flick Slash Renderer

    private func drawFingerSwipeSlash(context: inout GraphicsContext) {
        let activePoints = engine.isDraggingSwipe ? engine.touchPoints : engine.fadingSwipePoints
        let baseAlpha = engine.isDraggingSwipe ? 1.0 : engine.fadingSwipeAlpha
        guard activePoints.count >= 2 && baseAlpha > 0.02 else { return }

        let glowColor = Color(hex: store.activeBall.trailColorHex)
        let count = activePoints.count

        // Draw tapered comet-style swipe ribbon segments
        for i in 1..<count {
            let p0 = activePoints[i - 1]
            let p1 = activePoints[i]
            let progress = Double(i) / Double(count - 1)
            let width = CGFloat(2.0 + progress * 9.5)

            var seg = Path()
            seg.move(to: p0)
            seg.addLine(to: p1)

            // Outer neon glow
            context.stroke(
                seg,
                with: .color(glowColor.opacity(baseAlpha * progress * 0.52)),
                style: StrokeStyle(lineWidth: width * 1.9, lineCap: .round, lineJoin: .round)
            )
            // Crisp white core slash
            context.stroke(
                seg,
                with: .color(Color.white.opacity(baseAlpha * (0.35 + progress * 0.65))),
                style: StrokeStyle(lineWidth: width * 0.72, lineCap: .round, lineJoin: .round)
            )
        }

        // Glowing tip spark at the finger / end of swipe
        if let tip = activePoints.last {
            let r: Double = 6.5
            let tx = Double(tip.x)
            let ty = Double(tip.y)
            let tipRect = CGRect(x: tx - r, y: ty - r, width: r * 2.0, height: r * 2.0)
            context.fill(Path(ellipseIn: tipRect), with: .color(glowColor.opacity(baseAlpha * 0.85)))
            context.fill(Path(ellipseIn: tipRect.insetBy(dx: 2.5, dy: 2.5)), with: .color(Color.white.opacity(baseAlpha)))
        }
    }
}
