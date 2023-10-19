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

                // Apply a red background.
                customNavBarAppearance.configureWithOpaqueBackground()
                customNavBarAppearance.backgroundColor = .black

                // Apply white colored normal and large titles.
                customNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.systemRed]
                customNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemRed]


                // Apply white color to all the nav bar buttons.
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

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigator.path) {
                DJMainMenu()
                    .navigationDestination(for: String.self) { id in
                        if id == String(describing: DJHomeView.self) {
                            DJHomeView()
                        }
                        if id == String(describing: ProfileView.self) {
                            ProfileView()
                        }
                        if id == String(describing: CreateEventView.self) {
                            CreateEventView()
                        }
                        else {
                            EmptyView()
                                .onAppear {
                                    print(id)
                                }
                        }
                    }
            }
            .environmentObject(navigator)
            .tint(.accent)
        }
    }
}
