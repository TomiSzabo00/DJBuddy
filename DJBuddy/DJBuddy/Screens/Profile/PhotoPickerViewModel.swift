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
    @Published var error: Error?
    @Published var isLoading = false
    @Published var selectedImage: UIImage?

    func uploadImage(user: UserData, completion: @escaping (Result<Void, APIError>) -> Void) {
        isLoading = true

        API.uploadProfilePic(for: user, image: selectedImage!) { [weak self] result in
            self?.isLoading = false
            completion(result)
        }
    }

//    private func multipartFormDataBody(boundary: String, image: UIImage) -> Data {
//        let lineBreak = "\r\n"
//        var body = Data()
//
//        body.append("--\(boundary + lineBreak)")
//        body.append("Content-Disposition: form-data; name=\"fromName\"\(lineBreak + lineBreak)")
//        body.append("pic\(lineBreak)")
//
//        if let uuid = UUID().uuidString.components(separatedBy: "-").first {
//            body.append("--\(boundary + lineBreak)")
//            body.append("Content-Disposition: form-data; name=\"imageUploads\"; filename=\"\(uuid).jpg\"\(lineBreak)")
//            body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
//            body.append(image.jpegData(compressionQuality: 0.99)!)
//            body.append(lineBreak)
//        }
//
//        body.append("--\(boundary)--\(lineBreak)") // End multipart form and return
//        return body
//    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
