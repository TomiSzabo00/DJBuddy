//
//  Navigator.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

enum NavigationDestination: Hashable {
    case home
    case profile(UserData)
    case requestSong(EventData)
}

class Navigator: ObservableObject {
    @Published var path = NavigationPath()

    func show<V>(_ viewType: V.Type) where V: View {
        path.append(String(describing: viewType.self))
    }

    func navigate(with: any Hashable) {
        path.append(with)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func back() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func navigate(to dest: NavigationDestination) {
        path.append(dest)
    }
}
