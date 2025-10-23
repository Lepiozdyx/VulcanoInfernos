import SwiftUI

struct ToggleRow: View {
    let label: String
    let systemIcon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemIcon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 1.0, green: 0.4, blue: 0.1))
                .frame(width: 30)
            
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color(red: 1.0, green: 0.4, blue: 0.1))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

#Preview {
    VStack(spacing: 0) {
        ToggleRow(label: "Sounds", systemIcon: "speaker.wave.2.fill", isOn: .constant(true))
        Divider()
            .background(Color.gray.opacity(0.3))
        ToggleRow(label: "Music", systemIcon: "music.note", isOn: .constant(false))
    }
    .background(Color(red: 0.1, green: 0.1, blue: 0.1))
    .cornerRadius(12)
    .padding()
    .background(Color.black)
}
