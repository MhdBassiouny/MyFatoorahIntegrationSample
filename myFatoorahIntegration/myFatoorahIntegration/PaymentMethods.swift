//
//  PaymentMethods.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 12/20/23.
//

import SwiftUI
import MFSDK

struct PaymentMethods: View {
    @Binding var paymentMethods: [MFPaymentMethod]?
    @Binding var selectedPaymentMethod: Int?
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: [GridItem(.fixed(100))], spacing: 30) {
                ForEach(paymentMethods ?? [], id: \.self) { paymentMethod in
                    if !paymentMethod.isEmbeddedSupported {
                        VStack {
//                            CustomAsyncImage(imageURL: URL(string: paymentMethod.imageUrl ?? ""), dimensios: 50)
                            Text(paymentMethod.paymentMethodEn ?? "")
                            if selectedPaymentMethod == paymentMethod.paymentMethodId {
                                Image(systemName: "checkmark")
                                    .checkMarkModifier(.green)
                            } else {
                                Image(systemName: "checkmark")
                                    .checkMarkModifier(.gray)
                            }
                        }
                        .onTapGesture {
                            selectedPaymentMethod = paymentMethod.paymentMethodId
                        }
                    }
                }
            }.padding(.horizontal)
        }
    }
}

#Preview {
    PaymentMethods(paymentMethods: .constant([]), selectedPaymentMethod: .constant(1))
}



