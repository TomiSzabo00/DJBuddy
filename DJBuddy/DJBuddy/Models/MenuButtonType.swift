//
//  MenuButtonType.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import Foundation

enum MenuButtonType: Identifiable, CaseIterable {
    var id: UUID { UUID() }

    case upcoming
    case past
    case liked
    case profile
    case settings
}
