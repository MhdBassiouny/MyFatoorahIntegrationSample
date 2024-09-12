//
//  MFPaymentView.swift
//
//  Created by Muhammad Bassiouny on 3/10/24.
//

import SwiftUI
import MFSDK


@available(iOS 15.0.0, *)
struct MFPaymentView: View {
    @StateObject var paymentManager: MFPaymentManager
    
    @State var selectedPaymentOptio: MFPaymentOptions? = nil /// this var is only used in desing 1
    
    init(paymentRequest: MFExecutePaymentRequest, language: MFAPILanguage  = .english, customerIdentifier: String = "", handler: @escaping (Result<MFPaymentStatusResponse, MFFailResponse>, _: String?) -> Void) {
        _paymentManager = StateObject(wrappedValue:MFPaymentManager(request: paymentRequest, language: language, customerIdentifier: customerIdentifier, handler: handler))
    }
    
    var body: some View {
        ZStack {
            /// Choose only one of the below VStacks
            /// Design 1
            VStack {
                applePaySelection
                redirectionPaymentMethodsSelection
                cardViewSelection
                
                selectedPayment
            }

            // Design 2
//            VStack {
//                applePay
//                redirectionPaymentMethods
//                cardView
//            }
            
            MFPaymentViewState(paymentManager: paymentManager)
        }
        .environment(\.layoutDirection, paymentManager.isLTR ? .leftToRight : .rightToLeft)
        .onReceive(paymentManager.$cardBin) { newValue in
            ///Here you will receive the card bin added in the CardView
        }
    }
}
//MARK: - Desing 1
@available(iOS 15.0.0, *)
extension MFPaymentView {
    private var applePaySelection: some View {
        MFPaymentDisplayButton(selectedOption: $selectedPaymentOptio, tag: .applePay, labelText: paymentManager.isLTR ? "Apple Pay" : "أبل باي", image: "apple.logo")
    }
    
    private var redirectionPaymentMethodsSelection: some View {
        MFPaymentDisplayButton(selectedOption: $selectedPaymentOptio, tag: .cards, labelText: paymentManager.availableCards, image: "creditcard")
    }
    
    private var cardViewSelection: some View {
        MFPaymentDisplayButton(selectedOption: $selectedPaymentOptio, tag: .cardView, labelText: paymentManager.isLTR ? "Add a Card" : "اضف الكارت", image: "creditcard")
    }
    
    @ViewBuilder
    private var selectedPayment: some View {
        if paymentManager.applePayEnabled, let session = paymentManager.session {
            MFApplePayButton(session: session, request: paymentManager.request, state: $paymentManager.state, handler: paymentManager.handler)
                .frame(width: 200, height: selectedPaymentOptio == .applePay ? 40 : 0)
                .opacity(selectedPaymentOptio == .applePay ? 1 : 0)
        }
        
        if !paymentManager.redirectionPaymentMethods.isEmpty {
            paymentMethods
                .opacity(selectedPaymentOptio == .cards ? 1 : 0)
                .frame(height: selectedPaymentOptio == .cards ? nil : 0)
        }
        
        if paymentManager.cardsEnabled, let session = paymentManager.session {
            cardViewPayment(session)
                .opacity(selectedPaymentOptio == .cardView ? 1 : 0)
                .frame(height: selectedPaymentOptio == .cardView ? nil : 0)
        }
    }
}

@available(iOS 15.0.0, *)
struct MFPaymentDisplayButton<T: Hashable>: View {
    @Binding var selectedOption: T?
    var tag: T
    var labelText: String
    var image: String
    
    var body: some View {
        Button {
            withAnimation {
                if selectedOption == tag {
                    selectedOption = nil
                } else {
                    selectedOption = tag
                }
            }
        } label: {
            HStack {
                Image(systemName: image)
                    .frame(width: 30)
                Text(labelText)
                Spacer()
                circle
            }
            .padding(.vertical, 8)
            .foregroundStyle(Color.black)
        }
    }
    
    private var circle: some View {
        Circle()
            .fill(selectedOption == tag ? Color.blue : Color.clear)
            .padding(4)
            .overlay(
                Circle()
                    .stroke(selectedOption == tag ? Color.blue : Color.gray, lineWidth: 2)
            )
            .frame(width: 16, height: 16)
            .padding(4)
    }
}

//MARK: - Desing 2
@available(iOS 15.0.0, *)
extension MFPaymentView {
    @ViewBuilder
    private var applePay: some View {
        if paymentManager.applePayEnabled, let session = paymentManager.session {
            MFApplePayButton(session: session, request: paymentManager.request, state: $paymentManager.state, handler: paymentManager.handler)
                .frame(width: 200, height: 40)
        }
    }
    
    @ViewBuilder
    private var redirectionPaymentMethods: some View {
        if !paymentManager.redirectionPaymentMethods.isEmpty {
            MFSectionSeparator(text: paymentManager.isLTR ? "Pay with Cards" : "ادفع عن طريق")
            paymentMethods
        }
    }
    
    @ViewBuilder
    private var cardView: some View {
        if paymentManager.cardsEnabled, let session = paymentManager.session {
            MFSectionSeparator(text: paymentManager.isLTR ? "Add a Card" : "اضف الكارت")
            cardViewPayment(session)
        }
    }
}

@available(iOS 13.0.0, *)
struct MFSectionSeparator: View {
    var text: String
    
    var body: some View {
        ZStack {
            Divider()
            
            Text(text)
                .padding(5)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 5)
    }
}

//MARK: - Common Views
@available(iOS 15.0.0, *)
extension MFPaymentView {
    private func cardViewPayment(_ session: MFInitiateSessionResponse) -> some View {
        Group {
            MFCardView(session: session, request: paymentManager.request, language: paymentManager.language, shouldStartPayment: $paymentManager.startPayment, state: $paymentManager.state, handler: paymentManager.handler)
                .cardBin($paymentManager.cardBin)
                .height($paymentManager.height)
                .frame(height: paymentManager.height) ///You need to adjust the frame height in case of chaging the style of the card view
            
            payWithCardButton
        }
    }
    
    private var paymentMethods: some View {
        ///You can add a scroll view in case of more than three redirection method
        HStack(spacing: 25) {
            ForEach(paymentManager.redirectionPaymentMethods, id: \.self) { paymentMethod in
                VStack {
                    MFAsyncImage(imageURL: paymentMethod.imageUrl)
                    
                    Text(paymentManager.isLTR ? paymentMethod.paymentMethodEn : paymentMethod.paymentMethodAr)
                        .lineLimit(1)
                }
                .onTapGesture {
                    paymentManager.executePayment(paymentMethodId: paymentMethod.paymentMethodId)
                }
            }
        }
    }
    
    private var payWithCardButton: some View {
        Button(paymentManager.isLTR ? "Pay with Card" : "ادفع بالبطاقة") {
            paymentManager.startPayment = true
        }
        .buttonStyle(MFPayButtonStyle())
        .disabled(paymentManager.startPayment)
    }
}

//MARK: - Preview
#Preview {
    MFPaymentView(paymentRequest: MFExecutePaymentRequest(invoiceValue: 10, displayCurrencyIso: .kuwait_KWD), customerIdentifier: "123") { _, _ in }
}
