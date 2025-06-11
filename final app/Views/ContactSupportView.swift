import SwiftUI

struct ContactSupportView: View {
    @State private var selectedOption: SupportOption?
    @State private var message = ""
    @State private var userEmail = ""
    @State private var showingSubmitAlert = false
    
    enum SupportOption: String, CaseIterable {
        case bug = "Report a Bug"
        case feature = "Feature Request"
        case technical = "Technical Issue"
        case safety = "Safety Concern"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .bug: return "exclamationmark.triangle.fill"
            case .feature: return "lightbulb.fill"
            case .technical: return "gear.fill"
            case .safety: return "shield.fill"
            case .other: return "questionmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .bug: return .red
            case .feature: return .yellow
            case .technical: return .blue
            case .safety: return .orange
            case .other: return .gray
            }
        }
    }
    
    var body: some View {
        ZStack {
            AppTheme.nightBlack.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 15) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.primaryPurple)
                        
                        Text("Contact Support")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        Text("We're here to help! Choose how you'd like to get in touch.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 20)
                    
                    // Quick Contact Options
                    ProfileSectionCard(title: "Quick Contact") {
                        VStack(spacing: 0) {
                            SettingRow(
                                title: "Call Emergency Support",
                                icon: "phone.fill",
                                color: .red
                            ) {
                                if let url = URL(string: "tel://100") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            SettingRow(
                                title: "Email Support",
                                icon: "envelope.fill",
                                color: .blue
                            ) {
                                if let url = URL(string: "mailto:support@safetyfirst.com") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            SettingRow(
                                title: "Live Chat",
                                icon: "message.fill",
                                color: .green
                            ) {
                                // Open live chat
                            }
                        }
                    }
                    
                    // Contact Form
                    ProfileSectionCard(title: "Send us a Message") {
                        VStack(alignment: .leading, spacing: 20) {
                            // Email Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Email")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                TextField("", text: $userEmail)
                                    .placeholder(when: userEmail.isEmpty) {
                                        Text("Enter your email").foregroundColor(.gray.opacity(0.5))
                                    }
                                    .foregroundColor(.white)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(AppTheme.nightBlack)
                                    .cornerRadius(10)
                            }
                            
                            // Support Type Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("What can we help you with?")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                ForEach(SupportOption.allCases, id: \.self) { option in
                                    Button(action: {
                                        selectedOption = option
                                    }) {
                                        HStack {
                                            Image(systemName: option.icon)
                                                .font(.system(size: 20))
                                                .foregroundColor(option.color)
                                                .frame(width: 30)
                                            
                                            Text(option.rawValue)
                                                .font(.system(size: 16))
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            Image(systemName: selectedOption == option ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(selectedOption == option ? AppTheme.primaryPurple : .gray)
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 15)
                                        .background(selectedOption == option ? AppTheme.primaryPurple.opacity(0.1) : Color.clear)
                                        .cornerRadius(10)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            // Message Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Message")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                TextEditor(text: $message)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .frame(height: 120)
                                    .background(AppTheme.nightBlack)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            // Submit Button
                            Button(action: {
                                showingSubmitAlert = true
                            }) {
                                Text("Send Message")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        canSubmit ? AppTheme.primaryPurple : Color.gray
                                    )
                                    .cornerRadius(10)
                            }
                            .disabled(!canSubmit)
                        }
                        .padding()
                    }
                    
                    // Response Time Info
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Response Time")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("We typically respond within 24 hours for general inquiries and within 1 hour for safety-related concerns.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(AppTheme.darkGray)
                    .cornerRadius(15)
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
        }
        .navigationBarTitle("Contact Support", displayMode: .inline)
        .alert("Message Sent", isPresented: $showingSubmitAlert) {
            Button("OK") {
                // Reset form
                message = ""
                userEmail = ""
                selectedOption = nil
            }
        } message: {
            Text("Thank you for contacting us! We'll get back to you as soon as possible.")
        }
    }
    
    private var canSubmit: Bool {
        !userEmail.isEmpty && selectedOption != nil && !message.isEmpty
    }
}

#Preview {
    ContactSupportView()
} 