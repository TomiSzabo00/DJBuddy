//
//  StateHelper.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 15/05/2024.
//

import Foundation

final class StateHelper: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil

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
                self.error = error
            }
        }
    }
}
