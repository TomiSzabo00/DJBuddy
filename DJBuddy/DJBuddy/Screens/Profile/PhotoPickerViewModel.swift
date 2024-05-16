//
//  PhotoPickerViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 05/11/2023.
//

import Foundation
import UIKit
import SwiftUI

final class PhotoPickerViewModel: ObservableObject {
    @Published var selectedImage: UIImage?

    @MainActor
    func uploadImage(user: UserData) async throws {
        try await API.uploadProfilePic(for: user, image: selectedImage!)
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
