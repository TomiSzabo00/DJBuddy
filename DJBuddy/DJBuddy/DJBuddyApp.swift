//
//  DJBuddyApp.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import SwiftUI

@main
struct DJBuddyApp: App {
    init() {
        let newNavBarAppearance = {
            let customNavBarAppearance = UINavigationBarAppearance()
            customNavBarAppearance.configureWithOpaqueBackground()
            customNavBarAppearance.backgroundColor = .black

            customNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            customNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemRed]

            let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
            barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemRed]
            barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.systemRed]
            barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.systemRed]
            barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.systemRed]
            customNavBarAppearance.buttonAppearance = barButtonItemAppearance
            customNavBarAppearance.backButtonAppearance = barButtonItemAppearance
            customNavBarAppearance.doneButtonAppearance = barButtonItemAppearance

            return customNavBarAppearance
        }()

        let appearance = UINavigationBar.appearance()
        appearance.scrollEdgeAppearance = newNavBarAppearance
        appearance.compactAppearance = newNavBarAppearance
        appearance.standardAppearance = newNavBarAppearance
        if #available(iOS 15.0, *) {
            appearance.compactScrollEdgeAppearance = newNavBarAppearance
        }
    }

    @StateObject private var navigator = Navigator()
    @StateObject private var exampleUser = UserData(username: "exampleUser",
                                                    email: "example@email.com",
                                                    firstName: "Example",
                                                    lastName: "User",
                                                    type: .dj)
    @StateObject private var mainMenuViewModel = MainMenuViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigator.path) {
                MainMenu(viewModel: mainMenuViewModel)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        switch destination {
                        case let .requestSong(eventData):
                            RequestSongView(viewModel: EventControlViewModel(event: eventData))
                        case .profile:
                            ProfileView()
                        case .createEvent:
                            CreateEventView() { newEvent in
                                mainMenuViewModel.join(event: newEvent)
                            }
                        case let .selectEvent(eventList):
                            SelectEventView(yourEvents: eventList)
                        case let .eventControl(event):
                            EventControlView(event: event)
                        case let .userEventView(event):
                            UserEventView(event: event)
                        case let .songDetails(song, vm):
                            SongDetalsView(song: song, viewModel: vm)
                        }
                    }
            }
            .environmentObject(navigator)
            .environmentObject(exampleUser)
            .tint(.accent)
        }
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
}
