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
    let userType: UserTypeEnum
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
            ForEach(MenuButtonType.allCases(for: userType)) { type in
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
        let action = { () -> (() -> Void) in
            switch type {
            case .join:
                return {
                    navigator.navigate(to: .joinEvent)
                }
            case .past:
                return {
                    navigator.navigate(to: .pastEvents)
                }
            case .liked:
                return {
                    navigator.navigate(to: .likedDjs)
                }
            case .songs:
                if userType == .user {
                    return {
                        navigator.navigate(to: .savedSongs)
                    }
                }
                return {
                    navigator.navigate(to: .playlists)
                }
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

        Button(type.title(for: userType)) {
            isShowing.toggle()
            action()
        }
    }
}

#Preview {
    SideMenu(isShowing: .constant(true), navigator: Navigator(), userType: .user) {}
}
