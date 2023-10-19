//
//  AddressRow.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct AddressRow: View {
    let address: AddressResult

        var body: some View {
            VStack(alignment: .leading) {
                Text(address.title)
                Text(address.subtitle)
                    .font(.caption)
            }
        }
}

#Preview {
    AddressRow(address: AddressResult(title: "Title", subtitle: "Subtitle"))
}
