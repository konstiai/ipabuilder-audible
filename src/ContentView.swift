import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        ZStack {
            switch store.currentScreen {
            case .mainMenu:
                MainMenuView()
                    .transition(.opacity)

            case .levelSelect:
                LevelSelectView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))

            case .careerHub:
                CareerHubView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))

            case .tutorial:
                TutorialView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))

            case .settings:
                SettingsView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))

            case .matchPlay(let levelId):
                MatchPlayView(levelId: levelId)
                    .id(levelId)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.24), value: store.currentScreen)
    }
}
