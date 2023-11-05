//
//  EventAnnotation.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 23/10/2023.
//

import SwiftUI

struct EventAnnotation: View {
    let event: EventData

    @State var id = UUID()

    var body: some View {
        ZStack {
            Triangle()
                .fill(.white)
                .frame(width: 40, height: 30)
                .offset(y: 20)
            Circle()
                .fill(.white)
                .frame(width: 40)
                .overlay {
                    AsyncImage(url: URL(string: "\(API.apiAddress)/\(event.dj.profilePicUrl)")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 30)
                    } placeholder: {
                        Image("default")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                    }
                    .clipShape(.circle)
                    .id(id)
                }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    EventAnnotation(event: EventData.MapPreviewData)
        .backgroundColor(.asset.background)
}
