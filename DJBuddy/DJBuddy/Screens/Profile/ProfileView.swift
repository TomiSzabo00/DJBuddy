//
//  ProfileView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var viewModel: AuthViewModel

    @State var user: UserData

    @State private var height: CGFloat = 0
    @State private var error: Error?
    @State private var isLoading = false

    var body: some View {
        VStack {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    AsyncImage(url: URL(string: user.profilePicUrl)) { image in
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
                    HStack {
                        VStack(alignment: .leading) {
                            Text(user.fullName)
                                .font(.system(size: 48))
                                .fontWeight(.bold)
                            Text(verbatim: user.email)
                                .font(.callout)
                        }

                        Spacer()

                        CircleButton {
                            // TODO: change profile pic
                            print("Profile pic change action")
                        } label: {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title3)
                                .foregroundStyle(Color.black)
                        }
                    }
                    .padding(.horizontal)
                    .offset(y: -30)

                }
                .onAppear {
                    height = geo.size.width + 50
                }
            }
            .frame(maxHeight: height)

            HStack {
                Text("Balance: **\(user.balance.formatted(.currency(code: "USD")))**")
                    .font(.title3)
                Spacer()
            }
            .padding()

            Spacer()

            Button(user.type == .user ? "Top up balance" : "Withdraw balance") {
                navigator.navigate(to: .balanceTopUp)
            }
            .buttonStyle(.largeProminent)
            .padding()
        }
        .onAppear {
            isLoading = true
            viewModel.refreshUser { result in
                isLoading = false
                switch result {
                case .success():
                    if let currentUser = viewModel.currentUser {
                        // Workaround to refresh user datas
                        user = UserData.EmptyUser
                        user = currentUser
                    }
                case .failure(let failure):
                    error = failure
                }
            }
        }
        .loadingOverlay(isLoading: $isLoading)
        .errorAlert(error: $error)
        .foregroundStyle(Color.white)
        .ignoresSafeArea(edges: .horizontal)
        .navBarWithTitle(title: "Profile", navigator: navigator, leadingButton: .back)
        .backgroundColor(.asset.background)
    }
}

#Preview {
    NavigationView {
        ProfileView(user: UserData.EmptyUser)
            .environmentObject(Navigator())
            .environmentObject(AuthViewModel())
    }
}
