//
//  AuthViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import Foundation
import SwiftUI
import SwiftData

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
    @Published var error: Error? = nil
    @Published var isLoading = false

    private var context: ModelContext!

//    func fetchStoredUser(context: ModelContext) {
//        self.context = context
//        do {
//            let descriptor = FetchDescriptor<UserData>()
//            currentUser = try context.fetch(descriptor).first
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    private func saveUserToPersistentData() {
//        guard let currentUser else { return }
//        removeUserFromPresistentData()
//        context.insert(currentUser)
//        print("User saved as persistent!")
//    }
//
//    private func removeUserFromPresistentData() {
//        guard let currentUser else { return }
//        context.delete(currentUser)
//        print("User removed from persistent!")
//    }
//
//    private func removePreviousUsersFromPersistentData() {
//        do {
//            let descriptor = FetchDescriptor<UserData>()
//            let users = try context.fetch(descriptor)
//            for user in users {
//                context.delete(user)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//    }

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

    func login() {
        guard checkAllLoginFieldsAreValid() else { return }

        isLoading = true

        API.login(with: emailText, and: passwordText) { [weak self] response in
            self?.isLoading = false

            switch response {
            case .success(let user):
                self?.currentUser = user
//                self?.saveUserToPersistentData()
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func signUp() {
        guard checkAllRegisterFieldsAreValid() else { return }

        isLoading = true

        API.register(email: emailText,
                     password: passwordText,
                     firstName: firstNameText,
                     lastName: lastNameText,
                     artistName: artistNameText,
                     type: userType.rawValue) { [weak self] response in
            self?.isLoading = false

            switch response {
            case .success(let user):
                self?.currentUser = user
//                self?.saveUserToPersistentData()
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func signOut() {
//        removeUserFromPresistentData()
        currentUser = nil
        resetTextFields()
    }

    func checkAllLoginFieldsAreValid() -> Bool {
        guard !emailText.isEmpty else {
            error = FormError.emailMissing
            return false
        }

        guard !passwordText.isEmpty else {
            error = FormError.passwordMissing
            return false
        }

        return true
    }

    func checkAllRegisterFieldsAreValid() -> Bool {
        if userType == .dj {
            guard !artistNameText.isEmpty else {
                error = FormError.artistNameMissing
                return false
            }
        }

        guard !emailText.isEmpty else {
            error = FormError.emailMissing
            return false
        }

        guard !firstNameText.isEmpty else {
            error = FormError.firstNameMissing
            return false
        }

        guard !lastNameText.isEmpty else {
            error = FormError.lastNameMissing
            return false
        }

        guard !passwordText.isEmpty else {
            error = FormError.passwordMissing
            return false
        }

        guard passwordText == passwordAgainText else {
            error = FormError.passwordsDontMatch
            return false
        }

        return true
    }
}
