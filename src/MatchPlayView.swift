import SwiftUI
import Combine

struct MatchPlayView: View {
    @EnvironmentObject var store: GameStore
    @EnvironmentObject var sound: SoundManager
    @StateObject private var engine: PhysicsEngine

    @State private var isPaused: Bool = false
    @State private var showTacticalHintSheet: Bool = false

    private let frameTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    init(levelId: Int) {
        let lvl = LevelDatabase.level(for: levelId)
        _engine = StateObject(wrappedValue: PhysicsEngine(level: lvl))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Interactive 2.5D Pitch & Touch Gesture Layer
                PitchRendererView(engine: engine)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard !isPaused else { return }
                                if !engine.isDraggingSwipe {
                                    engine.beginSwipe(at: value.startLocation, in: geo.size)
                                }
                                engine.updateSwipe(at: value.location, in: geo.size)
                            }
                            .onEnded { value in
                                guard !isPaused else { return }
                                if !engine.isDraggingSwipe {
                                    engine.beginSwipe(at: value.startLocation, in: geo.size)
                                }
                                engine.endSwipe(at: value.location, predictedEnd: value.predictedEndLocation, in: geo.size)
                            }
                    )
                    .ignoresSafeArea()

                // 2. Top Broadcast HUD & Bottom Telemetry
                VStack(spacing: 0) {
                    topBroadcastScoreboard
                        .padding(.horizontal, 12)
                        .padding(.top, 4)

                    tacticalTelemetrySubBar
                        .padding(.horizontal, 12)
                        .padding(.top, 6)

                    if showTacticalHintSheet || engine.attemptsInLevel >= 3 {
                        tacticalCoachBanner
                            .padding(.horizontal, 14)
                            .padding(.top, 6)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Spacer()

                    bottomContextualHUD
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                }

                // 3. Instant Replay Broadcast TV Overlay
                if engine.phase == .instantReplay {
                    instantReplayOverlay
                }

                // 4. Play Failed Overlay
                if case .playFailed(let reason) = engine.phase {
                    playFailedOverlay(reason: reason)
                }

                // 5. Level Complete 3-Star Celebration Overlay
                if case .levelComplete(let stars, let coinsEarned, let hitStarTarget) = engine.phase {
                    levelCompleteOverlay(stars: stars, coinsEarned: coinsEarned, hitStarTarget: hitStarTarget)
                }

                // 6. Pause Menu Modal
                if isPaused {
                    pauseMenuOverlay
                }
            }
        }
        .onAppear {
            engine.bindStore(store)
            sound.startStadiumAmbience()
        }
        .onDisappear {
            sound.stopStadiumAmbience()
        }
        .onReceive(frameTimer) { _ in
            guard !isPaused else { return }
            engine.update(dt: 1.0 / 60.0)
        }
    }

    // MARK: - Top Broadcast Scoreboard

    private var topBroadcastScoreboard: some View {
        HStack(spacing: 8) {
            // Pause Button
            Button {
                sound.play(.menuClick)
                isPaused = true
            } label: {
                Image(systemName: "pause.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.62))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.22), lineWidth: 1))
            }

            // Broadcast Scoreboard Pill
            HStack(spacing: 8) {
                // Home Club
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color(hex: store.activeKit.primaryHex))
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color(hex: store.activeKit.secondaryHex), lineWidth: 1.5))
                    Text(shortTeamCode(engine.level.homeTeamName))
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }

                // Score & Minute
                VStack(spacing: 1) {
                    Text(engine.phase == .goalCelebration ? updatedGoalScore(engine.level.scoreContext) : engine.level.scoreContext)
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                    Text(engine.level.matchMinute)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.10))
                .cornerRadius(6)

                // Away Club
                HStack(spacing: 5) {
                    Text(shortTeamCode(engine.level.awayTeamName))
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Circle()
                        .fill(Color(hex: engine.level.awayKitPrimaryHex))
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color(hex: engine.level.awayKitSecondaryHex), lineWidth: 1.5))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.06, green: 0.10, blue: 0.18).opacity(0.90), Color(red: 0.10, green: 0.16, blue: 0.28).opacity(0.90)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))

            Spacer(minLength: 2)

            // Tactical Hint Button
            Button {
                sound.play(.menuClick)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    showTacticalHintSheet.toggle()
                }
            } label: {
                Image(systemName: showTacticalHintSheet ? "lightbulb.fill" : "lightbulb")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(showTacticalHintSheet ? .yellow : .white)
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.62))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(showTacticalHintSheet ? Color.yellow.opacity(0.7) : Color.white.opacity(0.22), lineWidth: 1))
            }

            // Instant Restart Button
            Button {
                sound.play(.menuClick)
                engine.retryCurrentLevel()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.62))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.22), lineWidth: 1))
            }
        }
    }

    private var tacticalTelemetrySubBar: some View {
        HStack(spacing: 8) {
            // Level & Scenario Tag
            HStack(spacing: 5) {
                Text("LVL \(engine.level.id)")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(engine.level.scenarioType.badgeColor)
                    .cornerRadius(5)

                Text(engine.level.scenarioType.rawValue.uppercased())
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.55))
            .clipShape(Capsule())

            // Pass Progress Pill
            if engine.level.recommendedPasses > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.swap")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.cyan)
                    Text("Pässe: \(engine.passesInCurrentPlay)/\(engine.level.recommendedPasses)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(engine.passesInCurrentPlay >= engine.level.recommendedPasses ? .green : .white)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.55))
                .clipShape(Capsule())
            }

            Spacer()

            // Wind Indicator Pill
            if abs(engine.level.windSpeed) > 0.05 {
                HStack(spacing: 4) {
                    Image(systemName: "wind")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f m/s %@", abs(engine.level.windSpeed), engine.level.windSpeed > 0 ? "→" : "←"))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.55))
                .clipShape(Capsule())
            }
        }
    }

    private var tacticalCoachBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "person.wave.2.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.yellow)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text("TRAINER-TIPP: \(engine.level.title.uppercased())")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)
                Text(engine.level.tacticalHint)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color(red: 0.06, green: 0.11, blue: 0.20).opacity(0.90))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.yellow.opacity(0.45), lineWidth: 1))
    }

    // MARK: - Bottom Contextual HUD (Live Swipe Telemetry & Objective)

    @ViewBuilder
    private var bottomContextualHUD: some View {
        if let shot = engine.currentShotParams {
            // Live Swipe Power, Curve & Action Readout
            HStack(spacing: 12) {
                // Action Type Badge
                HStack(spacing: 6) {
                    Image(systemName: shot.isShotOnGoal ? "flame.fill" : "arrow.up.right.circle.fill")
                        .foregroundColor(shot.isShotOnGoal ? .orange : .cyan)
                    Text(shot.isShotOnGoal ? "TORSCHUSS" : (shot.intendedReceiverId != nil ? "STEILPASS" : "FLACHPASS"))
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }

                Divider().frame(height: 18).background(Color.white.opacity(0.3))

                // Power Bar
                VStack(alignment: .leading, spacing: 2) {
                    Text("KRAFT \(Int(shot.powerNormalized * 100))%")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))
                    GeometryReader { barGeo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.2))
                            Capsule()
                                .fill(LinearGradient(colors: [.green, .yellow, .red], startPoint: .leading, endPoint: .trailing))
                                .frame(width: barGeo.size.width * CGFloat(shot.powerNormalized))
                        }
                    }
                    .frame(width: 68, height: 6)
                }

                Divider().frame(height: 18).background(Color.white.opacity(0.3))

                // Curve / Magnus Spin Indicator
                VStack(alignment: .leading, spacing: 2) {
                    Text("EFFET / DRALL")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))
                    let curvePct = Int(abs(shot.curveNormalized) * 100)
                    let curveDir = shot.curveNormalized < -0.08 ? "↶ Links" : (shot.curveNormalized > 0.08 ? "↷ Rechts" : "Gerade")
                    Text(curvePct > 8 ? "\(curveDir) (\(curvePct)%)" : "Direkt")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(curvePct > 25 ? .yellow : .cyan)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.76))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
        } else if engine.phase == .tacticalAiming, let banner = engine.statusBannerText {
            HStack(spacing: 8) {
                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.yellow)
                Text(banner)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.70))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.yellow.opacity(0.45), lineWidth: 1))
        } else if engine.phase == .goalCelebration {
            HStack(spacing: 8) {
                Image(systemName: "soccerball")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.yellow)
                Text(engine.statusBannerText ?? "TOOOOR!")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.82))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.yellow, lineWidth: 1.5))
        }
    }

    // MARK: - TV Broadcast Instant Replay Overlay

    private var instantReplayOverlay: some View {
        ZStack {
            // Broadcast frame border
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.55), lineWidth: 3)
                .padding(8)
                .ignoresSafeArea()

            VStack {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 9, height: 9)
                        Text("TV-TORWIEDERHOLUNG • 0.5x")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.78))
                    .clipShape(Capsule())

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 58)

                Spacer()

                HStack {
                    Spacer()
                    Button {
                        sound.play(.menuClick)
                        engine.skipInstantReplay()
                    } label: {
                        HStack(spacing: 6) {
                            Text("WEITER")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                            Image(systemName: "forward.end.fill")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.yellow)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.4), radius: 6)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Play Failed Overlay

    private func playFailedOverlay(reason: String) -> some View {
        ZStack {
            Color.black.opacity(0.48)
                .ignoresSafeArea()
                .onTapGesture {
                    sound.play(.menuClick)
                    engine.retryCurrentLevel()
                }

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)

                Text("SPIELZUG GESTOPPT")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text(reason)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                // Helpful tactical hint box
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text(engine.level.tacticalHint)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.leading)
                }
                .padding(10)
                .background(Color.white.opacity(0.08))
                .cornerRadius(10)

                HStack(spacing: 12) {
                    Button {
                        sound.play(.menuClick)
                        store.currentScreen = .levelSelect
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.grid.2x2.fill")
                            Text("LEVEL")
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 13)
                        .background(Color.white.opacity(0.16))
                        .cornerRadius(12)
                    }

                    Button {
                        sound.play(.menuClick)
                        engine.retryCurrentLevel()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("SOFORT WIEDERHOLEN")
                        }
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 13)
                        .background(
                            LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(12)
                    }
                }
            }
            .padding(22)
            .frame(maxWidth: 345)
            .background(Color(red: 0.07, green: 0.11, blue: 0.20).opacity(0.96))
            .cornerRadius(22)
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.orange.opacity(0.55), lineWidth: 1.5))
            .shadow(color: .black.opacity(0.6), radius: 18)
        }
    }

    // MARK: - 3-Star Level Complete Modal

    private func levelCompleteOverlay(stars: Int, coinsEarned: Int, hitStarTarget: Bool) -> some View {
        ZStack {
            Color.black.opacity(0.62)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("TOR & SIEG!")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)

                Text("Level \(engine.level.id): \(engine.level.title)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.88))

                // 3 Stars Row
                HStack(spacing: 14) {
                    ForEach(1...3, id: \.self) { idx in
                        Image(systemName: idx <= stars ? "star.fill" : "star")
                            .font(.system(size: idx == 2 ? 42 : 34, weight: .black))
                            .foregroundColor(idx <= stars ? .yellow : .white.opacity(0.25))
                            .shadow(color: idx <= stars ? .orange.opacity(0.7) : .clear, radius: 8)
                    }
                }
                .padding(.vertical, 4)

                // Rating Criteria Breakdown
                VStack(alignment: .leading, spacing: 7) {
                    criterionRow(
                        met: true,
                        text: "Entscheidendes Tor erzielt (★)"
                    )
                    criterionRow(
                        met: stars >= 2,
                        text: engine.level.recommendedPasses > 0
                            ? "Spielzug-Kombination oder Par (\(engine.level.parAttempts) Versuche) (★★)"
                            : "In maximal \(engine.level.parAttempts) Versuchen verwandelt (★★)"
                    )
                    criterionRow(
                        met: stars >= 3,
                        text: hitStarTarget
                            ? "Stern-Zielring im Torwinkel getroffen! (★★★)"
                            : "Stern-Ring treffen oder 1. Versuch mit Effet/Kombi (★★★)"
                    )
                }
                .padding(12)
                .background(Color.white.opacity(0.07))
                .cornerRadius(12)

                // Reward Coins Badge
                HStack(spacing: 8) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                    Text("+\(coinsEarned) Karriere-Münzen")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.16))
                .clipShape(Capsule())

                // Action Buttons
                HStack(spacing: 10) {
                    Button {
                        sound.play(.menuClick)
                        engine.setupPlay(resetAttempts: true)
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 46, height: 46)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(12)
                    }

                    if !engine.replayFrames.isEmpty {
                        Button {
                            sound.play(.menuClick)
                            engine.startInstantReplay()
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "video.fill")
                                Text("REPLAY")
                            }
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.cyan)
                            .padding(.horizontal, 14)
                            .frame(height: 46)
                            .background(Color.cyan.opacity(0.16))
                            .cornerRadius(12)
                        }
                    }

                    Button {
                        sound.play(.menuClick)
                        let nextId = engine.level.id + 1
                        if nextId <= LevelDatabase.levels.count {
                            let nextLvl = LevelDatabase.level(for: nextId)
                            store.selectedChapterId = nextLvl.chapterId
                            engine.loadLevel(nextLvl)
                        } else {
                            store.currentScreen = .careerHub
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(engine.level.id < LevelDatabase.levels.count ? "NÄCHSTES LEVEL" : "WELTMEISTER-EHRUNG")
                            Image(systemName: "play.fill")
                        }
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            LinearGradient(colors: [Color(red: 0.2, green: 0.92, blue: 0.48), Color(red: 0.1, green: 0.75, blue: 0.38)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(12)
                    }
                }
            }
            .padding(22)
            .frame(maxWidth: 355)
            .background(Color(red: 0.06, green: 0.11, blue: 0.19).opacity(0.97))
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.yellow.opacity(0.55), lineWidth: 1.5))
            .shadow(color: .black.opacity(0.65), radius: 20)
        }
    }

    private func criterionRow(met: Bool, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .foregroundColor(met ? .green : .white.opacity(0.35))
                .font(.system(size: 14, weight: .bold))
            Text(text)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundColor(met ? .white : .white.opacity(0.55))
        }
    }

    // MARK: - Pause Menu Overlay

    private var pauseMenuOverlay: some View {
        ZStack {
            Color.black.opacity(0.68)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("SPIEL PAUSIERT")
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("Level \(engine.level.id): \(engine.level.title)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.cyan)

                VStack(spacing: 10) {
                    Toggle("Flugbahn-Vorschau anzeigen", isOn: $store.showTrajectoryHelper)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .tint(.green)

                    Toggle("Soundeffekte (SFX)", isOn: $sound.sfxEnabled)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .tint(.green)

                    Toggle("Stadion-Atmosphäre", isOn: $sound.crowdEnabled)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .tint(.green)

                    Toggle("Haptisches Feedback", isOn: $sound.hapticsEnabled)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .tint(.green)
                }
                .padding(14)
                .background(Color.white.opacity(0.08))
                .cornerRadius(14)

                VStack(spacing: 10) {
                    Button {
                        sound.play(.menuClick)
                        isPaused = false
                    } label: {
                        Label("WEITERSPIELEN", systemImage: "play.fill")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color.green)
                            .cornerRadius(12)
                    }

                    Button {
                        sound.play(.menuClick)
                        isPaused = false
                        engine.setupPlay(resetAttempts: true)
                    } label: {
                        Label("LEVEL NEU STARTEN", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.14))
                            .cornerRadius(12)
                    }

                    Button {
                        sound.play(.menuClick)
                        isPaused = false
                        store.currentScreen = .levelSelect
                    } label: {
                        Label("ZUR LEVELAUSWAHL", systemImage: "square.grid.2x2.fill")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.14))
                            .cornerRadius(12)
                    }

                    Button {
                        sound.play(.menuClick)
                        isPaused = false
                        store.currentScreen = .mainMenu
                    } label: {
                        Label("HAUPTMENÜ", systemImage: "house.fill")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.red.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                }
            }
            .padding(22)
            .frame(maxWidth: 340)
            .background(Color(red: 0.07, green: 0.11, blue: 0.20).opacity(0.98))
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
    }

    // MARK: - Helpers

    private func shortTeamCode(_ fullName: String) -> String {
        let cleaned = fullName.uppercased()
        if cleaned.hasPrefix("FC ") {
            return String(cleaned.dropFirst(3).prefix(3))
        }
        return String(cleaned.prefix(3))
    }

    private func updatedGoalScore(_ context: String) -> String {
        let parts = context.split(separator: ":").map { $0.trimmingCharacters(in: .whitespaces) }
        if parts.count == 2, let home = Int(parts[0]) {
            return "\(home + 1) : \(parts[1])"
        }
        return "1 : 0"
    }
}
