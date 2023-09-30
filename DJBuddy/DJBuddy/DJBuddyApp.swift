//
//  DJBuddyApp.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import SwiftUI

@main
struct DJBuddyApp: App {
    @State private var navPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            LandingView()
        }
    }
}
