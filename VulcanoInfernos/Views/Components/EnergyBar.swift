import SwiftUI

struct EnergyBar: View {
    let currentEnergy: Int
    let maxEnergy: Int
    let showLabel: Bool
    
    private var progress: Double {
        guard maxEnergy > 0 else { return 0 }
        return Double(currentEnergy) / Double(maxEnergy)
    }
    
    var body: some View {
        HStack(spacing: 2) {
            if showLabel {
                Image(.energy)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Image(.scale)
                        .resizable()
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.5, blue: 0.0),
                                    Color(red: 1.0, green: 0.1, blue: 0.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress,height: 8)
                        .padding(.horizontal, 2)
                        .offset(y: -0.5)
                }
            }
            .frame(height: 16)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentEnergy)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        EnergyBar(currentEnergy: 10, maxEnergy: 100, showLabel: true)
        EnergyBar(currentEnergy: 75, maxEnergy: 100, showLabel: true)
        EnergyBar(currentEnergy: 100, maxEnergy: 100, showLabel: true)
    }
    .frame(width: 180)
    .padding()
}
