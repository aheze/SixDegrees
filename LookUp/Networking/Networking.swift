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
    static let baseURL = URL(string: "http://146.190.167.1:3000/")!
    
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
        
        print(string)
        
//        let url = baseURL.appending(path: <#T##StringProtocol#>)
//        var request = URLRequest(url: "http://146.190.167.1:3000/")
//        request.httpMethod = "POST"
//        
//        let (responseData, response) = try await session.upload(
//            for: request,
//            from: data
//        )
    }
}
