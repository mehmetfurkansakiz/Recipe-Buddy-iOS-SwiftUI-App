import SwiftUI

struct AuthTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var contentType: UITextContentType? = nil
    
    var body: some View {
        Group {
            if isSecure {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color("A3A3A3")))
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color("A3A3A3")))
            }
        }
        .padding()
        .tint(Color("EBA72B"))
        .autocapitalization(.none)
        .textContentType(contentType)
        .autocorrectionDisabled(true)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("A3A3A3").opacity(0.5))
                    .offset(y: 1)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("F2F2F7"))
            }
        )
    }
}

#Preview {
    AuthTextField(placeholder: "placeholder", text: Binding<String>(get: { "" }, set: { _ in }))
        .padding()
}
