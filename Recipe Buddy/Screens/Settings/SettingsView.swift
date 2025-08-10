import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let user = viewModel.currentUser {
                        profileHeader(user: user)
                    }
                    
                    accountSection
                    aboutSection
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color("FBFBFB"))
            .toolbarBackground(.thinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Ayarlar")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.EBA_72_B)
                }
            }
            .task {
                await viewModel.fetchCurrentUser()
            }
            .alert("Yakında", isPresented: $viewModel.showPremiumAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text("Bu özellik yakında sizlerle olacak!")
            }
            
            if viewModel.isSigningOut {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView("Çıkış yapılıyor...")
                    .padding(20)
                    .background(.thinMaterial)
                    .cornerRadius(12)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: viewModel.isSigningOut)
    }
    
    /// A header view that displays the user's profile information.
    private func profileHeader(user: User) -> some View {
        HStack(spacing: 16) {
            AsyncImage(url: user.avatarPublicURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray.opacity(0.5))
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName ?? "İsimsiz")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(user.username ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .onTapGesture {
            navigationPath.append(AppNavigation.profile)
        }
    }
    
    /// Section for account-related actions.
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HESAP")
                .font(.caption).foregroundStyle(.secondary).padding(.leading, 4)
            
            VStack(spacing: 0) {
                // Premium Button
                Button(action: { viewModel.showPremiumAlert = true }) {
                    SettingsRowView(title: "Üyeliği Yönet", icon: "crown.fill", iconColor: .EBA_72_B)
                }
                
                Divider().padding(.leading)
                
                Button(action: {
                    Task { await viewModel.signOut() }
                }) {
                    SettingsRowView(title: "Çıkış Yap", icon: "arrow.left.square.fill", iconColor: .red)
                }
                .disabled(viewModel.isSigningOut)
            }
            .background(.thinMaterial.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
        }
    }
    
    /// Section for app information like policies and version.
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HAKKINDA")
                .font(.caption)
                .foregroundStyle(.A_3_A_3_A_3)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                // These will open a web browser
                Link(destination: URL(string: "https://www.yourapp.com/privacy")!) {
                    SettingsRowView(title: "Gizlilik Politikası", icon: "shield.fill", iconColor: .A_3_A_3_A_3)
                }
                
                Divider().padding(.leading)
                
                Link(destination: URL(string: "https://www.yourapp.com/terms")!) {
                    SettingsRowView(title: "Kullanım Koşulları", icon: "doc.text.fill", iconColor: .A_3_A_3_A_3)
                }
                
                Divider().padding(.leading)
                
                SettingsRowView(
                    title: "Versiyon",
                    icon: "info.circle.fill",
                    iconColor: .A_3_A_3_A_3,
                    version: appVersion()
                )
            }
            .background(.thinMaterial.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
        }
    }
    
    /// A helper function to get the app version.
    private func appVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return "Bilinmiyor"
        }
        return "\(version) (\(build))"
    }
}

/// A reusable view for a single row in the settings screen.
struct SettingsRowView: View {
    let title: String
    let icon: String
    let iconColor: Color
    var version: String? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(iconColor)
            
            Text(title)
                .foregroundStyle(._181818)
            
            Spacer()
            
            if let version {
                Text(version)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(.EBA_72_B)
            }
        }
        .padding()
    }
}

