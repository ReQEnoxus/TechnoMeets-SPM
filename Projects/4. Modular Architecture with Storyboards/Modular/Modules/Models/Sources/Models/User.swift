//
//  User.swift
//  Modular
//
//  Created by Enoxus on 16.01.2021.
//

import Foundation

public struct User: Codable {
    public let name: String
    public let username: String
    public let email: String
    public let address: Address
    public let company: Company
}

public struct Address: Codable {
    public let city: String
}

public struct Company: Codable {
    public let name: String
}
