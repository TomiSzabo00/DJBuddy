//
//  Navigator.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

enum NavigationDestination: Hashable {
    case profile
    case createEvent
    case selectEvent([EventData])
    case eventControl(EventData)
    case userEventView(EventData)
    case requestSong(EventData)
    case songDetails(SongData)
}

class Navigator: ObservableObject {
    @Published var path = NavigationPath()

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
