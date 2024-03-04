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
    @Published var scanError: Error? = nil

    var placeholderText: String {
        String("XXXX - XXXX - XXXX".dropFirst(eventCode.count))
    }

    var isCodeValid: Bool {
        let parts = eventCode.components(separatedBy: " - ")
        return parts.count == 3 && parts.allSatisfy{ $0.count == 4 }
    }

    func charaterAddedToCode(oldValue: String) {
        if oldValue.count == 0 && eventCode.count > 1 {
            // text has been pasted here
            guard eventCode.components(separatedBy: " - ").count == 3 else {
                eventCode = ""
                scanError = APIError.general(desc: "Wrong code pasted. Try a different one.")
                return
            }
        }
        let parts = eventCode.components(separatedBy: " - ")
        if parts.count == 3 {
            if parts.last!.count == 4 {
                return
            } else if parts.last!.count > 4 {
                eventCode = eventCode.components(separatedBy: " - ").prefix(3).map { $0.prefix(4) }.joined(separator: " - ")
            }
        } else if parts.count > 3 {
            eventCode = eventCode.components(separatedBy: " - ").prefix(3).map { $0.prefix(4) }.joined(separator: " - ")
        }
        
        if let last = parts.last {
            if last.count == 4 {
                eventCode = parts.joined(separator: " - ") + " - "
            }
        }
    }

    func characterRemovedFromCode(original: String) {
        let parts = original.components(separatedBy: " - ")
        if parts.last!.isEmpty && !eventCode.isEmpty {
            eventCode = String(parts.dropLast().joined(separator: " - ").dropLast())
        }
    }

    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let success):
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.eventCode = success.string.uppercased()
            }
        case .failure(let failure):
            scanError = failure
        }
    }
}
