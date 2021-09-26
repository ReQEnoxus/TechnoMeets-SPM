//
//  MainViewModel.swift
//  Modular
//
//  Created by Enoxus on 16.01.2021.
//

import RxRelay
import Moya
import Models

typealias Users = [UserViewData]

struct MainViewModel {
    let users = BehaviorRelay<Users>(value: [])
    
    private let provider: UserProviderProtocol = UserProvider()
    
    func loadUsers() {
        provider.getUsers { response in
            guard let response = response else { return }
            users.accept(UserViewData.transform(response))
        }
    }
}
