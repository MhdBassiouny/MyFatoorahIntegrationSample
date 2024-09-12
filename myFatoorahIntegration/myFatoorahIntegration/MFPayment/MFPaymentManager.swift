//
//  MFPaymentManager.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 09/03/1446 AH.
//

import SwiftUI
import MFSDK

//MARK: - ViewModel
@available(iOS 13.0.0, *)
@MainActor
class MFPaymentManager: ObservableObject {
    @Published var state: MFPaymentState = .loading
    @Published var cardBin: String? = nil
    @Published var startPayment = false
    @Published var session: MFInitiateSessionResponse?
    @Published var height: CGFloat? = 160
    
    var availableCards: String = "KNet"
    var redirectionPaymentMethods: [MFRedirectionPaymentMethod] = [
        .init(
            paymentMethodEn: "Knet",
            paymentMethodAr: "كينت",
            imageUrl: "https://portal.myfatoorah.com/imgs/payment-methods/kn.png",
            paymentMethodId: 1
        )
    ]
    var applePayEnabled = true
    var cardsEnabled = true
    
    var request: MFExecutePaymentRequest
    let language: MFAPILanguage
    let customerIdentifier: String
    let handler: (Result<MFPaymentStatusResponse, MFFailResponse>, _ invoiceId: String?) -> Void
    let isLTR: Bool
    
    init(
        request: MFExecutePaymentRequest,
        language: MFAPILanguage = .english,
        customerIdentifier: String = "",
        handler: @escaping (Result<MFPaymentStatusResponse, MFFailResponse>, _: String?) -> Void
    ) {
        self.request = request
        self.language = language
        self.customerIdentifier = customerIdentifier
        self.handler = handler
        self.request.updatePaymentMethod(-1)
        self.isLTR = language == .english ? true : false
    }
    
    func initiateSession() async {
        guard cardsEnabled || applePayEnabled else { return }
        let initSessionRequest = MFInitiateSessionRequest(customerIdentifier: customerIdentifier)
        let sessionResult = await MFPaymentRequest.shared.initiateSession(request: initSessionRequest, apiLanguage: language)
        switch sessionResult {
        case .success(let response):
            session = response
            state = .normal
        case.failure(let error):
            print(error.errorDescription)
        }
    }
    
    func executePayment(paymentMethodId: Int) {
        Task {
            state = .processingPayment
            request.updatePaymentMethod(paymentMethodId)
            let (result, invoiceId) = await MFPaymentRequest.shared.executePayment(request: request, apiLanguage: .english)
            switch result {
            case .success(let paymentStatus):
                state = .success
                handler(.success(paymentStatus), invoiceId)
            case .failure(let error):
                state = .failed(error.errorDescription)
                handler(.failure(error), nil)
            }
        }
    }
    
    func resetPaymentView() async {
        request.updatePaymentMethod(-1)
        request.sessionId = ""
        cardBin = nil
        await initiateSession()
    }
}
