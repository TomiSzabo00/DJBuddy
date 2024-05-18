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
            } catch {
                isLoading = false
                showError(from: error)
            }
        }
    }

    func showError(from error: Error) {
        if let apiError = error as? APIError {
            alertContent = AlertContent(title: apiError.title, message: apiError.message) { [weak self] in
                if apiError.isFatal {
                    self?.signoutAction()
                }
            }
        } else if let formError = error as? FormError {
            alertContent = AlertContent(title: formError.title, message: formError.message)
        } else {
            alertContent = AlertContent(title: error.localizedDescription)
        }
    }
}
