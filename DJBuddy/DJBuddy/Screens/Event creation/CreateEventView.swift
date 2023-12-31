//
//  CreateEventView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct CreateEventView: View {
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var user: UserData

    @StateObject var viewModel = CreateEventViewModel()
    @State var isAddressSheetShowing = false
    @State var isDatePickerShowing = false
    @State var error: Error? = nil

    var body: some View {
        VStack(spacing: 40) {
            PlaceholderTextField(placeholder: "Name of event", text: $viewModel.eventName)
            addressSelectionButton()
            dateSelectionButton()
            Spacer()
            Button("Create event") {
                viewModel.createEvent(by: user) { result in
                    switch result {
                    case .success():
                        navigator.back()
                    case .failure(let error):
                        self.error = error
                    }
                }
            }
            .buttonStyle(.largeProminent)
        }
        .padding()
        .sheet(isPresented: $isAddressSheetShowing) {
            AddressSelectionView(currentAddress: viewModel.currentAddress) { selectedAddress in
                viewModel.selectedAddress = selectedAddress
                isAddressSheetShowing = false
            }
        }
        .sheet(isPresented: $isDatePickerShowing) {
            DatePicker(selection: $viewModel.dateOfEvent, in: Date.now..., displayedComponents: .date) {}
                .datePickerStyle(.graphical)
                .labelsHidden()
                .presentationDetents([.medium])
        }
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: "Create new event", navigator: navigator, leadingButton: .back)
        .loadingOverlay(isLoading: $viewModel.isLoading)
        .errorAlert(error: $error)
        .errorAlert(error: $viewModel.formError)
    }

    @ViewBuilder private func addressSelectionButton() -> some View {
        ZStack {
            if let address = viewModel.selectedAddress {
                AddressRow(address: address)
            } else {
                Text("Address")
            }

        }
        .fontWeight(.semibold)
        .foregroundStyle(.gray)
        .frame(maxWidth: .infinity, maxHeight: 66, alignment: .leading)
        .padding(.horizontal)
        .background(.white)
        .clipShape(.rect(cornerRadius: 12))
        .onTapGesture {
            isAddressSheetShowing.toggle()
        }
    }

    @ViewBuilder private func dateSelectionButton() -> some View {
        ZStack {
            if let dateString = viewModel.displayDate {
                Text(dateString)
            } else {
                Text("Select date")
            }

        }
        .fontWeight(.semibold)
        .foregroundStyle(.gray)
        .frame(maxWidth: .infinity, maxHeight: 66, alignment: .leading)
        .padding(.horizontal)
        .background(.white)
        .clipShape(.rect(cornerRadius: 12))
        .onTapGesture {
            isDatePickerShowing.toggle()
        }
    }
}

#Preview {
    CreateEventView()
        .environmentObject(UserData.EmptyUser)
        .environmentObject(Navigator())
}
