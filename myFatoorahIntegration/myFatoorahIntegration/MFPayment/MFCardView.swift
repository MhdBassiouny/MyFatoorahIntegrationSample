//
//  MFCardView.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 09/03/1446 AH.
//

import SwiftUI
import MFSDK


@available(iOS 13.0.0, *)
struct MFCardView: UIViewRepresentable {
    private let session: MFInitiateSessionResponse
    private let request: MFExecutePaymentRequest
    private let language: MFAPILanguage
    @Binding private var shouldStartPayment: Bool
    @Binding private var state: MFPaymentState
    @Binding private var cardBin: String?
    @Binding var cardViewHeight: CGFloat?
    private let handler: (Result<MFPaymentStatusResponse, MFFailResponse>, _ invoiceId: String?) -> Void
    
    init(
        session: MFInitiateSessionResponse,
        request: MFExecutePaymentRequest,
        language: MFAPILanguage = .english,
        shouldStartPayment: Binding<Bool>,
        state: Binding<MFPaymentState>,
        handler: @escaping (Result<MFPaymentStatusResponse, MFFailResponse>, _: String?) -> Void
    ) {
        self.session = session
        self.request = request
        self.language = language
        self._shouldStartPayment = shouldStartPayment
        self._state = state
        self._cardBin = .constant(nil)
        self._cardViewHeight = .constant(nil)
        self.handler = handler
    }
    
    func makeUIView(context: Context) -> MFPaymentCardView {
        return context.coordinator.cardView
    }
    
    func updateUIView(_ uiView: MFPaymentCardView, context: Context) {
        if session.sessionId != context.coordinator.currentSession {
            context.coordinator.currentSession = session.sessionId
            context.coordinator.cardView.load(initiateSession: session) { bin in
                cardBin = bin
            }
        }
        if shouldStartPayment {
            context.coordinator.executePayment(request, handler)
        }
    }
    
    func makeCoordinator() -> MFCardViewCoordinator {
        return MFCardViewCoordinator(self)
    }
    
    class MFCardViewCoordinator: MFCardViewDelegate {
        let parent: MFCardView
        let cardView = MFPaymentCardView()
        private let configure = MFCardConfigureBuilder.default
        var currentSession: String?
        
        init(_ parent: MFCardView) {
            self.parent = parent
            cardView.delegate = self
            ///Here you can adjust the style of the Card View
            if parent.language == .arabic {
                configure.setPlaceholder(MFCardPlaceholder(cardHolderNamePlaceholder: "اسم حامل البطاقة", cardNumberPlaceholder: "رقم البطاقة", expiryDatePlaceholder: "MM / YY", cvvPlaceholder: "CVV"))
                configure.setSaveCardText(MFSavedCardText(saveCardText: "حفظ البطاقة لعمليات الدفع القادمة", addCardText: "اضف بطاقة جديدة", deleteAlertText: MFDeleteAlert(title: "حذف البطاقة", message: "هل تريد تأكيد حذف البطاقة", confirm: "موافق", cancel: "إلغاء")))
            }
            //configure.setLabel(MFCardLabel(cardHolderNameLabel: "Card holder name", cardNumberLabel: "Card number", expiryDateLabel: "MM / YY", cvvLabel: "CVV", showLabels: false, fontWeight: .normal))
            let theme = MFCardTheme(inputColor: .black, labelColor: .black, errorColor: .red, borderColor: .lightGray)
            theme.language = parent.language == .english ? .english : .arabic
            configure.setTheme(theme)
            configure.setCardInput(MFCardInput(inputHeight: 35, inputMargin: -1, outerRadius: 12))
            //configure.setFontFamily(.arial)
            //configure.setBoxShadow(MFBoxShadow(hOffset: 0, vOffset: 0, blur: 0, spread: 0, color: .gray))
            configure.setFontSize(16)
            configure.setBorderRadius(5)
            //configure.setBorderWidth(1)
            ///Make sure to adjust the height of the card view (and the full view frame height, in case of adjusting the style)
            configure.setTokenHeight(160)
            configure.setCardHeight(160)
            cardView.configure = configure.build()
        }
        
        public func didHeightChanged(height: CGFloat) {
            parent.cardViewHeight = height
        }
        
        func executePayment(_ request: MFExecutePaymentRequest, _ completion: @escaping (Result<MFPaymentStatusResponse, MFFailResponse>, _: String?) -> Void) {
            cardView.submit { [weak self] result in
                self?.parent.shouldStartPayment = false
                switch result {
                case.success(_):
                    ///Here you will receive the Card Brand
                    self?.parent.state = .processingPayment
                    self?.cardView.pay(request, .english) { response, invoiceId in
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
                    print(error.errorDescription)
                }
            }
        }
    }
    
    func cardBin(_ cardBin: Binding<String?>) -> MFCardView {
        var view = self
        view._cardBin = cardBin
        return view
    }
    
    public func height(_ height: Binding<CGFloat?>) -> MFCardView {
        var view = self
        view._cardViewHeight = height
        return view
    }
}
