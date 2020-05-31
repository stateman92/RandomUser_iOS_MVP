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
    /// - Note:
    /// Can be used to display somewhere. 
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

// MARK: - Service parts.



// MARK: - ApiService part.



// MARK: - ApiService Container part.
protocol ApiServiceContainerProtocol {
    
    /// Download random users with the given parameters.
    /// - Parameters:
    ///   - page: the page that wanted to be downloaded.
    ///   - results: the number of results in a page.
    ///   - seed: the API use this to give back some data. For the same seed it gives back the same results.
    ///   - completion: will be called after the data is ready in an array, or an error occured. Both parameters in the same time couldn't be `nil`.
    func getUsers(page: Int, results: Int, seed: String, completion: @escaping (Result<[User], ErrorTypes>) -> ())
    
    /// The API URL (in `String` format).
    static func getBaseApiUrl() -> String
}

// MARK: - ApiService part.
protocol ApiServiceProtocol {
    
    /// Download random users with the given parameters.
    /// - Parameters:
    ///   - page: the page that wanted to be downloaded.
    ///   - results: the number of results in a page.
    ///   - seed: the API use this to give back some data. For the same seed it gives back the same results.
    ///   - completion: will be called after the data is ready in an array, or an error occured. Both parameters in the same time couldn't be `nil`.
    func getUsers(page: Int, results: Int, seed: String, completion: @escaping (Result<[User], ErrorTypes>) -> ())
}

// MARK: - ImageService part.



// MARK: - ImageService Container part.
protocol ImageServiceContainerProtocol {
    
    /// Load an url into the image.
    /// - Parameters:
    ///   - url: the url in `String` format of the image.
    ///   - into: the `UIImageView` that will hold the image.
    ///   - withDelay: seconds, after the image loading will start.
    ///   - isLoadingPresenting: whether it shows a loading animation before it loaded.
    ///   - completionHandler: will be called after the image loaded.
    func load(url urlString: String, into imageView: UIImageView, withDelay delay: Double, isLoadingPresenting loading: Bool, completionHandler: @escaping () -> Void)
}
extension ImageServiceContainerProtocol {
    
    /// Load an url into the image. It's the customization of the `ImageServiceContainerProtocol`'s `load(url:into:withdelay:isloadingPresenting:completionHandler:)` method.
    /// - Parameters:
    ///   - withDelay: optional argument, by default it is 0.0.
    ///   - isLoadingPresenting: optional argument, by default it is false.
    ///   - completionHandler: optional argument, by default it does nothing.
    func load(url urlString: String, into imageView: UIImageView, withDelay delay: Double = 0.0, isLoadingPresenting loading: Bool = false, completionHandler: @escaping () -> Void = { }) {
        load(url: urlString, into: imageView, withDelay: delay, isLoadingPresenting: loading, completionHandler: completionHandler)
    }
}

// MARK: - ImageService part.
protocol ImageServiceProtocol {
    
    /// Load an url into the image.
    /// - Parameters:
    ///   - url: the url in `URL` format of the image.
    ///   - into: the `UIImageView` that will hold the image.
    ///   - completionHandler: will be called after the image loaded.
    func load(url: URL, into imageView: UIImageView, completionHandler: @escaping () -> ())
}

// MARK: - PersistenceService part.


// MARK: - PersistenceService Container part.
protocol PersistenceServiceContainerProtocol {
    
    /// Store a `Persistable` struct into a database.
    func add<T: Persistable>(_ value: T)
    
    /// Store some `Persistable` structs into a database.
    func add<T: Sequence>(_ sequence: T) where T.Element: Persistable
    
    /// Delete the `Object` Element from the database.
    func delete<Element: Object>(_ objects: Results<Element>)
    
    /// Retrieve the `Object` Element from the database.
    func objects<Element: Object>(_ type: Element.Type) -> Results<Element>
}

// MARK: - PersistenceService part.
protocol PersistenceServiceProtocol {
    
    /// Store a `Persistable` struct into a database.
    func add<T: Persistable>(_ value: T) throws
    
    /// Store some `Persistable` structs into a database.
    func add<T: Sequence>(_ sequence: T) throws where T.Element: Persistable
    
    /// Delete the `Object` Element from the database.
    func delete<Element: Object>(_ objects: Results<Element>) throws
    
    /// Retrieve the `Object` Element from the database.
    func objects<Element: Object>(_ type: Element.Type) throws -> Results<Element>
}

// MARK: - Persistable part.
protocol Persistable {
    associatedtype ManagedObject: Object
    
    /// Create the `struct` based on the `Object` from the database.
    /// If the`Object` is `nil`, it should initialize the struct appropriately.
    init(managedObject: ManagedObject?)
    
    /// Create the `Object` that will be stored in the database based on the `struct`.
    func managedObject() -> ManagedObject
}
