//
//  CreateEventView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct AddressSelectionView: View {
    @StateObject var viewModel = AddressSelectionViewModel()
    @FocusState private var isFocusedTextField: Bool
    var currentAddress: String? = nil

    let completion: (AddressResult) -> Void

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                TextField("Type address", text: $viewModel.searchableText)
                    .padding()
                    .autocorrectionDisabled()
                    .focused($isFocusedTextField)
                    .font(.title)
                    .onReceive(
                        viewModel.$searchableText.debounce(
                            for: .seconds(1),
                            scheduler: DispatchQueue.main
                        )
                    ) {
                        viewModel.searchAddress($0)
                    }
                    .background(Color.init(uiColor: .systemBackground))
                    .overlay {
                        ClearButton(text: $viewModel.searchableText)
                            .padding(.trailing)
                            .padding(.top, 8)
                    }
                    .onAppear {
                        if let currentAddress {
                            viewModel.searchableText = currentAddress
                            viewModel.searchAddress(currentAddress)
                        } else {
                            isFocusedTextField = true
                        }
                    }

                List(self.viewModel.results) { address in
                    NavigationLink {
                        MapView(address: address, completion: completion)
                    } label: {
                        AddressRow(address: address)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Select location")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AddressSelectionView() { _ in }
}
