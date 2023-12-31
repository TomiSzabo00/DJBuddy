//
//  SongDetalsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import SwiftUI

struct SongDetalsView: View {
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var user: UserData
    let song: SongData
    @StateObject var viewModel: EventControlViewModel

    @State var isIncPriceShowing = false

    @State var error: Error? = nil

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    AsyncImage(url: URL(string: song.albumArtUrl)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: geo.size.width)
                    } placeholder: {
                        Image("default")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.width)
                    }
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [.clear, .asset.background]),
                                       startPoint: .top,
                                       endPoint: .bottom)
                    )

                    VStack(alignment: .leading, spacing: 0) {
                        Text(song.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text(song.artist)
                            .font(.title3)
                            .padding(.vertical, 10)
                        Text("Current price: **\(song.amount.formatted(.currency(code: "USD")))**")
                            .padding(.vertical, 30)

                        if user.type == .dj {
                            Button("Accept") {
                                viewModel.accept(song: song, dj: user) { result in
                                    switch result {
                                    case .success(_):
                                        navigator.back()
                                    case .failure(let error):
                                        self.error = error
                                    }
                                }
                            }
                            .buttonStyle(.largeProminent)
                            .padding(.vertical)

                            Button("Decline") {
                                viewModel.decline(song: song) { result in
                                    switch result {
                                    case .success(_):
                                        navigator.back()
                                    case .failure(let error):
                                        self.error = error
                                    }
                                }
                            }
                            .buttonStyle(.largeSecondary)
                        } else {
                            Button("Increase price") {
                                isIncPriceShowing.toggle()
                            }
                            .buttonStyle(.largeProminent)
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(y: -30)

                }
            }
        }
        .onAppear {
            viewModel.currentSong = song
        }
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: "Song", navigator: navigator, leadingButton: .back)
        .sheet(isPresented: $isIncPriceShowing) {
            IncreasePriceView(song: song, viewModel: viewModel, isShowing: $isIncPriceShowing)
                .environmentObject(user)
        }
        .loadingOverlay(isLoading: $viewModel.isLoading)
        .errorAlert(error: $error)
    }
}

#Preview {
    NavigationView {
        SongDetalsView(song: SongData.PreviewData, viewModel: EventControlViewModel(event: EventData.PreviewData))
            .environmentObject(Navigator())
            .environmentObject(UserData.EmptyUser)
    }
}
