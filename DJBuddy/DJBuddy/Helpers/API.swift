//
//  API.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 28/10/2023.
//

import Foundation

final class API {
    private static let apiAddress = "http://127.0.0.1:9000"

    static func login(with email: String, and password: String, completion: @escaping (Result<UserData, APIError>) -> Void) {
        let url = URL(string: "\(apiAddress)/login")!
        
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
            else {                                                               // check for fundamental networking error
                if let error {
                    if (error as NSError).code == -1004 {
                        DispatchQueue.main.async {
                            completion(.failure(.unreachable))
                        }
                    } else {
                        print("Some unhandled error: \(error.localizedDescription)")
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
                }
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(UserData.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(responseObject))
                }
            } catch {
                print(error) // parsing error

                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                } else {
                    print("unable to parse error response as string")
                }
            }
        }

        task.resume()
    }
}
