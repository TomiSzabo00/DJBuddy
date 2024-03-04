//
//  JoinEventView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 26/02/2024.
//

import SwiftUI
import CodeScanner

struct JoinEventView: View {
    @EnvironmentObject var navigator: Navigator

    @StateObject private var viewModel = JoinEventViewModel()
    @State private var isScannerShowing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            InfoView("You can join by typing in the code of the event or by scanning the QR code.")

            Text("Code")
            codeInputView()

            scanItView()
                .padding(.vertical, 20)

            Spacer()

            Button("Join event") {

            }
            .buttonStyle(.largeProminent)
            .disabled(!viewModel.isCodeValid)

        }
        .padding(20)
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: "Join an event", navigator: navigator, leadingButton: .back)
        .errorAlert(error: $viewModel.scanError)
        .sheet(isPresented: $isScannerShowing) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "it works!") { result in
                isScannerShowing = false
                viewModel.handleScan(result: result)
            }
        }
    }

    @ViewBuilder private var placeholderView: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                Text(viewModel.eventCode)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
                Text(viewModel.placeholderText)
                    .foregroundColor(.gray.opacity(0.5))
                    .font(.system(size: 18, weight: .semibold))
            }
        }
    }

    @ViewBuilder private func codeInputView() -> some View {
        TextField("", text: $viewModel.eventCode)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.gray)
            .autocorrectionDisabled(true)
            .autocapitalization(.allCharacters)
            .background(placeholderView, alignment: .leading)
            .padding(.leading)
            .frame(height: 66)
            .background(
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                }
            )
            .onChange(of: viewModel.eventCode) { oldValue, newValue in
                if newValue.count > oldValue.count {
                    viewModel.charaterAddedToCode(oldValue: oldValue)
                } else if newValue.count < oldValue.count {
                    viewModel.characterRemovedFromCode(original: oldValue)
                }
            }
    }

    @ViewBuilder private func scanItView() -> some View {
        HStack {
            HStack {
                Text("Do you have a QR code? You can also scan it to join!")
                    .padding(.trailing, 20)

                Spacer()

                Button {
                    isScannerShowing = true
                } label: {
                    HStack {
                        Text("Scan it!")
                        Image(systemName: "qrcode.viewfinder")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .padding(20)
                }
                .tint(.red)
                .frame(maxHeight: 60)
                .background(RoundedRectangle(cornerRadius: 12).fill(.white))
            }
        }
    }
}

#Preview {
    NavigationView {
        JoinEventView()
            .environmentObject(Navigator())
    }
}
