//
//  UserData.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import Foundation

final class UserData: Identifiable, ObservableObject, Hashable {
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        lhs.id == rhs.id
    }

    let id = UUID()
    let username: String
    let email: String
    let name: NameData
    let type: UserTypeEnum

    init(username: String, email: String, name: NameData, type: UserTypeEnum) {
        self.username = username
        self.email = email
        self.name = name
        self.type = type
    }

    init(username: String, email: String, firstName: String, lastName: String, type: UserTypeEnum) {
        self.username = username
        self.email = email
        self.name = NameData(firstName: firstName, lastName: lastName)
        self.type  = type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static var PreviewUser: UserData {
        UserData(username: "dj name",
                 email: "example@email.com",
                 firstName: "Example",
                 lastName: "User",
                 type: .user)
    }
}

struct NameData: Hashable {
    let firstName: String
    let lastName: String

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
