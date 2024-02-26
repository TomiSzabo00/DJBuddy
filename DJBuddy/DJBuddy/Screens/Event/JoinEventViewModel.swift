//
//  JoinEventViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 26/02/2024.
//

import Foundation
import CodeScanner

final class JoinEventViewModel: ObservableObject {
    @Published var eventCode: String = ""
    @Published var isCodeValid: Bool = false
    @Published var scanError: Error? = nil

    func validateCode() {
        isCodeValid = eventCode.count == 10
    }

    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let success):
            print(success.string)
        case .failure(let failure):
            scanError = failure
        }
    }
}
