//
//  ContentView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import SwiftUI

struct WavyBackgroundView: View {
    let height: Double

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack(alignment: .leading) {
                WaveBackGround()
                Image("headphones")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
            }
            .frame(height: 300)
            Rectangle()
                .frame(height: abs(height - 300))
                .ignoresSafeArea()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct WaveBackGround: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))

            path.addCurve(to: CGPoint(x: rect.maxX, y: rect.height / 3.5), control1: CGPoint(x: rect.width * 0.5, y: rect.height * 0.3), control2: CGPoint(x: rect.width * 0.75, y: rect.height * 0.7))

            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

#Preview {
    @Namespace var namespace
    return WavyBackgroundView(height: 550)
}
