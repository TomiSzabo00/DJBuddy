//
//  Errors.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 23/10/2023.
//

import Foundation


struct APIError: Error {
    let title: String
    let message: String
    let errorCode: Int

    var isFatal: Bool {
        [1].contains(errorCode)
    }

    init(title: String = "Error", message: String, errorCode: Int = -1) {
        self.title = title
        self.message = message
        self.errorCode = errorCode
    }

    init(from response: CustomResponse) {
        self.init(title: "Error", message: response.message, errorCode: response.errorCode)
    }
}

extension APIError {
    static var somethingWentWrong: APIError {
        APIError(message: "Something went wrong", errorCode: 0)
    }
}


enum FormError: Error, CaseIterable {
    case nameMissing
    case acceptMissing
    case priceMissing
    case dateMissing
    case addressMissing
    case songMissing
    case emailMissing
    case passwordsDontMatch
    case passwordMissing
    case artistNameMissing
    case firstNameMissing
    case lastNameMissing
    case codeMissing

    var title: String {
        if self == .acceptMissing {
            return "Terms and Conditions"
        } else if self == .passwordsDontMatch {
            return "Passwords don't match"
        }
        let prefix = {
            switch self {
            case .nameMissing:
                return "Name"
            case .acceptMissing:
                return ""
            case .priceMissing:
                return "Price"
            case .dateMissing:
                return "Date"
            case .addressMissing:
                return "Address"
            case .songMissing:
                return "Song"
            case .emailMissing:
                return "Email address"
            case .passwordsDontMatch:
                return ""
            case .passwordMissing:
                return "Password"
            case .artistNameMissing:
                return "Artist (DJ) name"
            case .firstNameMissing:
                return "First name"
            case .lastNameMissing:
                return "Last name"
            case .codeMissing:
                return "Token or code"
            }
        }()

        return prefix + " is missing"
    }

    var message: String {
        switch self {
        case .acceptMissing:
            "You have to accept our Terms and Conditions."
        case .passwordsDontMatch:
            "The two passwords don't match. Please correct them."
        default:
            "Please provide it."
        }
    }
}
