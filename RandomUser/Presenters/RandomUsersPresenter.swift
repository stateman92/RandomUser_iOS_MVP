//
//  RandomUsersPresenter.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 12..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import Foundation

// MARK: - The main Presenter base part.
class RandomUsersPresenter {
    
    /// MVP architecture elements.
    private var randomUserProtocol: RandomUserViewProtocol?
    private var apiServiceContainer: ApiServiceContainerProtocol
    private var persistenceServiceContainer: PersistenceServiceContainerProtocol
    
    /// Dependency Injection via Constructor Injection.
    init(_ apiServiceType: ApiServiceContainer.USType = .alamofire, _ persistenceServiceType: PersistenceServiceContainer.PSType = .realm) {
        self.apiServiceContainer = ApiServiceContainer.init(apiServiceType)
        self.persistenceServiceContainer = PersistenceServiceContainer.init(persistenceServiceType)
    }
    
    /// Number of users that will be downloaded at the same time.
    private let numberOfUsersPerPage = 10
    /// The initial seed value. Changed after all refresh / restart.
    private var seed = String.getRandomString()
    /// Returns the number of the next page.
    private var nextPage: Int {
        return users.count / numberOfUsersPerPage + 1
    }
    
    /// `RandomUserPresenterProtocol` variables part.
    
    /// The so far fetched user data.
    var users = [User]()
    
    /// If fetch is in progress, no more network request will be executed.
    var isFetchInProgress = false
}

// MARK: The RandomUserPresenterProtocol part.
extension RandomUsersPresenter: RandomUserPresenterProtocol {
    
    /// Returns the so far fetched data + number of users in a page.
    /// - Note:
    /// If the number of the displayed user is greater or equal with the `users.count` but less than the `currentMaxUsers`,
    ///     the View can display a loading icon.
    var currentMaxUsers: Int {
        return nextPage * numberOfUsersPerPage
    }
    
    /// Self-check, that actually distinct users are fetched.
    /// - Note:
    /// Can be used to display somewhere.
    var numberOfDistinctNamedPeople: Int {
        Set(users.map { user -> String in
            user.fullName
        }).count
    }
    
    /// Dependency Injection via Setter Injection.
    func inject(_ randomUserProtocol: RandomUserViewProtocol) {
        self.randomUserProtocol = randomUserProtocol
    }
    
    /// Dependency Injection via Setter Injection.
    func inject(_ apiServiceContainer: ApiServiceContainerProtocol) {
        self.apiServiceContainer = apiServiceContainer
    }
    
    /// Dependency Injection via Setter Injection.
    func inject(_ persistenceServiceContainer: PersistenceServiceContainerProtocol) {
        self.persistenceServiceContainer = persistenceServiceContainer
    }
    
    /// Fetch some random users.
    /// - Note:
    /// It calls either `randomUsersAvailable()` or `errorWhileDownload()` method of the `delegate`.
    /// The `isFetchInProgress` variable should be set to false by the View after all the data displayed corretly!
    func getRandomUsers() {
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        
        apiServiceContainer.getUsers(page: nextPage, results: numberOfUsersPerPage, seed: seed) { result in
            switch result {
            case .success(let users):
                self.users = users
                self.randomUserProtocol?.didRandomUsersAvailable()
            case .failure(let errorType):
                self.randomUserProtocol?.didErrorOccuredWhileDownload(errorMessage: errorType.rawValue)
            }
        }
    }
    
    /// Fetch some more random users.
    /// - Note:
    /// If a fetch is in progress, does nothing.
    /// Otherwise it downloads some more users.
    func getMoreRandomUsers() {
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        
        apiServiceContainer.getUsers(page: nextPage, results: numberOfUsersPerPage, seed: seed) { result in
            defer {
                self.isFetchInProgress = false
            }
            
            switch result {
            case .success(let users):
                self.users.append(contentsOf: users)
                self.persistenceServiceContainer.deleteAndAdd(UserObject.self, users)
                self.randomUserProtocol?.didEndRandomUsersPaging()
            case .failure(let errorType):
                self.randomUserProtocol?.didErrorOccuredWhileDownload(errorMessage: errorType.rawValue)
            }
        }
    }
    
    /// Fetch some new random users.
    /// - Note:
    /// Remove all so far downloaded data, recreate the seed value.
    /// Immediately calls the `randomUsersRefreshStarted()` method of the `delegate`.
    /// - Parameters:
    ///   - withDelay: the duration after the fetch starts.
    func refresh(withDelay delay: Double = 0) {
        users.removeAll()
        seed = String.getRandomString()
        randomUserProtocol?.willRandomUsersRefresh()
        run(delay) {
            self.getRandomUsers()
        }
    }
    
    /// Retrieve the previously cached users.
    func getCachedUsers() {
        run(1.0) {
            defer {
                self.randomUserProtocol?.didRandomUsersAvailable()
            }
            
            let users = self.persistenceServiceContainer.objects(UserObject.self)
            for user in users {
                self.users.append(User(managedObject: user))
            }
        }
    }
}
