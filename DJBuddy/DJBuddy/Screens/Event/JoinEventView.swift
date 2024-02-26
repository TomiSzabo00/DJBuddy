//
//  JoinEventView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 26/02/2024.
//

import SwiftUI

struct JoinEventView: View {
    @EnvironmentObject var navigator: Navigator

    @StateObject private var viewModel = JoinEventViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            InfoView("You can join by typing in the code of the event or by scanning the QR code.")

            Text("Code")
            PlaceholderTextField(placeholder: "Event's code...", text: $viewModel.eventCode) {
                viewModel.validateCode()
            }

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
    }

    @ViewBuilder private func scanItView() -> some View {
        HStack {
            HStack {
                Text("Do you have a QR code? You can also scan it to join!")
                    .padding(.trailing, 20)

                Spacer()

                Button {

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
