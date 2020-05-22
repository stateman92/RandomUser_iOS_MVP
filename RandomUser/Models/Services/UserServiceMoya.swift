//
//  UserServiceMoya.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 15..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import Foundation
import Moya

enum MoyaEnums {
    case randomUsers(page: Int, results: Int, seed: String)
}

// MARK: - TargetType implementation.
extension MoyaEnums: TargetType {
    var path: String {
        switch self {
        case .randomUsers: return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .randomUsers: return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .randomUsers:
            guard let url = Bundle.main.url(forResource: "sample", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        }
    }
    
    var task: Task {
        switch self {
        case .randomUsers(let page, let results, let seed):
            return .requestParameters(parameters: [
                "inc" : "name,picture,gender,location,email,phone,cell",
                "page" : String(page),
                "results" : String(results),
                "seed" : seed
            ], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        nil
    }
    
    var baseURL: URL { return URL(string: "https://randomuser.me/api/1.3")! }
}

// MARK: - Helpers.
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}

class UserServiceMoya: RandomUserServiceProtocol {
    
    func getUsers(page: Int, results: Int, seed: String, completion: @escaping ([User]?, String?) -> ()) {
        // If you want to debug, use this:
        // let provider = MoyaProvider<MoyaEnums>(plugins: [NetworkLoggerPlugin()])
        let provider = MoyaProvider<MoyaEnums>()
        provider.request(.randomUsers(page: page, results: results, seed: seed)) { result in
            do {
                switch result {
                case let .success(moyaResponse):
                    let userResult = try JSONDecoder().decode(UserResult.self, from: moyaResponse.data)
                    completion(userResult.results, nil)
                case let .failure(error):
                    completion(nil, error.localizedDescription)
                }
            } catch let error {
                completion(nil, error.localizedDescription)
            }
        }
    }
}
