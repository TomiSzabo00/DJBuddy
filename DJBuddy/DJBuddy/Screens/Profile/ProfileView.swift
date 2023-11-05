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
    @State private var isPhotoSelectShowing = false

    @State private var id = UUID()

    var body: some View {
        VStack {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    AsyncImage(url: URL(string: "\(API.apiAddress)/\(user.profilePicUrl)")) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.width, alignment: .center)
                            .clipped()
                    } placeholder: {
                        Image("default")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.width)
                    }
                    .id(id)
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
                            isPhotoSelectShowing.toggle()
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
                if user.type == .user {
                    navigator.navigate(to: .balanceTopUp)
                } else {
                    isLoading = true
                    API.withdrawFromBalance(of: user) { result in
                        isLoading = false
                        switch result {
                        case .success():
                            refreshUser()
                        case .failure(let error):
                            self.error = error
                        }
                    }
                }
            }
            .buttonStyle(.largeProminent)
            .padding()
        }
        .onAppear {
            refreshUser()
        }
        .sheet(isPresented: $isPhotoSelectShowing) {
            refreshUser()
        } content: {
            NavigationView {
                PhotoPickerView(isShowing: $isPhotoSelectShowing)
            }
        }
        .loadingOverlay(isLoading: $isLoading)
        .errorAlert(error: $error)
        .foregroundStyle(Color.white)
        .ignoresSafeArea(edges: .horizontal)
        .navBarWithTitle(title: "Profile", navigator: navigator, leadingButton: .back)
        .backgroundColor(.asset.background)
    }

    private func refreshUser() {
        isLoading = true
        viewModel.refreshUser { result in
            isLoading = false
            switch result {
            case .success():
                DispatchQueue.main.async {
                    if let currentUser = viewModel.currentUser {
                        user = currentUser
                        id = UUID()
                    }
                }
            case .failure(let failure):
                error = failure
            }
        }
    }
}

#Preview {
    NavigationView {
        ProfileView(user: UserData.EmptyUser)
            .environmentObject(Navigator())
            .environmentObject(AuthViewModel())
    }
}
