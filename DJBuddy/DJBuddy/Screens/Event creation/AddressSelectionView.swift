//
//  CreateEventView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct AddressSelectionView: View {
    @StateObject var viewModel = CreateEventViewModel()
    @FocusState private var isFocusedTextField: Bool

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
                        isFocusedTextField = true
                    }

                List(self.viewModel.results) { address in
                    AddressRow(address: address)
                        .listRowBackground(Color.asset.background)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Color.asset.background)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

#Preview {
    AddressSelectionView()
}
