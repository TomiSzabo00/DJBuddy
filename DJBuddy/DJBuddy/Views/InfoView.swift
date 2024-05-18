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
                .padding(.leading, 10)
            Text(.init(text))
        }
        .foregroundStyle(.white.opacity(0.8))
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .background(backgroundColor.opacity(0.5))
        .clipShape(.rect(cornerRadius: 12))
    }

    init(_ text: String, type: InfoType = .info) {
        self.text = text
        self.type = type
    }

    init(from state: EventState) {
        text = {
            switch state {
            case .upcoming:
                "This event hasn't started yet. Come back later!"
            case .inProgress:
                "This event is currently in progress. Request songs now!"
            case .paused:
                "Requests for this event are paused. Wait a few minutes."
            case .ended:
                "This event has ended. Hope you had a great time!"
            }
        }()

        type = {
            if [.paused, .upcoming].contains(state) {
                return .warning
            } else if state == .ended {
                return .error
            }
            return .info
        }()
    }
}

#Preview {
    InfoView("Requests for this event are paused.")
        .padding()
}
