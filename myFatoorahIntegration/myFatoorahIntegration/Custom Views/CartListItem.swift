//
//  CartListItem.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 1/17/24.
//

import SwiftUI

struct CartListItem: View {
    @EnvironmentObject var cartManager: CartManager
    @State var product: Product
    
    var body: some View {
        HStack() {
            VStack(alignment: .leading, spacing: 10) {
                Text(product.name)
                    .bold()
                
                Text("\(product.total, specifier: "%.2f")")
                    .bold()
                
                HStack {
                    Text("Quantity")

                    Button {
                        cartManager.reduceQuantity(product: product)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(Color.red)
                    }
                    
                    Text("\(product.quantity)")
                    
                    Button {
                        cartManager.addQuantity(product: product)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(Color.green)
                    }
                    Spacer()
                }
            }
            .padding()
            
            Image(systemName: "trash")
                .foregroundStyle(Color.red)
                .onTapGesture {
                    cartManager.removeFromCart(product: product)
                }
                .padding(.trailing)
        }
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
}

#Preview {
    CartListItem(product: productList[0])
        .environmentObject(CartManager())
}
