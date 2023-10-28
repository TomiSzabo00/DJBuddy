//
//  AuthViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import Foundation
import SwiftUI

final class AuthViewModel: ObservableObject {
    @Published private(set) var pageState: LandingPageEnum = .landingPage
    @Published var userType: UserTypeEnum = .user
    @Published var usernameText: String = ""
    @Published var passwordText: String = ""
    @Published var passwordAgainText: String = ""
    @Published var artistNameText: String = ""

    @Published var currentUser: UserData? = nil
    @Published var error: Error? = nil

    func navigate(to state: LandingPageEnum) {
        pageState = state
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        usernameText.removeAll()
        passwordText.removeAll()
        passwordAgainText.removeAll()
        artistNameText.removeAll()
    }

    func login() {
        API.login(with: usernameText, and: passwordText) { [weak self] response in
            switch response {
            case .success(let user):
                self?.currentUser = user
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func signUp() {
        
    }
}
