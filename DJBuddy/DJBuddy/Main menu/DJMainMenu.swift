//
//  DJMainMenu.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 08/10/2023.
//

import SwiftUI

struct DJMainMenu: View {
    var body: some View {
        VStack {
            List {
                Section("Your events") {
                    Text("Event 1")
                }
            }
            .preferredColorScheme(.dark)
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {}, label: {
                    Image(systemName: "line.3.horizontal")
                })
                .tint(.red)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Hi, DJ") {}
                    .tint(.red)
            }
        }
    }
}

#Preview {
    NavigationView {
        DJMainMenu()
    }
}
