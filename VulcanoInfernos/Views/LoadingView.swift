//
//  LoadingView.swift
//  VulcanoInfernos
//
//  Created by Alex on 28.10.2025.
//


import SwiftUI

struct LoadingView: View {
    @State private var loading: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.b1, .b2],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            
            VStack(spacing: -30) {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160)
                
                Image(.loadingTitle)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
            }
            
            VStack {
                Spacer()
                
                Capsule()
                    .foregroundStyle(.gray.opacity(0.4))
                    .frame(maxWidth: 200, maxHeight: 17)
                    .overlay {
                        Capsule()
                            .stroke(.b1, lineWidth: 1.5)
                    }
                    .overlay(alignment: .leading) {
                        Capsule()
                            .foregroundStyle(.white)
                            .frame(width: 198 * loading, height: 15)
                            .padding(.horizontal, 1)
                    }
                    .overlay {
                        Text("Loading")
                            .titanFont(10, color: .b2)
                    }
            }
            .padding()
        }
        .onAppear {
            withAnimation(.linear(duration: 5)) {
                loading = 1
            }
        }
    }
}

#Preview {
    LoadingView()
}
