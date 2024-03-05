//
//  LikedDJRow.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 04/03/2024.
//

import SwiftUI

struct LikedDJRow: View {
    let dj: UserData
    let likeText: String

    var body: some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: "\(API.apiAddress)/\(dj.profilePicUrl)")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
            } placeholder: {
                Image("default")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            }

            VStack(alignment: .leading) {
                Text(dj.username)
                    .textCase(.uppercase)
                    .fontWeight(.heavy)
                    .font(.title3)

                Text(.init(likeText))
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .backgroundColor(Color.white)
            .foregroundStyle(Color.black)
        }
        .frame(height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    LikedDJRow(dj: UserData.PreviewUser, likeText: "You and **3M** other people")
        .backgroundColor(.background)
}
