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
                colors: [.blue, .purple],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            
            VStack {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .overlay(alignment: .bottom) {
                        VStack(spacing: -50) {
                            Image(.logo)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250)
                            
                            Text("Stay Powered. Stay Focused.")
                                .titanFont(12)
                        }
                        .offset(y: 50)
                    }
                    .offset(y: -100)
                
                Capsule()
                    .foregroundStyle(.black.opacity(0.4))
                    .frame(maxWidth: 200, maxHeight: 17)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .foregroundStyle(.yellow)
                            .frame(width: 198 * loading, height: 15)
                            .padding(.horizontal, 1)
                            .shadow(color: .yellow, radius: 3)
                    }
            }
            .padding()
        }
        .onAppear {
            withAnimation(.linear(duration: 2.5)) {
                loading = 1
            }
        }
    }
}

#Preview {
    LoadingView()
}
