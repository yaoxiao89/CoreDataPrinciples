//
//  ListItem.swift
//  CoreDataPrinciples
//
//  Copyright © 2019 Xiao Yao. All rights reserved.
//  See LICENSE.txt for licensing information.
//

import CoreData
import Foundation

// MARK: -

extension ListItem {
    
    private struct Keys {
        static let creationDate = "creationDate"
        static let isComplete = "isComplete"
        static let sectionID = "sectionID"
    }
    
    public override func value(forKey key: String) -> Any? {
        if key == ListItem.Keys.sectionID {
            return sectionID
        }
        return super.value(forKey: key)
    }
    
    private var sectionID: String {
        return isComplete ? "0" : "1"
    }
    
}

// MARK: - NSFetchRequest

extension ListItem {
    
    static func sorted() -> NSFetchRequest<ListItem> {
        let request: NSFetchRequest<ListItem> = ListItem.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: ListItem.Keys.isComplete, ascending: true),
            NSSortDescriptor(key: ListItem.Keys.creationDate, ascending: true),
        ]
        return request
    }
    
}

// MARK: - NSFetchedResultsController

extension ListItem {
    
    static func sorted(withContext context: NSManagedObjectContext) -> NSFetchedResultsController<ListItem> {
        return NSFetchedResultsController(
            fetchRequest: ListItem.sorted(),
            managedObjectContext: context,
            sectionNameKeyPath: ListItem.Keys.sectionID,
            cacheName: nil
        )
    }
    
}
