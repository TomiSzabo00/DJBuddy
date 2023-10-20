//
//  MainMenuViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import Foundation

final class MainMenuViewModel: ObservableObject {
    @Published private(set) var yourEvents: [EventData] = []
    @Published var isLoading = false

    func fetchEvents(for user: UserData) {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            self?.yourEvents = [EventData.PreviewData, EventData.PreviewData]
            self?.isLoading = false
        }
    }
}
