//
//  EventListTile.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct EventListTile: View {
    let eventData: EventData
    
    var body: some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: eventData.dj.profilePicUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
            } placeholder: {
                Image("default")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
            }

            VStack(alignment: .leading) {
                Text(eventData.dj.username)
                    .textCase(.uppercase)
                    .fontWeight(.heavy)
                    .font(.title3)
                Text(eventData.location.title)
                    .fontWeight(.medium)
                Spacer()
                HStack {
                    Spacer()
                    Text(eventData.date.formatted(.dateTime.day().month().year()))
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 10)
            .backgroundColor(Color.white)
            .foregroundStyle(Color.black)
        }
        .listRowInsets(EdgeInsets())
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 20)
    }
}

#Preview {
    EventListTile(eventData: EventData.PreviewData)
        .padding()
        .backgroundColor(.asset.background)
}
