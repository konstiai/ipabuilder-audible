import Foundation

// MARK: - Extended Career (Chapters 6 - 20, Levels 31 - 180)
//
// Alle zusätzlichen Level sind fest vordefiniert (deterministisch aus der Level-ID erzeugt),
// d. h. jedes Level sieht bei jedem Start exakt gleich aus. Schwierigkeit, Wind, Torwart-Stärke,
// Anzahl der Verteidiger und Stern-Ring-Größe steigen langsam von Level 31 bis Level 180 an.

fileprivate struct SeededRandom {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed &* 0x9E3779B97F4A7C15 &+ 0xD1B54A32D192ED03
    }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }

    mutating func unit() -> Double {
        return Double(next() >> 11) / 9007199254740992.0
    }

    mutating func range(_ lo: Double, _ hi: Double) -> Double {
        return lo + (hi - lo) * unit()
    }

    mutating func int(_ lo: Int, _ hi: Int) -> Int {
        let span = UInt64(hi - lo + 1)
        return lo + Int(next() % span)
    }

    mutating func sign() -> Double {
        return unit() < 0.5 ? -1.0 : 1.0
    }

    mutating func pick<T>(_ items: [T]) -> T {
        let idx = Int(next() % UInt64(items.count))
        return items[idx]
    }
}

fileprivate func clampD(_ v: Double, _ lo: Double, _ hi: Double) -> Double {
    return max(lo, min(hi, v))
}

fileprivate struct ChapterSeed {
    let title: String
    let league: String
    let icon: String
    let colorHex: UInt32
    let description: String
    let windBase: Double
    let homeTeam: String
}

fileprivate struct OpponentSeed {
    let name: String
    let primary: UInt32
    let secondary: UInt32
}

fileprivate let generatedChapterSeeds: [ChapterSeed] = [
    ChapterSeed(title: "Kapitel 6: Landespokal-Nächte", league: "Landespokal", icon: "flag.fill", colorHex: 0x14B8A6, description: "Pokal-Atmosphäre: Kleine Vereine, enge Räume und kein Fehler erlaubt.", windBase: 0.2, homeTeam: "Pokal-Auswahl"),
    ChapterSeed(title: "Kapitel 7: Auslands-Abenteuer", league: "Premier Division", icon: "airplane", colorHex: 0x6366F1, description: "Dein Wechsel ins Ausland: härtere Zweikämpfe und schnellere Verteidiger.", windBase: 0.4, homeTeam: "Legionäre XI"),
    ChapterSeed(title: "Kapitel 8: Südamerika-Tour", league: "Copa del Sur", icon: "globe.americas.fill", colorHex: 0xF97316, description: "Heißblütige Fans, wendige Keeper und Tricks auf engstem Raum.", windBase: 0.3, homeTeam: "Tour-Elf"),
    ChapterSeed(title: "Kapitel 9: Derby-Fieber", league: "Stadtderby", icon: "flame.fill", colorHex: 0xEF4444, description: "Die Stadt brennt: Intensive Derbys mit aggressiven Verteidigern.", windBase: 0.5, homeTeam: "Stadt-Stars"),
    ChapterSeed(title: "Kapitel 10: Stern-Gala", league: "Europa-Supercup", icon: "star.circle.fill", colorHex: 0xEAB308, description: "Glanz und Gloria: Europas beste Teams im Flutlicht-Spektakel.", windBase: 0.5, homeTeam: "Euro-Auswahl"),
    ChapterSeed(title: "Kapitel 11: Wüsten-Cup", league: "Wüsten-Turnier", icon: "sun.max.fill", colorHex: 0xF59E0B, description: "Flimmernde Hitze und Seitenwind aus den Dünen.", windBase: 0.6, homeTeam: "Oasen-Elf"),
    ChapterSeed(title: "Kapitel 12: Schneeschlacht", league: "Winter-Liga", icon: "snowflake", colorHex: 0x38BDF8, description: "Eisiger Wind und kompakte Abwehrreihen im Schneetreiben.", windBase: 0.9, homeTeam: "Eis-Express"),
    ChapterSeed(title: "Kapitel 13: Regen-Marathon", league: "Regenpokal", icon: "cloud.rain.fill", colorHex: 0x0EA5E9, description: "Böiger Regen-Wind: Plane deine Flugkurve mit Weitblick.", windBase: 1.1, homeTeam: "Regen-Rebellen"),
    ChapterSeed(title: "Kapitel 14: Nachtschicht", league: "Flutlicht-Liga", icon: "moon.stars.fill", colorHex: 0x8B5CF6, description: "Spiele unter Flutlicht gegen hellwache Torhüter.", windBase: 0.7, homeTeam: "Nacht-Elf"),
    ChapterSeed(title: "Kapitel 15: Olympia-Turnier", league: "Olympia-Endrunde", icon: "medal.fill", colorHex: 0xFACC15, description: "Jetzt geht es um Medaillen: Höchste Präzision ist gefragt.", windBase: 0.8, homeTeam: "Olympia-Team"),
    ChapterSeed(title: "Kapitel 16: Superliga-Giganten", league: "Superliga", icon: "shield.fill", colorHex: 0x10B981, description: "Die Giganten des Weltfußballs mit Abwehrmauern aus Stahl.", windBase: 0.9, homeTeam: "Giganten FC"),
    ChapterSeed(title: "Kapitel 17: Weltauswahl", league: "Weltauswahl-Gala", icon: "person.3.fill", colorHex: 0xEC4899, description: "Die besten Spieler der Welt stehen dir gegenüber.", windBase: 1.0, homeTeam: "Weltauswahl"),
    ChapterSeed(title: "Kapitel 18: Legenden-Spiel", league: "Legenden-Cup", icon: "bolt.fill", colorHex: 0xF43F5E, description: "Schlage Fußball-Legenden mit genialen Kombinationen.", windBase: 1.1, homeTeam: "Legenden XI"),
    ChapterSeed(title: "Kapitel 19: Ewiger Ruhm", league: "Ruhmeshalle-Pokal", icon: "trophy.fill", colorHex: 0xD946EF, description: "Fast am Ziel: Reaktionsschnelle Verteidiger, extreme Winde, winzige Zielringe.", windBase: 1.2, homeTeam: "Ruhmes-Elf"),
    ChapterSeed(title: "Kapitel 20: Hall of Fame", league: "Hall-of-Fame-Finale", icon: "rosette", colorHex: 0xFDE047, description: "Die ultimative Prüfung: Schaffe alle Level und werde zur unsterblichen Legende!", windBase: 1.3, homeTeam: "Unsterbliche")
]

fileprivate let generatedOpponents: [OpponentSeed] = [
    OpponentSeed(name: "SV Eichenwald", primary: 0x15803D, secondary: 0xFFFFFF),
    OpponentSeed(name: "FC Nordlicht", primary: 0x1D4ED8, secondary: 0xBAE6FD),
    OpponentSeed(name: "Rot-Weiß Aurora", primary: 0xDC2626, secondary: 0xFFFFFF),
    OpponentSeed(name: "Dynamo Falkensee", primary: 0x7C2D12, secondary: 0xFDE68A),
    OpponentSeed(name: "Atlético Brisa", primary: 0xEF4444, secondary: 0xFFFFFF),
    OpponentSeed(name: "Sporting Marina", primary: 0x16A34A, secondary: 0xFACC15),
    OpponentSeed(name: "Inter Vulcano", primary: 0x1E293B, secondary: 0x38BDF8),
    OpponentSeed(name: "Olympique Rivage", primary: 0x2563EB, secondary: 0xFFFFFF),
    OpponentSeed(name: "Real Sombra", primary: 0xF8FAFC, secondary: 0x7C3AED),
    OpponentSeed(name: "Estrella Azul", primary: 0x38BDF8, secondary: 0xFFFFFF),
    OpponentSeed(name: "FK Zvezda Nord", primary: 0xB91C1C, secondary: 0x111827),
    OpponentSeed(name: "Polder Boys", primary: 0xF97316, secondary: 0xFFFFFF),
    OpponentSeed(name: "Borea United", primary: 0x4C1D95, secondary: 0xFDE047),
    OpponentSeed(name: "Costa Dorada", primary: 0xEAB308, secondary: 0x1E3A8A),
    OpponentSeed(name: "Alpen-Adler", primary: 0x0F766E, secondary: 0xFFFFFF),
    OpponentSeed(name: "Vorwärts Hafen", primary: 0x0369A1, secondary: 0xFCA5A5),
    OpponentSeed(name: "Sparta Granit", primary: 0x57534E, secondary: 0xFB923C),
    OpponentSeed(name: "Lions Kapstadt", primary: 0xCA8A04, secondary: 0x0F172A),
    OpponentSeed(name: "Tokio Sakura", primary: 0xEC4899, secondary: 0xFFFFFF),
    OpponentSeed(name: "Pampa Rangers", primary: 0x0EA5E9, secondary: 0xFEF08A)
]

fileprivate let generatedHomeNames: [String] = [
    "Lukas", "Marco", "Leon", "Jamal", "Florian", "Kai", "Toni", "Mario", "Serge", "Emre",
    "Niklas", "Ben", "Yannik", "Tim", "Jonas", "David", "Amir", "Felix", "Noah", "Elias"
]

fileprivate let generatedAwayNames: [String] = [
    "Brandt", "Vogel", "Kessler", "Hartmann", "Lindner", "Becker", "Rossi", "Moreau", "Duarte", "Silva",
    "Novak", "Petrov", "Jansen", "Larsen", "Costa", "Ferrer", "Okafor", "Mendes", "Sato", "Kowalski",
    "Bauer", "Winter", "Krüger", "Franke", "Albers", "Dietrich", "Haas", "Roth", "Engel", "Voigt"
]

fileprivate let generatedHairColors: [UInt32] = [
    0x18181B, 0x3B2314, 0x78350F, 0xB45309, 0x451A03, 0x111827, 0xFACC15, 0x92400E
]

fileprivate let finishingTitles: [String] = [
    "Torjäger-Instinkt", "Kaltschnäuzig vor dem Kasten", "Strafraum-Hexenkessel", "Der Knipser",
    "Nerven aus Stahl", "Pfeilschuss in den Winkel", "Abschluss unter Druck", "Flutlicht-Treffer"
]
fileprivate let throughBallTitles: [String] = [
    "Steilpass-Künstler", "Der tödliche Pass", "Lauf in die Tiefe", "Zwischen den Linien",
    "Der Schlüsselpass", "Pass durch die Gasse", "Tiefenlauf", "Der öffnende Ball"
]
fileprivate let freeKickTitles: [String] = [
    "Freistoß-Magier", "Bananenflanke", "Mauer-Knacker", "Effet-Meister",
    "Der Zirkler", "Ruhender Ball, heißes Eck", "Freistoß aus 25 Metern", "Knatterschuss um die Mauer"
]
fileprivate let counterTitles: [String] = [
    "Blitzkonter", "Umschaltspiel", "Konter über Außen", "Gegenstoß",
    "Schnell nach vorn", "Tempo-Gegenstoß", "Flügelzange", "Konter in Überzahl"
]
fileprivate let tikiTitles: [String] = [
    "Tiki-Taka-Zauber", "Kurzpass-Kombination", "Passstafette", "Ballstafette",
    "Spielverlagerung", "Dreiecksspiel", "Doppelpass-Festival", "Kombinationsfußball"
]

// MARK: - Public extension used by LevelDatabase

extension LevelDatabase {

    static let firstGeneratedChapterId: Int = 6
    static let firstGeneratedLevelId: Int = 31
    static let levelsPerGeneratedChapter: Int = 10

    static func buildGeneratedChapters() -> [CareerChapter] {
        var result: [CareerChapter] = []
        for (index, seed) in generatedChapterSeeds.enumerated() {
            let chapter = CareerChapter(
                id: firstGeneratedChapterId + index,
                title: seed.title,
                leagueName: seed.league,
                badgeIcon: seed.icon,
                themeColorHex: seed.colorHex,
                requiredStarsToUnlock: 66 + index * 20,
                description: seed.description
            )
            result.append(chapter)
        }
        return result
    }

    static func buildGeneratedLevels() -> [LevelDefinition] {
        var result: [LevelDefinition] = []
        for (chapterIndex, seed) in generatedChapterSeeds.enumerated() {
            let chapterId = firstGeneratedChapterId + chapterIndex
            for n in 1...levelsPerGeneratedChapter {
                let levelId = firstGeneratedLevelId + chapterIndex * levelsPerGeneratedChapter + (n - 1)
                result.append(makeGeneratedLevel(id: levelId, chapterId: chapterId, indexInChapter: n, seed: seed))
            }
        }
        return result
    }
}

// MARK: - Level Factory

fileprivate func makeGeneratedLevel(id: Int, chapterId: Int, indexInChapter n: Int, seed: ChapterSeed) -> LevelDefinition {
    var rng = SeededRandom(seed: UInt64(id) &* 7919 &+ 17)
    let d = clampD(Double(id - 31) / 149.0, 0.0, 1.0)
    let isFinal = (n == 10)
    let theme = SecretLevelDatabase.modifier(for: chapterId)

    let kinds: [ScenarioType] = [
        .finishing, .throughBall, .freeKick, .counterAttack, .finishing,
        .tikiTaka, .freeKick, .throughBall, .counterAttack, .championshipFinal
    ]
    let kind = kinds[n - 1]

    // Difficulty scaling: progressive per chapter, subtle and fair
    let defSpeed = 6.4 + 2.0 * d + theme.defenderAggression * 1.5 + (isFinal ? 0.25 : 0.0)
    let defReact = max(0.08, 0.24 - 0.12 * d - theme.defenderAggression * 0.08)
    let gkSpeed = 6.0 + 2.2 * d + theme.keeperSkillBonus * 1.4 + (isFinal ? 0.25 : 0.0)
    let gkReact = max(0.08, 0.26 - 0.14 * d - theme.keeperSkillBonus * 0.08 - (isFinal ? 0.02 : 0.0))
    let windMagnitude = clampD((seed.windBase + theme.windBonus + d * 0.6) * rng.range(0.45, 1.0), 0.0, 2.8)
    let wind = rng.sign() * windMagnitude
    let starX = rng.sign() * rng.range(2.4, 5.5)
    let starZ = rng.range(2.5, 3.5)
    let starRadius = max(1.05, (1.8 - 0.5 * d - (isFinal ? 0.1 : 0.0)) * theme.starRadiusScale)
    let parAttempts = chapterId >= 13 ? 3 : 2
    let reward = 70 + Int(230.0 * d) + (isFinal ? 80 : 0)

    let opponent = rng.pick(generatedOpponents)
    let minute: String = isFinal ? "90+\(rng.int(1, 5))'" : "\(rng.int(4, 89))'"
    let scoreContext: String = isFinal ? "1 : 1" : "\(rng.int(0, 2)) : \(rng.int(0, 3))"
    let titleIndex = (id * 3 + n) % 8
    let starSideWord = starX < 0 ? "linken" : "rechten"

    var players: [PlayerSpawn] = []
    var defCount = 0
    var recommendedPasses = 0
    // Chapter-specific ball start offset: Some chapters start further back (e.g. Ch 7 Weitschuss, Ch 18/20 Distanztore)
    var ballStart = Vec2(x: 0.0, y: clampD(34.0 + theme.ballStartYOffset, 14.0, 38.0))
    var title = ""
    var subtitle = ""
    var hint = ""

    let defNumbers: [Int] = [4, 5, 3, 15, 2, 6, 13, 22]

    func addHome(id pid: String, role: PlayerRole, shirt: Int, pos: Vec2, wps: [Vec2], speedBonus: Double) {
        let name = rng.pick(generatedHomeNames)
        let hair = rng.pick(generatedHairColors)
        let skin = rng.int(0, 3)
        let spawn = PlayerSpawn(
            id: pid, name: name, shirtNumber: shirt, side: .home, role: role,
            position: pos, runWaypoints: wps, speed: 7.4 + 1.6 * d + speedBonus,
            reactionDelay: 0.06, hairColorHex: hair, skinToneIndex: skin
        )
        players.append(spawn)
    }

    func addKeeper(x: Double, extraReact: Double) {
        let name = rng.pick(generatedAwayNames)
        let hair = rng.pick(generatedHairColors)
        let skin = rng.int(0, 3)
        let spawn = PlayerSpawn(
            id: "gk", name: name, shirtNumber: 1, side: .away, role: .goalkeeper,
            position: Vec2(x: x, y: 51.2), runWaypoints: [], speed: gkSpeed,
            reactionDelay: max(0.07, gkReact - extraReact), hairColorHex: hair, skinToneIndex: skin
        )
        players.append(spawn)
    }

    func addLaneDefender(from a: Vec2, to b: Vec2, t: Double, side: Double, role: PlayerRole) {
        defCount += 1
        let dx = b.x - a.x
        let dy = b.y - a.y
        let len = max(0.001, (dx * dx + dy * dy).squareRoot())
        let ux = dx / len
        let uy = dy / len
        let clearance = 4.0 - 1.3 * d + rng.range(0.0, 1.4)
        let baseX = a.x + dx * t
        let baseY = a.y + dy * t
        var px = baseX + (-uy) * side * clearance
        var py = baseY + ux * side * clearance
        px = clampD(px, -27.0, 27.0)
        py = clampD(py, 12.0, 48.5)

        let toBallX = px - ballStart.x
        let toBallY = py - ballStart.y
        if (toBallX * toBallX + toBallY * toBallY).squareRoot() < 3.8 {
            py = min(48.5, py + 3.8)
        }

        let name = rng.pick(generatedAwayNames)
        let hair = rng.pick(generatedHairColors)
        let skin = rng.int(0, 3)
        let shirt = defNumbers[(defCount - 1) % defNumbers.count]
        let wp = Vec2(x: (px + baseX) * 0.5, y: (py + baseY) * 0.5)
        let spawn = PlayerSpawn(
            id: "d\(defCount)", name: name, shirtNumber: shirt, side: .away, role: role,
            position: Vec2(x: px, y: py), runWaypoints: [wp], speed: defSpeed,
            reactionDelay: defReact, hairColorHex: hair, skinToneIndex: skin
        )
        players.append(spawn)
    }

    func addWallDefender(index: Int, pos: Vec2) {
        let name = rng.pick(generatedAwayNames)
        let hair = rng.pick(generatedHairColors)
        let skin = rng.int(0, 3)
        let spawn = PlayerSpawn(
            id: "w\(index)", name: name, shirtNumber: 5 + index, side: .away, role: .wallDefender,
            position: pos, runWaypoints: [], speed: 5.8, reactionDelay: 0.14,
            hairColorHex: hair, skinToneIndex: skin
        )
        players.append(spawn)
    }

    let goalTarget = Vec2(x: starX, y: 52.0)

    switch kind {

    case .finishing:
        let bx = rng.range(-11.0, 11.0)
        let by = clampD(rng.range(31.0, 38.0) + theme.ballStartYOffset, 16.0, 39.0)
        ballStart = Vec2(x: bx, y: by)
        addHome(id: "h9", role: .ballCarrier, shirt: 9, pos: Vec2(x: bx, y: by - 0.7), wps: [], speedBonus: 0.0)

        let cnt: Int = d < 0.12 ? 0 : (d < 0.5 ? 1 : (d < 0.8 ? 2 : 3))
        let firstSide = rng.sign()
        for i in 0..<cnt {
            let side = (i % 2 == 0) ? firstSide : -firstSide
            addLaneDefender(from: ballStart, to: goalTarget, t: 0.45 + 0.14 * Double(i), side: side, role: .defender)
        }
        addKeeper(x: rng.range(-1.6, 1.6), extraReact: n == 5 ? 0.04 : 0.0)

        if n == 5 {
            title = "1-gegen-1: " + rng.pick(finishingTitles)
            subtitle = "Der Torwart lauert – überliste ihn mit einem präzisen Schuss in den \(starSideWord) Winkel!"
        } else {
            title = finishingTitles[titleIndex]
            subtitle = "Wische vom Ball in den goldenen Stern-Ring im \(starSideWord) Torwinkel!"
        }
        hint = "Wische vom Ball in Richtung des Stern-Rings am \(starSideWord) Pfosten. Ein Bogen in der Wischbewegung gibt dem Ball Effet. (\(theme.specialHint))"
        recommendedPasses = 0

    case .throughBall:
        let bx = rng.range(-9.0, 9.0)
        let by = clampD(rng.range(21.0, 26.0) + theme.ballStartYOffset, 10.0, 30.0)
        ballStart = Vec2(x: bx, y: by)
        let carrierWp = Vec2(x: bx * 0.8, y: by + 7.0)
        addHome(id: "h8", role: .ballCarrier, shirt: 8, pos: Vec2(x: bx, y: by - 0.7), wps: [carrierWp], speedBonus: 0.0)

        let mateSide: Double = bx >= 0 ? -1.0 : 1.0
        let mx = clampD(bx * -0.4 + mateSide * rng.range(5.0, 9.0), -16.0, 16.0)
        let wp1 = Vec2(x: mx * 0.85, y: clampD(rng.range(36.0, 41.0) + theme.ballStartYOffset * 0.5, 26.0, 42.0))
        let wp2 = Vec2(x: wp1.x * 0.7, y: clampD(rng.range(43.0, 45.5) + theme.ballStartYOffset * 0.2, 38.0, 46.5))
        addHome(id: "h9", role: .striker, shirt: 9, pos: Vec2(x: mx, y: clampD(28.0 + theme.ballStartYOffset * 0.7, 18.0, 32.0)), wps: [wp1, wp2], speedBonus: 0.3)

        let firstSide = rng.sign()
        addLaneDefender(from: ballStart, to: wp1, t: 0.5, side: firstSide, role: .defender)
        addLaneDefender(from: wp1, to: goalTarget, t: 0.4, side: -firstSide, role: .defender)
        if d > 0.45 {
            addLaneDefender(from: ballStart, to: wp1, t: 0.75, side: -firstSide, role: .defender)
        }
        if d > 0.8 {
            addLaneDefender(from: wp1, to: goalTarget, t: 0.7, side: firstSide, role: .sweeper)
        }
        addKeeper(x: rng.range(-1.4, 1.4), extraReact: 0.0)

        title = throughBallTitles[titleIndex]
        subtitle = "Spiele den Ball in den Lauf von Stürmer #9 und verwandle!"
        hint = "Passe zuerst in den freien Laufweg von #9 (gestrichelter Pfeil). Sobald er den Ball annimmt, schieße in den \(starSideWord) Stern-Ring. (\(theme.specialHint))"
        recommendedPasses = 1

    case .freeKick:
        let bx = rng.range(-9.0, 9.0)
        let by = clampD(rng.range(27.0, 31.0) + theme.ballStartYOffset * 0.6, 18.0, 33.0)
        ballStart = Vec2(x: bx, y: by)
        addHome(id: "h10", role: .ballCarrier, shirt: 10, pos: Vec2(x: bx - 0.4, y: by - 0.8), wps: [], speedBonus: 0.0)

        let wallCount: Int = d < 0.3 ? 2 : (d < 0.65 ? 3 : 4)
        let gx = 0.0 - bx
        let gy = 52.0 - by
        let glen = max(0.001, (gx * gx + gy * gy).squareRoot())
        let ux = gx / glen
        let uy = gy / glen
        let wallDist = 8.6
        let cx = bx + ux * wallDist
        let cy = by + uy * wallDist
        let perpX = -uy
        let perpY = ux
        for i in 0..<wallCount {
            let offset = (Double(i) - Double(wallCount - 1) * 0.5) * 1.45
            let wx = clampD(cx + perpX * offset, -27.0, 27.0)
            let wy = cy + perpY * offset
            addWallDefender(index: i + 1, pos: Vec2(x: wx, y: wy))
        }
        addKeeper(x: rng.range(-1.6, 1.6), extraReact: 0.0)

        title = freeKickTitles[titleIndex]
        subtitle = "Zirkle den Freistoß mit Effet um die \(wallCount)er-Mauer ins Tor!"
        hint = "Die Mauer springt beim Schuss hoch – schlage mit einem deutlichen Bogen in der Wischbewegung außen herum in den \(starSideWord) Stern-Ring. (\(theme.specialHint))"
        recommendedPasses = 0

    case .counterAttack:
        let bx = rng.range(-6.0, 6.0)
        let by = clampD(rng.range(15.0, 21.0) + theme.ballStartYOffset * 0.8, 8.0, 22.0)
        ballStart = Vec2(x: bx, y: by)
        addHome(id: "h6", role: .ballCarrier, shirt: 6, pos: Vec2(x: bx, y: by - 0.7), wps: [Vec2(x: bx, y: by + 9.0)], speedBonus: 0.0)

        let flank = rng.sign()
        let wx = flank * rng.range(10.0, 13.0)
        let wWp1 = Vec2(x: wx * 0.95, y: clampD(rng.range(36.0, 38.5) + theme.ballStartYOffset * 0.5, 24.0, 40.0))
        let wWp2 = Vec2(x: wx * 0.7, y: 42.0)
        addHome(id: "h11", role: .winger, shirt: 11, pos: Vec2(x: wx, y: by + 4.0), wps: [wWp1, wWp2], speedBonus: 0.7)

        let sx = -flank * rng.range(2.0, 5.0)
        let sWp1 = Vec2(x: sx * 0.7, y: clampD(rng.range(39.0, 41.0) + theme.ballStartYOffset * 0.4, 28.0, 42.0))
        let sWp2 = Vec2(x: sx * 0.4, y: 44.5)
        addHome(id: "h9", role: .striker, shirt: 9, pos: Vec2(x: sx, y: clampD(27.0 + theme.ballStartYOffset * 0.6, 16.0, 29.0)), wps: [sWp1, sWp2], speedBonus: 0.3)

        let side = rng.sign()
        addLaneDefender(from: ballStart, to: sWp1, t: 0.55, side: side, role: .defender)
        addLaneDefender(from: ballStart, to: wWp1, t: 0.6, side: -side, role: .defender)
        if d > 0.4 {
            addLaneDefender(from: sWp1, to: goalTarget, t: 0.45, side: side, role: .defender)
        }
        if d > 0.75 {
            addLaneDefender(from: wWp1, to: goalTarget, t: 0.5, side: -side, role: .sweeper)
        }
        addKeeper(x: rng.range(-1.2, 1.2), extraReact: 0.0)

        title = counterTitles[titleIndex]
        subtitle = "Schicke den Flügelflitzer #11 oder Stürmer #9 und schließe blitzschnell ab!"
        hint = "Spiele zu #11 auf dem Flügel oder zu #9 in der Mitte. Von dort kannst du direkt in den \(starSideWord) Stern-Ring abschließen. (\(theme.specialHint))"
        recommendedPasses = 1

    case .tikiTaka, .championshipFinal:
        let bx = rng.range(-8.0, 8.0)
        let by = clampD((isFinal ? rng.range(10.0, 14.0) : rng.range(16.0, 22.0)) + theme.ballStartYOffset * 0.8, 6.0, 24.0)
        ballStart = Vec2(x: bx, y: by)
        addHome(id: "h8", role: .ballCarrier, shirt: 8, pos: Vec2(x: bx, y: by - 0.7), wps: [Vec2(x: bx, y: by + 8.0)], speedBonus: 0.0)

        let side = rng.sign()
        let m1x = clampD(bx + side * rng.range(6.0, 9.0), -16.0, 16.0)
        let m1Wp1 = Vec2(x: m1x * 0.95, y: by + rng.range(9.0, 12.0))
        let m1Wp2 = Vec2(x: m1x * 0.8, y: m1Wp1.y + 5.0)
        addHome(id: "h10", role: .midfielder, shirt: 10, pos: Vec2(x: m1x, y: by + 4.5), wps: [m1Wp1, m1Wp2], speedBonus: 0.4)

        let sx = clampD(-side * rng.range(2.0, 6.0), -10.0, 10.0)
        let sWp1 = Vec2(x: sx * 0.7, y: clampD(rng.range(39.0, 41.5) + theme.ballStartYOffset * 0.4, 28.0, 43.0))
        let sWp2 = Vec2(x: sx * 0.4, y: 44.5)
        addHome(id: "h9", role: .striker, shirt: 9, pos: Vec2(x: sx, y: clampD(30.0 + theme.ballStartYOffset * 0.5, 18.0, 32.0)), wps: [sWp1, sWp2], speedBonus: 0.3)

        if isFinal {
            let wx = side * rng.range(11.0, 14.0)
            let wWp1 = Vec2(x: wx * 0.9, y: clampD(rng.range(37.0, 40.0) + theme.ballStartYOffset * 0.4, 26.0, 41.0))
            addHome(id: "h7", role: .winger, shirt: 7, pos: Vec2(x: wx, y: clampD(26.0 + theme.ballStartYOffset * 0.6, 16.0, 28.0)), wps: [wWp1, Vec2(x: wx * 0.65, y: 43.0)], speedBonus: 0.8)
        }

        let firstSide = rng.sign()
        addLaneDefender(from: ballStart, to: m1Wp1, t: 0.5, side: firstSide, role: .defender)
        addLaneDefender(from: m1Wp1, to: sWp1, t: 0.5, side: -firstSide, role: .defender)
        addLaneDefender(from: sWp1, to: goalTarget, t: 0.45, side: firstSide, role: .defender)
        if d > 0.55 || isFinal {
            addLaneDefender(from: ballStart, to: m1Wp1, t: 0.8, side: -firstSide, role: .defender)
        }
        if isFinal {
            addLaneDefender(from: sWp1, to: goalTarget, t: 0.75, side: -firstSide, role: .sweeper)
        }
        addKeeper(x: rng.range(-1.2, 1.2), extraReact: isFinal ? 0.02 : 0.0)

        if isFinal {
            title = seed.league + "-Finale"
            subtitle = "Das Kapitel-Finale! Spiele dich durch die Abwehr und werde zum Helden!"
            hint = "Meister-Spielzug: Spiele zu #10, dann in den Lauf von #9 oder #7 und schließe in den \(starSideWord) Stern-Ring ab. (\(theme.specialHint))"
            recommendedPasses = 3
        } else {
            title = tikiTitles[titleIndex]
            subtitle = "Kombiniere über #10 und #9 – erst dann fällt das Tor!"
            hint = "Spiele zuerst zu #10, von dort in den Lauf von #9 und schließe in den \(starSideWord) Stern-Ring ab. (\(theme.specialHint))"
            recommendedPasses = 2
        }
    }

    return LevelDefinition(
        id: id,
        chapterId: chapterId,
        levelNumberInChapter: n,
        title: title,
        subtitle: subtitle,
        matchMinute: minute,
        scoreContext: scoreContext,
        homeTeamName: seed.homeTeam,
        awayTeamName: opponent.name,
        awayKitPrimaryHex: opponent.primary,
        awayKitSecondaryHex: opponent.secondary,
        scenarioType: kind,
        tacticalHint: hint,
        recommendedPasses: recommendedPasses,
        parAttempts: parAttempts,
        windSpeed: wind,
        starTarget: StarTargetZone(x: starX, z: starZ, radius: starRadius),
        ballStart: ballStart,
        players: players,
        rewardCoins: reward
    )
}
