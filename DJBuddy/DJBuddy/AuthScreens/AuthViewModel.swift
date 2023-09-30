//
//  AuthViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import Foundation

final class AuthViewModel: ObservableObject {
    @Published private(set) var pageState: LandingPageEnum = .landingPage
    @Published var usernameText: String = ""
    @Published var passwordText: String = ""
    @Published var passwordAgainText: String = ""

    func navigate(to state: LandingPageEnum) {
        pageState = state
    }
}
