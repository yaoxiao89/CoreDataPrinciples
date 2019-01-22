//
//  CoreDataController.swift
//  CoreDataPrinciples
//
//  Copyright © 2019 Xiao Yao. All rights reserved.
//  See LICENSE.txt for licensing information.
//

import CoreData
import Foundation
import os.log

// MARK: - CoreDataController

class CoreDataController {
    
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(name: String = "DataModel") {
        persistentContainer = NSPersistentContainer(name: name)
        persistentContainer.loadPersistentStores { (description, error) in
            guard let err = error else { return }
            /// For the demo, log the error
            /// In your application, please handle the error :)
            os_log("CoreData Error: %@", err.localizedDescription)
        }
    }
    
}
