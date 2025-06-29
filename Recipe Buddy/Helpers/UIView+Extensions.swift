import SwiftUI

// EndEditing keyboard extension
extension View {
    func endEditing() {
        // (TextField, SecureField etc.) resign first responder
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
