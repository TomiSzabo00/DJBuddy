//
//  LikedDJsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 04/03/2024.
//

import SwiftUI

struct LikedDJsView: View {
    @EnvironmentObject private var navigator: Navigator
    @EnvironmentObject private var user: UserData

    @StateObject private var viewModel = LikedDJsViewModel()

    var body: some View {
        List {
            Section {
                ForEach(viewModel.likedDJs, id: \.0) { dj, likeText in
                    LikedDJRow(dj: dj, likeText: likeText)
                        .discardable {
                            viewModel.dislike(dj: dj, by: user)
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
            viewModel.getLikedDjs(for: user)
        }
    }
}

#Preview {
    NavigationView {
        LikedDJsView()
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
