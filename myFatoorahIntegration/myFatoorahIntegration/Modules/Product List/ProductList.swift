//
//  ProductList.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 1/17/24.
//

import SwiftUI

struct ProductList: View {
    @EnvironmentObject var cartManager: CartManager
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack {
            NavigationLink {
                CartView()
                    .environmentObject(cartManager)
            } label: {
                cartView
            }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(productList, id: \.id) { product in
                        ProductListItem(product: product)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var cartView: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                Image(systemName: "cart")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                
                if cartManager.numberOfItems > 0 {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 25, height: 25)
                        .overlay(
                            Text("\(cartManager.numberOfItems)")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.white)
                        )
                        .offset(x: -5, y: -5)
                }
            }
            Text("Go to Cart")
        }
    }
}

#Preview {
    ProductList()
        .environmentObject(CartManager())
}
