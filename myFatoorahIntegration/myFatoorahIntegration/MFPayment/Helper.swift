//
//  Helper.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 09/03/1446 AH.
//

import SwiftUI


enum MFPaymentState {
    case loading, normal, processingPayment, success, failed(String)
}

enum MFPaymentOptions {
    case applePay, cards, cardView
}

struct MFRedirectionPaymentMethod: Hashable {
    let id = UUID()
    let paymentMethodEn: String
    let paymentMethodAr: String
    let imageUrl: String
    let paymentMethodId: Int
}

@available(iOS 15.0.0, *)
struct MFPaymentViewState: View {
    @ObservedObject var paymentManager: MFPaymentManager
    
    var body: some View {
        switch paymentManager.state {
        case .loading:
            ProgressView()
                .scaleEffect(3)
                .task {
                    await paymentManager.initiateSession()
                }
        case .normal:
            EmptyView()
        case .processingPayment:
            Color.white.opacity(0.01)
            ProgressView()
                .scaleEffect(3)
        case .success:
            Color.white
            successView
        case .failed(let error):
            Color.white
            failedView(error)
        }
    }
    
    private var successView: some View {
        VStack {
            Image(systemName: "checkmark.circle")
                .mfImageModifier(100)
                .foregroundStyle(Color.green)
            
            Text(paymentManager.isLTR ? "Successfull Payment" : "عملية دفع ناجحة")
        }
    }
    
    private func failedView(_ error: String) -> some View {
        VStack {
            Image(systemName: "x.circle")
                .mfImageModifier(100)
                .foregroundStyle(Color.red)
            
            Text(error)
            
            Button(paymentManager.isLTR ? "Try Again" : "عادة محاولة الدفع") {
                Task {
                    await paymentManager.resetPaymentView()
                }
            }
        }
    }
}

@available(iOS 15.0.0, *)
struct MFAsyncImage: View {
    var imageURL: String?
    
    var body: some View {
        AsyncImage(
            url: URL(string: imageURL ?? ""),
            transaction: Transaction(animation: .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.25))
        ) { phase in
            switch phase {
            case .success(let image):
                image
                    .mfImageModifier(65)
                    .transition(.scale)
            case .failure(_), .empty:
                Image(systemName: "photo.circle.fill")
                    .mfImageModifier(65)
            @unknown default:
                ProgressView()
            }
        }
    }
}

@available(iOS 15.0.0, *)
struct MFPayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(width: 200, height: 40)
            .foregroundColor(.white)
            .background(Color.primary)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 1.2 : 1.0)
            .animation(.easeOut(duration: 0.5), value: configuration.isPressed)
    }
}

@available(iOS 13.0.0, *)
extension Image {
    func mfImageModifier(_ dimension: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: dimension, height: dimension)
    }
}

extension Decimal {
    var mfDoubleConversion: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
