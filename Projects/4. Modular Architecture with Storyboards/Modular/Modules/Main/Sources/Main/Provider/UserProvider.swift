//
//  UserProvider.swift
//  Modular
//
//  Created by Enoxus on 16.01.2021.
//

import Moya
import Foundation
import Models

public protocol UserProviderProtocol {
    func getUsers(completion: @escaping ([User]?) -> Void)
}

public struct UserProvider: UserProviderProtocol {
    private let provider = MoyaProvider<UserApi>()
    
    public init() {}
    
    public func getUsers(completion: @escaping ([User]?) -> Void) {
        provider.request(.all) { result in
            if case let .success(response) = result {
                do {
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode([User].self, from: response.data)
                    completion(decoded)
                }
                catch {
                    completion(nil)
                }
            }
            else {
                completion(nil)
            }
        }
    }
}
