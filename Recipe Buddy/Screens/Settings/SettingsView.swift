import SwiftUI

struct SettingsView: View {
    @AppStorage("appearance") private var appearance = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Görünüm") {
                    Picker("Tema", selection: $appearance) {
                        Text("Sistem").tag("")
                        Text("Açık").tag("light")
                        Text("Koyu").tag("dark")
                    }
                }
                
                Section("Uygulama Hakkında") {
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                       let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        HStack {
                            Text("Versiyon")
                            Spacer()
                            Text("\(version) (\(buildNumber))")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Ayarlar")
        }
    }
}
