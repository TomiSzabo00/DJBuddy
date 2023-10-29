//
//  Errors.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 23/10/2023.
//

import Foundation

enum APIError: LocalizedError {
    case unreachable
    case wrongEmailOrPassword
    case userAlreadyExists
    case sessionExpired

    var errorDescription: String? {
        switch self {
        case .unreachable:
            return "Unreachable"
        case .wrongEmailOrPassword:
            return "Incorrect login"
        case .userAlreadyExists:
            return "Email in use"
        case .sessionExpired:
            return "Session expired"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unreachable:
            return "Couldn't reach the server. Try again later."
        case .wrongEmailOrPassword:
            return "The email and password combination was incorrect."
        case .userAlreadyExists:
            return "This email has been registered already. Try logging in."
        case .sessionExpired:
            return "The previous login session has expired. Please log in again."
        }
    }
}

enum FormError: LocalizedError {
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

    var errorDescription: String? {
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
            }
        }()

        return prefix + " is missing"
    }

    var recoverySuggestion: String? {
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
