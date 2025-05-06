//
//  CoreDataManager.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 2/13/25.
//
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer
    private init() {
          container = NSPersistentContainer(name: "RecipesModel")
          container.loadPersistentStores { storeDescription, error in
              if let error = error {
                  fatalError("❌ Core Data failed to load: \(error.localizedDescription)")
              }
              // Print the SQLite file path after successful loading
              if let storeURL = storeDescription.url {
                  print("📍 Core Data SQLite file location: \(storeURL.path)")
              } else {
                  print("❌ Could not determine SQLite file location")
              }
          }
      }
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    func save() {
        do {
            try context.save()
        } catch {
            print("❌ Error saving Core Data: \(error)")
        }
    }
    func cacheRecipes(_ recipes: [Recipe]) {
        let context = self.context
        // Clear old cache
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedRecipe")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)
        save()
        // Cache new recipes
        for recipe in recipes {
            let cachedRecipe = CachedRecipe(context: context)
            cachedRecipe.id = recipe.id
            cachedRecipe.name = recipe.name
            cachedRecipe.thumbnailURL = recipe.thumbnailURL
        }
        save()
    }
    func cacheDetails(_ details: RecipeDetailsModel) {
        let context = self.context
        // Clear old cache
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedDetails")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)
        save()
        // Cache new recipe
        let cachedDetails = CachedDetails(context: context)
        // Assign arrays directly (assuming ingredients, instructions, and measurements are [String])
        cachedDetails.ingredients = details.ingredients as NSObject
        cachedDetails.instructions = details.instructions as NSObject
        cachedDetails.measurements = details.measurements as NSObject
        save()
    }
}


