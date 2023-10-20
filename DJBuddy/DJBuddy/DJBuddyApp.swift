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

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigator.path) {
                MainMenu()
                    .navigationDestination(for: String.self) { id in
                        if id == String(describing: ProfileView.self) {
                            ProfileView()
                        } else if id == String(describing: CreateEventView.self) {
                            CreateEventView()
                        }
                        else {
                            Text("Opened \(id), but there is no navigation set up.")
                        }
                    }
                    .navigationDestination(for: EventData.self) { event in
                        if exampleUser.type == .dj {
                            EventControlView(event: event)
                        } else {
                            Text("User's event screen")
                        }
                    }
            }
            .environmentObject(navigator)
            .environmentObject(exampleUser)
            .tint(.accent)
        }
    }
}
