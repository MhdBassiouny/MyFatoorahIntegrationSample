//
//  CustomAsyncImage.swift
//  myFatoorahIntegration
//
//  Created by Muhammad Bassiouny on 1/17/24.
//

import SwiftUI

struct CustomAsyncImage: View {
    var imageURL: URL?
    
    var body: some View {
        AsyncImage(
            url: imageURL,
            transaction: Transaction(animation: .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.25))
        ) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .transition(.scale)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            case .failure(_), .empty:
                Image(systemName: "photo.circle.fill")
                    .resizable()
                    .scaledToFit()
            @unknown default:
                ProgressView()
            }
        }
    }
}
