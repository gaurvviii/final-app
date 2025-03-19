import SwiftUI

struct ProfileView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("userPhone") private var userPhone = ""
    @AppStorage("emergencyMessage") private var emergencyMessage = "I need help! This is an emergency."
    @State private var showingEditProfile = false
    @State private var showingEmergencyContacts = false
    @State private var notificationsEnabled = true
    @State private var locationTrackingEnabled = true
    @State private var autoRecordEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppTheme.primaryPurple)
                        
                        Text(userName.isEmpty ? "Set up your profile" : userName)
                            .font(.headline)
                        
                        if !userPhone.isEmpty {
                            Text(userPhone)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Button("Edit Profile") {
                            showingEditProfile = true
                        }
                        .foregroundColor(AppTheme.deepBlue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                
                // Emergency Settings
                Section(header: Text("Emergency Settings")) {
                    NavigationLink(destination: EmergencyContactsView()) {
                        Label("Emergency Contacts", systemImage: "person.2.fill")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Emergency Message")
                            .font(.headline)
                        TextEditor(text: $emergencyMessage)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2))
                            )
                    }
                    .padding(.vertical, 8)
                }
                
                // Safety Settings
                Section(header: Text("Safety Settings")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Location Tracking", isOn: $locationTrackingEnabled)
                    Toggle("Auto Record in Emergency", isOn: $autoRecordEnabled)
                }
                
                // Privacy & Security
                Section(header: Text("Privacy & Security")) {
                    NavigationLink(destination: PrivacySettingsView()) {
                        Label("Privacy Settings", systemImage: "lock.fill")
                    }
                    
                    NavigationLink(destination: SafetyPreferencesView()) {
                        Label("Safety Preferences", systemImage: "shield.fill")
                    }
                }
                
                // Help & Support
                Section(header: Text("Help & Support")) {
                    Button(action: {
                        // Open help center
                    }) {
                        Label("Help Center", systemImage: "questionmark.circle.fill")
                    }
                    
                    Button(action: {
                        // Contact support
                    }) {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }
                    
                    Button(action: {
                        // Show about
                    }) {
                        Label("About", systemImage: "info.circle.fill")
                    }
                }
                
                // Version Info
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(userName: $userName, userPhone: $userPhone)
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var userName: String
    @Binding var userPhone: String
    @State private var tempName: String = ""
    @State private var tempPhone: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Your Name", text: $tempName)
                    TextField("Phone Number", text: $tempPhone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Note")) {
                    Text("Your information is kept private and only used for emergency purposes.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    userName = tempName
                    userPhone = tempPhone
                    dismiss()
                }
                .disabled(tempName.isEmpty)
            )
            .onAppear {
                tempName = userName
                tempPhone = userPhone
            }
        }
    }
}

struct PrivacySettingsView: View {
    @State private var locationAccess = true
    @State private var cameraAccess = true
    @State private var microphoneAccess = true
    @State private var notificationAccess = true
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        Form {
            Section(header: Text("App Permissions")) {
                Toggle("Location Access", isOn: $locationAccess)
                Toggle("Camera Access", isOn: $cameraAccess)
                Toggle("Microphone Access", isOn: $microphoneAccess)
                Toggle("Notification Access", isOn: $notificationAccess)
            }
            
            Section(header: Text("Data & Privacy")) {
                Button(action: { showingDeleteConfirmation = true }) {
                    HStack {
                        Text("Delete All Data")
                        Spacer()
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.red)
                }
                
                Button(action: {
                    // Handle data export
                }) {
                    Text("Export My Data")
                }
                
                NavigationLink(destination: Text("Privacy Policy Content")) {
                    Text("Privacy Policy")
                }
            }
        }
        .navigationTitle("Privacy Settings")
        .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Handle data deletion
            }
        } message: {
            Text("Are you sure you want to delete all your data? This action cannot be undone.")
        }
    }
}

struct SafetyPreferencesView: View {
    @State private var safetyRadius: Double = 1.0
    @State private var alertVolume: Double = 0.8
    @State private var vibrationEnabled = true
    @State private var autoRecordDuration: Double = 5
    
    var body: some View {
        Form {
            Section(header: Text("Safety Zone")) {
                VStack(alignment: .leading) {
                    Text("Safety Radius: \(Int(safetyRadius * 1000))m")
                    Slider(value: $safetyRadius, in: 0.1...5.0)
                }
            }
            
            Section(header: Text("Alert Settings")) {
                VStack(alignment: .leading) {
                    Text("Alert Volume")
                    Slider(value: $alertVolume)
                }
                Toggle("Enable Vibration", isOn: $vibrationEnabled)
            }
            
            Section(header: Text("Recording Settings")) {
                VStack(alignment: .leading) {
                    Text("Auto Record Duration: \(Int(autoRecordDuration)) minutes")
                    Slider(value: $autoRecordDuration, in: 1...30, step: 1)
                }
            }
        }
        .navigationTitle("Safety Preferences")
    }
}

#Preview {
    ProfileView()
} 