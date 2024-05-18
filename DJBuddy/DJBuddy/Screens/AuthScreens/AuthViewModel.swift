//
//  AuthViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import Foundation
import SwiftUI
import SwiftData

enum AuthState {
    case loggedOut
    case loggedIn
    case verifyEmail
}

final class AuthViewModel: ObservableObject {
    @Published private(set) var pageState: LandingPageEnum = .landingPage
    @Published var userType: UserTypeEnum = .user
    @Published var emailText: String = ""
    @Published var passwordText: String = ""
    @Published var passwordAgainText: String = ""
    @Published var artistNameText: String = ""
    @Published var firstNameText: String = ""
    @Published var lastNameText: String = ""

    @Published var currentUser: UserData? = nil

    @Published var authState: AuthState = .loggedOut
    @Published var verifyableUserId: String?
    @Published var verificationCode = ""
    @Published var isVerifyAlertShowing = false

    private var context: ModelContext?

    @MainActor
    func tryLoginFromStoredData(context: ModelContext) async throws {
        self.context = context
        guard let loginData = fetchStoredLoginData() else { print("No previous login data found."); return }

        do {
            currentUser = try await API.login(with: loginData.email, token: loginData.token)
            authState = .loggedIn
        } catch {
            throw error
        }
    }

    private func fetchStoredLoginData() -> LoginData? {
        do {
            let descriptor = FetchDescriptor<LoginData>()
            return try context?.fetch(descriptor).first
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    private func saveLoginDataToPersistentData(email: String, token: String) {
        removeLoginDataFromPresistentData()
        context?.insert(LoginData(email: email, token: token))
        print("User saved as persistent!")
    }

    private func removeLoginDataFromPresistentData() {
        do {
            let descriptor = FetchDescriptor<LoginData>()
            if let datas = try context?.fetch(descriptor) {
                for data in datas {
                    context?.delete(data)
                }
            }
            print("User removed from persistent!")
        } catch {
            print(error.localizedDescription)
        }
    }

    func navigate(to state: LandingPageEnum) {
        pageState = state
        resetTextFields()
    }

    private func resetTextFields() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        emailText.removeAll()
        passwordText.removeAll()
        passwordAgainText.removeAll()
        artistNameText.removeAll()
    }

    @MainActor
    func login() async throws {
        guard try checkAllLoginFieldsAreValid() else { return }

        do {
            let (user, authToken) = try await API.login(with: emailText, password: passwordText)
            currentUser = user
            saveLoginDataToPersistentData(email: emailText, token: authToken)
            authState = .loggedIn
        } catch {
            throw error
        }
    }

    @MainActor
    func signUp() async throws {
        guard try checkAllRegisterFieldsAreValid() else { return }

        do {
            verifyableUserId = try await API.register(email: emailText,
                                                      password: passwordText,
                                                      firstName: firstNameText,
                                                      lastName: lastNameText,
                                                      artistName: artistNameText,
                                                      type: userType.rawValue)
            isVerifyAlertShowing.toggle()
        } catch {
            throw error
        }
    }

    @MainActor
    func verifyEmail() async throws {
        guard let verifyableUserId else { return }

        if verificationCode.isEmpty {
            throw FormError.codeMissing
        }

        do {
            currentUser = try await API.verifyEmail(for: verifyableUserId, with: verificationCode)
            authState = .loggedIn
        } catch {
            throw error
        }
    }

    func signOut() {
        removeLoginDataFromPresistentData()
        currentUser = nil
        resetTextFields()
        authState = .loggedOut
    }

    func checkAllLoginFieldsAreValid() throws -> Bool {
        guard !emailText.isEmpty else {
            throw FormError.emailMissing
        }

        guard !passwordText.isEmpty else {
            throw FormError.passwordMissing
        }

        return true
    }

    func checkAllRegisterFieldsAreValid() throws -> Bool {
        if userType == .dj {
            guard !artistNameText.isEmpty else {
                throw FormError.artistNameMissing
            }
        }

        guard !emailText.isEmpty else {
            throw FormError.emailMissing
        }

        guard !firstNameText.isEmpty else {
            throw FormError.firstNameMissing
        }

        guard !lastNameText.isEmpty else {
            throw FormError.lastNameMissing
        }

        guard !passwordText.isEmpty else {
            throw FormError.passwordMissing
        }

        guard passwordText == passwordAgainText else {
            throw FormError.passwordsDontMatch
        }

        return true
    }

    @MainActor
    func refreshUser() async throws {
        currentUser = try await API.getUserData()
    }
}
