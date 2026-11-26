//
//  APIModels.swift
//  SecureNest
//
//  Created by Teenu  on 09/11/26.
//

import Foundation

// MARK: - API Decodable DTO (Consuming public free endpoint JSONPlaceholder)

struct RemoteSecurityAlertDTO: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
}
