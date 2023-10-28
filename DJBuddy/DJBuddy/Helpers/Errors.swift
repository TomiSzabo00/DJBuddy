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

    var errorDescription: String? {
        switch self {
        case .unreachable:
            return "Unreachable"
        case .wrongEmailOrPassword:
            return "Incorrect login"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unreachable:
            return "Couldn't reach the server. Try again later."
        case .wrongEmailOrPassword:
            return "The email and password combination was incorrect."
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

    var errorDescription: String? {
        guard self != .acceptMissing else {
            return "Terms and Conditions"
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
            }
        }()

        return prefix + " is missing"
    }

    var recoverySuggestion: String? {
        switch self {
        case .acceptMissing:
            "You have to accept our Terms and Conditions."
        default:
            "Please provide it."
        }
    }
}
