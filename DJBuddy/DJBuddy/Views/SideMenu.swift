//
//  SideMenu.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct SideMenu: View {
    @Binding var isShowing: Bool
    let navigator: Navigator
    var edgeTransition: AnyTransition = .move(edge: .leading)

    let signOutAction: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                if (isShowing) {
                    Color.black
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isShowing.toggle()
                        }
                    content
                        .safeAreaPadding()
                        .transition(edgeTransition)
                        .frame(width: geo.size.width * 0.75)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .animation(.easeInOut, value: isShowing)
        }
    }

    @ViewBuilder var content: some View {
        VStack(alignment: .leading, spacing: 40) {
            ForEach(MenuButtonType.allCases) { type in
                HStack {
                    menuButton(type: type)
                    Spacer()
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
    }

    @ViewBuilder private func menuButton(type: MenuButtonType) -> some View {
        let title = { () -> String in
            switch type {
            case .signOut:
                return "Sign out"
            case .upcoming:
                return "Upcoming events"
            case .past:
                return "Past events"
            case .liked:
                return "Liked DJs"
            case .profile:
                return "Profile"
            }
        }()

        let action = { () -> (() -> Void) in
            switch type {
            case .upcoming:
                return {}
            case .past:
                return {}
            case .liked:
                return {}
            case .profile:
                return {
                    navigator.navigate(to: .profile)
                }
            case .signOut:
                return {
                    signOutAction()
                }
            }
        }()

        Button(title) {
            isShowing.toggle()
            action()
        }
    }
}

#Preview {
    SideMenu(isShowing: .constant(true), navigator: Navigator()) {}
}
