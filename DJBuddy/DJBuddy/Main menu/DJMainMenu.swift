//
//  DJMainMenu.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 08/10/2023.
//

import SwiftUI

struct DJMainMenu: View {
    @State var menu = false

    var body: some View {
        VStack {
            List {
                Section {
                    EventListTile()
                    EventListTile()
                } header: {
                    Text("Your events")
                        .textCase(.uppercase)
                        .font(.subheadline)
                }
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            }
            .preferredColorScheme(.dark)
            .background(Color.asset.background)
            .scrollContentBackground(.hidden)
        }
        .sideMenu(isShowing: $menu)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                MenuButton(isShowing: $menu) {
                    
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Hi, DJ") {

                }
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
