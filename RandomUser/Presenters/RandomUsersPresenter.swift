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
    private weak var randomUserProtocol: RandomUserViewProtocol?
    private var apiService: ApiServiceProtocol
    private var persistenceService: PersistenceServiceProtocol
    
    /// Dependency Injection via Constructor Injection.
    init(_ apiServiceType: ApiServiceContainer.USType = .alamofire, _ persistenceServiceType: PersistenceServiceContainer.PSType = .realm) {
        self.apiService = ApiServiceContainer.init(apiServiceType).service
        self.persistenceService = PersistenceServiceContainer.init(persistenceServiceType).service
    }
    
    /// Number of users that will be downloaded at the same time.
    private let numberOfUsersPerPage = 10
    /// The initial seed value. Changed after all refresh / restart.
    private var seed = String.getRandomString()
    /// Returns the number of the next page.
    private var nextPage: Int {
        return users.count / numberOfUsersPerPage + 1
    }
    /// If fetch is in progress, no more network request will be executed.
    private var isFetchInProgress = false
    
    /// `RandomUserPresenterProtocol` variables part.
    
    /// The so far fetched user data.
    var users = [User]()
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
    func inject(_ apiService: ApiServiceProtocol) {
        self.apiService = apiService
    }
    
    /// Dependency Injection via Setter Injection.
    func inject(_ persistenceService: PersistenceServiceProtocol) {
        self.persistenceService = persistenceService
    }
    
    /// Fetch some random users.
    /// - Note:
    /// It calls either `randomUsersAvailable()` or `errorWhileDownload()` method of the `delegate`.
    func getRandomUsers() {
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        
        apiService.getUsers(page: nextPage, results: numberOfUsersPerPage, seed: seed) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let users):
                self.users = users
                self.randomUserProtocol?.didRandomUsersAvailable {
                    self.isFetchInProgress = false
                }
            case .failure(let errorType):
                self.randomUserProtocol?.didErrorOccuredWhileDownload(errorMessage: errorType.rawValue)
                self.isFetchInProgress = false
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
        
        apiService.getUsers(page: nextPage, results: numberOfUsersPerPage, seed: seed) { [weak self] result in
            guard let self = self else { return }
            defer {
                self.isFetchInProgress = false
            }
            
            switch result {
            case .success(let users):
                self.users.append(contentsOf: users)
                self.persistenceService.deleteAndAdd(UserObject.self, self.users)
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
        persistenceService.deleteAndAdd(UserObject.self, [User]())
        seed = String.getRandomString()
        randomUserProtocol?.willRandomUsersRefresh()
        run(delay) { [weak self] in
            guard let self = self else { return }
            self.getRandomUsers()
        }
    }
    
    /// Retrieve the previously cached users.
    func getCachedUsers() {
        isFetchInProgress = true
        run(1.0) { [weak self] in
            guard let self = self else { return }
            let users = self.persistenceService.objects(UserObject.self)
            for user in users {
                self.users.append(User(managedObject: user))
            }
            if users.count == 0 {
                self.isFetchInProgress = false
                self.getRandomUsers()
            } else {
                self.randomUserProtocol?.didRandomUsersAvailable {
                    self.isFetchInProgress = false
                }
            }
        }
    }
}
