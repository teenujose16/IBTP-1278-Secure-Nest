//
//  SecurityFeedService.swift
//  SecureNest
//
//  Created by Teenu  on 09/11/26.
//

import Foundation

protocol SecurityFeedServiceProtocol {
    func fetchRecentAlerts() async throws -> [RemoteSecurityAlertDTO]
}

final class SecurityFeedService: SecurityFeedServiceProtocol {
    private let urlSession: URLSession
    private let endpoint = URL(string: "https://jsonplaceholder.typicode.com/posts?_limit=10")!

    init(session: URLSession = .shared) {
        self.urlSession = session
    }

    func fetchRecentAlerts() async throws -> [RemoteSecurityAlertDTO] {
        let (data, response) = try await urlSession.data(from: endpoint)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([RemoteSecurityAlertDTO].self, from: data)
    }
}
