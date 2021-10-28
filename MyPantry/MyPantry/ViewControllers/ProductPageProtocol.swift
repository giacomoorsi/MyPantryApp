//
//  ProductPageProtocol.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 25/05/2021.
//

import Foundation

/// The views which allow the user to edit or add a new product must implement this protocol
protocol ProductPageProtocol {
    func selectCategory(category: Category)
    func selectPantry(pantry: Pantry)
    var productDescription : String? { get set }
}
