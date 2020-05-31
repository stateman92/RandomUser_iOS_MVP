//
//  PersistenceServiceContainer.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 31..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import Foundation
import RealmSwift

class PersistenceServiceContainer: PersistenceServiceContainerProtocol {
    
    func add<T>(_ value: T) where T : Persistable {
        
    }
    
    func add<T>(_ sequence: T) where T : Sequence, T.Element : Persistable {
        
    }
    
    func delete<Element>(_ objects: Results<Element>) where Element : Object {
        
    }
}
