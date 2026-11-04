import Foundation

enum LevelDatabase {

    // MARK: - 5 Career Chapters

    // Chapters 1-5 handcrafted + Chapters 6-20 from LevelGenerator.swift
    static let chapters: [CareerChapter] = baseChapters + buildGeneratedChapters()

    private static let baseChapters: [CareerChapter] = [
        CareerChapter(
            id: 1,
            title: "Kapitel 1: Jugend-Akademie",
            leagueName: "Regionalliga & Talentsichtung",
            badgeIcon: "figure.soccer",
            themeColorHex: 0x22C55E,
            requiredStarsToUnlock: 0,
            description: "Meistere präzise Torschüsse, Steilpässe in den freien Raum und deinen ersten angeschnittenen Freistoß."
        ),
        CareerChapter(
            id: 2,
            title: "Kapitel 2: Aufstiegskampf",
            leagueName: "2. Profiliga",
            badgeIcon: "bolt.shield.fill",
            themeColorHex: 0x0EA5E9,
            requiredStarsToUnlock: 10,
            description: "Schnelle Konter, Doppelpässe durch kompakte Abwehrketten und Freistöße über dreiköpfige Mauern."
        ),
        CareerChapter(
            id: 3,
            title: "Kapitel 3: Meisterklasse",
            leagueName: "1. Bundesliga",
            badgeIcon: "crown.fill",
            themeColorHex: 0xF59E0B,
            requiredStarsToUnlock: 22,
            description: "Tiki-Taka-Kombinationen über drei Stationen, Seitenwechsel unter Pressing und Seitenwind im Stadion."
        ),
        CareerChapter(
            id: 4,
            title: "Kapitel 4: Königsklasse",
            leagueName: "Champions Cup K.O.-Phase",
            badgeIcon: "sparkles",
            themeColorHex: 0x8B5CF6,
            requiredStarsToUnlock: 36,
            description: "Flutlicht-Nächte gegen Europas beste Verteidiger und Torhüter mit extremen Bananenflanken."
        ),
        CareerChapter(
            id: 5,
            title: "Kapitel 5: Weltpokal-Legenden",
            leagueName: "WM-Endrunde",
            badgeIcon: "globe.europe.africa.fill",
            themeColorHex: 0xEF4444,
            requiredStarsToUnlock: 52,
            description: "Das höchste Niveau des Weltfußballs: Perfektes Timing, millimetergenaue Flugkurven und das große WM-Finale."
        )
    ]

    // MARK: - Unlockable Kits & Balls

    static let kits: [JerseyKit] = [
        JerseyKit(id: "kit_royal", name: "Königsblau & Gold", clubTitle: "FC Bavaria Star", primaryHex: 0x1D4ED8, secondaryHex: 0xFACC15, shortsHex: 0x1E3A8A, priceCoins: 0),
        JerseyKit(id: "kit_crimson", name: "Rot-Weiß Klassik", clubTitle: "SC Rhein Energie", primaryHex: 0xDC2626, secondaryHex: 0xFFFFFF, shortsHex: 0x991B1B, priceCoins: 150),
        JerseyKit(id: "kit_emerald", name: "Smaragd-Grün", clubTitle: "Werder Nord", primaryHex: 0x059669, secondaryHex: 0xA7F3D0, shortsHex: 0x064E3B, priceCoins: 250),
        JerseyKit(id: "kit_borussia", name: "Flutlicht-Gelb", clubTitle: "Westfalen 09", primaryHex: 0xEAB308, secondaryHex: 0x18181B, shortsHex: 0x18181B, priceCoins: 400),
        JerseyKit(id: "kit_galaxy", name: "Galaktisch Weiß", clubTitle: "Real Super Star", primaryHex: 0xF8FAFC, secondaryHex: 0xD97706, shortsHex: 0x334155, priceCoins: 600),
        JerseyKit(id: "kit_neon", name: "Cyber-Magenta", clubTitle: "Weltpokal-Legenden", primaryHex: 0xDB2777, secondaryHex: 0x38BDF8, shortsHex: 0x0F172A, priceCoins: 900)
    ]

    static let balls: [BallDesign] = [
        BallDesign(id: "ball_classic", name: "Telstar Pro", subtitle: "Klassisches Schwarz-Weiß mit Cyan-Spur", panelColorHex: 0x1E293B, accentColorHex: 0x38BDF8, trailColorHex: 0x38BDF8, priceCoins: 0),
        BallDesign(id: "ball_gold", name: "Finale Torfabrik", subtitle: "Goldene Panels mit Sonnen-Leuchtspur", panelColorHex: 0xD97706, accentColorHex: 0xFEF08A, trailColorHex: 0xFACC15, priceCoins: 180),
        BallDesign(id: "ball_fire", name: "Inferno Strike", subtitle: "Feuer-Rot mit glühendem Kometenschweif", panelColorHex: 0xDC2626, accentColorHex: 0xFB923C, trailColorHex: 0xF97316, priceCoins: 320),
        BallDesign(id: "ball_emerald", name: "Precision Volt", subtitle: "Neon-Limette für maximale Sichtbarkeit", panelColorHex: 0x16A34A, accentColorHex: 0xBEF264, trailColorHex: 0x4ADE80, priceCoins: 480),
        BallDesign(id: "ball_plasma", name: "Champions Plasma", subtitle: "Königsviolett mit elektrischer Kurvenspur", panelColorHex: 0x7C3AED, accentColorHex: 0xC084FC, trailColorHex: 0xA855F7, priceCoins: 700),
        BallDesign(id: "ball_worldcup", name: "Weltmeister Orbis", subtitle: "Smaragd & Gold der Weltpokal-Endrunde", panelColorHex: 0x0F172A, accentColorHex: 0xF59E0B, trailColorHex: 0xFDE047, priceCoins: 1000)
    ]

    // MARK: - All 30 Handcrafted Levels

    // 30 handcrafted levels + 150 extended levels (Levels 31-180)
    static let levels: [LevelDefinition] = buildAllLevels() + buildGeneratedLevels()

    static func level(for id: Int) -> LevelDefinition {
        levels.first(where: { $0.id == id }) ?? levels[0]
    }

    static func levels(inChapter chapterId: Int) -> [LevelDefinition] {
        levels.filter { $0.chapterId == chapterId }
    }

    private static func buildAllLevels() -> [LevelDefinition] {
        var list: [LevelDefinition] = []

        // =========================================================================
        // CHAPTER 1: JUGEND-AKADEMIE (Levels 1 - 6)
        // =========================================================================

        // Level 1: Direct Finishing Tutorial
        list.append(LevelDefinition(
            id: 1,
            chapterId: 1,
            levelNumberInChapter: 1,
            title: "Debüt im Strafraum",
            subtitle: "Ziehe deinen Finger vom Ball in den rechten oberen Winkel!",
            matchMinute: "14'",
            scoreContext: "0 : 0",
            homeTeamName: "Akademie XI",
            awayTeamName: "SV Nordstadt",
            awayKitPrimaryHex: 0xEF4444,
            awayKitSecondaryHex: 0xFFFFFF,
            scenarioType: .finishing,
            tacticalHint: "Wische vom Ball schräg nach rechts oben in den goldenen Stern-Ring am Torwinkel.",
            recommendedPasses: 0,
            parAttempts: 2,
            windSpeed: 0.0,
            starTarget: StarTargetZone(x: 4.8, z: 3.1, radius: 1.85),
            ballStart: Vec2(x: 0.0, y: 36.5),
            players: [
                PlayerSpawn(id: "h9", name: "Lukas", shirtNumber: 9, side: .home, role: .ballCarrier, position: Vec2(x: 0.0, y: 35.8), runWaypoints: [], speed: 7.2, reactionDelay: 0.1, hairColorHex: 0x3B2314, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Riemann", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: -0.6, y: 51.2), runWaypoints: [], speed: 5.5, reactionDelay: 0.28, hairColorHex: 0x1F2937, skinToneIndex: 1)
            ],
            rewardCoins: 40
        ))

        // Level 2: First Through-Ball (Steilpass in den Lauf)
        list.append(LevelDefinition(
            id: 2,
            chapterId: 1,
            levelNumberInChapter: 2,
            title: "Der erste Steilpass",
            subtitle: "Spiele den Ball in den Lauf von Stürmer Marco (#9) und verwandle!",
            matchMinute: "32'",
            scoreContext: "0 : 0",
            homeTeamName: "Akademie XI",
            awayTeamName: "FC Westend",
            awayKitPrimaryHex: 0xF97316,
            awayKitSecondaryHex: 0x1E293B,
            scenarioType: .throughBall,
            tacticalHint: "Passe zuerst kurz nach rechts vorn in den freien Laufweg von #9. Sobald er den Ball annimmt, schieße aufs Tor!",
            recommendedPasses: 1,
            parAttempts: 2,
            windSpeed: 0.0,
            starTarget: StarTargetZone(x: -4.6, z: 2.8, radius: 1.80),
            ballStart: Vec2(x: -4.5, y: 24.0),
            players: [
                PlayerSpawn(id: "h8", name: "Leon", shirtNumber: 8, side: .home, role: .ballCarrier, position: Vec2(x: -4.5, y: 23.3), runWaypoints: [Vec2(x: -4.0, y: 31.0)], speed: 7.0, reactionDelay: 0.1, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h9", name: "Marco", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: 7.5, y: 28.0), runWaypoints: [Vec2(x: 6.2, y: 39.0), Vec2(x: 4.5, y: 42.5)], speed: 8.2, reactionDelay: 0.08, hairColorHex: 0x111827, skinToneIndex: 1),
                PlayerSpawn(id: "d4", name: "Tah", shirtNumber: 4, side: .away, role: .defender, position: Vec2(x: -3.2, y: 32.0), runWaypoints: [Vec2(x: -4.0, y: 27.0)], speed: 6.2, reactionDelay: 0.25, hairColorHex: 0x1E293B, skinToneIndex: 2),
                PlayerSpawn(id: "gk", name: "Kobel", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.5, y: 51.2), runWaypoints: [], speed: 6.0, reactionDelay: 0.25, hairColorHex: 0x451A03, skinToneIndex: 0)
            ],
            rewardCoins: 50
        ))

        // Level 3: Curved Shot / Free Kick Around a 2-Man Wall
        list.append(LevelDefinition(
            id: 3,
            chapterId: 1,
            levelNumberInChapter: 3,
            title: "Effet um die Mauer",
            subtitle: "Zirkle den Freistoß mit einer Bananenkurve außen um die Mauer!",
            matchMinute: "58'",
            scoreContext: "1 : 1",
            homeTeamName: "Akademie XI",
            awayTeamName: "Union Süd",
            awayKitPrimaryHex: 0xDC2626,
            awayKitSecondaryHex: 0xFACC15,
            scenarioType: .freeKick,
            tacticalHint: "Wische in einem deutlichen Bogen (erst nach links außen, dann zum linken Torpfosten), um dem Ball Effet zu geben!",
            recommendedPasses: 0,
            parAttempts: 2,
            windSpeed: 0.0,
            starTarget: StarTargetZone(x: -4.8, z: 3.3, radius: 1.80),
            ballStart: Vec2(x: -4.2, y: 30.0),
            players: [
                PlayerSpawn(id: "h10", name: "Florian", shirtNumber: 10, side: .home, role: .ballCarrier, position: Vec2(x: -4.6, y: 29.2), runWaypoints: [], speed: 7.0, reactionDelay: 0.1, hairColorHex: 0x92400E, skinToneIndex: 0),
                PlayerSpawn(id: "w1", name: "Anton", shirtNumber: 5, side: .away, role: .wallDefender, position: Vec2(x: -4.4, y: 38.5), runWaypoints: [], speed: 5.5, reactionDelay: 0.18, hairColorHex: 0x1C1917, skinToneIndex: 1),
                PlayerSpawn(id: "w2", name: "Koch", shirtNumber: 6, side: .away, role: .wallDefender, position: Vec2(x: -2.9, y: 38.5), runWaypoints: [], speed: 5.5, reactionDelay: 0.18, hairColorHex: 0x713F12, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Trapp", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 1.4, y: 51.2), runWaypoints: [], speed: 6.2, reactionDelay: 0.24, hairColorHex: 0x27272A, skinToneIndex: 0)
            ],
            rewardCoins: 60
        ))

        // Level 4: Flank Counterattack (Flügelzange)
        list.append(LevelDefinition(
            id: 4,
            chapterId: 1,
            levelNumberInChapter: 4,
            title: "Flügelzange über Links",
            subtitle: "Schicke deinen schnellen Linksaußen (#11) und lege quer vors Tor!",
            matchMinute: "67'",
            scoreContext: "0 : 1",
            homeTeamName: "Akademie XI",
            awayTeamName: "Blau-Weiß 04",
            awayKitPrimaryHex: 0x0284C7,
            awayKitSecondaryHex: 0xFFFFFF,
            scenarioType: .counterAttack,
            tacticalHint: "Spiele erst nach links außen zu #11. Von dort kannst du entweder direkt ins lange Eck schlenzen oder auf #9 in der Mitte querlegen!",
            recommendedPasses: 1,
            parAttempts: 2,
            windSpeed: 0.0,
            starTarget: StarTargetZone(x: 5.0, z: 2.7, radius: 1.80),
            ballStart: Vec2(x: 0.0, y: 20.0),
            players: [
                PlayerSpawn(id: "h6", name: "Joshua", shirtNumber: 6, side: .home, role: .ballCarrier, position: Vec2(x: 0.0, y: 19.3), runWaypoints: [Vec2(x: 0.0, y: 29.0)], speed: 7.2, reactionDelay: 0.1, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h11", name: "Jamal", shirtNumber: 11, side: .home, role: .winger, position: Vec2(x: -11.5, y: 24.5), runWaypoints: [Vec2(x: -11.0, y: 37.5), Vec2(x: -8.5, y: 42.5)], speed: 8.8, reactionDelay: 0.08, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h9", name: "Kai", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: 4.5, y: 27.5), runWaypoints: [Vec2(x: 3.5, y: 40.5), Vec2(x: 2.0, y: 44.5)], speed: 8.1, reactionDelay: 0.08, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Schlotterbeck", shirtNumber: 4, side: .away, role: .defender, position: Vec2(x: -1.5, y: 29.5), runWaypoints: [Vec2(x: -1.0, y: 25.0)], speed: 6.5, reactionDelay: 0.22, hairColorHex: 0xB45309, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Süle", shirtNumber: 15, side: .away, role: .defender, position: Vec2(x: 5.5, y: 35.0), runWaypoints: [Vec2(x: 3.5, y: 40.0)], speed: 6.3, reactionDelay: 0.24, hairColorHex: 0x27272A, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Baumann", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 6.3, reactionDelay: 0.24, hairColorHex: 0x713F12, skinToneIndex: 0)
            ],
            rewardCoins: 65
        ))

        // Level 5: 1v1 Under Pressure
        list.append(LevelDefinition(
            id: 5,
            chapterId: 1,
            levelNumberInChapter: 5,
            title: "Nervenstärke im 1-gegen-1",
            subtitle: "Ein Verteidiger jagt dich – schlenze den Ball am herausstürmenden Keeper vorbei!",
            matchMinute: "79'",
            scoreContext: "2 : 2",
            homeTeamName: "Akademie XI",
            awayTeamName: "VfL Hansa",
            awayKitPrimaryHex: 0x7C3AED,
            awayKitSecondaryHex: 0xFDE047,
            scenarioType: .finishing,
            tacticalHint: "Der Torwart verkürzt den Winkel leicht nach rechts. Zirkle den Ball mit Linksdrall ins lange linke Eck!",
            recommendedPasses: 0,
            parAttempts: 2,
            windSpeed: 0.0,
            starTarget: StarTargetZone(x: -5.1, z: 2.6, radius: 1.75),
            ballStart: Vec2(x: 3.5, y: 34.0),
            players: [
                PlayerSpawn(id: "h9", name: "Timo", shirtNumber: 9, side: .home, role: .ballCarrier, position: Vec2(x: 3.5, y: 33.3), runWaypoints: [], speed: 8.4, reactionDelay: 0.1, hairColorHex: 0xD97706, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Upamecano", shirtNumber: 2, side: .away, role: .defender, position: Vec2(x: -1.8, y: 35.5), runWaypoints: [Vec2(x: 1.5, y: 37.5)], speed: 7.2, reactionDelay: 0.20, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "gk", name: "Nübel", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 1.2, y: 49.6), runWaypoints: [], speed: 6.5, reactionDelay: 0.22, hairColorHex: 0x78350F, skinToneIndex: 0)
            ],
            rewardCoins: 70
        ))

        // Level 6: Chapter 1 Final
        list.append(LevelDefinition(
            id: 6,
            chapterId: 1,
            levelNumberInChapter: 6,
            title: "Jugendpokal-Finale",
            subtitle: "89. Minute: Kombiniere über rechts und kröne dich zum Pokalsieger!",
            matchMinute: "89'",
            scoreContext: "1 : 1",
            homeTeamName: "Akademie XI",
            awayTeamName: "RB Junioren",
            awayKitPrimaryHex: 0xE11D48,
            awayKitSecondaryHex: 0xF8FAFC,
            scenarioType: .championshipFinal,
            tacticalHint: "Spiele den Steilpass auf Rechtsaußen #7, lege von dort quer auf #9 im Zentrum oder schließe direkt ins Kreuzeck ab!",
            recommendedPasses: 2,
            parAttempts: 3,
            windSpeed: 0.4,
            starTarget: StarTargetZone(x: -4.9, z: 3.2, radius: 1.75),
            ballStart: Vec2(x: -3.0, y: 18.5),
            players: [
                PlayerSpawn(id: "h10", name: "Ilkay", shirtNumber: 10, side: .home, role: .ballCarrier, position: Vec2(x: -3.0, y: 17.8), runWaypoints: [Vec2(x: -2.0, y: 28.0)], speed: 7.4, reactionDelay: 0.1, hairColorHex: 0x18181B, skinToneIndex: 1),
                PlayerSpawn(id: "h7", name: "Serge", shirtNumber: 7, side: .home, role: .winger, position: Vec2(x: 11.0, y: 23.0), runWaypoints: [Vec2(x: 11.5, y: 36.5), Vec2(x: 9.0, y: 42.0)], speed: 8.7, reactionDelay: 0.08, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h9", name: "Niclas", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: -4.5, y: 27.0), runWaypoints: [Vec2(x: -2.0, y: 39.5), Vec2(x: -1.0, y: 44.0)], speed: 8.0, reactionDelay: 0.08, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Orban", shirtNumber: 4, side: .away, role: .defender, position: Vec2(x: -1.5, y: 28.5), runWaypoints: [Vec2(x: -2.2, y: 23.5)], speed: 6.7, reactionDelay: 0.20, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Lukeba", shirtNumber: 23, side: .away, role: .defender, position: Vec2(x: 4.5, y: 34.0), runWaypoints: [Vec2(x: 6.5, y: 38.0)], speed: 6.8, reactionDelay: 0.20, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "gk", name: "Gulacsi", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 6.6, reactionDelay: 0.21, hairColorHex: 0x78350F, skinToneIndex: 0)
            ],
            rewardCoins: 100
        ))

        // =========================================================================
        // CHAPTER 2: AUFSTIEGSKAMPF (Levels 7 - 12)
        // =========================================================================

        // Level 7: Classic One-Two (Doppelpass)
        list.append(LevelDefinition(
            id: 7,
            chapterId: 2,
            levelNumberInChapter: 1,
            title: "Perfekter Doppelpass",
            subtitle: "Spiele #10 an, während dein Startspieler in die Gasse hinter die Abwehr sprintet!",
            matchMinute: "21'",
            scoreContext: "0 : 0",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Fortuna Rhein",
            awayKitPrimaryHex: 0xDC2626,
            awayKitSecondaryHex: 0xFFFFFF,
            scenarioType: .tikiTaka,
            tacticalHint: "Passe schräg nach rechts auf #10. Dein linker Stürmer #11 überläuft sofort den Verteidiger – lege ihm den Ball in den Strafraum vor!",
            recommendedPasses: 2,
            parAttempts: 2,
            windSpeed: 0.0,
            starTarget: StarTargetZone(x: 4.9, z: 3.0, radius: 1.70),
            ballStart: Vec2(x: -8.0, y: 20.0),
            players: [
                PlayerSpawn(id: "h11", name: "Leroy", shirtNumber: 11, side: .home, role: .ballCarrier, position: Vec2(x: -8.0, y: 19.3), runWaypoints: [Vec2(x: -6.5, y: 36.0), Vec2(x: -4.0, y: 42.5)], speed: 8.9, reactionDelay: 0.07, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h10", name: "Julian", shirtNumber: 10, side: .home, role: .midfielder, position: Vec2(x: 5.5, y: 26.5), runWaypoints: [Vec2(x: 4.5, y: 31.5)], speed: 7.6, reactionDelay: 0.08, hairColorHex: 0xD97706, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Zimmermann", shirtNumber: 25, side: .away, role: .defender, position: Vec2(x: -5.5, y: 28.0), runWaypoints: [Vec2(x: -7.0, y: 23.0)], speed: 6.9, reactionDelay: 0.19, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Hoffmann", shirtNumber: 3, side: .away, role: .defender, position: Vec2(x: 1.5, y: 35.5), runWaypoints: [Vec2(x: 2.5, y: 32.5)], speed: 6.8, reactionDelay: 0.20, hairColorHex: 0x27272A, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Kastenmeier", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: -0.5, y: 51.2), runWaypoints: [], speed: 6.8, reactionDelay: 0.20, hairColorHex: 0x78350F, skinToneIndex: 0)
            ],
            rewardCoins: 80
        ))

        // Level 8: Winger Cross to Striker
        list.append(LevelDefinition(
            id: 8,
            chapterId: 2,
            levelNumberInChapter: 2,
            title: "Maßflanke von der Grundlinie",
            subtitle: "Zirkle den Pass von rechts außen hinter den Verteidiger auf deinen Mittelstürmer!",
            matchMinute: "44'",
            scoreContext: "1 : 0",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "St. Pauli Kiezkicker",
            awayKitPrimaryHex: 0x78350F,
            awayKitSecondaryHex: 0xFFFFFF,
            scenarioType: .throughBall,
            tacticalHint: "Ziehe eine leicht gebogene Flanke von der rechten Außenbahn in den Lauf von #9 am Elfmeterpunkt!",
            recommendedPasses: 1,
            parAttempts: 2,
            windSpeed: -0.6,
            starTarget: StarTargetZone(x: -5.2, z: 3.1, radius: 1.70),
            ballStart: Vec2(x: 17.5, y: 34.0),
            players: [
                PlayerSpawn(id: "h7", name: "David", shirtNumber: 7, side: .home, role: .ballCarrier, position: Vec2(x: 17.8, y: 33.3), runWaypoints: [Vec2(x: 16.0, y: 41.0)], speed: 8.4, reactionDelay: 0.08, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "h9", name: "Deniz", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: -6.0, y: 31.0), runWaypoints: [Vec2(x: -1.5, y: 40.5), Vec2(x: -0.5, y: 43.5)], speed: 8.2, reactionDelay: 0.08, hairColorHex: 0x18181B, skinToneIndex: 1),
                PlayerSpawn(id: "d1", name: "Mets", shirtNumber: 24, side: .away, role: .defender, position: Vec2(x: 7.5, y: 36.5), runWaypoints: [Vec2(x: 12.0, y: 35.0)], speed: 7.0, reactionDelay: 0.18, hairColorHex: 0xB45309, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Wahl", shirtNumber: 5, side: .away, role: .defender, position: Vec2(x: 2.0, y: 40.0), runWaypoints: [Vec2(x: 0.5, y: 42.0)], speed: 6.7, reactionDelay: 0.20, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Vasilj", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 1.2, y: 51.2), runWaypoints: [], speed: 6.9, reactionDelay: 0.19, hairColorHex: 0x18181B, skinToneIndex: 0)
            ],
            rewardCoins: 85
        ))

        // Level 9: 3-Man Wall Free Kick
        list.append(LevelDefinition(
            id: 9,
            chapterId: 2,
            levelNumberInChapter: 3,
            title: "Freistoß-Kunstwerk (24m)",
            subtitle: "Überwinde die 3-Mann-Mauer mit einem angeschnittenen Schlenzer ins Toreck!",
            matchMinute: "63'",
            scoreContext: "1 : 1",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Hamburger Hafen",
            awayKitPrimaryHex: 0x1D4ED8,
            awayKitSecondaryHex: 0xEF4444,
            scenarioType: .freeKick,
            tacticalHint: "Ziehe die Flugbahn rechts an der Mauer vorbei mit Linksdrall (Kurve nach innen), damit der Ball ins rechte obere Eck einschlägt!",
            recommendedPasses: 0,
            parAttempts: 2,
            windSpeed: -0.8,
            starTarget: StarTargetZone(x: 5.1, z: 3.4, radius: 1.68),
            ballStart: Vec2(x: 4.5, y: 28.0),
            players: [
                PlayerSpawn(id: "h10", name: "Toni", shirtNumber: 10, side: .home, role: .ballCarrier, position: Vec2(x: 4.8, y: 27.2), runWaypoints: [], speed: 7.2, reactionDelay: 0.1, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "w1", name: "Schonlau", shirtNumber: 4, side: .away, role: .wallDefender, position: Vec2(x: 2.0, y: 37.5), runWaypoints: [], speed: 5.8, reactionDelay: 0.16, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "w2", name: "Meffert", shirtNumber: 23, side: .away, role: .wallDefender, position: Vec2(x: 3.4, y: 37.5), runWaypoints: [], speed: 5.8, reactionDelay: 0.16, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "w3", name: "Hadzikadunic", shirtNumber: 5, side: .away, role: .wallDefender, position: Vec2(x: 4.8, y: 37.5), runWaypoints: [], speed: 5.8, reactionDelay: 0.16, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Heuer", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: -1.5, y: 51.2), runWaypoints: [], speed: 7.0, reactionDelay: 0.18, hairColorHex: 0x451A03, skinToneIndex: 0)
            ],
            rewardCoins: 95
        ))

        // Level 10: Threading the Needle Between Two Center-Backs
        list.append(LevelDefinition(
            id: 10,
            chapterId: 2,
            levelNumberInChapter: 4,
            title: "Nadelöhr in der Zentrale",
            subtitle: "Spiele den tödlichen Pass genau durch die Schnittstelle zwischen den Innenverteidigern!",
            matchMinute: "74'",
            scoreContext: "0 : 1",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Hannover 96er",
            awayKitPrimaryHex: 0x991B1B,
            awayKitSecondaryHex: 0x18181B,
            scenarioType: .throughBall,
            tacticalHint: "Ziele den Pass genau durch die Mitte auf ca. 40 Meter vor dem Tor – #9 sprintet in die Lücke!",
            recommendedPasses: 1,
            parAttempts: 2,
            windSpeed: 0.0,
            starTarget: StarTargetZone(x: 5.2, z: 2.9, radius: 1.65),
            ballStart: Vec2(x: 0.0, y: 21.0),
            players: [
                PlayerSpawn(id: "h8", name: "Angelo", shirtNumber: 8, side: .home, role: .ballCarrier, position: Vec2(x: 0.0, y: 20.3), runWaypoints: [Vec2(x: 0.0, y: 28.0)], speed: 7.4, reactionDelay: 0.08, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "h9", name: "Maximilian", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: -7.5, y: 29.0), runWaypoints: [Vec2(x: 0.0, y: 40.5), Vec2(x: 0.5, y: 44.5)], speed: 8.6, reactionDelay: 0.07, hairColorHex: 0x92400E, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Halstenberg", shirtNumber: 23, side: .away, role: .defender, position: Vec2(x: -5.2, y: 33.5), runWaypoints: [Vec2(x: -3.5, y: 36.5)], speed: 7.0, reactionDelay: 0.18, hairColorHex: 0xD97706, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Neumann", shirtNumber: 5, side: .away, role: .defender, position: Vec2(x: 5.2, y: 33.5), runWaypoints: [Vec2(x: 3.5, y: 36.5)], speed: 7.0, reactionDelay: 0.18, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Zieler", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 7.1, reactionDelay: 0.18, hairColorHex: 0x78350F, skinToneIndex: 0)
            ],
            rewardCoins: 95
        ))

        // Level 11: Counterattack Against Fast Sweeper
        list.append(LevelDefinition(
            id: 11,
            chapterId: 2,
            levelNumberInChapter: 5,
            title: "Blitzkonter ab der Mittellinie",
            subtitle: "Überbrücke das Mittelfeld mit zwei schnellen Pässen bevor die Abwehr zurückrückt!",
            matchMinute: "82'",
            scoreContext: "2 : 2",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Karlsruher Blau",
            awayKitPrimaryHex: 0x1E40AF,
            awayKitSecondaryHex: 0xFFFFFF,
            scenarioType: .counterAttack,
            tacticalHint: "Spiele zuerst auf #10 im Halbfeld, dann sofort steil nach links auf #11 oder rechts auf #9!",
            recommendedPasses: 2,
            parAttempts: 2,
            windSpeed: 0.5,
            starTarget: StarTargetZone(x: -5.0, z: 3.2, radius: 1.65),
            ballStart: Vec2(x: 4.0, y: 10.0),
            players: [
                PlayerSpawn(id: "h6", name: "Robert", shirtNumber: 6, side: .home, role: .ballCarrier, position: Vec2(x: 4.0, y: 9.3), runWaypoints: [Vec2(x: 3.0, y: 20.0)], speed: 7.5, reactionDelay: 0.08, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "h10", name: "Chris", shirtNumber: 10, side: .home, role: .midfielder, position: Vec2(x: -5.5, y: 21.0), runWaypoints: [Vec2(x: -3.0, y: 29.5)], speed: 8.2, reactionDelay: 0.07, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h9", name: "Aleksandar", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: 10.5, y: 26.5), runWaypoints: [Vec2(x: 6.5, y: 39.5), Vec2(x: 4.0, y: 43.5)], speed: 8.6, reactionDelay: 0.07, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Franke", shirtNumber: 28, side: .away, role: .defender, position: Vec2(x: 1.5, y: 22.0), runWaypoints: [Vec2(x: -1.5, y: 26.0)], speed: 7.1, reactionDelay: 0.17, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Kobald", shirtNumber: 22, side: .away, role: .sweeper, position: Vec2(x: 2.0, y: 35.5), runWaypoints: [Vec2(x: 4.0, y: 39.0)], speed: 7.2, reactionDelay: 0.17, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Weiß", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 7.2, reactionDelay: 0.17, hairColorHex: 0xB45309, skinToneIndex: 0)
            ],
            rewardCoins: 100
        ))

        // Level 12: Promotion Decider (Aufstiegs-Finale)
        list.append(LevelDefinition(
            id: 12,
            chapterId: 2,
            levelNumberInChapter: 6,
            title: "Relegations-Herzschlagfinale",
            subtitle: "90.+2 Minute: Schieß dein Team in die 1. Bundesliga!",
            matchMinute: "90+2'",
            scoreContext: "2 : 2",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Hertha Hauptstadt",
            awayKitPrimaryHex: 0x2563EB,
            awayKitSecondaryHex: 0xFFFFFF,
            scenarioType: .championshipFinal,
            tacticalHint: "Ziehe das Pressing auf dich, spiele den Ball auf #7 rechts außen und bediene #9 im Zentrum für den Aufstiegstreffer!",
            recommendedPasses: 2,
            parAttempts: 3,
            windSpeed: -0.9,
            starTarget: StarTargetZone(x: 5.3, z: 3.3, radius: 1.62),
            ballStart: Vec2(x: -6.5, y: 17.0),
            players: [
                PlayerSpawn(id: "h8", name: "Pascal", shirtNumber: 8, side: .home, role: .ballCarrier, position: Vec2(x: -6.5, y: 16.3), runWaypoints: [Vec2(x: -4.0, y: 26.0)], speed: 7.6, reactionDelay: 0.08, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h7", name: "Karim", shirtNumber: 7, side: .home, role: .winger, position: Vec2(x: 12.5, y: 23.5), runWaypoints: [Vec2(x: 12.0, y: 36.5), Vec2(x: 9.0, y: 41.5)], speed: 8.9, reactionDelay: 0.07, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h9", name: "Jonathan", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: -2.0, y: 29.0), runWaypoints: [Vec2(x: -1.0, y: 40.5), Vec2(x: 0.5, y: 44.0)], speed: 8.4, reactionDelay: 0.07, hairColorHex: 0x92400E, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Kempf", shirtNumber: 20, side: .away, role: .defender, position: Vec2(x: -3.5, y: 26.5), runWaypoints: [Vec2(x: -5.5, y: 21.0)], speed: 7.2, reactionDelay: 0.16, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Leistner", shirtNumber: 37, side: .away, role: .defender, position: Vec2(x: 4.0, y: 32.5), runWaypoints: [Vec2(x: 7.5, y: 36.0)], speed: 7.1, reactionDelay: 0.17, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "d3", name: "Zefuik", shirtNumber: 42, side: .away, role: .sweeper, position: Vec2(x: -4.0, y: 37.5), runWaypoints: [Vec2(x: -1.5, y: 41.0)], speed: 7.3, reactionDelay: 0.16, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "gk", name: "Ernst", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 7.3, reactionDelay: 0.17, hairColorHex: 0xD97706, skinToneIndex: 0)
            ],
            rewardCoins: 130
        ))

        // =========================================================================
        // CHAPTER 3: MEISTERKLASSE (Levels 13 - 18)
        // =========================================================================

        // Level 13: Tight-Angle Banana Shot
        list.append(LevelDefinition(
            id: 13,
            chapterId: 3,
            levelNumberInChapter: 1,
            title: "Spitzer Winkel von Rechts",
            subtitle: "Zirkle den Ball von der rechten Strafraumkante mit starkem Innendrall ins lange Eck!",
            matchMinute: "19'",
            scoreContext: "0 : 0",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "VfB Neckar",
            awayKitPrimaryHex: 0xFFFFFF,
            awayKitSecondaryHex: 0xDC2626,
            scenarioType: .finishing,
            tacticalHint: "Wische zuerst rechts am Pfosten vorbei und ziehe den Finger dann nach links zum langen Pfosten für einen echten Bananenschuss!",
            recommendedPasses: 0,
            parAttempts: 2,
            windSpeed: -1.1,
            starTarget: StarTargetZone(x: -5.3, z: 3.3, radius: 1.60),
            ballStart: Vec2(x: 13.5, y: 37.5),
            players: [
                PlayerSpawn(id: "h7", name: "Michael", shirtNumber: 7, side: .home, role: .ballCarrier, position: Vec2(x: 13.8, y: 36.8), runWaypoints: [], speed: 8.5, reactionDelay: 0.08, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "d1", name: "Mittelstädt", shirtNumber: 7, side: .away, role: .defender, position: Vec2(x: 8.5, y: 41.0), runWaypoints: [Vec2(x: 10.5, y: 39.0)], speed: 7.4, reactionDelay: 0.16, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Nübel", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 3.0, y: 50.8), runWaypoints: [], speed: 7.4, reactionDelay: 0.16, hairColorHex: 0x78350F, skinToneIndex: 0)
            ],
            rewardCoins: 110
        ))

        // Level 14: 3-Pass Tiki-Taka Triangle
        list.append(LevelDefinition(
            id: 14,
            chapterId: 3,
            levelNumberInChapter: 2,
            title: "Tiki-Taka im Halbraum",
            subtitle: "Knacke das Dreieck-Pressing mit schnellem Direktspiel über 3 Stationen!",
            matchMinute: "37'",
            scoreContext: "1 : 0",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Werkself 04",
            awayKitPrimaryHex: 0xDC2626,
            awayKitSecondaryHex: 0x18181B,
            scenarioType: .tikiTaka,
            tacticalHint: "Spiele von #6 links auf #8, dann quer nach rechts auf #10 und steil auf #9 vor dem Tor!",
            recommendedPasses: 3,
            parAttempts: 2,
            windSpeed: 0.4,
            starTarget: StarTargetZone(x: 5.2, z: 3.1, radius: 1.60),
            ballStart: Vec2(x: 0.0, y: 13.0),
            players: [
                PlayerSpawn(id: "h6", name: "Granit", shirtNumber: 6, side: .home, role: .ballCarrier, position: Vec2(x: 0.0, y: 12.3), runWaypoints: [Vec2(x: 0.0, y: 22.0)], speed: 7.5, reactionDelay: 0.08, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "h8", name: "Exequiel", shirtNumber: 8, side: .home, role: .midfielder, position: Vec2(x: -11.0, y: 21.5), runWaypoints: [Vec2(x: -9.5, y: 29.0)], speed: 8.1, reactionDelay: 0.07, hairColorHex: 0x18181B, skinToneIndex: 1),
                PlayerSpawn(id: "h10", name: "Florian", shirtNumber: 10, side: .home, role: .midfielder, position: Vec2(x: 9.5, y: 27.5), runWaypoints: [Vec2(x: 7.5, y: 35.5)], speed: 8.4, reactionDelay: 0.07, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h9", name: "Victor", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: -3.5, y: 33.5), runWaypoints: [Vec2(x: -1.0, y: 42.0), Vec2(x: 0.0, y: 45.0)], speed: 8.7, reactionDelay: 0.06, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "d1", name: "Andrich", shirtNumber: 8, side: .away, role: .defender, position: Vec2(x: -2.0, y: 21.0), runWaypoints: [Vec2(x: -5.5, y: 23.0)], speed: 7.4, reactionDelay: 0.15, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Tapsoba", shirtNumber: 12, side: .away, role: .defender, position: Vec2(x: 2.5, y: 31.0), runWaypoints: [Vec2(x: 5.5, y: 33.5)], speed: 7.5, reactionDelay: 0.15, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "d3", name: "Tah", shirtNumber: 4, side: .away, role: .sweeper, position: Vec2(x: -3.5, y: 38.5), runWaypoints: [Vec2(x: -1.5, y: 41.5)], speed: 7.4, reactionDelay: 0.15, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "gk", name: "Hradecky", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 7.5, reactionDelay: 0.15, hairColorHex: 0xD97706, skinToneIndex: 0)
            ],
            rewardCoins: 120
        ))

        // Level 15: Diagonal Switch of Play (Seitenwechsel)
        list.append(LevelDefinition(
            id: 15,
            chapterId: 3,
            levelNumberInChapter: 3,
            title: "Diagonaler Seitenwechsel",
            subtitle: "Die linke Seite ist zugestellt – verlagere das Spiel weit nach rechts auf den freien Flügel!",
            matchMinute: "55'",
            scoreContext: "0 : 1",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Eintracht Adler",
            awayKitPrimaryHex: 0x18181B,
            awayKitSecondaryHex: 0xDC2626,
            scenarioType: .counterAttack,
            tacticalHint: "Ziehe einen langen, leicht angeschnittenen Diagonalball von links komplett rüber auf #7 auf dem rechten Flügel!",
            recommendedPasses: 1,
            parAttempts: 2,
            windSpeed: 1.2,
            starTarget: StarTargetZone(x: -5.1, z: 3.2, radius: 1.58),
            ballStart: Vec2(x: -15.5, y: 22.0),
            players: [
                PlayerSpawn(id: "h3", name: "Alejandro", shirtNumber: 3, side: .home, role: .ballCarrier, position: Vec2(x: -15.8, y: 21.3), runWaypoints: [Vec2(x: -14.0, y: 31.0)], speed: 8.3, reactionDelay: 0.08, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "h7", name: "Jeremie", shirtNumber: 7, side: .home, role: .winger, position: Vec2(x: 13.5, y: 27.0), runWaypoints: [Vec2(x: 11.0, y: 39.5), Vec2(x: 7.5, y: 43.5)], speed: 9.1, reactionDelay: 0.06, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "h9", name: "Harry", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: -1.5, y: 32.0), runWaypoints: [Vec2(x: 0.0, y: 42.5)], speed: 8.2, reactionDelay: 0.07, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Tuta", shirtNumber: 35, side: .away, role: .defender, position: Vec2(x: -10.5, y: 28.0), runWaypoints: [Vec2(x: -13.0, y: 24.5)], speed: 7.5, reactionDelay: 0.15, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "d2", name: "Koch", shirtNumber: 4, side: .away, role: .defender, position: Vec2(x: -3.5, y: 34.5), runWaypoints: [Vec2(x: 2.0, y: 38.0)], speed: 7.4, reactionDelay: 0.15, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Trapp", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: -0.5, y: 51.2), runWaypoints: [], speed: 7.6, reactionDelay: 0.15, hairColorHex: 0x27272A, skinToneIndex: 0)
            ],
            rewardCoins: 125
        ))

        // Level 16: High-Wind Free Kick Over 4-Man Wall
        list.append(LevelDefinition(
            id: 16,
            chapterId: 3,
            levelNumberInChapter: 4,
            title: "Sturm-Freistoß im Stadion",
            subtitle: "4-Mann-Mauer und starker Seitenwind: Halte dagegen und triff den Winkel!",
            matchMinute: "69'",
            scoreContext: "1 : 1",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Borussia Fohlen",
            awayKitPrimaryHex: 0x16A34A,
            awayKitSecondaryHex: 0xFFFFFF,
            scenarioType: .freeKick,
            tacticalHint: "Beachte den Seitenwind! Ziehe die Kurve weit links um die 4-Mann-Mauer herum, damit Wind und Drall den Ball ins Tor lenken.",
            recommendedPasses: 0,
            parAttempts: 2,
            windSpeed: 1.6,
            starTarget: StarTargetZone(x: -4.9, z: 3.5, radius: 1.55),
            ballStart: Vec2(x: -5.5, y: 27.0),
            players: [
                PlayerSpawn(id: "h10", name: "Joshua", shirtNumber: 10, side: .home, role: .ballCarrier, position: Vec2(x: -5.8, y: 26.2), runWaypoints: [], speed: 7.5, reactionDelay: 0.08, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "w1", name: "Itakura", shirtNumber: 3, side: .away, role: .wallDefender, position: Vec2(x: -6.2, y: 36.8), runWaypoints: [], speed: 6.0, reactionDelay: 0.14, hairColorHex: 0x18181B, skinToneIndex: 1),
                PlayerSpawn(id: "w2", name: "Elvedi", shirtNumber: 30, side: .away, role: .wallDefender, position: Vec2(x: -4.8, y: 36.8), runWaypoints: [], speed: 6.0, reactionDelay: 0.14, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "w3", name: "Weigl", shirtNumber: 8, side: .away, role: .wallDefender, position: Vec2(x: -3.4, y: 36.8), runWaypoints: [], speed: 6.0, reactionDelay: 0.14, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "w4", name: "Reitz", shirtNumber: 27, side: .away, role: .wallDefender, position: Vec2(x: -2.0, y: 36.8), runWaypoints: [], speed: 6.0, reactionDelay: 0.14, hairColorHex: 0x92400E, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Nicolas", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 1.8, y: 51.2), runWaypoints: [], speed: 7.6, reactionDelay: 0.15, hairColorHex: 0x451A03, skinToneIndex: 0)
            ],
            rewardCoins: 135
        ))

        // Level 17: Breaking a 4-Man Backline
        list.append(LevelDefinition(
            id: 17,
            chapterId: 3,
            levelNumberInChapter: 5,
            title: "Viererkette knacken",
            subtitle: "Locke die Viererkette heraus und spiele den tödlichen Schnittstellenpass!",
            matchMinute: "81'",
            scoreContext: "2 : 1",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "SC Breisgau",
            awayKitPrimaryHex: 0xEF4444,
            awayKitSecondaryHex: 0x18181B,
            scenarioType: .throughBall,
            tacticalHint: "Spiele zuerst kurz auf #10 im Zentrum. Dadurch rückt der rechte Außenverteidiger ein und #11 links ist völlig frei!",
            recommendedPasses: 2,
            parAttempts: 2,
            windSpeed: -0.5,
            starTarget: StarTargetZone(x: 5.4, z: 3.1, radius: 1.55),
            ballStart: Vec2(x: 6.0, y: 19.0),
            players: [
                PlayerSpawn(id: "h8", name: "Leon", shirtNumber: 8, side: .home, role: .ballCarrier, position: Vec2(x: 6.0, y: 18.3), runWaypoints: [Vec2(x: 5.0, y: 27.0)], speed: 7.8, reactionDelay: 0.08, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "h10", name: "Jamal", shirtNumber: 10, side: .home, role: .midfielder, position: Vec2(x: -1.5, y: 27.5), runWaypoints: [Vec2(x: -1.0, y: 33.0)], speed: 8.5, reactionDelay: 0.06, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h11", name: "Kingsley", shirtNumber: 11, side: .home, role: .winger, position: Vec2(x: -13.5, y: 29.0), runWaypoints: [Vec2(x: -9.5, y: 40.5), Vec2(x: -6.5, y: 44.0)], speed: 9.1, reactionDelay: 0.06, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "d1", name: "Ginter", shirtNumber: 28, side: .away, role: .defender, position: Vec2(x: 5.0, y: 32.0), runWaypoints: [Vec2(x: 5.5, y: 24.5)], speed: 7.5, reactionDelay: 0.14, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Lienhart", shirtNumber: 3, side: .away, role: .defender, position: Vec2(x: -1.5, y: 34.5), runWaypoints: [Vec2(x: -1.5, y: 30.5)], speed: 7.5, reactionDelay: 0.14, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d3", name: "Günter", shirtNumber: 30, side: .away, role: .defender, position: Vec2(x: -8.0, y: 35.0), runWaypoints: [Vec2(x: -4.5, y: 36.5)], speed: 7.6, reactionDelay: 0.14, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Atubolu", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 7.7, reactionDelay: 0.14, hairColorHex: 0x18181B, skinToneIndex: 3)
            ],
            rewardCoins: 140
        ))

        // Level 18: Bundesliga Championship Final
        list.append(LevelDefinition(
            id: 18,
            chapterId: 3,
            levelNumberInChapter: 6,
            title: "Deutsches Meisterschafts-Finale",
            subtitle: "Der Klassiker am 34. Spieltag: Erziele das Meistertor in der Nachspielzeit!",
            matchMinute: "90+1'",
            scoreContext: "2 : 2",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Westfalen 09",
            awayKitPrimaryHex: 0xFACC15,
            awayKitSecondaryHex: 0x18181B,
            scenarioType: .championshipFinal,
            tacticalHint: "Kombiniere schnell über links (#11), spiele den Ball um den Verteidiger herum auf #9 in der Mitte und verwandle eiskalt!",
            recommendedPasses: 2,
            parAttempts: 2,
            windSpeed: 0.8,
            starTarget: StarTargetZone(x: 5.4, z: 3.4, radius: 1.52),
            ballStart: Vec2(x: 2.0, y: 15.0),
            players: [
                PlayerSpawn(id: "h6", name: "Aleks", shirtNumber: 6, side: .home, role: .ballCarrier, position: Vec2(x: 2.0, y: 14.3), runWaypoints: [Vec2(x: 1.0, y: 24.0)], speed: 7.8, reactionDelay: 0.08, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "h11", name: "Jamal", shirtNumber: 11, side: .home, role: .winger, position: Vec2(x: -12.0, y: 22.5), runWaypoints: [Vec2(x: -11.0, y: 35.5), Vec2(x: -8.0, y: 41.0)], speed: 9.0, reactionDelay: 0.06, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h7", name: "Michael", shirtNumber: 7, side: .home, role: .winger, position: Vec2(x: 13.0, y: 25.0), runWaypoints: [Vec2(x: 11.5, y: 37.5)], speed: 8.9, reactionDelay: 0.06, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h9", name: "Harry", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: 0.5, y: 29.5), runWaypoints: [Vec2(x: 0.0, y: 41.0), Vec2(x: 1.0, y: 44.5)], speed: 8.6, reactionDelay: 0.06, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Can", shirtNumber: 23, side: .away, role: .defender, position: Vec2(x: 1.5, y: 24.5), runWaypoints: [Vec2(x: 1.8, y: 19.5)], speed: 7.6, reactionDelay: 0.14, hairColorHex: 0x18181B, skinToneIndex: 1),
                PlayerSpawn(id: "d2", name: "Schlotterbeck", shirtNumber: 4, side: .away, role: .defender, position: Vec2(x: -5.5, y: 32.5), runWaypoints: [Vec2(x: -8.5, y: 35.0)], speed: 7.7, reactionDelay: 0.14, hairColorHex: 0xB45309, skinToneIndex: 0),
                PlayerSpawn(id: "d3", name: "Anton", shirtNumber: 3, side: .away, role: .sweeper, position: Vec2(x: 4.5, y: 36.5), runWaypoints: [Vec2(x: 2.0, y: 40.5)], speed: 7.7, reactionDelay: 0.14, hairColorHex: 0x18181B, skinToneIndex: 1),
                PlayerSpawn(id: "gk", name: "Kobel", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 7.9, reactionDelay: 0.13, hairColorHex: 0x451A03, skinToneIndex: 0)
            ],
            rewardCoins: 170
        ))

        // =========================================================================
        // CHAPTER 4: KÖNIGSKLASSE (Levels 19 - 24)
        // =========================================================================

        // Level 19: High Press Escape in Champions Cup
        list.append(LevelDefinition(
            id: 19,
            chapterId: 4,
            levelNumberInChapter: 1,
            title: "Achtelfinale in Mailand",
            subtitle: "Befreie dich mit einem angeschnittenen Außenristpass aus dem Gegenpressing!",
            matchMinute: "28'",
            scoreContext: "0 : 0",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Inter Milano",
            awayKitPrimaryHex: 0x1E3A8A,
            awayKitSecondaryHex: 0x000000,
            scenarioType: .throughBall,
            tacticalHint: "Zirkle den Pass außen um den pressenden Verteidiger herum in den Lauf von #9!",
            recommendedPasses: 1,
            parAttempts: 2,
            windSpeed: -0.7,
            starTarget: StarTargetZone(x: -5.3, z: 3.3, radius: 1.50),
            ballStart: Vec2(x: 8.5, y: 22.0),
            players: [
                PlayerSpawn(id: "h10", name: "Jamal", shirtNumber: 10, side: .home, role: .ballCarrier, position: Vec2(x: 8.5, y: 21.3), runWaypoints: [Vec2(x: 7.0, y: 30.0)], speed: 8.5, reactionDelay: 0.06, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h9", name: "Harry", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: -6.5, y: 28.5), runWaypoints: [Vec2(x: -2.0, y: 40.5), Vec2(x: -1.0, y: 44.0)], speed: 8.7, reactionDelay: 0.06, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Barella", shirtNumber: 23, side: .away, role: .defender, position: Vec2(x: 3.5, y: 27.5), runWaypoints: [Vec2(x: 6.5, y: 24.0)], speed: 7.9, reactionDelay: 0.13, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Bastoni", shirtNumber: 95, side: .away, role: .defender, position: Vec2(x: -1.5, y: 34.5), runWaypoints: [Vec2(x: -3.0, y: 38.0)], speed: 7.8, reactionDelay: 0.13, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Sommer", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.5, y: 51.2), runWaypoints: [], speed: 8.0, reactionDelay: 0.13, hairColorHex: 0x451A03, skinToneIndex: 0)
            ],
            rewardCoins: 150
        ))

        // Level 20: Double Wing Overlap (Doppelte Überlagerung)
        list.append(LevelDefinition(
            id: 20,
            chapterId: 4,
            levelNumberInChapter: 2,
            title: "Viertelfinale in Paris",
            subtitle: "Nutze den hinterlaufenden Außenverteidiger für die perfekte Vorlage!",
            matchMinute: "52'",
            scoreContext: "1 : 1",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Paris Saint-Star",
            awayKitPrimaryHex: 0x1E293B,
            awayKitSecondaryHex: 0xE11D48,
            scenarioType: .counterAttack,
            tacticalHint: "Spiele von #8 nach links auf #19, der mit Höchsttempo die Linie entlang sprintet, und lege quer auf #9!",
            recommendedPasses: 2,
            parAttempts: 2,
            windSpeed: 1.0,
            starTarget: StarTargetZone(x: 5.4, z: 3.2, radius: 1.50),
            ballStart: Vec2(x: -2.0, y: 16.5),
            players: [
                PlayerSpawn(id: "h8", name: "Joshua", shirtNumber: 8, side: .home, role: .ballCarrier, position: Vec2(x: -2.0, y: 15.8), runWaypoints: [Vec2(x: -1.0, y: 25.0)], speed: 7.8, reactionDelay: 0.06, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h19", name: "Alphonso", shirtNumber: 19, side: .home, role: .winger, position: Vec2(x: -15.5, y: 22.0), runWaypoints: [Vec2(x: -14.5, y: 38.5), Vec2(x: -10.5, y: 43.5)], speed: 9.5, reactionDelay: 0.05, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "h9", name: "Harry", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: 4.5, y: 29.0), runWaypoints: [Vec2(x: 2.0, y: 41.5), Vec2(x: 1.5, y: 45.0)], speed: 8.6, reactionDelay: 0.06, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Hakimi", shirtNumber: 2, side: .away, role: .defender, position: Vec2(x: -8.5, y: 29.5), runWaypoints: [Vec2(x: -11.5, y: 34.5)], speed: 8.2, reactionDelay: 0.12, hairColorHex: 0x18181B, skinToneIndex: 1),
                PlayerSpawn(id: "d2", name: "Marquinhos", shirtNumber: 5, side: .away, role: .defender, position: Vec2(x: 0.5, y: 35.0), runWaypoints: [Vec2(x: -1.5, y: 39.5)], speed: 7.9, reactionDelay: 0.12, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "gk", name: "Donnarumma", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: -0.5, y: 51.2), runWaypoints: [], speed: 8.1, reactionDelay: 0.12, hairColorHex: 0x451A03, skinToneIndex: 0)
            ],
            rewardCoins: 160
        ))

        // Level 21: 26m Roberto-Carlos Trivela Free Kick
        list.append(LevelDefinition(
            id: 21,
            chapterId: 4,
            levelNumberInChapter: 3,
            title: "Bananen-Freistoß aus 26 Metern",
            subtitle: "4-Mann-Mauer im Halbfinal-Hinspiel: Zirkle das Leder unhaltbar in den Winkel!",
            matchMinute: "66'",
            scoreContext: "0 : 1",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Manchester Sky",
            awayKitPrimaryHex: 0x38BDF8,
            awayKitSecondaryHex: 0xFFFFFF,
            scenarioType: .freeKick,
            tacticalHint: "Ziehe einen kräftigen Bogen rechts außen um die Mauer mit starkem Linksdrall (Trivela-Kurve) direkt ins rechte Kreuzeck!",
            recommendedPasses: 0,
            parAttempts: 2,
            windSpeed: -1.4,
            starTarget: StarTargetZone(x: 5.3, z: 3.6, radius: 1.48),
            ballStart: Vec2(x: 3.2, y: 26.0),
            players: [
                PlayerSpawn(id: "h7", name: "Michael", shirtNumber: 7, side: .home, role: .ballCarrier, position: Vec2(x: 3.5, y: 25.2), runWaypoints: [], speed: 8.2, reactionDelay: 0.06, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "w1", name: "Dias", shirtNumber: 3, side: .away, role: .wallDefender, position: Vec2(x: 0.6, y: 36.2), runWaypoints: [], speed: 6.2, reactionDelay: 0.12, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "w2", name: "Rodri", shirtNumber: 16, side: .away, role: .wallDefender, position: Vec2(x: 2.0, y: 36.2), runWaypoints: [], speed: 6.2, reactionDelay: 0.12, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "w3", name: "Stones", shirtNumber: 5, side: .away, role: .wallDefender, position: Vec2(x: 3.4, y: 36.2), runWaypoints: [], speed: 6.2, reactionDelay: 0.12, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "w4", name: "Gvardiol", shirtNumber: 24, side: .away, role: .wallDefender, position: Vec2(x: 4.8, y: 36.2), runWaypoints: [], speed: 6.2, reactionDelay: 0.12, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Ederson", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: -1.8, y: 51.2), runWaypoints: [], speed: 8.2, reactionDelay: 0.12, hairColorHex: 0x18181B, skinToneIndex: 1)
            ],
            rewardCoins: 170
        ))

        // Level 22: Tiki-Taka Against Barcelona Press
        list.append(LevelDefinition(
            id: 22,
            chapterId: 4,
            levelNumberInChapter: 4,
            title: "Halbfinale in Barcelona",
            subtitle: "Spiele die hohe Abwehrlinie mit drei präzisen Direktpässen schwindelig!",
            matchMinute: "73'",
            scoreContext: "1 : 1",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "FC Blaugrana",
            awayKitPrimaryHex: 0x991B1B,
            awayKitSecondaryHex: 0x1D4ED8,
            scenarioType: .tikiTaka,
            tacticalHint: "Spiele von #6 auf #10, weiter nach rechts auf #7 und dann flach in den Fünfmeterraum auf #9!",
            recommendedPasses: 3,
            parAttempts: 2,
            windSpeed: 0.6,
            starTarget: StarTargetZone(x: -5.4, z: 3.1, radius: 1.48),
            ballStart: Vec2(x: -7.0, y: 14.0),
            players: [
                PlayerSpawn(id: "h6", name: "Joshua", shirtNumber: 6, side: .home, role: .ballCarrier, position: Vec2(x: -7.0, y: 13.3), runWaypoints: [Vec2(x: -5.0, y: 23.0)], speed: 8.0, reactionDelay: 0.06, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h10", name: "Jamal", shirtNumber: 10, side: .home, role: .midfielder, position: Vec2(x: 2.5, y: 23.0), runWaypoints: [Vec2(x: 3.5, y: 30.0)], speed: 8.8, reactionDelay: 0.05, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h7", name: "Serge", shirtNumber: 7, side: .home, role: .winger, position: Vec2(x: 14.0, y: 30.0), runWaypoints: [Vec2(x: 11.5, y: 40.5), Vec2(x: 8.5, y: 44.0)], speed: 9.0, reactionDelay: 0.05, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h9", name: "Harry", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: -4.5, y: 33.0), runWaypoints: [Vec2(x: -1.5, y: 43.0), Vec2(x: -1.0, y: 46.0)], speed: 8.7, reactionDelay: 0.05, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Pedri", shirtNumber: 8, side: .away, role: .defender, position: Vec2(x: -3.5, y: 22.0), runWaypoints: [Vec2(x: -5.5, y: 18.0)], speed: 8.0, reactionDelay: 0.12, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Araujo", shirtNumber: 4, side: .away, role: .defender, position: Vec2(x: 6.5, y: 32.0), runWaypoints: [Vec2(x: 8.5, y: 36.5)], speed: 8.2, reactionDelay: 0.12, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "d3", name: "Kounde", shirtNumber: 23, side: .away, role: .sweeper, position: Vec2(x: -2.0, y: 37.5), runWaypoints: [Vec2(x: 0.5, y: 41.5)], speed: 8.1, reactionDelay: 0.12, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "gk", name: "TerStegen", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 8.2, reactionDelay: 0.12, hairColorHex: 0xD97706, skinToneIndex: 0)
            ],
            rewardCoins: 175
        ))

        // Level 23: Semi-Final Comeback
        list.append(LevelDefinition(
            id: 23,
            chapterId: 4,
            levelNumberInChapter: 5,
            title: "Halbfinal-Rückspiel in Madrid",
            subtitle: "86. Minute im Bernabéu: Überliste die Abwehr mit einem Kurvenpass in die Tiefe!",
            matchMinute: "86'",
            scoreContext: "1 : 1",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Real Galacticos",
            awayKitPrimaryHex: 0xF8FAFC,
            awayKitSecondaryHex: 0xF59E0B,
            scenarioType: .throughBall,
            tacticalHint: "Zirkle den Pass von rechts außen um den Innenverteidiger herum in den Lauf von #11, der diagonal zum Tor zieht!",
            recommendedPasses: 1,
            parAttempts: 2,
            windSpeed: -1.0,
            starTarget: StarTargetZone(x: 5.5, z: 3.4, radius: 1.45),
            ballStart: Vec2(x: 11.5, y: 23.0),
            players: [
                PlayerSpawn(id: "h8", name: "Toni", shirtNumber: 8, side: .home, role: .ballCarrier, position: Vec2(x: 11.5, y: 22.3), runWaypoints: [Vec2(x: 9.5, y: 30.0)], speed: 7.9, reactionDelay: 0.06, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h11", name: "Leroy", shirtNumber: 11, side: .home, role: .striker, position: Vec2(x: -9.5, y: 28.5), runWaypoints: [Vec2(x: -1.5, y: 40.5), Vec2(x: 0.5, y: 44.0)], speed: 9.2, reactionDelay: 0.05, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "d1", name: "Rüdiger", shirtNumber: 22, side: .away, role: .defender, position: Vec2(x: 5.5, y: 30.5), runWaypoints: [Vec2(x: 8.5, y: 26.5)], speed: 8.3, reactionDelay: 0.11, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "d2", name: "Militao", shirtNumber: 3, side: .away, role: .defender, position: Vec2(x: -2.0, y: 34.5), runWaypoints: [Vec2(x: -3.5, y: 38.0)], speed: 8.2, reactionDelay: 0.11, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "gk", name: "Courtois", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: -0.5, y: 51.2), runWaypoints: [], speed: 8.4, reactionDelay: 0.11, hairColorHex: 0x451A03, skinToneIndex: 0)
            ],
            rewardCoins: 185
        ))

        // Level 24: Champions Cup Final (Wembley)
        list.append(LevelDefinition(
            id: 24,
            chapterId: 4,
            levelNumberInChapter: 6,
            title: "Champions-Cup-Finale in London",
            subtitle: "89. Minute: Kröne dich zum König von Europa!",
            matchMinute: "89'",
            scoreContext: "1 : 1",
            homeTeamName: "FC Bavaria Star",
            awayTeamName: "Liverpool Reds",
            awayKitPrimaryHex: 0xB91C1C,
            awayKitSecondaryHex: 0xFACC15,
            scenarioType: .championshipFinal,
            tacticalHint: "Spiele den Steilpass auf #10 im Halbraum, lege quer über die Abwehr auf #7 und schweiße den Ball ins obere Eck!",
            recommendedPasses: 2,
            parAttempts: 2,
            windSpeed: 1.2,
            starTarget: StarTargetZone(x: -5.4, z: 3.5, radius: 1.45),
            ballStart: Vec2(x: 0.0, y: 14.0),
            players: [
                PlayerSpawn(id: "h6", name: "Joshua", shirtNumber: 6, side: .home, role: .ballCarrier, position: Vec2(x: 0.0, y: 13.3), runWaypoints: [Vec2(x: 0.0, y: 23.0)], speed: 8.0, reactionDelay: 0.06, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h10", name: "Jamal", shirtNumber: 10, side: .home, role: .midfielder, position: Vec2(x: -11.0, y: 23.5), runWaypoints: [Vec2(x: -9.5, y: 35.5)], speed: 9.0, reactionDelay: 0.05, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h7", name: "Michael", shirtNumber: 7, side: .home, role: .winger, position: Vec2(x: 11.5, y: 28.0), runWaypoints: [Vec2(x: 6.5, y: 40.5), Vec2(x: 3.5, y: 44.0)], speed: 9.1, reactionDelay: 0.05, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h9", name: "Harry", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: -1.5, y: 31.0), runWaypoints: [Vec2(x: -2.0, y: 42.0)], speed: 8.7, reactionDelay: 0.05, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "MacAllister", shirtNumber: 10, side: .away, role: .defender, position: Vec2(x: -2.5, y: 23.5), runWaypoints: [Vec2(x: -4.0, y: 19.5)], speed: 8.1, reactionDelay: 0.11, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "VanDijk", shirtNumber: 4, side: .away, role: .defender, position: Vec2(x: -4.5, y: 35.0), runWaypoints: [Vec2(x: -6.5, y: 37.5)], speed: 8.4, reactionDelay: 0.11, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "d3", name: "Konate", shirtNumber: 5, side: .away, role: .sweeper, position: Vec2(x: 4.5, y: 35.5), runWaypoints: [Vec2(x: 3.5, y: 40.0)], speed: 8.3, reactionDelay: 0.11, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "gk", name: "Alisson", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 8.5, reactionDelay: 0.11, hairColorHex: 0x451A03, skinToneIndex: 0)
            ],
            rewardCoins: 240
        ))

        // =========================================================================
        // CHAPTER 5: WELTPOKAL-LEGENDEN (Levels 25 - 30)
        // =========================================================================

        // Level 25: World Cup Group Decider vs Spain
        list.append(LevelDefinition(
            id: 25,
            chapterId: 5,
            levelNumberInChapter: 1,
            title: "WM-Kracher gegen Spanien",
            subtitle: "Durchbrich das spanische Mittelfeld-Pressing mit 3 schnellen Direktpässen!",
            matchMinute: "61'",
            scoreContext: "1 : 1",
            homeTeamName: "Nationalelf",
            awayTeamName: "La Roja",
            awayKitPrimaryHex: 0xDC2626,
            awayKitSecondaryHex: 0xFACC15,
            scenarioType: .tikiTaka,
            tacticalHint: "Spiele von #8 auf #10 rechts, dann diagonal nach links auf #11 und schließlich quer vor das Tor auf #9!",
            recommendedPasses: 3,
            parAttempts: 2,
            windSpeed: -0.9,
            starTarget: StarTargetZone(x: 5.5, z: 3.4, radius: 1.42),
            ballStart: Vec2(x: -4.0, y: 11.0),
            players: [
                PlayerSpawn(id: "h8", name: "Toni", shirtNumber: 8, side: .home, role: .ballCarrier, position: Vec2(x: -4.0, y: 10.3), runWaypoints: [Vec2(x: -3.0, y: 20.0)], speed: 8.0, reactionDelay: 0.05, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h10", name: "Florian", shirtNumber: 10, side: .home, role: .midfielder, position: Vec2(x: 9.0, y: 20.5), runWaypoints: [Vec2(x: 8.0, y: 28.5)], speed: 8.9, reactionDelay: 0.05, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h11", name: "Jamal", shirtNumber: 11, side: .home, role: .winger, position: Vec2(x: -11.5, y: 28.5), runWaypoints: [Vec2(x: -9.5, y: 39.5), Vec2(x: -6.5, y: 43.5)], speed: 9.2, reactionDelay: 0.05, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h9", name: "Kai", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: 3.5, y: 34.0), runWaypoints: [Vec2(x: 2.0, y: 43.0)], speed: 8.8, reactionDelay: 0.05, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Rodri", shirtNumber: 16, side: .away, role: .defender, position: Vec2(x: 1.0, y: 20.0), runWaypoints: [Vec2(x: -1.5, y: 16.5)], speed: 8.3, reactionDelay: 0.10, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Carvajal", shirtNumber: 2, side: .away, role: .defender, position: Vec2(x: -5.5, y: 31.5), runWaypoints: [Vec2(x: -8.0, y: 35.5)], speed: 8.4, reactionDelay: 0.10, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "d3", name: "LeNormand", shirtNumber: 3, side: .away, role: .sweeper, position: Vec2(x: 3.5, y: 37.5), runWaypoints: [Vec2(x: 1.5, y: 41.5)], speed: 8.3, reactionDelay: 0.10, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Simon", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 8.6, reactionDelay: 0.10, hairColorHex: 0x451A03, skinToneIndex: 0)
            ],
            rewardCoins: 200
        ))

        // Level 26: Quarter-Final vs Brazil (Samba Free Kick)
        list.append(LevelDefinition(
            id: 26,
            chapterId: 5,
            levelNumberInChapter: 2,
            title: "WM-Viertelfinale gegen Brasilien",
            subtitle: "27-Meter-Freistoß bei Seitenwind gegen eine 4-Mann-Mauer!",
            matchMinute: "77'",
            scoreContext: "0 : 0",
            homeTeamName: "Nationalelf",
            awayTeamName: "Seleção",
            awayKitPrimaryHex: 0xFACC15,
            awayKitSecondaryHex: 0x16A34A,
            scenarioType: .freeKick,
            tacticalHint: "Zirkle den Ball mit maximalem Rechtsdrall links um die Mauer herum – nutze den Rückenwind für eine scharfe Bananenkurve!",
            recommendedPasses: 0,
            parAttempts: 2,
            windSpeed: 1.8,
            starTarget: StarTargetZone(x: -5.4, z: 3.6, radius: 1.40),
            ballStart: Vec2(x: -4.8, y: 25.5),
            players: [
                PlayerSpawn(id: "h8", name: "Toni", shirtNumber: 8, side: .home, role: .ballCarrier, position: Vec2(x: -5.1, y: 24.7), runWaypoints: [], speed: 8.0, reactionDelay: 0.05, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "w1", name: "Marquinhos", shirtNumber: 4, side: .away, role: .wallDefender, position: Vec2(x: -5.6, y: 35.8), runWaypoints: [], speed: 6.4, reactionDelay: 0.10, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "w2", name: "Gabriel", shirtNumber: 6, side: .away, role: .wallDefender, position: Vec2(x: -4.2, y: 35.8), runWaypoints: [], speed: 6.4, reactionDelay: 0.10, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "w3", name: "Bruno", shirtNumber: 5, side: .away, role: .wallDefender, position: Vec2(x: -2.8, y: 35.8), runWaypoints: [], speed: 6.4, reactionDelay: 0.10, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "w4", name: "Danilo", shirtNumber: 2, side: .away, role: .wallDefender, position: Vec2(x: -1.4, y: 35.8), runWaypoints: [], speed: 6.4, reactionDelay: 0.10, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "gk", name: "Alisson", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 1.8, y: 51.2), runWaypoints: [], speed: 8.7, reactionDelay: 0.10, hairColorHex: 0x451A03, skinToneIndex: 0)
            ],
            rewardCoins: 210
        ))

        // Level 27: Lightning Counter vs France
        list.append(LevelDefinition(
            id: 27,
            chapterId: 5,
            levelNumberInChapter: 3,
            title: "WM-Duell gegen Frankreich",
            subtitle: "Kontere Frankreichs pfeilschnelle Abwehr mit zwei chirurgischen Steilpässen!",
            matchMinute: "83'",
            scoreContext: "1 : 1",
            homeTeamName: "Nationalelf",
            awayTeamName: "Les Bleus",
            awayKitPrimaryHex: 0x1E3A8A,
            awayKitSecondaryHex: 0xEF4444,
            scenarioType: .counterAttack,
            tacticalHint: "Spiele sofort auf #10 im Zentrum, bevor der Verteidiger ihn stellt, und schicke dann #7 rechts außen steil in den Strafraum!",
            recommendedPasses: 2,
            parAttempts: 2,
            windSpeed: -1.2,
            starTarget: StarTargetZone(x: -5.5, z: 3.5, radius: 1.40),
            ballStart: Vec2(x: -9.5, y: 14.5),
            players: [
                PlayerSpawn(id: "h6", name: "Robert", shirtNumber: 6, side: .home, role: .ballCarrier, position: Vec2(x: -9.5, y: 13.8), runWaypoints: [Vec2(x: -7.5, y: 23.0)], speed: 8.0, reactionDelay: 0.05, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "h10", name: "Jamal", shirtNumber: 10, side: .home, role: .midfielder, position: Vec2(x: 0.5, y: 24.0), runWaypoints: [Vec2(x: 1.5, y: 32.0)], speed: 9.1, reactionDelay: 0.05, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h7", name: "Leroy", shirtNumber: 7, side: .home, role: .winger, position: Vec2(x: 13.5, y: 29.0), runWaypoints: [Vec2(x: 9.5, y: 41.0), Vec2(x: 6.5, y: 44.5)], speed: 9.4, reactionDelay: 0.05, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "d1", name: "Tchouameni", shirtNumber: 8, side: .away, role: .defender, position: Vec2(x: -4.5, y: 22.5), runWaypoints: [Vec2(x: -7.5, y: 18.0)], speed: 8.5, reactionDelay: 0.10, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "d2", name: "Saliba", shirtNumber: 17, side: .away, role: .defender, position: Vec2(x: 5.5, y: 33.5), runWaypoints: [Vec2(x: 7.5, y: 37.5)], speed: 8.6, reactionDelay: 0.10, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "d3", name: "Theo", shirtNumber: 22, side: .away, role: .sweeper, position: Vec2(x: -2.5, y: 37.0), runWaypoints: [Vec2(x: 2.0, y: 41.0)], speed: 8.8, reactionDelay: 0.10, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Maignan", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 8.7, reactionDelay: 0.10, hairColorHex: 0x18181B, skinToneIndex: 3)
            ],
            rewardCoins: 220
        ))

        // Level 28: Semi-Final vs England (Threaded Needle)
        list.append(LevelDefinition(
            id: 28,
            chapterId: 5,
            levelNumberInChapter: 4,
            title: "WM-Halbfinale gegen England",
            subtitle: "Zirkle den Steilpass durch vier englische Verteidiger auf deinen Torjäger!",
            matchMinute: "88'",
            scoreContext: "2 : 2",
            homeTeamName: "Nationalelf",
            awayTeamName: "Three Lions",
            awayKitPrimaryHex: 0xFFFFFF,
            awayKitSecondaryHex: 0x1E3A8A,
            scenarioType: .throughBall,
            tacticalHint: "Spiele zuerst kurz von #8 auf #10 und schneide dann den Ball durch die Lücke auf #9 im Strafraumzentrum an!",
            recommendedPasses: 2,
            parAttempts: 2,
            windSpeed: 1.4,
            starTarget: StarTargetZone(x: 5.5, z: 3.5, radius: 1.38),
            ballStart: Vec2(x: 7.5, y: 16.5),
            players: [
                PlayerSpawn(id: "h8", name: "Ilkay", shirtNumber: 8, side: .home, role: .ballCarrier, position: Vec2(x: 7.5, y: 15.8), runWaypoints: [Vec2(x: 6.0, y: 25.0)], speed: 8.0, reactionDelay: 0.05, hairColorHex: 0x18181B, skinToneIndex: 1),
                PlayerSpawn(id: "h10", name: "Florian", shirtNumber: 10, side: .home, role: .midfielder, position: Vec2(x: -5.5, y: 24.5), runWaypoints: [Vec2(x: -4.0, y: 31.5)], speed: 8.9, reactionDelay: 0.05, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h9", name: "Kai", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: 3.5, y: 31.5), runWaypoints: [Vec2(x: 0.5, y: 41.5), Vec2(x: 0.0, y: 45.0)], speed: 8.9, reactionDelay: 0.05, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Rice", shirtNumber: 4, side: .away, role: .defender, position: Vec2(x: 2.0, y: 23.5), runWaypoints: [Vec2(x: 4.5, y: 19.5)], speed: 8.5, reactionDelay: 0.10, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Walker", shirtNumber: 2, side: .away, role: .defender, position: Vec2(x: -6.5, y: 33.5), runWaypoints: [Vec2(x: -5.0, y: 30.5)], speed: 8.9, reactionDelay: 0.10, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "d3", name: "Stones", shirtNumber: 5, side: .away, role: .defender, position: Vec2(x: -2.0, y: 36.5), runWaypoints: [Vec2(x: -2.5, y: 40.0)], speed: 8.5, reactionDelay: 0.10, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d4", name: "Guehi", shirtNumber: 6, side: .away, role: .sweeper, position: Vec2(x: 4.5, y: 36.5), runWaypoints: [Vec2(x: 2.5, y: 40.0)], speed: 8.6, reactionDelay: 0.10, hairColorHex: 0x18181B, skinToneIndex: 3),
                PlayerSpawn(id: "gk", name: "Pickford", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 8.8, reactionDelay: 0.10, hairColorHex: 0xD97706, skinToneIndex: 0)
            ],
            rewardCoins: 240
        ))

        // Level 29: Extra-Time Thriller vs Italy
        list.append(LevelDefinition(
            id: 29,
            chapterId: 5,
            levelNumberInChapter: 5,
            title: "Verlängerung gegen Italien",
            subtitle: "118. Minute gegen das Catenaccio-Bollwerk: Finde den einzigen freien Passweg!",
            matchMinute: "118'",
            scoreContext: "1 : 1",
            homeTeamName: "Nationalelf",
            awayTeamName: "Squadra Azzurra",
            awayKitPrimaryHex: 0x2563EB,
            awayKitSecondaryHex: 0xFFFFFF,
            scenarioType: .tikiTaka,
            tacticalHint: "Spiele von #6 links auf #11, von dort diagonal ins Zentrum auf #10 und lege sofort in den Lauf von #9 vor dem Tor!",
            recommendedPasses: 3,
            parAttempts: 2,
            windSpeed: -1.5,
            starTarget: StarTargetZone(x: -5.5, z: 3.6, radius: 1.38),
            ballStart: Vec2(x: 3.0, y: 12.0),
            players: [
                PlayerSpawn(id: "h6", name: "Joshua", shirtNumber: 6, side: .home, role: .ballCarrier, position: Vec2(x: 3.0, y: 11.3), runWaypoints: [Vec2(x: 2.0, y: 21.0)], speed: 8.2, reactionDelay: 0.05, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h11", name: "Jamal", shirtNumber: 11, side: .home, role: .winger, position: Vec2(x: -13.0, y: 21.5), runWaypoints: [Vec2(x: -11.5, y: 32.0)], speed: 9.2, reactionDelay: 0.05, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h10", name: "Florian", shirtNumber: 10, side: .home, role: .midfielder, position: Vec2(x: 1.5, y: 29.5), runWaypoints: [Vec2(x: 2.0, y: 36.0)], speed: 9.0, reactionDelay: 0.05, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h9", name: "Niclas", shirtNumber: 9, side: .home, role: .striker, position: Vec2(x: 11.5, y: 33.5), runWaypoints: [Vec2(x: 4.5, y: 42.5), Vec2(x: 2.0, y: 45.5)], speed: 8.9, reactionDelay: 0.05, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "Barella", shirtNumber: 18, side: .away, role: .defender, position: Vec2(x: -2.5, y: 20.5), runWaypoints: [Vec2(x: -5.5, y: 22.0)], speed: 8.6, reactionDelay: 0.09, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Calafiori", shirtNumber: 5, side: .away, role: .defender, position: Vec2(x: -5.5, y: 32.5), runWaypoints: [Vec2(x: -3.5, y: 34.5)], speed: 8.6, reactionDelay: 0.09, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "d3", name: "Bastoni", shirtNumber: 23, side: .away, role: .sweeper, position: Vec2(x: 5.5, y: 36.5), runWaypoints: [Vec2(x: 4.5, y: 40.5)], speed: 8.7, reactionDelay: 0.09, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Donnarumma", shirtNumber: 1, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 8.9, reactionDelay: 0.09, hairColorHex: 0x451A03, skinToneIndex: 0)
            ],
            rewardCoins: 260
        ))

        // Level 30: THE WORLD CUP FINAL (WM-Finale)
        list.append(LevelDefinition(
            id: 30,
            chapterId: 5,
            levelNumberInChapter: 6,
            title: "DAS GROSSE WM-FINALE",
            subtitle: "120. Minute: Ein letzter Spielzug zum Weltmeistertitel – werde zur Fußball-Legende!",
            matchMinute: "120'",
            scoreContext: "2 : 2",
            homeTeamName: "Nationalelf",
            awayTeamName: "Albiceleste",
            awayKitPrimaryHex: 0x38BDF8,
            awayKitSecondaryHex: 0xFFFFFF,
            scenarioType: .championshipFinal,
            tacticalHint: "Meister-Spielzug: Spiele von #8 auf #10, schicke #7 auf dem rechten Flügel, flanke in den Lauf von #9 und zirkle den Ball in den goldenen Stern-Winkel!",
            recommendedPasses: 3,
            parAttempts: 2,
            windSpeed: 1.6,
            starTarget: StarTargetZone(x: -5.5, z: 3.6, radius: 1.35),
            ballStart: Vec2(x: 0.0, y: 10.0),
            players: [
                PlayerSpawn(id: "h8", name: "Toni", shirtNumber: 8, side: .home, role: .ballCarrier, position: Vec2(x: 0.0, y: 9.3), runWaypoints: [Vec2(x: 0.0, y: 19.0)], speed: 8.2, reactionDelay: 0.05, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h10", name: "Jamal", shirtNumber: 10, side: .home, role: .midfielder, position: Vec2(x: -9.5, y: 20.5), runWaypoints: [Vec2(x: -7.5, y: 29.0)], speed: 9.3, reactionDelay: 0.04, hairColorHex: 0x18181B, skinToneIndex: 2),
                PlayerSpawn(id: "h7", name: "Florian", shirtNumber: 7, side: .home, role: .winger, position: Vec2(x: 13.0, y: 26.5), runWaypoints: [Vec2(x: 11.5, y: 39.5), Vec2(x: 8.5, y: 43.5)], speed: 9.3, reactionDelay: 0.04, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "h9", name: "Mario", shirtNumber: 19, side: .home, role: .striker, position: Vec2(x: -2.0, y: 32.0), runWaypoints: [Vec2(x: -1.5, y: 42.5), Vec2(x: -0.5, y: 45.5)], speed: 9.1, reactionDelay: 0.04, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "d1", name: "DePaul", shirtNumber: 7, side: .away, role: .defender, position: Vec2(x: -2.5, y: 19.0), runWaypoints: [Vec2(x: -4.5, y: 16.0)], speed: 8.7, reactionDelay: 0.09, hairColorHex: 0x451A03, skinToneIndex: 0),
                PlayerSpawn(id: "d2", name: "Enzo", shirtNumber: 24, side: .away, role: .defender, position: Vec2(x: 4.5, y: 26.5), runWaypoints: [Vec2(x: 7.5, y: 31.0)], speed: 8.7, reactionDelay: 0.09, hairColorHex: 0x18181B, skinToneIndex: 0),
                PlayerSpawn(id: "d3", name: "Romero", shirtNumber: 13, side: .away, role: .defender, position: Vec2(x: -4.5, y: 35.5), runWaypoints: [Vec2(x: -3.0, y: 39.5)], speed: 8.9, reactionDelay: 0.09, hairColorHex: 0x18181B, skinToneIndex: 1),
                PlayerSpawn(id: "d4", name: "Lisandro", shirtNumber: 25, side: .away, role: .sweeper, position: Vec2(x: 3.5, y: 37.5), runWaypoints: [Vec2(x: 1.5, y: 41.5)], speed: 8.8, reactionDelay: 0.09, hairColorHex: 0x78350F, skinToneIndex: 0),
                PlayerSpawn(id: "gk", name: "Martinez", shirtNumber: 23, side: .away, role: .goalkeeper, position: Vec2(x: 0.0, y: 51.2), runWaypoints: [], speed: 9.0, reactionDelay: 0.09, hairColorHex: 0x18181B, skinToneIndex: 1)
            ],
            rewardCoins: 400
        ))

        return list
    }
}
