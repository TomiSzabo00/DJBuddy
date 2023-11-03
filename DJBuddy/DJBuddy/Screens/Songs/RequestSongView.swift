//
//  RequestSongView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 21/10/2023.
//

import SwiftUI
import StripePaymentSheet

struct RequestSongView: View {
    @EnvironmentObject var navigator: Navigator
    @ObservedObject var viewModel: EventControlViewModel

    @State var isSongSelectionShowing = false
    @State var error: Error? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let theme = viewModel.event.theme {
                InfoView("The DJ has set the theme to \(theme.displayName.uppercased()) for this event. You can only request songs from this category at the moment.", type: .info)
            }

            Text("Choose a song:")
            songSelectionButton()

            Text("Set a price")
            PriceSelectionView(amounts: [1, 3, 5], selectedAmount: $viewModel.selectedPrice)

            Spacer()

            Button("I agree to the [Terms and Conditions](https://en.wikipedia.org/wiki/Terms_of_service) and want to continue with the payment.") {

            }
            .buttonStyle(.checkmark(isOn: $viewModel.didAgree))

            if let paymentSheet = viewModel.paymentSheet {
                PaymentSheet.PaymentButton(
                    paymentSheet: paymentSheet,
                    onCompletion: viewModel.onPaymentCompletion
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
        .onReceive(viewModel.$selectedPrice) { newPrice in
            viewModel.preparePaymentSheet(price: newPrice)
        }
        .onReceive(viewModel.$paymentResult) { result in
            switch result {
            case .success(_):
                navigator.back()
            case .failure(let error):
                self.error = error
            case .none:
                break
            }
        }
        .foregroundStyle(.white)
        .padding()
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: "Request a song", navigator: navigator, leadingButton: .back)
        .sheet(isPresented: $isSongSelectionShowing) {
            SongSelectionView(isShowing: $isSongSelectionShowing, theme: viewModel.event.theme) { selectedSong in
                viewModel.selectedSong = selectedSong
                isSongSelectionShowing = false
            }
        }
        .loadingOverlay(isLoading: $viewModel.isLoading)
        .errorAlert(error: $error)
        .errorAlert(error: $viewModel.formError)
        .onAppear {
            viewModel.getCurrentTheme()
            viewModel.initWebSocketForEventThemeChanges()
        }
        .onDisappear {
            viewModel.closeWebSockets()
        }
    }

    @ViewBuilder private func agreePrivacyPolicy(_ checkbox: Binding<Bool>) -> some View {
        HStack {
            Toggle("Title", isOn: checkbox)
        }
    }

    @ViewBuilder private func songSelectionButton() -> some View {
        ZStack(alignment: .leading) {
            if let song = viewModel.selectedSong {
                SimpleSongRow(song: song)
            } else {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search by artist or title...")
                }
                .padding(.horizontal)
            }
        }
        .fontWeight(.semibold)
        .foregroundStyle(.gray)
        .frame(maxWidth: .infinity, maxHeight: 66, alignment: .leading)
        .background(.white)
        .clipShape(.rect(cornerRadius: 12))
        .onTapGesture {
            isSongSelectionShowing.toggle()
        }
    }
}

#Preview {
    NavigationView {
        RequestSongView(viewModel: EventControlViewModel(event: EventData.PreviewData))
            .environmentObject(Navigator())
    }
}
