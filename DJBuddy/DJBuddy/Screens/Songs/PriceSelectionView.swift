//
//  PriceSelectionView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 21/10/2023.
//

import SwiftUI

struct PriceSelectionView: View {
    let amounts: [Double]
    @Binding var selectedAmount: Double
    @State var customAmount: Double? = nil
    @State var isCustomAmountAlertShowing = false
    @State var customAmountText = ""
    var amountToNext: Double? = nil

    var body: some View {
        LazyVGrid(columns: [GridItem(.fixed(110)), GridItem(.fixed(110)), GridItem(.fixed(110))]) {
            ForEach(amounts, id: \.self) { amount in
                priceRect(amount: amount, isSelected: amount == selectedAmount)
            }
            customPriceRect(amount: customAmount, isSelected: selectedAmount == customAmount)
            if let amountToNext, !amounts.contains(amountToNext) {
                priceRect(amount: amountToNext, isSelected: selectedAmount == amountToNext)
            }
        }
        .animation(.default, value: selectedAmount)
        .alert("Enter amount", isPresented: $isCustomAmountAlertShowing) {
            TextField("Custom amount", text: $customAmountText)
                .keyboardType(.decimalPad)
            Button("OK") {
                if let newAmount = Double(customAmountText) {
                    customAmount = newAmount
                    selectedAmount = newAmount
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enter the desired amount.")
        }
    }

    @ViewBuilder private func priceRect(amount: Double, isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill((isSelected ? Color.red : Color.gray).opacity(0.35))
            .overlay {
                Text("\(amount.formatted(.currency(code: "USD")))")
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? .red : .white)
            }
            .frame(width: 110, height: 50)
            .onTapGesture {
                selectedAmount = amount
            }
    }

    @ViewBuilder private func customPriceRect(amount: Double?, isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill((isSelected ? Color.red : Color.gray).opacity(0.35))
            .overlay {
                if let amount {
                    HStack {
                        Text("\(amount.formatted(.currency(code: "USD")))")
                            .fontWeight(.semibold)
                        Image(systemName: "multiply.circle.fill")
                            .onTapGesture {
                                if selectedAmount == customAmount {
                                    selectedAmount = amounts.first ?? 0
                                }
                                customAmount = nil
                            }
                    }
                    .foregroundStyle(isSelected ? .red : .white)
                    .onTapGesture {
                        selectedAmount = amount
                    }
                } else {
                    HStack {
                        Text("Custom")
                            .fontWeight(.semibold)
                        Image(systemName: "pencil.line")
                    }
                    .foregroundStyle(isSelected ? .red : .white)
                    .onTapGesture {
                        isCustomAmountAlertShowing.toggle()
                    }
                }
            }
            .frame(width: 110, height: 50)
    }

}

#Preview {
    PriceSelectionView(amounts: [1, 3, 5], selectedAmount: .constant(1))
        .backgroundColor(.asset.background)
}
