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
        VStack(spacing: 6) {
            if showLabel {
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(red: 1.0, green: 0.4, blue: 0.1))
                    Text("\(currentEnergy) / \(maxEnergy)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.6, blue: 0.0),
                                    Color(red: 1.0, green: 0.3, blue: 0.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                        .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.1).opacity(0.6), radius: 4, x: 0, y: 2)
                }
            }
            .frame(height: 16)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentEnergy)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        EnergyBar(currentEnergy: 50, maxEnergy: 100, showLabel: true)
        EnergyBar(currentEnergy: 75, maxEnergy: 100, showLabel: true)
        EnergyBar(currentEnergy: 100, maxEnergy: 100, showLabel: true)
    }
    .padding()
    .background(Color.black)
}
