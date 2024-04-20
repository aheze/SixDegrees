//
//  Networking.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Foundation

enum NetworkingError: Error {
    case couldNotGetString
}

enum Networking {
    static let baseURL = URL(string: "http://146.190.167.1")!

    static func uploadContactsDictionary(ownPhoneNumber: String, ownName: String, contactsDictionary: [String: ContactMetadata]) async throws {
        let dump = ContactDump(
            ownPhoneNumber: ownPhoneNumber,
            ownName: ownName,
            contactsDictionary: contactsDictionary
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(dump)

        guard let string = String(data: data, encoding: .utf8) else {
            throw NetworkingError.couldNotGetString
        }
        
//        print(string)

        var request = URLRequest(url: baseURL.appendingPathComponent("/user/signup"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        
        let (responseData, response) = try await URLSession.shared.data(for: request)

        print("responseData: \(responseData), response: \(response)")

        // handle responseData and response
    }
}

