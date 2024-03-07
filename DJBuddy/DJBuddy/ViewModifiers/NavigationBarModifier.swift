import SwiftUI

struct NavigationBarModifier<MenuContent: View>: ViewModifier {
    let title: String
    let leadingButton: ButtonType?
    let trailingButton: ButtonType?
    let buttonColor: Color
    let navigator: Navigator
    @ViewBuilder let actionSheetContent: MenuContent

    @State var isMenuShowing = false
    @State var isOptionsShowing = false

    @State private var signOutAction: () -> Void = {}
    @State private var userType: UserTypeEnum = .user

    init(title: String, 
         navigator: Navigator,
         leadingButton: ButtonType? = nil,
         trailingButton: ButtonType? = nil,
         buttonColor: Color = .red,
         @ViewBuilder actionSheetContent: @escaping () -> MenuContent) {
        self.title = title
        self.navigator = navigator
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
        self.buttonColor = buttonColor
        self.actionSheetContent = actionSheetContent()

        UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .dark
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
            .sideMenu(isShowing: $isMenuShowing, navigator: navigator, userType: userType, signOutAction: signOutAction)
            .confirmationDialog("", isPresented: $isOptionsShowing) {
                actionSheetContent
                .preferredColorScheme(.dark)
                .environment(\.colorScheme, .dark)
            }
    }

    @ViewBuilder private func button(for type: ButtonType) -> some View {
        switch type {
        case .back:
            Button {
                navigator.back()
            } label: {
                Image(systemName: "chevron.left")
            }
        case let .menu(type, signOutAction):
            MenuButton(isShowing: $isMenuShowing) {}
                .onAppear {
                    self.userType = type
                    self.signOutAction = signOutAction
                }
        case .options:
            Button {
                isOptionsShowing.toggle()
            } label: {
                Image(systemName: "gearshape.2")
            }
        case let .profile(name):
            Button("Hi, \(name)") {
                navigator.navigate(to: .profile)
            }
        case let .close(isShowing):
            Button {
                isShowing.wrappedValue = false
            } label: {
                Image(systemName: "multiply")
            }
        case let .share(isShowing):
            Button {
                isShowing.wrappedValue = true
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        case let .add(isShowing):
            Button {
                isShowing.wrappedValue = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

extension View {
    func navBarWithTitle<MenuContent: View>(title: String, navigator: Navigator = Navigator(), leadingButton: ButtonType? = nil, trailingButton: ButtonType? = nil, buttonColor: Color = .red, @ViewBuilder actionSheetContent: @escaping () -> MenuContent = { EmptyView() }) -> some View {
        self.modifier(NavigationBarModifier(title: title, navigator: navigator, leadingButton: leadingButton, trailingButton: trailingButton, buttonColor: buttonColor, actionSheetContent: actionSheetContent))
    }

}
