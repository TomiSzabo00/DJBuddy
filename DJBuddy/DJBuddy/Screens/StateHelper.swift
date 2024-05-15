//
//  StateHelper.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 15/05/2024.
//

import Foundation

struct AlertContent {
    let title: String
    let message: String
    let dismissAction: () -> Void

    init(title: String, message: String = "", dismissAction: @escaping () -> Void = {}) {
        self.title = title
        self.message = message
        self.dismissAction = dismissAction
    }
}

final class StateHelper: ObservableObject {
    @Published var isLoading: Bool = false
    @Published private(set) var alertContent: AlertContent?

    var signoutAction: () -> Void

    init(signoutAction: @escaping () -> Void) {
        self.signoutAction = signoutAction
    }

    @MainActor
    func performWithProgress(task: @escaping () async throws -> Void) {
        Task {
            isLoading = true
            do {
                try await task()
                isLoading = false
            } catch let error as APIError {
                isLoading = false
                alertContent = AlertContent(title: error.title, message: error.message) { [weak self] in
                    if error.isFatal {
                        self?.signoutAction()
                    }
                }
            } catch let error as FormError {
                isLoading = false
                alertContent = AlertContent(title: error.title, message: error.message)
            } catch {
                isLoading = false
                alertContent = AlertContent(title: error.localizedDescription)
            }
        }
    }
}
