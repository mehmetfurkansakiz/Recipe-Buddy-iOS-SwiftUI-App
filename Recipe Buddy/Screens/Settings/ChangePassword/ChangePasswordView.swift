import SwiftUI

struct ChangePasswordView: View {
    @ObservedObject var viewModel: ChangePasswordViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.FBFBFB.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("PAROLAYI DEĞİŞTİR")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)

                    VStack(spacing: 12) {
                        SecureField("Mevcut Parola", text: $viewModel.currentPassword)
                            .textContentType(.password)
                            .textFieldStyle(CustomTextFieldStyle())

                        SecureField("Yeni Parola (en az 8 karakter)", text: $viewModel.newPassword)
                            .textContentType(.newPassword)
                            .textFieldStyle(CustomTextFieldStyle())

                        SecureField("Yeni Parola (Tekrar)", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                            .textFieldStyle(CustomTextFieldStyle())
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }

                    Button {
                        Task { await viewModel.changePassword() }
                    } label: {
                        Text("Kaydet")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.EBA_72_B)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!viewModel.isValid || viewModel.isSaving)
                    .opacity((!viewModel.isValid || viewModel.isSaving) ? 0.6 : 1.0)
                }
                .padding()
            }
            .navigationTitle("Parola")
            .inlineColoredNavigationBar(titleColor: .EBA_72_B, textStyle: .headline, weight: .bold, hidesOnSwipe: true, transparentBackground: true)
            .onChange(of: viewModel.showSuccess) {
                if viewModel.showSuccess { dismiss() }
            }

            if viewModel.isSaving {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView("Güncelleniyor...")
                    .padding(20)
                    .background(.thinMaterial)
                    .cornerRadius(12)
            }
        }
        .tint(.EBA_72_B)
    }
}

#Preview {
    NavigationStack { ChangePasswordView(viewModel: ChangePasswordViewModel()) }
}
