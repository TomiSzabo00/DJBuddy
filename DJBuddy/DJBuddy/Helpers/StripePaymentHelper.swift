//
//  StripePaymentHelper.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 04/11/2023.
//

import Foundation
import StripePaymentSheet

final class StripePaymentHelper: ObservableObject {
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: Result<Void, APIError>?
    @Published var error: Error?
    @Published var amount: Double = 0
    @Published var isLoading = false
    private var user: UserData?

    @MainActor
    func preparePaymentSheet(price: Double, for user: UserData) async throws {
        paymentSheet = nil
        amount = 0
        self.user = user
        do {
            amount = price
            paymentSheet = try await API.preparePayment(forAmount: price)
        } catch {
            throw error
        }
    }

    func onPaymentCompletion(result: PaymentSheetResult) -> (() async throws -> Void)? {
        switch result {
        case .completed:
            return addFundsToUser
        case .canceled:
            break
        case .failed(_):
            self.paymentSheet = nil
        }
        return nil
    }

    func addFundsToUser() async throws {
        guard amount > 0, let user else { return }
        do {
            try await API.addToUserBalance(amount: amount, user: user)
            paymentResult = .success(())
        } catch {
            throw error
        }
    }
}
