//
//  JoinEventViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 26/02/2024.
//

import Foundation

final class JoinEventViewModel: ObservableObject {
    @Published var eventCode: String = ""
    @Published var isCodeValid: Bool = false

    func validateCode() {
        isCodeValid = eventCode.count == 10
    }
}
