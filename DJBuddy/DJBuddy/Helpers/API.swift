//
//  API.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 28/10/2023.
//

import Foundation

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

    // MARK: Get events
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
}
