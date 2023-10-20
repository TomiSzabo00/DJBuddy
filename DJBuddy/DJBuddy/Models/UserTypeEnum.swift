//
//  UserTypeEnum.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 30/09/2023.
//

enum UserTypeEnum: Identifiable, CaseIterable, Hashable {
    case user
    case dj

    var id : Int { self.hashValue }

    var displayString: String {
        switch self {
        case .user:
            return "User"
        case .dj:
            return "DJ"
        }
    }
}
