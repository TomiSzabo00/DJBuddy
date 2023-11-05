//
//  BalanceTopUpView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 04/11/2023.
//

import SwiftUI
import StripePaymentSheet

struct BalanceTopUpView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var navigator: Navigator

    @StateObject private var paymentHelper = StripePaymentHelper()
    @State var selectedAmount: Double = 10

    var body: some View {
        VStack(spacing: 20) {
            Text("Select the amount you wish to add to your profile")
                .frame(maxWidth: .infinity)

            PriceSelectionView(amounts: [10, 20, 50], selectedAmount: $selectedAmount)

            InfoView("Once you've added funds to your account, you won't be able to refund them. Only add as much as you think is necessary.", type: .warning)

            Spacer()

            if let paymentSheet = paymentHelper.paymentSheet {
                PaymentSheet.PaymentButton(
                    paymentSheet: paymentSheet,
                    onCompletion: paymentHelper.onPaymentCompletion
                ) {
                    Text("Go to payment")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(12)
                }
            } else {
                Button {

                } label: {
                    ProgressView()
                }
                .buttonStyle(.largeProminent)
                .disabled(true)
            }

        }
        .onAppear {
            paymentHelper.preparePaymentSheet(price: selectedAmount, for: user)
        }
        .onChange(of: selectedAmount) { _, newValue in
            paymentHelper.preparePaymentSheet(price: newValue, for: user)
        }
        .onReceive(paymentHelper.$paymentResult) { result in
            switch result {
            case .success(_):
                navigator.back()
            case .failure(let error):
                paymentHelper.error = error
            case .none:
                break
            }

        }
        .loadingOverlay(isLoading: $paymentHelper.isLoading)
        .errorAlert(error: $paymentHelper.error)
        .padding()
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: "Add funds", navigator: navigator, leadingButton: .back)
    }
}

#Preview {
    NavigationView {
        BalanceTopUpView()
            .environmentObject(UserData.EmptyUser)
            .environmentObject(Navigator())
    }
}
