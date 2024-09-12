//
//  ProductCardView.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 1/17/24.
//

import SwiftUI

struct ProductListItem: View {
    @EnvironmentObject var cartManager: CartManager
    @State var product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center) {
                Text(product.name)
                    .font(.headline)
                
                CustomAsyncImage(imageURL: product.imageUrl)
                    .frame(maxWidth: 120)
            }.frame(maxWidth: .infinity)

            
            Text("Item Price: \(product.price, specifier: "%.2f")")
            
            ProductQuantity(product: $product)
            
            HStack {
                Spacer()
                Button {
                    cartManager.addToCart(product: product)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
}

#Preview {
    ProductListItem(product: productList[0])
        .environmentObject(CartManager())
}
