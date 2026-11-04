import Foundation

// MARK: - Secret Levels & Chapter Special Themes
//
// Jedes der 20 Kapitel besitzt:
// 1. Eine eigene Besonderheit / Gameplay-Modifikator (z.B. Weitschuss-Distanz, Seitenwind,
//    engere Verteidigung, Flankenfokus, Doppel-Mauer, etc.)
// 2. Ein freischaltbares SECRET-LEVEL ganz unten im Kapitel, das nur spielbar wird,
//    wenn in ALLEN regulären Spielen dieses Kapitels die vollen 3 Sterne gesammelt wurden.

struct ChapterThemeModifier {
    let name: String
    let subtitleModifier: String
    let ballStartYOffset: Double      // z.B. -12.0 für Kapitel, die viel weiter hinten starten
    let windBonus: Double             // Kapitel mit starkem Wind
    let defenderAggression: Double    // Schnellere Reaktionen
    let keeperSkillBonus: Double      // Stärkere Paraden
    let starRadiusScale: Double       // Zirkel-Präzision
    let specialHint: String
}

enum SecretLevelDatabase {

    // MARK: - 20 Kapitel-Themen & Besonderheiten
    static func modifier(for chapterId: Int) -> ChapterThemeModifier {
        switch chapterId {
        case 1:
            return ChapterThemeModifier(
                name: "Akademie-Grundlagen",
                subtitleModifier: "Gute Einstiegs-Distanzen zum Erlernen von Pässen und Torschüssen.",
                ballStartYOffset: 0.0,
                windBonus: 0.0,
                defenderAggression: 0.0,
                keeperSkillBonus: 0.0,
                starRadiusScale: 1.0,
                specialHint: "Konzentriere dich auf präzise Laufwege und den goldenen Stern-Ring."
            )
        case 2:
            return ChapterThemeModifier(
                name: "Aufsteiger-Kompaktheit",
                subtitleModifier: "Gegner stehen kompakter – schnelle Doppelpässe sind gefragt.",
                ballStartYOffset: -2.0,
                windBonus: 0.15,
                defenderAggression: 0.05,
                keeperSkillBonus: 0.05,
                starRadiusScale: 0.96,
                specialHint: "Doppelpässe öffnen Lücken in der kompakten Kette."
            )
        case 3:
            return ChapterThemeModifier(
                name: "Bundesliga-Pressing",
                subtitleModifier: "Aggressives Verteidiger-Gegenpressing und böiger Stadionwind.",
                ballStartYOffset: -4.0,
                windBonus: 0.45,
                defenderAggression: 0.12,
                keeperSkillBonus: 0.10,
                starRadiusScale: 0.92,
                specialHint: "Spiele den Ball direkt weiter, bevor der Abwehrspieler heranrauscht!"
            )
        case 4:
            return ChapterThemeModifier(
                name: "Königsklasse-Flanken",
                subtitleModifier: "Angriffe starten weiter außen auf dem Flügel – weite Hereingaben nötig.",
                ballStartYOffset: -5.5,
                windBonus: 0.40,
                defenderAggression: 0.16,
                keeperSkillBonus: 0.15,
                starRadiusScale: 0.88,
                specialHint: "Flanke diagonal in den Strafraum, wo dein Stürmer einläuft."
            )
        case 5:
            return ChapterThemeModifier(
                name: "Weltpokal-Magie",
                subtitleModifier: "Weltmeister-Torhüter mit Hechtsprung-Reflexen.",
                ballStartYOffset: -7.0,
                windBonus: 0.60,
                defenderAggression: 0.20,
                keeperSkillBonus: 0.20,
                starRadiusScale: 0.85,
                specialHint: "Platziere deine Schüsse haarscharf in die Winkel, sonst pariert der Keeper."
            )
        case 6:
            return ChapterThemeModifier(
                name: "Pokalschreck-Kollision",
                subtitleModifier: "Tiefe Rasen-Duelle: Enge Zweikämpfe und überraschende Vorstöße.",
                ballStartYOffset: -6.0,
                windBonus: 0.35,
                defenderAggression: 0.18,
                keeperSkillBonus: 0.15,
                starRadiusScale: 0.88,
                specialHint: "Vermeide direkte Duelle und ziehe Pässe steil in den freien Raum."
            )
        case 7:
            return ChapterThemeModifier(
                name: "Fernschuss-Power",
                subtitleModifier: "Große Distanz: Alle Spielzüge starten von deutlich weiter hinten!",
                ballStartYOffset: -12.5,
                windBonus: 0.40,
                defenderAggression: 0.20,
                keeperSkillBonus: 0.18,
                starRadiusScale: 0.86,
                specialHint: "Ziehe lange, kraftvolle Linien für wuchtige Distanz-Geschosse!"
            )
        case 8:
            return ChapterThemeModifier(
                name: "Samba-Effet & Bananen-Bogen",
                subtitleModifier: "Extremer Kurvendrall belohnt: Umkurve Mauern und Abwehrriegel.",
                ballStartYOffset: -6.5,
                windBonus: 0.50,
                defenderAggression: 0.22,
                keeperSkillBonus: 0.22,
                starRadiusScale: 0.84,
                specialHint: "Ziehe deutliche Bögen – der Ball folgt deiner Wischkurve perfekt."
            )
        case 9:
            return ChapterThemeModifier(
                name: "Derby-Hexenkessel",
                subtitleModifier: "Hitze & Hektik: Verteidiger setzen dich blitzschnell unter Druck.",
                ballStartYOffset: -8.0,
                windBonus: 0.60,
                defenderAggression: 0.26,
                keeperSkillBonus: 0.24,
                starRadiusScale: 0.82,
                specialHint: "Plane deinen Pass schon vor dem Wischen – keine Zögersekunde!"
            )
        case 10:
            return ChapterThemeModifier(
                name: "Flutlicht-Präzision",
                subtitleModifier: "Goldener Stern-Ring verkleinert – höchste Treffgenauigkeit gefordert.",
                ballStartYOffset: -9.0,
                windBonus: 0.55,
                defenderAggression: 0.28,
                keeperSkillBonus: 0.26,
                starRadiusScale: 0.78,
                specialHint: "Präzision schlägt Kraft: Zirkle den Ball exakt ins markierte Eck."
            )
        case 11:
            return ChapterThemeModifier(
                name: "Wüstenwind-Drift",
                subtitleModifier: "Starker konstanter Seitenwind treibt den Ball seitlich ab.",
                ballStartYOffset: -8.5,
                windBonus: 1.25,
                defenderAggression: 0.30,
                keeperSkillBonus: 0.28,
                starRadiusScale: 0.80,
                specialHint: "Kalkuliere den starken Wind ein: Halte leicht gegen die Windrichtung vor!"
            )
        case 12:
            return ChapterThemeModifier(
                name: "Schneeglätte & Flachschüsse",
                subtitleModifier: "Rutschiger Boden: Schnelle Flachpässe rollen rasant durch die Lücken.",
                ballStartYOffset: -10.0,
                windBonus: 0.80,
                defenderAggression: 0.32,
                keeperSkillBonus: 0.30,
                starRadiusScale: 0.78,
                specialHint: "Flache, scharfe Schüsse rutschen tückisch an Verteidigern vorbei."
            )
        case 13:
            return ChapterThemeModifier(
                name: "Regensturm-Böen",
                subtitleModifier: "Unberechenbare Windstöße und weite Flankenläufe.",
                ballStartYOffset: -11.0,
                windBonus: 1.45,
                defenderAggression: 0.34,
                keeperSkillBonus: 0.32,
                starRadiusScale: 0.76,
                specialHint: "Schneide den Ball mit starkem Drall gegen den Wind an."
            )
        case 14:
            return ChapterThemeModifier(
                name: "Nachtschatten-Mauer",
                subtitleModifier: "Freistoßmauern springen synchron hoch – Schlenzer mit Topspin!",
                ballStartYOffset: -7.5,
                windBonus: 0.70,
                defenderAggression: 0.36,
                keeperSkillBonus: 0.34,
                starRadiusScale: 0.75,
                specialHint: "Zirkle den Ball außen an der Mauer vorbei statt darüber hinweg."
            )
        case 15:
            return ChapterThemeModifier(
                name: "Olympia-Tiki-Taka",
                subtitleModifier: "Großes Dreiecksspiel: Mindestens 2-3 Passstationen zum Freispielen.",
                ballStartYOffset: -12.0,
                windBonus: 0.75,
                defenderAggression: 0.38,
                keeperSkillBonus: 0.36,
                starRadiusScale: 0.74,
                specialHint: "Kombiniere schnell über beide Mitspieler, bis das Tor frei ist."
            )
        case 16:
            return ChapterThemeModifier(
                name: "Superliga-Abwehrbollwerk",
                subtitleModifier: "Viererketten und Libero: Nur Millimeter-Pässe kommen an.",
                ballStartYOffset: -13.0,
                windBonus: 0.85,
                defenderAggression: 0.40,
                keeperSkillBonus: 0.38,
                starRadiusScale: 0.72,
                specialHint: "Lupfe den Ball über die gegnerische Abwehrkette in den Lauf."
            )
        case 17:
            return ChapterThemeModifier(
                name: "Weltauswahl-Speed",
                subtitleModifier: "Gegenspieler mit Weltklasse-Tempo – extrem schnelles Umschalten.",
                ballStartYOffset: -13.5,
                windBonus: 0.90,
                defenderAggression: 0.42,
                keeperSkillBonus: 0.40,
                starRadiusScale: 0.70,
                specialHint: "Schicke den Ball sofort in den freien Raum, ehe die Lücke zugeht."
            )
        case 18:
            return ChapterThemeModifier(
                name: "Legenden-Traumtore",
                subtitleModifier: "Distanzschüsse aus 35 Metern unter tosendem Jubel.",
                ballStartYOffset: -15.0,
                windBonus: 0.95,
                defenderAggression: 0.44,
                keeperSkillBonus: 0.42,
                starRadiusScale: 0.68,
                specialHint: "Volle Schusslinie über den halben Bildschirm für einen 35-Meter-Strahl!"
            )
        case 19:
            return ChapterThemeModifier(
                name: "Ruhmeshallen-Prüfung",
                subtitleModifier: "Winziger Stern-Ring im Kreuzeck & Torwart-Titanen.",
                ballStartYOffset: -14.0,
                windBonus: 1.10,
                defenderAggression: 0.46,
                keeperSkillBonus: 0.45,
                starRadiusScale: 0.65,
                specialHint: "Nur absolute Traumtore in den Winkel werden hier mit 3 Sternen belohnt."
            )
        case 20:
            return ChapterThemeModifier(
                name: "Hall-of-Fame-Meister",
                subtitleModifier: "Die ultimative Herausforderung aus maximaler Distanz und Pressing.",
                ballStartYOffset: -16.0,
                windBonus: 1.30,
                defenderAggression: 0.50,
                keeperSkillBonus: 0.50,
                starRadiusScale: 0.62,
                specialHint: "Perfektes Timing, Kurvenball & Lupfer kombiniert – zeige dein ganzes Können!"
            )
        default:
            return ChapterThemeModifier(
                name: "Karriere-Kapitel",
                subtitleModifier: "Klassische Spielsituation.",
                ballStartYOffset: 0.0,
                windBonus: 0.0,
                defenderAggression: 0.0,
                keeperSkillBonus: 0.0,
                starRadiusScale: 1.0,
                specialHint: "Triff den goldenen Stern-Ring für 3 Sterne!"
            )
        }
    }

    // MARK: - Secret Level Generator (1 Secret Level pro Kapitel)
    static func buildAllSecretLevels() -> [LevelDefinition] {
        var secrets: [LevelDefinition] = []

        let secretNames: [String] = [
            "SECRET 1: Das Wunder der Akademie",
            "SECRET 2: Flutlicht-Showdown im Pokal",
            "SECRET 3: 40-Meter-Kanonenschuss",
            "SECRET 4: Der unmögliche Bananen-Bogen",
            "SECRET 5: Jahrhundert-Tor der WM",
            "SECRET 6: Pokalfinale in Unterzahl",
            "SECRET 7: Premier-Klassiker aus 38 Metern",
            "SECRET 8: Maracanã-Traumtor",
            "SECRET 9: Derby-Drama in der 95. Minute",
            "SECRET 10: Supercup-Freistoß über 5er-Mauer",
            "SECRET 11: Wüsten-Zauber gegen den Sturm",
            "SECRET 12: Eis-Gala im Schneechaos",
            "SECRET 13: Regen-Wunder von Bern",
            "SECRET 14: Mitternachts-Lupfer",
            "SECRET 15: Goldmedaillen-Spielzug",
            "SECRET 16: Superliga-Giganten-Sturz",
            "SECRET 17: Die Weltauswahl bezwungen",
            "SECRET 18: Fallrückzieher der Legenden",
            "SECRET 19: Das Tor für die Ewigkeit",
            "SECRET 20: UNSTERBLICHKEIT – DIE HALL OF FAME"
        ]

        for chapterId in 1...20 {
            let secretId = 1000 + chapterId
            let theme = modifier(for: chapterId)
            let isLate = chapterId >= 10
            let startY = 14.0 + theme.ballStartYOffset * 0.4
            let ballPos = Vec2(x: (chapterId % 2 == 0) ? -6.5 : 6.5, y: max(6.0, startY))
            let starSide = (chapterId % 2 == 0) ? 5.2 : -5.2
            let starRingRadius = max(0.95, 1.65 * theme.starRadiusScale)

            let secret = LevelDefinition(
                id: secretId,
                chapterId: chapterId,
                levelNumberInChapter: 99,
                title: secretNames[chapterId - 1],
                subtitle: "★ SECRET LEVEL ★ Freigeschaltet durch perfekte 3-Sterne-Wertung in Kapitel \(chapterId)!",
                matchMinute: "90+5'",
                scoreContext: "2 : 2",
                homeTeamName: "Meister XI",
                awayTeamName: "All-Star Elite",
                awayKitPrimaryHex: 0x7C3AED,
                awayKitSecondaryHex: 0xFACC15,
                scenarioType: isLate ? .championshipFinal : .finishing,
                tacticalHint: "★ SECRET CHALLENGE ★ \(theme.specialHint) Der finale Test für echte Fußball-Götter!",
                recommendedPasses: isLate ? 2 : 1,
                parAttempts: 3,
                windSpeed: (chapterId % 2 == 0 ? 1.0 : -1.0) * (0.8 + theme.windBonus),
                starTarget: StarTargetZone(x: starSide, z: 3.5, radius: starRingRadius),
                ballStart: ballPos,
                players: [
                    PlayerSpawn(
                        id: "h10", name: "Spielmacher", shirtNumber: 10, side: .home, role: .ballCarrier,
                        position: Vec2(x: ballPos.x, y: ballPos.y - 0.7),
                        runWaypoints: [Vec2(x: ballPos.x * 0.5, y: ballPos.y + 12.0)],
                        speed: 8.8, reactionDelay: 0.05, hairColorHex: 0xFACC15, skinToneIndex: 0
                    ),
                    PlayerSpawn(
                        id: "h9", name: "Star-Stürmer", shirtNumber: 9, side: .home, role: .striker,
                        position: Vec2(x: -ballPos.x * 0.6, y: ballPos.y + 16.0),
                        runWaypoints: [Vec2(x: -ballPos.x * 0.3, y: 44.0)],
                        speed: 9.2, reactionDelay: 0.04, hairColorHex: 0x18181B, skinToneIndex: 1
                    ),
                    PlayerSpawn(
                        id: "d1", name: "Titan-Verteidiger", shirtNumber: 4, side: .away, role: .defender,
                        position: Vec2(x: 0.0, y: 32.0),
                        runWaypoints: [Vec2(x: ballPos.x * 0.3, y: 26.0)],
                        speed: 7.8 + theme.defenderAggression * 2.5,
                        reactionDelay: max(0.08, 0.20 - theme.defenderAggression * 0.15),
                        hairColorHex: 0x451A03, skinToneIndex: 2
                    ),
                    PlayerSpawn(
                        id: "d2", name: "Abfangjäger", shirtNumber: 5, side: .away, role: .sweeper,
                        position: Vec2(x: -ballPos.x * 0.4, y: 38.0),
                        runWaypoints: [Vec2(x: 0.0, y: 43.0)],
                        speed: 8.2 + theme.defenderAggression * 2.5,
                        reactionDelay: max(0.08, 0.18 - theme.defenderAggression * 0.15),
                        hairColorHex: 0x18181B, skinToneIndex: 0
                    ),
                    PlayerSpawn(
                        id: "gk", name: "Hexer", shirtNumber: 1, side: .away, role: .goalkeeper,
                        position: Vec2(x: 0.0, y: 51.2),
                        runWaypoints: [],
                        speed: 8.2 + theme.keeperSkillBonus * 2.0,
                        reactionDelay: max(0.07, 0.18 - theme.keeperSkillBonus * 0.14),
                        hairColorHex: 0x18181B, skinToneIndex: 0
                    )
                ],
                rewardCoins: 500 + chapterId * 50,
                isSecret: true
            )
            secrets.append(secret)
        }

        return secrets
    }
}
