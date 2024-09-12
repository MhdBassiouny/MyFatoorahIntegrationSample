//
//  CartView.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 1/17/24.
//

import SwiftUI
import MFSDK

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State var request = MFExecutePaymentRequest(invoiceValue: 0, displayCurrencyIso: .kuwait_KWD)
    
    
    var body: some View {
        ScrollView {
            ForEach(cartManager.products, id: \.self) { product in
                CartListItem(product: product)
            }
        }
        .frame(maxHeight: 200)
        
        HStack {
            Text("Your Total is")
            Spacer()
            Text("\(cartManager.total, specifier: "%.2f")")
                .bold()
        }
        .padding(.horizontal)
        Divider()
        
        //MARK: - MFPayment View
        if cartManager.total > 0 {
            MFPaymentView(paymentRequest: request, customerIdentifier: "1234") { response, invoiceId in
                switch response {
                case .success(let response):
                    // Handle Success Case
                    print(response.invoiceID)
                case .failure(let error):
                    print(error.errorDescription)
                }
            }
            .task(id: cartManager.total) {
                request.invoiceValue = Decimal(cartManager.total)
            }
        }
        
        Spacer()
    }
}

#Preview {
    CartView()
        .environmentObject(CartManager())
}
