//
//  DJBuddyApp.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import SwiftUI
import SwiftData

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

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .systemRed
    }

    var body: some Scene {
        let container = try! ModelContainer(for: LoginData.self)

        WindowGroup {
            StateManager()
        }
        .modelContainer(container)
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
