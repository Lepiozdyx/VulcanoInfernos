import SwiftUI

struct ToggleRow: View {
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color(red: 1.0, green: 0.4, blue: 0.1))
        }
        .padding()
    }
}

#Preview {
    VStack(spacing: 0) {
        ToggleRow(label: "Sounds", isOn: .constant(true))

        ToggleRow(label: "Music", isOn: .constant(false))
    }
    .background(.gray)
    .padding()
}
