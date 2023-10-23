//
//  Errors.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 23/10/2023.
//

import Foundation

enum APIError: LocalizedError {
    case unreachable

    var errorDescription: String? {
        switch self {
        case .unreachable:
            return "Unreachable"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unreachable:
            return "Couldn't reach the server. Try again later."
        }
    }
}
