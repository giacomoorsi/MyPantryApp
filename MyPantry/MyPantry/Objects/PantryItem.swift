//
//  PantryItem.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 23/05/2021.
//

import Foundation
import CoreData

/// Class which handles a product
// Product was not a name available in Swift, so I decided to use PantryItem
class PantryItem : NSManagedObject {
    convenience init(context: NSManagedObjectContext, name: String, productDescription : String?, expireDate : Date?, category : Category?, pantry : Pantry?, barcode : String, consumed: Bool, opened : Bool){
        self.init(context: context)
        self.name = name
        self.productDescription = productDescription
        self.expireDate = expireDate
        self.category = category
        self.pantry = pantry
        self.opened = opened
        self.consumed = consumed
        self.barcode = barcode
    }
}
