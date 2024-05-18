//
//  LikedDJsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 04/03/2024.
//

import SwiftUI

struct LikedDJsView: View {
    @EnvironmentObject private var stateHelper: StateHelper
    @EnvironmentObject private var navigator: Navigator

    @StateObject private var viewModel = LikedDJsViewModel()

    var body: some View {
        List {
            Section {
                ForEach(viewModel.likedDJs, id: \.0) { dj, likeText in
                    LikedDJRow(dj: dj, likeText: likeText)
                        .discardable {
                            stateHelper.performWithProgress {
                                try await viewModel.dislike(dj: dj)
                            }
                        }
                }
            } header: {
                Text("Your liked Djs")
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
        }
        .preferredColorScheme(.dark)
        .background(Color.asset.background)
        .scrollContentBackground(.hidden)
        .navBarWithTitle(title: "Liked DJs", navigator: navigator, leadingButton: .back)
        .onAppear {
            stateHelper.performWithProgress {
                try await viewModel.getLikedDjs()
            }
        }
    }
}

#Preview {
    NavigationView {
        LikedDJsView()
            .environmentObject(Navigator())
    }
}
