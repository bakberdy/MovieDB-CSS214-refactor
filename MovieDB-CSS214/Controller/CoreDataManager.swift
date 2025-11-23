//
//  CoreDataManager.swift
//  MovieDB-CSS214
//
//  Created by GitHub Copilot on 23.11.2025.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    private var context: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistantContainer.viewContext
    }
    
    @discardableResult
    func saveFavorite(movie: Result) -> Bool {
        guard let context = context,
              let entity = NSEntityDescription.entity(forEntityName: "Favorite", in: context) else {
            print("Error: Unable to get context or entity")
            return false
        }
        
        let favorite = NSManagedObject(entity: entity, insertInto: context)
        favorite.setValue(movie.id, forKey: "movieID")
        favorite.setValue(movie.posterPath, forKey: "posterPath")
        favorite.setValue(movie.title, forKey: "title")
        favorite.setValue(movie.voteAverage, forKey: "voteAverage")
        
        do {
            try context.save()
            return true
        } catch {
            print("Error saving favorite: \(error.localizedDescription)")
            return false
        }
    }
    
    @discardableResult
    func deleteFavorite(movie: Result) -> Bool {
        guard let context = context,
              let movieID = movie.id else {
            print("Error: Unable to get context or movie ID")
            return false
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        fetchRequest.predicate = NSPredicate(format: "movieID == %d", movieID)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let objectToDelete = result.first as? NSManagedObject {
                context.delete(objectToDelete)
                try context.save()
                return true
            }
            return false
        } catch {
            print("Error deleting favorite: \(error.localizedDescription)")
            return false
        }
    }
    
    func isFavorite(movie: Result) -> Bool {
        guard let context = context,
              let movieID = movie.id else {
            return false
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        fetchRequest.predicate = NSPredicate(format: "movieID == %d", movieID)
        
        do {
            let result = try context.fetch(fetchRequest)
            return !result.isEmpty
        } catch {
            print("Error checking favorite status: \(error.localizedDescription)")
            return false
        }
    }
    
    func loadAllFavorites() -> [Result] {
        guard let context = context else {
            print("Error: Unable to get context")
            return []
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Favorite")
        
        do {
            let result = try context.fetch(fetchRequest)
            var movies: [Result] = []
            
            for data in result as? [NSManagedObject] ?? [] {
                guard let movieID = data.value(forKey: "movieID") as? Int,
                      let title = data.value(forKey: "title") as? String,
                      let posterPath = data.value(forKey: "posterPath") as? String,
                      let voteAverage = data.value(forKey: "voteAverage") as? Double else {
                    continue
                }
                
                let movie = Result(id: movieID, posterPath: posterPath, title: title, voteAverage: voteAverage)
                movies.append(movie)
            }
            
            return movies
        } catch {
            print("Error loading favorites: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetch(entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [NSManagedObject] {
        guard let context = context else {
            print("Error: Unable to get context")
            return []
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let result = try context.fetch(fetchRequest)
            return result as? [NSManagedObject] ?? []
        } catch {
            print("Error fetching \(entityName): \(error.localizedDescription)")
            return []
        }
    }
    
    @discardableResult
    func deleteAll(entityName: String) -> Bool {
        guard let context = context else {
            print("Error: Unable to get context")
            return false
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            return true
        } catch {
            print("Error deleting all \(entityName): \(error.localizedDescription)")
            return false
        }
    }
}
