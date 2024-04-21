//
//  Networking.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

enum NetworkingError: Error, LocalizedError {
    case couldNotGetString
    case errorCode(Int)
    
    var errorDescription: String? {
        switch self {
        case .couldNotGetString:
            return "couldNotGetString"
        case .errorCode(let int):
            return "error \(int)"
        }
    }
}

enum Networking {
    static let baseURL = URL(string: "http://146.190.167.1:80")!

    static func uploadContactsDictionary(
        ownPhoneNumber: String,
        ownName: String,
        email: String,
        bio: String,
        insta: String,
        contactsDictionary: [String: ContactMetadata]
    ) async throws {
        let dump = ContactDump(
            ownPhoneNumber: ownPhoneNumber,
            ownName: ownName,
            email: email,
            bio: bio,
            links: [insta],
            contactsDictionary: contactsDictionary
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(dump)

        guard let string = String(data: data, encoding: .utf8) else {
            throw NetworkingError.couldNotGetString
        }
        
        print(string)

        var request = URLRequest(url: baseURL.appendingPathComponent("/user/signup"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (responseData, response) = try await URLSession.shared.data(for: request)

        print("responseData: \(responseData), response: \(response)")

        // handle responseData and response
    }
    
    static func getGraph(phoneNumber: String, targetDepth: Int) async throws -> Graph {
        let targetDepthString = "\(targetDepth)"
        
        var request = URLRequest(url: baseURL.appendingPathComponent("/graph/getGraph"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(GetGraphStruct(phoneNumber: phoneNumber, targetDepth: targetDepthString))
        request.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        let string = String(data: responseData, encoding: .utf8)
        
//        print("got: \(string)")
//        print("responseData: \(responseData).. response: \(response) -> \(string)")
        
        guard let r = response as? HTTPURLResponse, r.statusCode == 200 else {
            throw "Error: \(response)"
        }
        
        let decoder = JSONDecoder()
        let graph = try decoder.decode(GraphContainer.self, from: responseData)
        
//        print("graph: \(graph)")
        
        return graph.graph
    }
    
    static func getPath(source: String, destination: String) async throws -> [String] {
        var request = URLRequest(url: baseURL.appendingPathComponent("/graph/getPath"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(GetPathStruct(source: source, destination: destination))
        request.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let r = response as? HTTPURLResponse, r.statusCode == 200 else {
            throw "Error: \(response)"
        }
        
        let decoder = JSONDecoder()
        let path = try decoder.decode(PathContainer.self, from: responseData)
        
        return path.path
    }
    
    static func getAnalysis(phoneNumber: String) async throws -> Analysis? {
        var request = URLRequest(url: baseURL.appendingPathComponent("/user/getAnalysis"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(GetAnalysisStruct(phoneNumber: phoneNumber))
        request.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        let string = String(data: responseData, encoding: .utf8)
        print(string)
        
        guard let r = response as? HTTPURLResponse, r.statusCode == 200 else {
            throw "Error: \(response)"
        }
        
        let decoder = JSONDecoder()
        let analysis = try decoder.decode(AnalysisContainer.self, from: responseData)
        
        return analysis.analysis
    }
}

struct GetPathStruct: Codable {
    var source: String
    var destination: String
}

struct GetGraphStruct: Codable {
    var phoneNumber: String
    var targetDepth: String
}

struct GetAnalysisStruct: Codable {
    var phoneNumber: String
}

struct GraphContainer: Codable {
    var graph: Graph
}

struct PathContainer: Codable {
    var path: [String]
}

struct Analysis: Codable {
    var phoneNumber: String
    var bio: String
    var hobbies: [String]
}

struct AnalysisContainer: Codable {
    var analysis: Analysis?
    
    enum CodingKeys: String, CodingKey {
           case analysis
       }

       init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           // Check if the value is a string and equals "none"
           if let analysisString = try? container.decode(String.self, forKey: .analysis), analysisString == "none" {
               analysis = nil
           } else {
               // Try to decode Analysis object
               analysis = try? container.decode(Analysis.self, forKey: .analysis)
           }
       }
}
