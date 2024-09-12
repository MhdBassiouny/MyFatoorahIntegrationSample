//
//  ProductQuantity.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 1/24/24.
//

import SwiftUI

struct ProductQuantity: View {
    @Binding var product: Product
    
    var body: some View {
        HStack {
            Text("Qty")
                .font(.subheadline)

            Button {
                product.reduceQuatity()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.red)
            }
            
            Text("\(product.quantity)")
            
            Button {
                product.addQuatity()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(Color.green)
            }
            Spacer()
        }
    }
}

#Preview {
    ProductQuantity(product: .constant(Product(name: "", price: 10)))
}
