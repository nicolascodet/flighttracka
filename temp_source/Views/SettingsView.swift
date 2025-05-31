import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var flightManager: FlightManager
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var homeAddress = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("your@email.com", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Home Address")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("123 Main St, City, State", text: $homeAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Email notifications will be sent when flight status changes. Home address is used to calculate when you should leave for the airport.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Section {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                        Text("Push Notifications")
                        Spacer()
                        Text("Enabled")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text("Location Services")
                        Spacer()
                        Text("When In Use")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Permissions")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Version 1.0")
                            .font(.system(size: 14))
                        Text("Built with SwiftUI")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
            .onAppear {
                email = flightManager.userEmail
                homeAddress = flightManager.homeAddress
            }
        }
    }
    
    private func saveSettings() {
        flightManager.userEmail = email
        flightManager.homeAddress = homeAddress
        
        // Save to UserDefaults
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(homeAddress, forKey: "homeAddress")
    }
} 