//
//  LikedDJsViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 05/03/2024.
//

import Foundation

final class LikedDJsViewModel: ObservableObject {
    @Published private(set) var likedDJs: [(dj: UserData, likeText: String)] = []
    @Published var isLoading = false
    @Published var error: Error? = nil

    func getLikedDjs(for user: UserData) {
        isLoading = true

        API.getAllLiked(by: user) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let success):
                let likedData = success.map {
                    (dj: $0.dj, likeText: self?.transformLikeCount(from: $0.like) ?? "" )
                }
                DispatchQueue.main.async {
                    self?.likedDJs = likedData
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }

    func transformLikeCount(from likeCount: Int) -> String {
        if likeCount > 2 {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 1
            
            if likeCount < 1_000_000 {
                return "You and **\(numberFormatter.string(from: NSNumber(value: likeCount - 1)) ?? String(likeCount - 1))M** other people"
            } else {
                let major = Double(likeCount - 1) / Double(1_000_000)
                if let numStr = numberFormatter.string(from: NSNumber(value: major)){
                    return "You and **\(numStr)M** other people"
                } else {
                    return "You and **\(likeCount - 1)** other people"
                }
            }
        }  else if likeCount == 2 {
            return "You and **\(1)** other person"
        } else {
            return "Only **you** like this DJ"
        }
    }

    func dislike(dj: UserData, by user: UserData) {
        API.unlike(dj: dj, by: user) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success():
                if let index = likedDJs.firstIndex(where: { $0.dj == dj }) {
                    DispatchQueue.main.async {
                        self.likedDJs.remove(at: index)
                    }
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self.error = failure
                }
            }
        }
    }
}
