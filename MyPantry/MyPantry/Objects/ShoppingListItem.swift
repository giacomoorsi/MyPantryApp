//
//  ShoppingListItem.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 29/05/2021.
//

import Foundation
import CoreData

/// Item on the shopping list
class ShoppingListItem : NSManagedObject {
    convenience init(context: NSManagedObjectContext, barcode: String, productName: String, productDescription : String?, category : Category?, pantry : Pantry?){
        self.init(context: context)
        self.name = productName
        self.productDescription = productDescription
        self.pantry = pantry
        self.category = category
        self.barcode = barcode
    }
    convenience init(context: NSManagedObjectContext, pantryItem: PantryItem){
        self.init(context: context)
        self.name = pantryItem.name
        self.productDescription = pantryItem.productDescription
        self.category = pantryItem.category
        self.barcode = pantryItem.barcode
        self.pantry = pantryItem.pantry
    }
}
