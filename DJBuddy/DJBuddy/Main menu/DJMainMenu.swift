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
            EventList {
                EventListTile()
                EventListTile()
            }
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
