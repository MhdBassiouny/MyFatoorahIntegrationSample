//
//  MFApplePayButton.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 09/03/1446 AH.
//

import SwiftUI
import MFSDK
import PassKit

@available(iOS 14.0.0, *)
struct MFApplePayButton: UIViewRepresentable {
    let session: MFInitiateSessionResponse
    var request: MFExecutePaymentRequest
    @Binding var state: MFPaymentState
    let handler: (Result<MFPaymentStatusResponse, MFFailResponse>, _ invoiceId: String?) -> Void
    
    func makeUIView(context: Context) -> PKPaymentButton {
        return context.coordinator.button
    }
    
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {
        if session.sessionId != context.coordinator.currentSession {
            context.coordinator.loadApplePay(request, session)
        }
        
        if request != context.coordinator.parent.request {
            context.coordinator.parent.request = request
        }
    }
    
    func makeCoordinator() -> MFApplePayCoordinator {
        return MFApplePayCoordinator(self)
    }
    
    class MFApplePayCoordinator {
        var parent: MFApplePayButton
        let applePay = MFApplePay()
        let button: PKPaymentButton
        var currentSession: String?
        
        init(_ parent: MFApplePayButton) {
            self.parent = parent
            ///Here you can adjust the style of Apple Pay Button
            self.button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .automatic)
            button.addTarget(self, action: #selector(executePayment), for: .touchUpInside)
            button.alpha = 0.7
            button.isEnabled = false
            applePay.didLoad = { [weak self] in
                self?.button.alpha = 1
                self?.button.isEnabled = true
            }
        }
        
        @objc
        func executePayment() {
            applePay.update(amount: parent.request.invoiceValue.mfDoubleConversion)
            applePay.openPaymentSheet { [weak self] result in
                switch result {
                case.success(_):
                    ///The reslt in case of success will include the card brand and the first 8-digits of the card (If the feature is enabled)
                    self?.parent.state = .processingPayment
                    self?.applePay.executePayment(request: self?.parent.request) { response, invoiceId in
                        switch response {
                        case .success(let paymentStatus):
                            self?.parent.state = .success
                            self?.parent.handler(.success(paymentStatus), invoiceId)
                        case .failure(let error):
                            self?.parent.state = .failed(error.errorDescription)
                            self?.parent.handler(.failure(error), nil)
                        }
                    }
                case.failure(let error):
                    self?.parent.handler(.failure(error), nil)
                }
            }
        }
        
        func loadApplePay(_ request: MFExecutePaymentRequest, _ session: MFInitiateSessionResponse) {
            currentSession = session.sessionId
            ///To chage the busiess name on Apple Payment Sheet
            //context.coordinator.applePay.merchantName = "Test"
            applePay.setupApplePay(session, request, .english)
        }
    }
}
