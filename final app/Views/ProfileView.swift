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
        ZStack {
            AppTheme.nightBlack.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.darkGray)
                                .frame(width: 100, height: 100)
                                .shadow(color: Color.black.opacity(0.2), radius: 10)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.primaryPurple)
                        }
                        
                        Text(userName.isEmpty ? "Set up your profile" : userName)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        if !userPhone.isEmpty {
                            Text(userPhone)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            showingEditProfile = true
                        }) {
                            Text("Edit Profile")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(AppTheme.primaryPurple)
                                .cornerRadius(25)
                        }
                    }
                    .padding(.vertical, 30)
                    
                    // Safety Settings Section
                    ProfileSectionCard(title: "Safety Settings") {
                        ToggleSettingRow(
                            title: "Enable Notifications",
                            icon: "bell.fill",
                            color: .blue,
                            isOn: $notificationsEnabled
                        )
                        
                        ToggleSettingRow(
                            title: "Location Tracking",
                            icon: "location.fill",
                            color: .green,
                            isOn: $locationTrackingEnabled
                        )
                        
                        ToggleSettingRow(
                            title: "Auto Record in Emergency",
                            icon: "record.circle.fill",
                            color: .red,
                            isOn: $autoRecordEnabled
                        )
                    }
                    
                    // Emergency Settings Section
                    ProfileSectionCard(title: "Emergency Settings") {
                        NavigationSettingRow(
                            title: "Emergency Contacts",
                            icon: "person.2.fill",
                            color: AppTheme.primaryPurple,
                            destination: AnyView(EmergencyContactsView())
                        )
                        
                        TextSettingRow(
                            title: "Emergency Message",
                            icon: "message.fill",
                            color: AppTheme.deepBlue,
                            text: $emergencyMessage
                        )
                    }
                    
                    // Privacy & Security Section
                    ProfileSectionCard(title: "Privacy & Security") {
                        NavigationSettingRow(
                            title: "Privacy Settings",
                            icon: "lock.fill",
                            color: .orange,
                            destination: AnyView(PrivacySettingsView())
                        )
                        
                        NavigationSettingRow(
                            title: "Safety Preferences",
                            icon: "shield.fill",
                            color: .green,
                            destination: AnyView(SafetyPreferencesView())
                        )
                    }
                    
                    // Help & Support Section
                    ProfileSectionCard(title: "Help & Support") {
                        SettingRow(
                            title: "Help Center",
                            icon: "questionmark.circle.fill",
                            color: .blue
                        ) {
                            // Open help center
                        }
                        
                        SettingRow(
                            title: "Contact Support",
                            icon: "envelope.fill",
                            color: .green
                        ) {
                            // Contact support
                        }
                        
                        SettingRow(
                            title: "About",
                            icon: "info.circle.fill",
                            color: AppTheme.primaryPurple
                        ) {
                            // Show about
                        }
                    }
                    
                    // Version Info
                    HStack {
                        Spacer()
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 100) // Extra padding for tab bar
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Profile")
        .navigationBarHidden(true)
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(userName: $userName, userPhone: $userPhone)
        }
    }
}

struct ProfileSectionCard: View {
    let title: String
    let content: AnyView
    
    init(title: String, @ViewBuilder content: () -> some View) {
        self.title = title
        self.content = AnyView(content())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 5)
            
            VStack(spacing: 0) {
                content
            }
            .background(AppTheme.darkGray)
            .cornerRadius(15)
        }
    }
}

struct SettingRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 15)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NavigationSettingRow: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 15)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ToggleSettingRow: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: AppTheme.primaryPurple))
        }
        .padding(.vertical, 15)
        .padding(.horizontal)
    }
}

struct TextSettingRow: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            TextEditor(text: $text)
                .foregroundColor(.black)
                .padding(10)
                .frame(height: 100)
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
                .padding(.leading, 30)
        }
        .padding(.vertical, 15)
        .padding(.horizontal)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var userName: String
    @Binding var userPhone: String
    @State private var tempName: String = ""
    @State private var tempPhone: String = ""
    
    var body: some View {
        ZStack {
            AppTheme.nightBlack.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("Edit Profile")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        userName = tempName
                        userPhone = tempPhone
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(tempName.isEmpty ? .gray : AppTheme.primaryPurple)
                    }
                    .disabled(tempName.isEmpty)
                }
                .padding()
                
                ZStack {
                    Circle()
                        .fill(AppTheme.darkGray)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.primaryPurple)
                    
                    Circle()
                        .stroke(AppTheme.primaryPurple, lineWidth: 3)
                        .frame(width: 100, height: 100)
                }
                .padding(.top, 20)
                
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextField("", text: $tempName)
                            .placeholder(when: tempName.isEmpty) {
                                Text("Enter your name").foregroundColor(.gray.opacity(0.5))
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(AppTheme.darkGray)
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone Number")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextField("", text: $tempPhone)
                            .placeholder(when: tempPhone.isEmpty) {
                                Text("Enter your phone number").foregroundColor(.gray.opacity(0.5))
                            }
                            .foregroundColor(.white)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(AppTheme.darkGray)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Privacy Note")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Your information is kept private and only used for emergency purposes.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkGray)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            tempName = userName
            tempPhone = userPhone
        }
    }
}

// Helper extension for placeholder text in TextField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
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
        ZStack {
            AppTheme.nightBlack.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    // App Permissions Section
                    ProfileSectionCard(title: "App Permissions") {
                        ToggleSettingRow(
                            title: "Location Access",
                            icon: "location.fill",
                            color: .blue,
                            isOn: $locationAccess
                        )
                        
                        ToggleSettingRow(
                            title: "Camera Access",
                            icon: "camera.fill",
                            color: .green,
                            isOn: $cameraAccess
                        )
                        
                        ToggleSettingRow(
                            title: "Microphone Access",
                            icon: "mic.fill",
                            color: .orange,
                            isOn: $microphoneAccess
                        )
                        
                        ToggleSettingRow(
                            title: "Notification Access",
                            icon: "bell.fill",
                            color: .red,
                            isOn: $notificationAccess
                        )
                    }
                    
                    // Data & Privacy Section
                    ProfileSectionCard(title: "Data & Privacy") {
                        SettingRow(
                            title: "Delete All Data",
                            icon: "trash.fill",
                            color: .red
                        ) {
                            showingDeleteConfirmation = true
                        }
                        
                        SettingRow(
                            title: "Export My Data",
                            icon: "square.and.arrow.up.fill",
                            color: .blue
                        ) {
                            // Handle data export
                        }
                        
                        NavigationSettingRow(
                            title: "Privacy Policy",
                            icon: "doc.text.fill",
                            color: AppTheme.primaryPurple,
                            destination: AnyView(Text("Privacy Policy Content")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(AppTheme.nightBlack)
                            )
                        )
                    }
                    
                    // About Privacy Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About Your Privacy")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("We take your privacy seriously. Your data is stored locally on your device and is only shared with emergency contacts when you explicitly initiate an SOS alert. Your location data is only used for safety features and is never sold or shared with third parties.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(AppTheme.darkGray)
                    .cornerRadius(15)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
                .padding(.top)
            }
        }
        .navigationBarTitle("Privacy Settings", displayMode: .inline)
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
    @State private var selectedTheme = 0
    
    private let themes = ["System Default", "Dark Mode", "Light Mode"]
    
    var body: some View {
        ZStack {
            AppTheme.nightBlack.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    // Safety Zone Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Safety Zone")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "circle.dashed")
                                    .font(.system(size: 22))
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                
                                Text("Safety Radius: \(Int(safetyRadius * 1000))m")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal)
                            
                            Slider(value: $safetyRadius, in: 0.1...5.0)
                                .accentColor(AppTheme.primaryPurple)
                                .padding(.horizontal, 40)
                            
                            Text("Safe zones are areas within the defined radius around your trusted locations.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 40)
                                .padding(.bottom, 10)
                        }
                        .background(AppTheme.darkGray)
                        .cornerRadius(15)
                    }
                    
                    // Alert Settings Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Alert Settings")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                        
                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: "speaker.wave.3.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.orange)
                                        .frame(width: 30)
                                    
                                    Text("Alert Volume")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                                
                                Slider(value: $alertVolume)
                                    .accentColor(AppTheme.primaryPurple)
                                    .padding(.horizontal, 40)
                                    .padding(.bottom, 10)
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            ToggleSettingRow(
                                title: "Enable Vibration",
                                icon: "iphone.radiowaves.left.and.right",
                                color: .green,
                                isOn: $vibrationEnabled
                            )
                        }
                        .background(AppTheme.darkGray)
                        .cornerRadius(15)
                    }
                    
                    // Recording Settings Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recording Settings")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "record.circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(.red)
                                    .frame(width: 30)
                                
                                Text("Auto Record Duration: \(Int(autoRecordDuration)) minutes")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal)
                            
                            Slider(value: $autoRecordDuration, in: 1...30, step: 1)
                                .accentColor(AppTheme.primaryPurple)
                                .padding(.horizontal, 40)
                            
                            Text("Audio will be automatically recorded during an emergency for the specified duration.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 40)
                                .padding(.bottom, 10)
                        }
                        .background(AppTheme.darkGray)
                        .cornerRadius(15)
                    }
                    
                    // App Theme Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("App Theme")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                        
                        VStack(alignment: .leading) {
                            Picker("Theme", selection: $selectedTheme) {
                                ForEach(0..<themes.count, id: \.self) { index in
                                    Text(themes[index])
                                        .foregroundColor(.white)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                        }
                        .background(AppTheme.darkGray)
                        .cornerRadius(15)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
                .padding(.top)
            }
        }
        .navigationBarTitle("Safety Preferences", displayMode: .inline)
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
} 
