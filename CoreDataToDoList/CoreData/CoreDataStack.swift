//
//  CoreDataStack.swift
//  CoreDataToDoList
//
//  Created by Sophie Jacquot  on 22/05/2021.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Todos")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
        }
        
        return container
    }

    var managedContext: NSManagedObjectContext {
        return container.viewContext
    }
}
