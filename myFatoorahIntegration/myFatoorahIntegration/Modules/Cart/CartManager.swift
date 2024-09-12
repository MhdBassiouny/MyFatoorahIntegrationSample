//
//  CartManager.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 1/17/24.
//

import SwiftUI

class CartManager: ObservableObject {
    @Published var products: [Product] = []
    @Published private(set) var total: Double = 0
    @Published private(set) var numberOfItems: Int = 0
    
    func addToCart(product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index].quantity += product.quantity
        } else {
            products.append(product)
        }
        total += product.total
        numberOfItems += product.quantity
    }
    
    func removeFromCart(product: Product) {
        products = products.filter { $0.id != product.id }
        total -= product.total
        numberOfItems -= product.quantity
    }
    
    func addQuantity(product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index].quantity += 1
        } else {
            products.append(product)
        }
        total += product.price
        numberOfItems += 1
    }
    
    func reduceQuantity(product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }), products[index].quantity > 1 {
            products[index].quantity -= 1
        } else {
            products = products.filter { $0.id != product.id }
        }
        total -= product.price
        numberOfItems -= 1
    }
    
    func emptyCart() {
        total = 0
        products = []
    }
}
