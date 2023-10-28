//
//  UserTypeEnum.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 30/09/2023.
//

enum UserTypeEnum: String, Identifiable, CaseIterable, Hashable, Decodable {
    case user = "user"
    case dj = "dj"

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
