import SwiftUI

struct NavigationBarModifier: ViewModifier {
    let title: String
    let leadingButton: ButtonType?
    let trailingButton: ButtonType?
    let buttonColor: Color
    let navigator: Navigator

    @State var isMenuShowing = false

    init(title: String, navigator: Navigator, leadingButton: ButtonType? = nil, trailingButton: ButtonType? = nil, buttonColor: Color = .red) {
        self.title = title
        self.navigator = navigator
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
        self.buttonColor = buttonColor
    }

    func body(content: Content) -> some View {
        content
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if let leadingButton {
                    ToolbarItem(placement: .topBarLeading) {
                        button(for: leadingButton)
                            .tint(buttonColor)
                    }
                }
                if let trailingButton {
                    ToolbarItem(placement: .topBarTrailing) {
                        button(for: trailingButton)
                            .tint(buttonColor)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .sideMenu(isShowing: $isMenuShowing, navigator: navigator)
    }

    @ViewBuilder private func button(for type: ButtonType) -> some View {
        switch type {
        case .back:
            Button {
                navigator.back()
            } label: {
                Image(systemName: "chevron.left")
            }
        case .menu:
            MenuButton(isShowing: $isMenuShowing) {}
        case .options:
            Button {
                // TODO: show context menu
            } label: {
                Image(systemName: "gearshape.2")
            }
        case let .profile(name):
            Button("Hi, \(name)") {
                navigator.show(ProfileView.self)
            }
        }
    }
}

extension View {
    func navBarWithTitle(title: String, navigator: Navigator, leadingButton: ButtonType? = nil, trailingButton: ButtonType? = nil, buttonColor: Color = .red) -> some View {
        self.modifier(NavigationBarModifier(title: title, navigator: navigator, leadingButton: leadingButton, trailingButton: trailingButton, buttonColor: buttonColor))
    }

}
