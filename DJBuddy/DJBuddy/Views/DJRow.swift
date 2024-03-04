//
//  DJRow.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 04/03/2024.
//

import SwiftUI

struct DJRow: View {
    let dj: UserData
    @Binding var isLiked: Bool?
    let likeAtion: () -> Void

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

            HStack {
                Text(dj.username)
                    .textCase(.uppercase)
                    .fontWeight(.heavy)
                    .font(.title3)
                Spacer()
                if let isLiked {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(isLiked ? Color.red : Color.black)
                        .onTapGesture {
                            likeAtion()
                        }
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
            .backgroundColor(Color.white)
            .foregroundStyle(Color.black)
        }
        .listRowInsets(EdgeInsets())
        .frame(height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 20)
        .animation(.spring(.bouncy), value: isLiked)
    }
}

#Preview {
    VStack {
        DJRow(dj: UserData.PreviewUser, isLiked: .constant(false)) {}
        DJRow(dj: UserData.PreviewUser, isLiked: .constant(true)) {}
    }
    .padding()
    .backgroundColor(.background)
}
