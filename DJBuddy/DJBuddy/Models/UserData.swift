//
//  UserData.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import Foundation

struct UserData: Identifiable {
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
}

struct NameData {
    let firstName: String
    let lastName: String

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
