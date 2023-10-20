//
//  InfoView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import SwiftUI

enum InfoType {
    case info
    case warning
    case error
}

struct InfoView: View {
    let text: String
    let type: InfoType

    var imageName: String {
        switch type {
        case .info:
            "info.circle.fill"
        case .warning:
            "exclamationmark.triangle.fill"
        case .error:
            "xmark.octagon.fill"
        }
    }

    var backgroundColor: Color {
        switch type {
        case .info:
                .gray
        case .warning:
                .orange
        case .error:
                .red
        }
    }

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: imageName)
                .font(.title2)
            Text(text)
        }
        .foregroundStyle(.white.opacity(0.8))
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(backgroundColor.opacity(0.5))
        .clipShape(.rect(cornerRadius: 12))
    }

    init(_ text: String, type: InfoType = .info) {
        self.text = text
        self.type = type
    }
}

#Preview {
    InfoView("Requests for this event are paused.")
        .padding()
}
