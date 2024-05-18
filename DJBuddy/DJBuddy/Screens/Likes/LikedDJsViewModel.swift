//
//  LikedDJsViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 05/03/2024.
//

import Foundation

final class LikedDJsViewModel: ObservableObject {
    @Published private(set) var likedDJs: [(dj: UserData, likeText: String)] = []

    @MainActor
    func getLikedDjs(for user: UserData) async throws {
        do {
            let likedData = try await API.getAllLiked(by: user)
            likedDJs = likedData.map {
                (dj: $0.dj, likeText: transformLikeCount(from: $0.like))
            }
        } catch {
            throw error
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

    @MainActor
    func dislike(dj: UserData, by user: UserData) async throws {
        do {
            try await API.unlike(dj: dj, by: user)
            if let index = likedDJs.firstIndex(where: { $0.dj == dj }) {
                likedDJs.remove(at: index)
            }
        } catch {
            throw error
        }
    }
}
