//
//  Protocols.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 19..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - MVP architecture's elements.



// MARK: - View part.
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

// MARK: - Presenter part.
protocol RandomUserPresenterProtocol {
    
    /// The so far fetched user data.
    var users: [User] { get set }
    
    /// If fetch is in progress, no more network request will be executed.
    var isFetchInProgress: Bool { get set }
    
    /// Returns the so far fetched data + number of users in a page.
    var currentMaxUsers: Int { get }
    
    /// Self-check, that actually distinct users are fetched.
    var numberOfDistinctNamedPeople: Int { get }
    
    /// Dependency Injection via Setter Injection.
    func inject(_ delegate: RandomUserViewProtocol)
    func inject(_ apiServiceContainer: ApiServiceContainerProtocol)
    func inject(_ persistenceServiceContainer: PersistenceServiceContainerProtocol) 
    
    /// Fetch some random users.
    func getRandomUsers()
    
    /// Fetch some more random users.
    func getMoreRandomUsers()
    
    /// Fetch some new random users.
    func refresh(withDelay: Double)
    
    /// Retrieve the previously cached users.
    func getCachedUsers()
}
