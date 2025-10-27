import SwiftUI

struct ToggleRow: View {
    let label: String
    let isOn: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Text(label)
                .titanFont(18)
            
            Spacer()
            
            Button(action: action) {
                Image(isOn ? .check : .x)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .animation(.default, value: isOn)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    VStack(spacing: 0) {
        ToggleRow(label: "Sounds", isOn: true, action: {})

        ToggleRow(label: "Music", isOn: false, action: {})
    }
    .background(.gray)
    .padding()
}
