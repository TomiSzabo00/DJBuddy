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

struct CustomResponse: Decodable {
    let detail: String
}

final class API {
    // MARK: Constants
    private static let apiAddress = "http://127.0.0.1:9000"
    private static let apiWebSocketAddress = "ws://127.0.0.1:9000"
    private static let eventWebSocketUrl = "\(apiWebSocketAddress)/ws/events"

    // MARK: Login
    static func login(with email: String, and password: String, completion: @escaping (Result<UserData, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/users/login")!

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            guard response.statusCode == 200 else {
                print("Got a response, but it wasn't 200 OK")
                print("Response: \(response.statusCode)")
                if response.statusCode == 401 {
                    DispatchQueue.main.async {
                        completion(.failure(.wrongEmailOrPassword))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.general(desc: response.debugDescription)))
                    }
                }
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(UserData_Database.self, from: data)
                let userData = UserData(decodable: responseObject)
                DispatchQueue.main.async {
                    completion(.success(userData))
                }
            } catch {
                print(error) // parsing error

                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                    DispatchQueue.main.async {
                        completion(.failure(.general(desc: responseString)))
                    }
                } else {
                    print("unable to parse error response as string")
                }
            }
        }

        task.resume()
    }

    // MARK: Register
    static func register(email: String, password: String, firstName: String, lastName: String, artistName: String, type: String, completion: @escaping (Result<UserData, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/users/register")!

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

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
        } catch let error {
            print(error.localizedDescription)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            guard response.statusCode == 201 else {
                print("Got a response, but it wasn't 201 CREATED")
                print("Response: \(response.statusCode)")
                if response.statusCode == 401 {
                    DispatchQueue.main.async {
                        completion(.failure(.wrongEmailOrPassword))
                    }
                } else if response.statusCode == 400 {
                    DispatchQueue.main.async {
                        completion(.failure(.userAlreadyExists))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.general(desc: response.debugDescription)))
                    }
                }
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(UserData_Database.self, from: data)
                let userData = UserData(decodable: responseObject)
                DispatchQueue.main.async {
                    completion(.success(userData))
                }
            } catch {
                print(error) // parsing error

                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                    DispatchQueue.main.async {
                        completion(.failure(.general(desc: responseString)))
                    }
                } else {
                    print("unable to parse error response as string")
                }
            }
        }

        task.resume()
    }

    // MARK: User

    static func getUserData(_ user: UserData, completion: @escaping (Result<UserData, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/users/\(user.id)")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard
                let data = data,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(UserData_Database.self, from: data)
                let user = UserData(decodable: responseObject)
                DispatchQueue.main.async {
                    completion(.success(user))
                }
            } catch {
                print(error) // parsing error

                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                    DispatchQueue.main.async {
                        completion(.failure(.general(desc: responseString)))
                    }
                } else {
                    print("unable to parse error response as string")
                }
            }
        }

        task.resume()
    }

    static func addToUserBalance(amount: Double, user: UserData, completion: @escaping (Result<Void, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/users/\(user.id)/balance/\(amount)")!

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let response = response as? HTTPURLResponse
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            guard response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: response.debugDescription)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }

        task.resume()
    }

    static func removeFromUserBalance(amount: Double, user: UserData, completion: @escaping (Result<Void, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/users/\(user.id)/balance/\(amount)/remove")!

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let response = response as? HTTPURLResponse
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            guard response.statusCode == 200 else {
                if let data {
                    do {
                        let responseObject = try JSONDecoder().decode(CustomResponse.self, from: data)
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: responseObject.detail)))
                        }
                        return
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: response.debugDescription)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }

        task.resume()
    }

    // MARK: Events

    static func createEvent(_ event: EventData, by dj: UserData? = nil, completion: @escaping (Result<Void, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/events/create")!

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

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

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard let response = response as? HTTPURLResponse,
                  error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                }
                return
            }

            guard response.statusCode == 201 else {
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: response.debugDescription)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }

        task.resume()
    }

    static func getAllEvents(limit: Int? = nil, completion: @escaping (Result<[EventData], APIError>) -> Void) {
        var components = URLComponents(string: "\(apiAddress)/events/all/")!

        if let limit {
            components.queryItems = [
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        }

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"


        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            guard response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: response.debugDescription)))
                }
                return
            }

            do {
                let responseObject = try JSONDecoder().decode([EventData_Database].self, from: data)
                let events = responseObject.map { EventData(decodable: $0) }
                DispatchQueue.main.async {
                    completion(.success(events))
                }
            } catch {
                print(error) // parsing error

                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                    DispatchQueue.main.async {
                        completion(.failure(.general(desc: responseString)))
                    }
                } else {
                    print("unable to parse error response as string")
                }
            }
        }

        task.resume()
    }

    static func getAllEvents(nearTo location: CLLocationCoordinate2D, maxDistance: Double? = nil, completion: @escaping (Result<[EventData], APIError>) -> Void) {
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

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"


        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            guard response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: response.debugDescription)))
                }
                return
            }

            do {
                let responseObject = try JSONDecoder().decode([EventData_Database].self, from: data)
                let events = responseObject.map { EventData(decodable: $0) }
                DispatchQueue.main.async {
                    completion(.success(events))
                }
            } catch {
                print(error) // parsing error

                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                    DispatchQueue.main.async {
                        completion(.failure(.general(desc: responseString)))
                    }
                } else {
                    print("unable to parse error response as string")
                }
            }
        }

        task.resume()
    }

    static func getEvents(from user: UserData, completion: @escaping (Result<[EventData], APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/users/\(user.id)/events")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard
                let data = data,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            do {
                let responseObject = try JSONDecoder().decode([EventData_Database].self, from: data)
                let events = responseObject.map { EventData(decodable: $0) }
                DispatchQueue.main.async {
                    completion(.success(events))
                }
            } catch {
                print(error) // parsing error

                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                    DispatchQueue.main.async {
                        completion(.failure(.general(desc: responseString)))
                    }
                } else {
                    print("unable to parse error response as string")
                }
            }
        }

        task.resume()
    }

    static func getEventsAsync(from user: UserData) async -> [EventData] {
        let url = URL(string: "\(apiAddress)/users/\(user.id)/events")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let responseObject = try JSONDecoder().decode([EventData_Database].self, from: data)
            let events = responseObject.map { EventData(decodable: $0) }
            return events
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    static func getEventTheme(for event: EventData, completion: @escaping (Result<SongTheme?, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/theme")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard
                let data = data,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(String.self, from: data)
                let theme = SongTheme(rawValue: responseObject)
                DispatchQueue.main.async {
                    completion(.success(theme))
                }
            } catch {
                print(error) // parsing error

                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                    DispatchQueue.main.async {
                        completion(.failure(.general(desc: responseString)))
                    }
                } else {
                    print("unable to parse error response as string")
                }
            }
        }

        task.resume()
    }

    static func getEvent(id: String, completion: @escaping (Result<EventData, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/events/\(id)")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard
                let data = data,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(EventData_Database.self, from: data)
                let event = EventData(decodable: responseObject)
                DispatchQueue.main.async {
                    completion(.success(event))
                }
            } catch {
                print(error) // parsing error

                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                    DispatchQueue.main.async {
                        completion(.failure(.general(desc: responseString)))
                    }
                } else {
                    print("unable to parse error response as string")
                }
            }
        }

        task.resume()
    }

    static func setEventTheme(to theme: SongTheme?, in event: EventData, completion: @escaping (Result<Void, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/theme/\(theme?.rawValue ?? "none")")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            guard response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: response.debugDescription)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }

        task.resume()
    }

    static func setEventState(to state: EventState, in event: EventData, completion: @escaping (Result<Void, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/state/\(state.rawValue)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            guard response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: response.debugDescription)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }

        task.resume()
    }

    static func joinEvent(_ event: EventData, user: UserData, completion: @escaping (Result<Void, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/join/\(user.id)")!

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            guard response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: response.debugDescription)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }

        task.resume()
    }

    static func leaveEvent(_ event: EventData, user: UserData, completion: @escaping (Result<Void, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/events/\(event.id)/leave/\(user.id)")!

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            guard response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: response.debugDescription)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }

        task.resume()
    }

    // MARK: Song functions

    static func requestSong(_ song: SongData, for event: EventData, completion: @escaping (Result<Int, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/songs")!

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        let parameters: [String: Any] = [
            "title": song.title,
            "artist": song.artist,
            "amount": song.amount,
            "albumArtUrl": song.albumArtUrl,
            "event_id": event.id
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data,
                  let response = response as? HTTPURLResponse,
                  error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                }
                return
            }

            guard response.statusCode == 201 else {
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: response.debugDescription)))
                }
                return
            }
            
            do {
                let song = try JSONDecoder().decode(SongData.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(song.id))
                }
            } catch {
                print(error) // parsing error

                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                    DispatchQueue.main.async {
                        completion(.failure(.general(desc: responseString)))
                    }
                } else {
                    print("unable to parse error response as string")
                }
            }
        }

        task.resume()
    }

    static func increasePrice(of song: SongData, by amount: Double, completion: @escaping (Result<Double, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/songs/\(song.id)/amount/increase_by/\(amount)")!

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard
                let data = data,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            do {
                let newAmount = try JSONDecoder().decode(Double.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(newAmount))
                }
            } catch {
                print(error) // parsing error

                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                    DispatchQueue.main.async {
                        completion(.failure(.general(desc: responseString)))
                    }
                } else {
                    print("unable to parse error response as string")
                }
            }
        }

        task.resume()
    }

    static func removeSong(_ song: SongData, completion: @escaping (Result<Void, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/songs/\(song.id)/remove")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.general(desc: error.localizedDescription)))
                        }
                    }
                } else {
                    print("Error occured but it is nil")
                }
                return
            }

            guard response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: response.debugDescription)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }

        task.resume()
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

    static func preparePayment(forAmount amount: Double, completion: @escaping (Result<PaymentSheet, APIError>) -> Void) {
        var components = URLComponents(string: "\(apiAddress)/payment/create/")!

        components.queryItems = [
            URLQueryItem(name: "amount", value: "\(amount)")
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data, error == nil
            else {
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: error!.localizedDescription)))
                }
                return
            }

            do {
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

                let paymentSheet = PaymentSheet(paymentIntentClientSecret: response.paymentIntent, configuration: configuration)
                DispatchQueue.main.async {
                    completion(.success(paymentSheet))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.general(desc: error.localizedDescription)))
                    print(String.init(data: data, encoding: .utf8) ?? "")
                }
            }
        }

        task.resume()
    }
}
