import SwiftUI

@main
struct SoccergameApp: App {
    @StateObject private var store = GameStore()
    @StateObject private var sound = SoundManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(sound)
                .preferredColorScheme(.dark)
        }
    }
}
