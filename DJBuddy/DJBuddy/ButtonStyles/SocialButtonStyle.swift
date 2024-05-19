//
//  SocialButtonStyle.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/05/2024.
//

import SwiftUI

struct SocialButtonStyle: ButtonStyle {
    let company: Company
    let size: ButtonSize

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
                .foregroundStyle(iconColor)
                .opacity(configuration.isPressed ? 0.2 : 1)
            if size == .large {
                Text("Continue with \(company.rawValue)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textColor)
                    .opacity(configuration.isPressed ? 0.8 : 1)
            }
        }
        .frame(height: 60)
        .frame(maxWidth: size == .extraSmall ? 60 : .infinity)
        .background(backgroundColor)
        .cornerRadius(12)
        .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension SocialButtonStyle {
    enum ButtonSize {
        case large
        case compact
        case extraSmall
    }

    enum Company: String {
        case google = "Google"
        case facebook = "Facebook"
        case email = "Email"
    }

    var backgroundColor: Color {
        switch company {
        case .facebook: .blue
        case .google: .white
        case .email: .black
        }
    }

    var textColor: Color {
        switch company {
        case .facebook, .email: .white
        case .google: .black
        }
    }

    var icon: ImageResource {
        switch company {
        case .facebook: .facebook
        case .google: .google
        case .email: .email
        }
    }

    var iconColor: Color {
        switch company {
        case .facebook, .email: .white
        default: .clear
        }
    }
}

extension SwiftUI.ButtonStyle where Self == SocialButtonStyle {
    static func social(for company: SocialButtonStyle.Company, size: SocialButtonStyle.ButtonSize = .large) -> Self {
        Self(company: company, size: size)
    }
}

#Preview {
    VStack {
        Button("") {}
            .buttonStyle(.social(for: .google))

        Button("") {}
            .buttonStyle(.social(for: .facebook))

        HStack {
            Button("") {}
                .buttonStyle(.social(for: .google, size: .compact))

            Button("") {}
                .buttonStyle(.social(for: .facebook, size: .compact))
        }
    }
    .padding()
    .backgroundColor(.background)
}
