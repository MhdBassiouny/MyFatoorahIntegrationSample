//
//  Product.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 1/17/24.
//

import Foundation

struct Product: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var imageUrl: URL?
    var quantity: Int = 1
    var price: Double
    var total: Double {
        Double(quantity) * price
    }
    
    mutating func addQuatity() {
        quantity += 1
    }
    
    mutating func reduceQuatity() {
        if quantity > 1 {
            quantity -= 1
        }
    }
}


var productList = [
    Product(name: "Product Test", price: 10),
    Product(name: "Product Test", price: 10),
    Product(name: "Product Test", price: 10),
    Product(name: "Product Test", price: 10),
    Product(name: "Product Test", price: 10),
    Product(name: "Product Test", price: 10),
    Product(name: "Product Test", price: 10),
    Product(name: "Product Test", price: 10),
    Product(name: "Product Test", price: 10),
    Product(name: "Product Test", price: 10),
    Product(name: "Product Test", price: 10),
    Product(name: "Product Test", price: 10),
    Product(name: "Product Test", price: 10)
]
