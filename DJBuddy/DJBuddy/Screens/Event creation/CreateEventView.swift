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

    let completion: (EventData) -> Void

    var body: some View {
        VStack(spacing: 40) {
            PlaceholderTextField(placeholder: "Name of event", text: $viewModel.eventName)
            addressSelectionButton()
            dateSelectionButton()
            Spacer()
            Button("Create event") {
                viewModel.createEvent(by: user) { result in
                    switch result {
                    case let .success(newEvent):
                        completion(newEvent)
                        navigator.back()
                    case .failure(_):
                        break
                        // TODO: handle error
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
    CreateEventView() { _ in }
        .environmentObject(UserData.PreviewUser)
}
