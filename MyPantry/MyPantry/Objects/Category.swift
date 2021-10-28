//
//  Category.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 10/05/2021.
//

import Foundation
import CoreData

/// Class for a Category of products
class Category : NSManagedObject {
    convenience init(context: NSManagedObjectContext, name: String){
        self.init(context: context)
        self.name = name
    }
}
