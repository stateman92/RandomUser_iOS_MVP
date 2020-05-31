//
//  UserService.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 31..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import Foundation

// MARK: - A class that manages the network communication dependencies.
class ApiServiceBase {
    
    /// This class currently supports the 2 major HTTP communication external libraries.
    enum USType {
        case alamofire
        case moya
    }
    
    private let service: ApiServiceProtocol
    
    init(_ usType: USType) {
        switch usType {
        case .alamofire:
            service = ApiServiceAlamofire()
        case .moya:
            service = ApiServiceAlamofire()
        }
    }
}


// MARK: - Implement the delegate pattern.
/// Delegate all of the `RandomUserServiceProtocol` methods to the `service` property.
extension ApiServiceBase: ApiServiceContainerProtocol {
    
    func getBaseApiUrl() -> String {
         return "https://randomuser.me/api/1.3/"
    }
    
    func getUsers(page: Int, results: Int, seed: String, completion: @escaping (Result<[User], ErrorTypes>) -> ()) {
        service.getUsers(page: page, results: results, seed: seed) { result in
            completion(result)
        }
    }
}
