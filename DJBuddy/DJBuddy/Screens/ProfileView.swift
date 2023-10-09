//
//  ProfileView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct ProfileView: View {
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
                        Text("DJ")
                            .font(.system(size: 48))
                            .fontWeight(.bold)
                        Text(verbatim: "dj@email.com")
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
            .ignoresSafeArea(edges: .horizontal)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(backgroundColor: .black, titleColor: .red)
        .backgroundColor(.asset.background)
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
