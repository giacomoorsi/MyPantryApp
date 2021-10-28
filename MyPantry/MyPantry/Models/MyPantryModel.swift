//
//  MyPantryModel.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 09/05/2021.
//

import Foundation
import CoreData
import NotificationCenter
import WidgetKit

/**
 Handles all the main activies of MyPantry and the connection with the CoreData database
 */
class MyPantryModel
{
    static let model = MyPantryModel() // singleton
    let context = AppDelegate.viewContext
    let watchConnectionModel = WatchConnectionModel.model
    let notificationCenter = UNUserNotificationCenter.current()
    let defaults: UserDefaults = UserDefaults(suiteName: "group.giacomoorsi.MyPantry")!
    
    /// A `PantryItem` is considered "expiring" when its expiry date is later then the `expiringThreshold`
    var expiringThreshold : Int {
        get {
            let threshold = defaults.integer(forKey: "expiringThreshold")
            if (threshold == 0){
                return 7 // default threshold
            } else {
                return threshold
            }
        }
        set {
            defaults.setValue(newValue, forKey: "expiringThreshold")
        }
    }
    
    /// `true` if the user has enabled notifications for MyPantry
    var notificationsEnabled : Bool {
        get {
            let enabled = defaults.bool(forKey: "notificationsEnabled")
            if(enabled == nil || enabled == false){
                return false
            } else {
                return true
            }
        }
    }
    
    /// `true` if the user has completed the welcome procedure
    var welcomeCompleted : Bool {
        get { return ServerModel.model.registered }
    }
    
    /// Contains the list of categories in the database
    var categories : [Category] {
        get {
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            do {
                return try context.fetch(request)
            } catch {
                fatalError("Errore nel caricamento delle categorie")
            }
        }
    }
    
    /// Contains the list of pantries in the database
    var pantries : [Pantry] {
        get {
            let request: NSFetchRequest<Pantry> = Pantry.fetchRequest()
            do {
                return try context.fetch(request)
            } catch {
                fatalError("Errore nel caricamento delle dispense")
            }
        }
    }
    
    /// Contains the list of shopping-list items in the database
    var shoppingListItems : [ShoppingListItem] {
        get {
            let request: NSFetchRequest<ShoppingListItem> = ShoppingListItem.fetchRequest()
            do {
                return try context.fetch(request)
            } catch {
                fatalError("Errore nel caricamento degli elementi della lista della spesa")
            }
        }
    }
    
    /// Contains an unfiltered list of products
    var products : [PantryItem] {
        get {
            let request: NSFetchRequest<PantryItem> = PantryItem.fetchRequest()
            request.predicate = NSPredicate(format: "consumed == NO")
            do {
                let products = try context.fetch(request)
                defaults.setValue(String(products.count), forKey: "numberOfProductsInPantry")
                defaults.synchronize()
                updateWidget()
                watchConnectionModel.session.sendMessage(["numberOfProductsInPantry":String(products.count)], replyHandler: nil, errorHandler: nil)
                return products
            } catch {
                fatalError("Errore nel caricamento delle dispense")
            }
        }
    }
    
    
    
    
    /** Adds a new `Category` to the CoreData database
     - Parameter newCategoryName: the name of the new `Category` */
    func add(categoryWithName newCategoryName: String){
        _ = Category(context: context, name: newCategoryName)
        commit()
    }
    
    /** Adds a new `ShoppingListItem` from a `PantryItem`
     - Parameter pantryItem: the `PantryItem` from which it is created a new  `ShoppingListItem` */
    func add(shoppingListItemFromPantryItem pantryItem : PantryItem) {
        _ = ShoppingListItem(context: context, pantryItem: pantryItem)
        commit()
    }
    
    /// Adds a new `Pantry` to the CodeData database
    /// - Parameter newPantryName: the name of the new `Pantry`
    func add(pantryWithName newPantryName: String){
        _ = Pantry(context: context, name: newPantryName)
        commit()
    }
    
    /**
     Adds a new `PantryItem` to the CoreData database
     - Parameters:
     - name: the name of the product
     - productDescription: the description of the product (optional)
     - expireDate: the expiry date of the product (optional)
     - category: the category of the product
     - pantry: the pantry where the product is situated
     - barcode: the barcode of the product
     - Returns: the new product
     */
    func addPantryItem (name: String, productDescription : String?, expireDate : Date?, category : Category?, pantry : Pantry?, barcode : String) -> PantryItem {
        let pantryItem = PantryItem(context: context, name: name, productDescription: productDescription, expireDate: expireDate, category: category, pantry: pantry, barcode: barcode, consumed: false, opened: false)
        
        commit()
        setNotificationsFor(product: pantryItem)
        return pantryItem
    }
    
    /**
     Inverts the `consumed` attribute of a `PantryItem` and enables/disables the notifications for its expiry date
     - Parameter product: the product which has been consumed
     */
    func consume(product: PantryItem){
        product.consumed = !product.consumed
        if product.consumed {
            removeNotificationsFor(product: product)
        } else {
            setNotificationsFor(product: product)
        }
    }
    
    /**
     Inverts the `opened` attribute of a `PantryItem`
     - Parameter product: the product which has been opened/closed
     */
    func open(product: PantryItem){
        product.opened = !product.opened
    }
    
    /**
     Removes a `Category` from the CoreData database
     - Parameter oldCateogory: the category to be removed
     */
    func remove(category oldCateogory: Category){
        let productsWithCategory = getProductsBy(category: oldCateogory)
        for product in productsWithCategory {
            context.delete(product)
        }
        
        let shoppingListItemsWithCategory = getShoppingListItemsBy(category: oldCateogory)
        for item in shoppingListItemsWithCategory {
            context.delete(item)
        }
        
        context.delete(oldCateogory)
        commit()
    }
    
    /**
     Removes a `Pantry` from the CoreData database
     - Parameter oldPantry: the pantry to be removed
     */
    func remove(pantry oldPantry: Pantry){
        let productWithPantry = getProductsBy(pantry: oldPantry)
        for product in productWithPantry {
            context.delete(product)
        }
        
        let shoppingListItemsWithPantry = getShoppingListItemsBy(pantry: oldPantry)
        for item in shoppingListItemsWithPantry {
            context.delete(item)
        }
        
        context.delete(oldPantry)
        commit()
    }
    
    /**
     Removes a `PantryItem` from the CoreData database
     - Parameter oldProduct: the product to be removed
     */
    func remove(product oldProduct: PantryItem){
        removeNotificationsFor(product: oldProduct)
        context.delete(oldProduct)
        commit()
    }
    
    /**
     Removes a `ShoppingListItem` from the CoreData database
     - Parameter oldProduct: the item to be removed
     */
    func remove(shoppingListItem oldShoppingListItem: ShoppingListItem){
        context.delete(oldShoppingListItem)
        commit()
    }
    
    /**
     Enables the reminders for a product
     - Parameter pantryItem: the product
     */
    func setNotificationsFor(product pantryItem: PantryItem) {
        if(notificationsEnabled && pantryItem.expireDate != nil) {
            if (pantryItem.expireDate! > Date.init() ){
                let content = UNMutableNotificationContent()
                content.title = "Prodotto scaduto"
                content.body = pantryItem.name! + " è in scadenza oggi."
                content.sound = .default
                
                var dateComponents = Calendar.current.dateComponents(Set(arrayLiteral: Calendar.Component.year, Calendar.Component.month, Calendar.Component.day), from: pantryItem.expireDate!)
                dateComponents.hour = 9
                dateComponents.minute = 0
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: String(pantryItem.objectID.hash) + "-expired", content: content, trigger: trigger)
                notificationCenter.add(request)
                print("Impostata notifica per prodotto scaduto il \(pantryItem.expireDate!)")

            }
            
            let expiringDate = Calendar.current.date(byAdding: .day, value: -expiringThreshold, to: pantryItem.expireDate!)!
            if (expiringDate > Date.init()) {
                let content = UNMutableNotificationContent()
                content.title = "Prodotto in scadenza"
                content.body = pantryItem.name! + " scadrà tra " + String(expiringThreshold) + " giorni."
                content.sound = .default
                
                var dateComponents = Calendar.current.dateComponents(Set(arrayLiteral: Calendar.Component.year, Calendar.Component.month, Calendar.Component.day), from: expiringDate)
                dateComponents.hour = 9
                dateComponents.minute = 0
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: String(pantryItem.objectID.hash) + "-expiring", content: content, trigger: trigger)
                notificationCenter.add(request)
                
                print("Impostata notifica per prodotto in scadenza il \(expiringDate)")
            }
        }
    }
    
    /**
     Removes all the notifications for a product
     - Parameter pantryItem: the product
     */
    func removeNotificationsFor(product pantryItem: PantryItem) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [String(pantryItem.objectID.hash) + "-exipiring", String(pantryItem.objectID.hash) + "-expired"])
    }
    
    /**
     Returns all the products which are expired and have not been consumed
     - Returns: the list of products
     */
    func getExpiredProducts() -> [PantryItem] {
        let request: NSFetchRequest<PantryItem> = PantryItem.fetchRequest()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date.init())
        request.predicate = NSPredicate(format: "expireDate <= %@ AND consumed == NO", today as NSDate)
        do {
            let products = try context.fetch(request)
            defaults.setValue(String(products.count), forKey: "numberOfExpiredProducts")
            defaults.synchronize()
            updateWidget()
            watchConnectionModel.session.sendMessage(["numberOfExpiredProducts":String(products.count)], replyHandler: nil, errorHandler: nil)
            return products
        } catch {
            fatalError("Errore nel caricamento dei prodotti")
        }
    }
    
    /**
     Returns all the products which are going to expire soon and have not been consumed
     - Returns: the list of products
     */
    func getExpiringProducts() -> [PantryItem] {
        let request: NSFetchRequest<PantryItem> = PantryItem.fetchRequest()
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: expiringThreshold, to: Date.init())
        let today = calendar.startOfDay(for: Date.init())
        request.predicate = NSPredicate(format: "expireDate <= %@ AND expireDate >= %@ AND consumed == NO", date! as NSDate, today as NSDate)
        
        do {
            let products = try context.fetch(request)
            defaults.setValue(String(products.count), forKey: "numberOfExpiringProducts")
            defaults.synchronize()
            updateWidget()
            watchConnectionModel.session.sendMessage(["numberOfExpiringProducts":String(products.count)], replyHandler: nil, errorHandler: nil)
            return products
        } catch {
            fatalError("Errore nel caricamento dei prodotti")
        }
    }
    
    /**
     Returns all the products which are opened and not consumed
     - Returns: the list of products
     */
    func getOpenedProducts() -> [PantryItem] {
        let request: NSFetchRequest<PantryItem> = PantryItem.fetchRequest()
        request.predicate = NSPredicate(format: "opened == YES AND consumed == NO")
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Errore nel caricamento dei prodotti")
        }
    }
    
    /**
     Returns all the consumed products
     - Returns: the list of products
     */
    func getConsumedProducts() -> [PantryItem] {
        let request: NSFetchRequest<PantryItem> = PantryItem.fetchRequest()
        request.predicate = NSPredicate(format: "consumed == YES")
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Errore nel caricamento dei prodotti")
        }
    }
    
    /**
     Returns all the products which belongs to a certain `Category`
     - Parameter category: the searched category
     - Returns: the list of products
     */
    func getProductsBy(category: Category) -> [PantryItem] {
        let request: NSFetchRequest<PantryItem> = PantryItem.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Errore nel caricamento dei prodotti")
        }
    }
    
    /**
     Returns all the products which belongs to a certain `Pantry`
     - Parameter pantry: the searched pantry
     - Returns: the list of products
     */
    func getProductsBy(pantry: Pantry) -> [PantryItem] {
        let request: NSFetchRequest<PantryItem> = PantryItem.fetchRequest()
        request.predicate = NSPredicate(format: "pantry == %@", pantry)
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Errore nel caricamento dei prodotti")
        }
    }
    
    /**
     Returns all the shopping list items which belongs to a certain `Pantry`
     - Parameter pantry: the searched pantry
     - Returns: the list of shopping list items
     */
    private func getShoppingListItemsBy(pantry: Pantry) -> [ShoppingListItem] {
        let request: NSFetchRequest<ShoppingListItem> = ShoppingListItem.fetchRequest()
        request.predicate = NSPredicate(format: "pantry == %@", pantry)
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Errore nel caricamento dei prodotti")
        }
    }
    
    /**
     Returns all the shopping list items which belongs to a certain `Category`
     - Parameter category: the searched category
     - Returns: the list of shopping list items
     */
    private func getShoppingListItemsBy(category: Category) -> [ShoppingListItem] {
        let request: NSFetchRequest<ShoppingListItem> = ShoppingListItem.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Errore nel caricamento dei prodotti")
        }
    }
    
    /**
     Commits the changes on the CoreData database
     */
    func commit() {
        do {
            try context.save()
        } catch {
            fatalError("Errore nel salvataggio")
        }
    }
    
    /**
     Tells iOS to update the widget shown in the home or the notification center of the device
     */
    private func updateWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /**
     Aborts the changes on the CoreData database
     */
    func rollback() {
        context.rollback()
    }
    
    /**
     Initializes some categories and pantries in the CoreData database
     */
    func initApplication() {
        if categories.count == 0 && pantries.count == 0 {
            let demoCategories = ["Pasta", "Snack", "Dolci", "Bevande", "Verdure", "Frutta"]
            let demoPantries = ["Frigo", "Freezer", "Scaffale"]
            
            for category in demoCategories {
                add(categoryWithName: category)
            }
            for pantry in demoPantries {
                add(pantryWithName: pantry)
            }
        }
    }
}
