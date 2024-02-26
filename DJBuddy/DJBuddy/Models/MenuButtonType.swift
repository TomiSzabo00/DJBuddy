//
//  MenuButtonType.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import Foundation

enum MenuButtonType: Identifiable, CaseIterable {
    var id: UUID { UUID() }

    case join
    case past
    case liked
    case songs
    case profile
    case signOut

    var title: String {
        switch self {
        case .join:
            "Join an event"
        case .past:
            "Past events"
        case .liked:
            "Liked DJs"
        case .songs:
            "Saved songs"
        case .profile:
            "Profile"
        case .signOut:
            "Sign out"
        }
    }
}
