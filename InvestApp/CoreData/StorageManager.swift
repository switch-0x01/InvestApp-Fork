//
//  CoreDataManager.swift
//  My Portfolio
//
//  Created by Сергей Петров on 01.03.2022.
//

import Foundation
import CoreData

enum StorageError: Error {
    case noDataError(message: String)
    case notEnoughCash(message: String)
    case internalError(message: String)
}

protocol StorageProtocol {
    var persistentContainer: NSPersistentContainer { get }
    var mainContext: NSManagedObjectContext { get }
    func saveContext(context: NSManagedObjectContext, completion: @escaping (StorageError?) -> Void)
}

final class StorageManager: StorageProtocol {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "My_Portfolio")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext(context: NSManagedObjectContext, completion: @escaping (StorageError?) -> Void) {
        if context.hasChanges {
            do {
                try context.save()
                completion(nil)
            } catch let error {
                completion(StorageError.internalError(message: "Can't save context! \(error.localizedDescription)"))
            }
        } else {
            completion(StorageError.noDataError(message: "Context hasn't changes!"))
        }
    }
}
