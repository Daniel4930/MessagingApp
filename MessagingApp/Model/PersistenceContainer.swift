//
//  PersistenceContainer.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/19/25.
//
import CoreData

class PersistenceContainer {
    static let shared = PersistenceContainer()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "Persistence")
        guard container.persistentStoreDescriptions.first != nil else {
            fatalError("Could not find persistence container")
        }
        
        container.loadPersistentStores { storeDescription, error in
            print(storeDescription.url ?? "no path")
            guard error == nil else {
                fatalError("Couldn't load persistence stores. \(error?.localizedDescription ?? "")")
            }
        }
        context = container.viewContext
    }
    
    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Failed to save the context", error.localizedDescription)
        }
    }
    
}
