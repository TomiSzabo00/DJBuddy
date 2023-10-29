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

    func tryLoginFromStoredData(context: ModelContext) {
        self.context = context
        guard let loginData = fetchStoredLoginData() else { print("No previous login data found."); return }
        
        isLoading = true

        API.login(with: loginData.email, and: loginData.password) { [weak self] response in
            guard let self else { return }
            isLoading = false

            switch response {
            case .success(let user):
                currentUser = user
            case .failure(let error):
                print(error.localizedDescription)
                self.error = APIError.sessionExpired
            }
        }
    }

    private func fetchStoredLoginData() -> LoginData? {
        do {
            let descriptor = FetchDescriptor<LoginData>()
            return try context.fetch(descriptor).first
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    private func saveLoginDataToPersistentData(email: String, password: String) {
        removeLoginDataFromPresistentData()
        context.insert(LoginData(email: email, password: password))
        print("User saved as persistent!")
    }

    private func removeLoginDataFromPresistentData() {
        do {
            let descriptor = FetchDescriptor<LoginData>()
            let datas = try context.fetch(descriptor)
            for data in datas {
                context.delete(data)
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

    func login() {
        guard checkAllLoginFieldsAreValid() else { return }

        isLoading = true

        API.login(with: emailText, and: passwordText) { [weak self] response in
            guard let self else { return }
            isLoading = false

            switch response {
            case .success(let user):
                currentUser = user
                saveLoginDataToPersistentData(email: emailText, password: passwordText)
            case .failure(let error):
                self.error = error
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
            guard let self else { return }
            isLoading = false

            switch response {
            case .success(let user):
                currentUser = user
                saveLoginDataToPersistentData(email: emailText, password: passwordText)
            case .failure(let error):
                self.error = error
            }
        }
    }

    func signOut() {
        removeLoginDataFromPresistentData()
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
