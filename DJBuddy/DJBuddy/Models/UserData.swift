//
//  UserData.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import Foundation

final class UserData: Identifiable, ObservableObject, Hashable, Decodable {
    let id: String
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let type: String
    var profilePicUrl: String

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var userType: UserTypeEnum {
        UserTypeEnum(rawValue: type) ?? .user
    }

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case username, email, firstName, lastName, type, profilePicUrl
    }

    init(id: String, username: String, email: String, firstName: String, lastName: String, type: UserTypeEnum, profilePicUrl: String = "") {
        self.id = id
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.type = type.rawValue
        self.profilePicUrl = profilePicUrl
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UserData, rhs: UserData) -> Bool {
        lhs.id == rhs.id
    }

    static var PreviewUser: UserData {
        UserData(id: "example",
                 username: "dj name",
                 email: "example@email.com",
                 firstName: "Example",
                 lastName: "User",
                 type: .dj)
    }

    static var EmptyUser: UserData {
        UserData(id: "",
                 username: "",
                 email: "",
                 firstName: "",
                 lastName: "",
                 type: .user)
    }
}
