//
//  Persistent.swift
//  TaskManager
//
//  Created by Stefano on 11.03.25.
//

import CoreData

struct PersistentController {
    static let shared = PersistentController()
    
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "TaskModel")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return container.viewContext
    }
}
