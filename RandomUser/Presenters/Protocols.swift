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
    
    func inject(_ delegate: RandomUserViewProtocol)
    
    /// Fetch some random users.
    func getRandomUsers()
    
    /// Fetch some more random users.
    func getMoreRandomUsers()
    
    /// Fetch some new random users.
    func refresh(withDelay: Double)
}

// MARK: - Service parts.



// MARK: - ApiService part.



// MARK: - ApiService Container part.
protocol ApiServiceContainerProtocol {
    
    /// Download random users with the given parameters.
    /// - Parameters:
    ///   - page: the page that you want to download.
    ///   - results: the number of results in a page.
    ///   - seed: the API use this to give some data. For the same seed, it gives back the same results.
    ///   - completion: will be called after the data is ready in an array, or some error occured. Both parameters in the same time couldn't be `nil`.
    func getUsers(page: Int, results: Int, seed: String, completion: @escaping (Result<[User], ErrorTypes>) -> ())
    
    /// The API URL (in `String`).
    /// - Note:
    /// The number in the `String` indicate the used version of the API.
    /// With `1.3` it works fine, but maybe a newer version would break the implementation.
    func getBaseApiUrl() -> String
}

// MARK: - ApiService part.
protocol ApiServiceProtocol {
    
    /// Download random users with the given parameters.
    /// - Parameters:
    ///   - page: the page that you want to download.
    ///   - results: the number of results in a page.
    ///   - seed: the API use this to give some data. For the same seed, it gives back the same results.
    ///   - completion: will be called after the data is ready in an array, or some error occured. Both parameters in the same time couldn't be `nil`.
    func getUsers(page: Int, results: Int, seed: String, completion: @escaping (Result<[User], ErrorTypes>) -> ())
}

// MARK: - ImageService part.



// MARK: - ImageService Container part.
protocol ImageServiceContainerProtocol {
    
    /// Load an url into the image.
    /// - Parameters:
    ///   - urlString: the url in string format of the image.
    ///   - imageView: the `UIImageView` that will hold the image.
    ///   - withDelay: seconds, after the image loading will start.
    ///   - isLoadingPresenting: whether it shows a loading animation before it loaded.
    ///   - completionHandler: will be called after the image loaded.
    func load(url urlString: String, into imageView: UIImageView, withDelay delay: Double, isLoadingPresenting loading: Bool, completionHandler: @escaping () -> Void)
}
extension ImageServiceContainerProtocol {
    
    func load(url urlString: String, into imageView: UIImageView, withDelay delay: Double = 0.0, isLoadingPresenting loading: Bool = false, completionHandler: @escaping () -> Void = { }) {
        load(url: urlString, into: imageView, withDelay: delay, isLoadingPresenting: loading, completionHandler: completionHandler)
    }
}

// MARK: - ImageService part.
protocol ImageServiceProtocol {
    
    /// Load an url into the image.
    /// - Parameters:
    ///   - urlString: the url in string format of the image.
    ///   - imageView: the `UIImageView` that will hold the image.
    ///   - completionHandler: will be called after the image loaded.
    func load(url: URL, into imageView: UIImageView, completionHandler: @escaping () -> ())
}

// MARK: - PersistenceService part.


// MARK: - PersistenceService Container part.
protocol PersistenceServiceContainerProtocol {
    
    func add<T: Persistable>(_ value: T)
    
    func add<T : Sequence>(_ sequence: T) where T.Element: Persistable
    
    func delete<Element: Object>(_ objects: Results<Element>)
}

// MARK: - PersistenceService part.
protocol PersistenceServiceProtocol {
    
}

// MARK: - Pardonable structs conform.
public protocol Persistable {
    associatedtype ManagedObject: Object
    
    /// Create the `struct` based on the `Object` from the database.
    init(managedObject: ManagedObject)
    
    /// Create the `Object` that will be stored in the database based on the `stuct`.
    func managedObject() -> ManagedObject
}
