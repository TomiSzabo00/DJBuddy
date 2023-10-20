//
//  Navigator.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

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
        path.removeLast()
    }
}
