import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                if viewModel.isLoading {
                    ProgressView()
                } else if let user = viewModel.currentUser {
                    profileHeader(user: user)
                    statsSection
                    actionsSection
                } else {
                    Text("Kullanıcı bilgileri yüklenemedi.")
                }
            }
            .padding()
        }
        .background(Color.FBFBFB)
        .navigationTitle("Profilim")
        .task {
            await viewModel.fetchAllProfileData()
        }
    }
    
    /// The main header with avatar, name, and username.
    private func profileHeader(user: User) -> some View {
        VStack(spacing: 16) {
            AsyncImage(url: user.avatarPublicURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.gray.opacity(0.3))
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.systemGray5), lineWidth: 1))
            
            VStack {
                Text(user.fullName ?? "İsimsiz")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("@\(user.username ?? "")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // TODO: Navigate to an edit screen
            Button("Profili Düzenle") { }
                .fontWeight(.semibold)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.15))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
    }
    
    /// The section with user stats like recipe and favorite counts.
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("İSTATİSTİKLER")
                .font(.caption).foregroundStyle(.secondary).padding(.leading, 4)
            
            HStack(spacing: 12) {
                ProfileStatView(count: viewModel.ownedRecipeCount, title: "Tariflerim")
                ProfileStatView(count: viewModel.totalFavoritesReceived, title: "Alınan Favori")
                ProfileStatView(value: String(format: "%.1f", viewModel.averageRating), title: "Ort. Puan"
                )
            }
        }
    }
    
    /// The section for actions like logging out or deleting the account.
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HESAP İŞLEMLERİ")
                .font(.caption).foregroundStyle(.secondary).padding(.leading, 4)
            
            VStack(spacing: 0) {
                Button(role: .destructive, action: {
                    Task { await viewModel.signOut() }
                }) {
                    SettingsRowView(title: "Çıkış Yap", icon: "arrow.left.square.fill", iconColor: .red)
                }
                
                Divider().padding(.leading)
                
                // TODO: Add a confirmation alert before deleting
                Button(role: .destructive, action: { }) {
                    SettingsRowView(title: "Hesabı Sil", icon: "trash.fill", iconColor: .red)
                }
            }
            .background(.thinMaterial.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
        }
    }
}

/// A reusable view for displaying a single statistic.
struct ProfileStatView: View {
    let value: String
    let title: String
    
    init(count: Int, title: String) {
        self.value = "\(count)"
        self.title = title
    }
    
    init(value: String, title: String) {
        self.value = value
        self.title = title
    }
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
    }
}

#Preview {
    ProfileView(viewModel: ProfileViewModel(coordinator: AppCoordinator()))
}
