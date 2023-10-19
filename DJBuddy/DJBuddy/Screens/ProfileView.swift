//
//  ProfileView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct ProfileView: View {
    let user: UserData

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Image("default")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.width)
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [.clear, .asset.background]),
                                       startPoint: .top,
                                       endPoint: .bottom)
                    )
                HStack {
                    VStack(alignment: .leading) {
                        Text(user.name.fullName)
                            .font(.system(size: 48))
                            .fontWeight(.bold)
                        Text(verbatim: user.email)
                            .font(.callout)
                    }
                    .foregroundStyle(Color.white)

                    Spacer()

                    CircleButton {} label: {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title3)
                            .foregroundStyle(Color.black)
                    }
                }
                .padding(.horizontal)
                .offset(y: -30)

                Spacer()
            }
        }
        .ignoresSafeArea(edges: .horizontal)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .backgroundColor(.asset.background)
    }
}

#Preview {
    NavigationView {
        ProfileView(user: UserData(username: "exampleUser",
                                   email: "example@email.com",
                                   firstName: "Example",
                                   lastName: "User",
                                   type: .user))
    }
}
