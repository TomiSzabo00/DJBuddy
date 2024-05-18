//
//  API.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 28/10/2023.
//

import Foundation
import CoreLocation
import StripeCore
import StripePaymentSheet
import UIKit

extension HTTPURLResponse {
    var isSuccess: Bool {
        statusCode >= 200 && statusCode < 300
    }
}

extension URLSession {
    @discardableResult
    func fetchData(with request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.somethingWentWrong
            }

            if httpResponse.isSuccess {
                let token = httpResponse.allHeaderFields["user_token"] as? String
                API.setUserToken(token)
                return data
            } else {
                let errorData = try JSONDecoder().decode(CustomResponse.self, from: data)
                throw APIError(from: errorData)
            }
        } catch {
            throw error
        }
    }
}

struct CustomResponse: Decodable {
    let message: String
    let errorCode: Int

    private enum CodingKeys: CodingKey {
        case detail
    }

    private enum DetailKeys: String, CodingKey {
        case message
        case errorCode = "error_code"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let detailContainer = try container.nestedContainer(keyedBy: DetailKeys.self, forKey: .detail)
        message = try detailContainer.decode(String.self, forKey: .message)
        errorCode = try detailContainer.decode(Int.self, forKey: .errorCode)
    }
}

final class API {
    // MARK: Constants
//    static let apiAddress = "https://djbuddy.online/api"
    static let apiAddress = "http://127.0.0.1:9000/api"
    private static let apiWebSocketAddress = "wss://djbuddy.online"
    private static let eventWebSocketUrl = "\(apiWebSocketAddress)/ws/events"

    static private var userToken: String = ""

    static func setUserToken(_ value: String?) {
        guard let value else { return }
        userToken = value
    }

    static func getRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(API.userToken, forHTTPHeaderField: "user_token")
        return request
    }

    static func postRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.addValue(API.userToken, forHTTPHeaderField: "user_token")
        return request
    }

    static func putRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue(API.userToken, forHTTPHeaderField: "user_token")
        return request
    }

    // MARK: Login

    static func login(with email: String, password: String) async throws -> (user: UserData, token: String) {
        let url = URL(string: "\(apiAddress)/users/login")!

        var request = API.postRequest(url: url)

        let parameters: [String: Any] = [
            "email": email,
            "password": password,
            "auth_token": ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            throw error
        }

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            let responseObject = try JSONDecoder().decode(UserData_Database.self, from: data)
            return (UserData(decodable: responseObject), API.userToken)
        } catch {
            throw error
        }
    }

    static func login(with email: String, token: String) async throws -> UserData {
        let url = URL(string: "\(apiAddress)/users/login")!

        var request = API.postRequest(url: url)

        let parameters: [String: Any] = [
            "email": email,
            "password": "",
            "auth_token": token
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            throw error
        }

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            let responseObject = try JSONDecoder().decode(UserData_Database.self, from: data)
            return UserData(decodable: responseObject)
        } catch {
            throw error
        }
    }

    // MARK: Register

    static func register(email: String, password: String, firstName: String, lastName: String, artistName: String, type: String) async throws -> String {
        let url = URL(string: "\(apiAddress)/users/register")!

        var request = API.postRequest(url: url)

        let parameters: [String: Any] = [
            "username": artistName,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "type": type,
            "profilePicUrl": "",
            "password_string": password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            throw error
        }

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            return try JSONDecoder().decode(String.self, from: data)
        } catch {
            throw error
        }
    }

    // MARK: Verification

    static func verifyEmail(for userId: String, with code: String) async throws -> UserData {
        let url = URL(string: "\(apiAddress)/users/verify/\(userId)/with/\(code)")!
        let request = API.postRequest(url: url)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            let responseObject = try JSONDecoder().decode(UserData_Database.self, from: data)
            return UserData(decodable: responseObject)
        } catch {
            throw error
        }
    }

    // MARK: User

    static func getUserData(_ user: UserData) async throws -> UserData {
        let url = URL(string: "\(apiAddress)/users")!
        let request = API.getRequest(url: url)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            let responseObject = try JSONDecoder().decode(UserData_Database.self, from: data)
            return UserData(decodable: responseObject)
        } catch {
            throw error
        }
    }

    static func addToUserBalance(amount: Double, user: UserData) async throws {
        let url = URL(string: "\(apiAddress)/users/balance/\(amount)")!
        let request = API.putRequest(url: url)

        try await URLSession.shared.fetchData(with: request)
    }

    static func removeFromUserBalance(amount: Double, user: UserData) async throws {
        let url = URL(string: "\(apiAddress)/users/balance/remove/\(amount)")!
        let request = API.putRequest(url: url)
        
        try await URLSession.shared.fetchData(with: request)
    }

    static func withdrawFromBalance(of user: UserData, amount: Double? = nil) async throws {
        var components = URLComponents(string: "\(apiAddress)/users/withdraw/")!

        if let amount {
            components.queryItems = [
                URLQueryItem(name: "amount", value: "\(amount)")
            ]
        }

        let request = API.putRequest(url: components.url!)
        try await URLSession.shared.fetchData(with: request)
    }

    static func uploadProfilePic(for user: UserData, image: UIImage) async throws {
        let url = URL(string: "\(apiAddress)/users/profile_pic/upload")!
        var request = API.putRequest(url: url)

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Append the image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"pic\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(image.jpegData(compressionQuality: 1.0)!)
        body.append("\r\n".data(using: .utf8)!)

        // Finish with the boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        try await URLSession.shared.fetchData(with: request)
    }

    static func isDJLikedByUser(dj: UserData, user: UserData) async throws -> Bool {
        let url = URL(string: "\(apiAddress)/users/likes/\(dj.id)")!
        let request = API.getRequest(url: url)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            return try JSONDecoder().decode(Bool.self, from: data)
        } catch {
            throw error
        }
    }

    static func like(dj: UserData, by user: UserData) async throws {
        let url = URL(string: "\(apiAddress)/users/like/\(dj.id)")!
        let request = API.putRequest(url: url)

        try await URLSession.shared.fetchData(with: request)
    }

    static func unlike(dj: UserData, by user: UserData) async throws {
        let url = URL(string: "\(apiAddress)/users/unlike/\(dj.id)")!
        let request = API.putRequest(url: url)

        try await URLSession.shared.fetchData(with: request)
    }

    static func getAllLiked(by user: UserData) async throws -> [(dj: UserData, like: Int)] {
        let url = URL(string: "\(apiAddress)/users/likes")!
        let request = API.getRequest(url: url)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            let responseObject = try JSONDecoder().decode([LikedDJData].self, from: data)
            return responseObject.map { (dj: UserData(decodable: $0), like: $0.likeCount) }
        } catch {
            throw error
        }
    }

    // MARK: Events

    static func createEvent(_ event: EventData, by dj: UserData? = nil) async throws {
        let url = URL(string: "\(apiAddress)/events/create")!
        var request = API.postRequest(url: url)

        let parameters: [String: Any] = [
            "name": event.name,
            "dj_id": dj?.id ?? event.dj.id,
            "latitude": event.location.latitude,
            "longitude": event.location.longitude,
            "address_title": event.location.title,
            "address_subtitle": event.location.subtitle,
            "date": event.date.toIsoString(),
            "state": event.state.rawValue,
            "theme": event.theme?.rawValue ?? "none"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }

        try await URLSession.shared.fetchData(with: request)
    }

    static func getAllEvents(nearTo location: CLLocationCoordinate2D, maxDistance: Double? = nil) async throws -> [EventData] {
        var components = URLComponents(string: "\(apiAddress)/events/near_me/")!

        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(location.latitude)"),
            URLQueryItem(name: "longitude", value: "\(location.longitude)")
        ]

        if let maxDistance {
            components.queryItems?.append(
                URLQueryItem(name: "distance", value: "\(maxDistance)")
            )
        }

        let request = API.getRequest(url: components.url!)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            let responseObject = try JSONDecoder().decode([EventData_Database].self, from: data)
            return responseObject.map { EventData(decodable: $0) }
        } catch {
            throw error
        }
    }

    static func getEvents(for user: UserData) async throws -> [EventData] {
        let url = URL(string: "\(apiAddress)/users/events")!
        let request = API.getRequest(url: url)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            let responseObject = try JSONDecoder().decode([EventData_Database].self, from: data)
            return responseObject.map { EventData(decodable: $0) }
        } catch {
            throw error
        }
    }

    static func getEventTheme(for event: EventData) async throws -> SongTheme? {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/theme")!
        let request = API.getRequest(url: url)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            let responseObject = try JSONDecoder().decode(String.self, from: data)
            return SongTheme(rawValue: responseObject)
        } catch {
            throw error
        }
    }

    static func getEvent(id: String) async throws -> EventData {
        let url = URL(string: "\(apiAddress)/events/\(id)")!
        let request = API.getRequest(url: url)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            let responseObject = try JSONDecoder().decode(EventData_Database.self, from: data)
            return EventData(decodable: responseObject)
        } catch {
            throw error
        }
    }

    static func setEventTheme(to theme: SongTheme?, in event: EventData) async throws {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/theme/\(theme?.rawValue ?? "none")")!
        let request = API.postRequest(url: url)

        try await URLSession.shared.fetchData(with: request)
    }

    static func setEventState(to state: EventState, in event: EventData) async throws {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/state/\(state.rawValue)")!
        let request = API.postRequest(url: url)

        try await URLSession.shared.fetchData(with: request)
    }

    static func setEventPlaylist(to playlist: Playlist, in event: EventData) async throws {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/playlist/\(playlist.id)")!
        let request = API.putRequest(url: url)

        try await URLSession.shared.fetchData(with: request)
    }

    static func removeEventPlaylist(from event: EventData) async throws {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/remove_playlist")!
        let request = API.postRequest(url: url)

        try await URLSession.shared.fetchData(with: request)
    }

    static func getEventPlaylist(for event: EventData) async throws -> Playlist? {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/playlist")!
        let request = API.getRequest(url: url)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            return try JSONDecoder().decode(Playlist.self, from: data)
        }
    }

    static func joinEvent(_ event: EventData, user: UserData) async throws {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/join")!
        let request = API.putRequest(url: url)

        try await URLSession.shared.fetchData(with: request)
    }

    static func leaveEvent(_ event: EventData, user: UserData) async throws {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/leave")!
        let request = API.putRequest(url: url)

        try await URLSession.shared.fetchData(with: request)
    }

    static func getnumberOfJoined(to event: EventData) async throws -> Int {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/users/count")!
        let request = API.getRequest(url: url)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            return try JSONDecoder().decode(Int.self, from: data)
        } catch {
            throw error
        }
    }

    // MARK: Song

    static func requestSong(_ song: SongData, for event: EventData, by user: UserData) async throws -> Int {
        let url = URL(string: "\(apiAddress)/songs/request")!
        var request = API.postRequest(url: url)

        let parameters: [String: Any] = [
            "title": song.title,
            "artist": song.artist,
            "amount": song.amount,
            "albumArtUrl": song.albumArtUrl,
            "event_id": event.id
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            throw error
        }

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            let song = try JSONDecoder().decode(SongData.self, from: data)
            return song.id
        } catch {
            throw error
        }
    }

    static func increasePrice(of song: SongData, by amount: Double) async throws -> Double {
        let url = URL(string: "\(apiAddress)/songs/\(song.id)/amount/increase_by/\(amount)")!
        let request = API.putRequest(url: url)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            return try JSONDecoder().decode(Double.self, from: data)
        } catch {
            throw error
        }
    }

    static func removeSong(_ song: SongData) async throws {
        let url = URL(string: "\(apiAddress)/songs/\(song.id)/remove")!
        let request = API.postRequest(url: url)

        try await URLSession.shared.fetchData(with: request)
    }

    static func save(song: SongData, by user: UserData) async throws -> Int {
        let url = URL(string: "\(apiAddress)/users/save")!
        var request = API.postRequest(url: url)

        let parameters: [String: Any] = [
            "title": song.title,
            "artist": song.artist,
            "amount": song.amount,
            "albumArtUrl": song.albumArtUrl,
            "event_id": ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            throw error
        }

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            let song = try JSONDecoder().decode(SongData.self, from: data)
            return song.id
        } catch {
            throw error
        }
    }

    static func unsave(song: SongData, by user: UserData) async throws {
        let url = URL(string: "\(apiAddress)/users/unsave/\(song.id)")!
        let request = API.putRequest(url: url)

        try await URLSession.shared.fetchData(with: request)
    }

    static func getAllSavedSongs(by user: UserData) async throws -> [SongData] {
        let url = URL(string: "\(apiAddress)/users/saved_songs")!
        let request = API.getRequest(url: url)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            return try JSONDecoder().decode([SongData].self, from: data)
        } catch {
            throw error
        }
    }

    // MARK: WebSockets

    private static func connectToWebSocket(on urlString: String) -> URLSessionWebSocketTask? {
        guard let url = URL(string: urlString) else { return nil }
        let request = URLRequest(url: url)
        return URLSession.shared.webSocketTask(with: request)
    }

    static func connectToEventWebSocket(id: String, pathSuffix: String? = nil) -> URLSessionWebSocketTask? {
        var concreteUrl = "\(eventWebSocketUrl)/\(id)"
        if let pathSuffix {
            concreteUrl += "/\(pathSuffix)"
        }
        let task = connectToWebSocket(on: concreteUrl)
        return task
    }

    // MARK: Payment

    static func preparePayment(forAmount amount: Double) async throws -> PaymentSheet {
        var components = URLComponents(string: "\(apiAddress)/payment/create/")!
        components.queryItems = [
            URLQueryItem(name: "amount", value: "\(amount)")
        ]
        
        let request = API.getRequest(url: components.url!)

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            let response = try JSONDecoder().decode(PaymentResponse.self, from: data)

            STPAPIClient.shared.publishableKey = response.publishableKey

            // Create a PaymentSheet instance
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "DJBuddy, Inc."
            configuration.customer = .init(id: response.customer, ephemeralKeySecret: response.ephemeralKey)
            configuration.style = .alwaysDark
            configuration.defaultBillingDetails.address.country = "HU"

            var appearance = PaymentSheet.Appearance()
            appearance.cornerRadius = 12
            appearance.colors.primary = .systemRed
            appearance.colors.textSecondary = .white
            appearance.colors.componentText = .white
            appearance.colors.componentPlaceholderText = .white

            configuration.appearance = appearance

            return PaymentSheet(paymentIntentClientSecret: response.paymentIntent, configuration: configuration)
        } catch {
            throw error
        }
    }

    // MARK: Playlists

    static func createPlaylist(by user: UserData, name: String) async throws -> Int {
        let url = URL(string: "\(apiAddress)/playlists/create")!
        var request = API.postRequest(url: url)

        let parameters: [String: Any] = [
            "name": name,
            "user_id": user.id
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            throw error
        }

        do {
            let data = try await URLSession.shared.fetchData(with: request)
            return try JSONDecoder().decode(Int.self, from: data)
        } catch {
            throw error
        }
    }

    static func deletePlaylist(id: Int) async throws {
        let url = URL(string: "\(apiAddress)/playlists/\(id)/remove")!
        let request = API.postRequest(url: url)

        try await URLSession.shared.fetchData(with: request)
    }

    static func addSong(to playlist: Playlist, song: SongData, completion: @escaping (Result<Void, APIError>) -> Void) {
//        let url = URL(string: "\(apiAddress)/playlists/\(playlist.id)/add_song")!
//
//        var request = URLRequest(url: url)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//
//        let parameters: [String: Any] = [
//            "title": song.title,
//            "artist": song.artist,
//            "amount": 0,
//            "albumArtUrl": song.albumArtUrl,
//            "event_id": ""
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//        } catch let error {
//            print(error.localizedDescription)
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { _, _, error in
//            guard error == nil
//            else {
//                if let error {
//                    if (error as NSError).code == -1004 {
//                        DispatchQueue.main.async {
//                            completion(.failure(.unreachable))
//                        }
//                    } else {
//                        let msg = decodeCustomResponse(from: error)
//                        DispatchQueue.main.async {
//                            completion(.failure(.general(desc: msg)))
//                        }
//                    }
//                } else {
//                    print("Error occured but it is nil")
//                }
//                return
//            }
//
//            DispatchQueue.main.async {
//                completion(.success(()))
//            }
//        }
//
//        task.resume()
    }

    static func removeSong(from playlist: Playlist, song: SongData, completion: @escaping (Result<Void, APIError>) -> Void) {
//        let url = URL(string: "\(apiAddress)/playlists/\(playlist.id)/remove_song/\(song.id)")!
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let task = URLSession.shared.dataTask(with: request) { _, _, error in
//            guard error == nil
//            else {
//                if let error {
//                    if (error as NSError).code == -1004 {
//                        DispatchQueue.main.async {
//                            completion(.failure(.unreachable))
//                        }
//                    } else {
//                        let msg = decodeCustomResponse(from: error)
//                        DispatchQueue.main.async {
//                            completion(.failure(.general(desc: msg)))
//                        }
//                    }
//                } else {
//                    print("Error occured but it is nil")
//                }
//                return
//            }
//
//            DispatchQueue.main.async {
//                completion(.success(()))
//            }
//        }
//
//        task.resume()
    }

    static func getAllSongs(from playlist: Playlist, completion: @escaping (Result<[SongData], APIError>) -> Void) {
//        let url = URL(string: "\(apiAddress)/playlists/\(playlist.id)/songs")!
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        let task = URLSession.shared.dataTask(with: request) { data, _, error in
//            guard let data, error == nil
//            else {
//                if let error {
//                    if (error as NSError).code == -1004 {
//                        DispatchQueue.main.async {
//                            completion(.failure(.unreachable))
//                        }
//                    } else {
//                        let msg = decodeCustomResponse(from: error)
//                        DispatchQueue.main.async {
//                            completion(.failure(.general(desc: msg)))
//                        }
//                    }
//                } else {
//                    print("Error occured but it is nil")
//                }
//                return
//            }
//
//            do {
//                let responseObject = try JSONDecoder().decode([SongData].self, from: data)
//                DispatchQueue.main.async {
//                    completion(.success(responseObject))
//                }
//            } catch {
//                print(error) // parsing error
//
//                if let responseString = String(data: data, encoding: .utf8) {
//                    print("responseString = \(responseString)")
//                    DispatchQueue.main.async {
//                        completion(.failure(.general(desc: responseString)))
//                    }
//                } else {
//                    print("unable to parse error response as string")
//                }
//            }
//        }
//
//        task.resume()
    }

    static func getAllPlaylists(of user: UserData, completion: @escaping (Result<[Playlist], APIError>) -> Void) {
//        let url = URL(string: "\(apiAddress)/users/playlists/\(user.id)")!
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        let task = URLSession.shared.dataTask(with: request) { data, _, error in
//            guard let data, error == nil
//            else {
//                if let error {
//                    if (error as NSError).code == -1004 {
//                        DispatchQueue.main.async {
//                            completion(.failure(.unreachable))
//                        }
//                    } else {
//                        let msg = decodeCustomResponse(from: error)
//                        DispatchQueue.main.async {
//                            completion(.failure(.general(desc: msg)))
//                        }
//                    }
//                } else {
//                    print("Error occured but it is nil")
//                }
//                return
//            }
//
//            do {
//                let responseObject = try JSONDecoder().decode([Playlist].self, from: data)
//                DispatchQueue.main.async {
//                    completion(.success(responseObject))
//                }
//            } catch {
//                print(error) // parsing error
//
//                if let responseString = String(data: data, encoding: .utf8) {
//                    print("responseString = \(responseString)")
//                    DispatchQueue.main.async {
//                        completion(.failure(.general(desc: responseString)))
//                    }
//                } else {
//                    print("unable to parse error response as string")
//                }
//            }
//        }
//
//        task.resume()
    }
}
