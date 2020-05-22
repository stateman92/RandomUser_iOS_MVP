//
//  Protocols.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 19..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import Foundation

// MARK: - View needs to implement this.
protocol RandomUserViewProtocol {
    
    /// Will be called after it downloads data while previously it contains (locally) no data.
    func didRandomUsersAvailable()
    
    /// Will be called if the refresh (download new users with new seed value) starts.
    func willRandomUsersRefresh()
    
    /// Will be called if the paging is done (and can be more data requested).
    func didEndRandomUsersPaging()
    
    /// Will be called if any error occured while the requests.
    func didErrorOccuredWhileDownload(errorMessage: String)
}

// MARK: - Presenter needs to implement this.
protocol RandomUserPresenterProtocol {
    
    /// The so far fetched user data.
    var users: [User] { get set }
    
    /// If fetch is in progress, no more network request will be executed.
    var isFetchInProgress: Bool { get set }
    
    /// Returns the so far fetched data + number of users in a page.
    var currentMaxUsers: Int { get }
    
    /// Self-check, that actually distinct users are fetched.
    var numberOfDistinctNamedPeople: Int { get }
    
    func inject(_ delegate: RandomUserViewProtocol)
    
    /// Fetch some random users.
    func getRandomUsers()
    
    /// Fetch some more random users.
    func getMoreRandomUsers()
    
    /// Fetch some new random users.
    func refresh(withDelay: Double)
}

// MARK: - Service needs to implement this.
protocol RandomUserServiceProtocol {
    
    /// Download random users with the given parameters.
    /// - Parameters:
    ///   - page: the page that you want to download.
    ///   - results: the number of results in a page.
    ///   - seed: the API use this to give some data. For the same seed, it gives back the same results.
    ///   - completion: will be called after the data is ready in an array, or some error occured. Both parameters in the same time couldn't be `nil`.
    func getUsers(page: Int, results: Int, seed: String, completion: @escaping ([User]?, String?) -> ())
}

extension RandomUserServiceProtocol {
    
    /// The API URL (in `String`).
    /// - Note:
    /// The number in the `String` indicate the used version of the API.
    /// With `1.3` it works fine, but maybe a newer version would break the implementation.
    func getBaseApiUrl() -> String {
        return "https://randomuser.me/api/1.3/"
    }
}

