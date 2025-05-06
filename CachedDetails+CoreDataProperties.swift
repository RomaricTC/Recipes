//
//  CachedDetails+CoreDataProperties.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 2/27/25.
//
//

import Foundation
import CoreData

extension CachedDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedDetails> {
        return NSFetchRequest<CachedDetails>(entityName: "CachedDetails")
    }

    @NSManaged public var ingredients: [String]?
    @NSManaged public var instructions: [String]?
    @NSManaged public var measurements: [String]?

}
