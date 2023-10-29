//
//  UserData.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import Foundation

class UserData_Database: Decodable {
    let id: String
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let type: String
    var profilePicUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case username, email, firstName, lastName, type, profilePicUrl
    }
}

final class UserData: Identifiable, ObservableObject, Hashable {
    let id: String
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let type: UserTypeEnum
    var profilePicUrl: String

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    init(id: String, username: String, email: String, firstName: String, lastName: String, type: UserTypeEnum, profilePicUrl: String) {
        self.id = id
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.type = type
        self.profilePicUrl = profilePicUrl
    }

    init(decodable: UserData_Database) {
        self.id = decodable.id
        self.username = decodable.username
        self.email = decodable.email
        self.firstName = decodable.firstName
        self.lastName = decodable.lastName
        self.type = UserTypeEnum(rawValue: decodable.type) ?? .user
        self.profilePicUrl = decodable.profilePicUrl
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UserData, rhs: UserData) -> Bool {
        lhs.id == rhs.id
    }

    static var EmptyUser: UserData {
        UserData(id: "",
                 username: "",
                 email: "",
                 firstName: "",
                 lastName: "",
                 type: .user,
                 profilePicUrl: ""
        )
    }
}
