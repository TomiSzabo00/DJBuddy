//
//  HomeTabView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct HomeTabView: View {
    @State var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            DJHomeView().tag(0)
            Text("Map").tag(1)
        }
        .overlay(alignment: .bottom) {
            TabViewSelector(selected: $selectedTab)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomeTabView()
}
