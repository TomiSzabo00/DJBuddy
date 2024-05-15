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

    func preparePaymentSheet(price: Double, for user: UserData) {
        paymentSheet = nil
        amount = 0
        self.user = user

        API.preparePayment(forAmount: price) { [weak self] result in
            switch result {
            case .success(let paymentSheet):
                DispatchQueue.main.async {
                    self?.amount = price
                    self?.paymentSheet = paymentSheet
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }

    func onPaymentCompletion(result: PaymentSheetResult) {
        switch result {
        case .completed:
            addFundsToUser()
        case .canceled:
            // This is not an error so don't treat it like one
            print("Payment cancelled")
        case .failed(_):
//            self.error = APIError.general(desc: error.localizedDescription)
            self.paymentSheet = nil
        }
    }

    func addFundsToUser() {
        isLoading = true
        guard amount > 0, let user else { return }
        API.addToUserBalance(amount: amount, user: user) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.paymentResult = result
            }
        }
    }
}
