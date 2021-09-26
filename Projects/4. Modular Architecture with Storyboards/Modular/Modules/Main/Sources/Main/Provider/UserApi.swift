//
//  UserApi.swift
//  Modular
//
//  Created by Enoxus on 16.01.2021.
//

import Moya
import Foundation

public enum UserApi {
    case all
}

extension UserApi: TargetType {
    public var baseURL: URL {
        URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    public var path: String {
        switch self {
        case .all:
            return "/users"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .all:
            return .get
        }
    }
    
    public var sampleData: Data {
        Data()
    }
    
    public var task: Task {
        switch self {
        case .all:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        nil
    }
}

