//
//  UserDetailViewModel.swift
//  Modular
//
//  Created by Enoxus on 16.01.2021.
//

import Foundation
import RxSwift
import RxRelay
import Models

struct UserDetailViewModel {
    let name = BehaviorRelay<String>(value: "")
    let username = BehaviorRelay<String>(value: "")
    let email = BehaviorRelay<String>(value: "")
    let city = BehaviorRelay<String>(value: "")
    let company = BehaviorRelay<String>(value: "")
    
    func accept(_ data: UserViewData) {
        name.accept(data.name)
        username.accept(data.username)
        email.accept(data.email)
        city.accept(data.address)
        company.accept(data.company)
    }
}

