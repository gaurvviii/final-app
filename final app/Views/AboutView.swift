import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            AppTheme.nightBlack.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    // App Logo and Header
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primaryPurple)
                                .frame(width: 100, height: 100)
                                .shadow(color: AppTheme.primaryPurple.opacity(0.5), radius: 20)
                            
                            Image(systemName: "shield.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        
                        Text("Nyx")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        Text("Women's Safety App")
                            .font(.title2)
                            .foregroundColor(AppTheme.primaryPurple)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 20)
                    
                    // Mission Statement
                    ProfileSectionCard(title: "Our Mission") {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Nyx is dedicated to empowering women with technology that enhances their safety and peace of mind. We believe every woman should feel secure whether she's walking home at night, traveling to new places, or simply going about her daily life.")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .lineSpacing(6)
                            
                            Text("Our app combines real-time safety data, emergency response features, and community support to create a comprehensive safety network.")
                                .foregroundColor(.gray)
                                .font(.caption)
                                .lineSpacing(4)
                        }
                        .padding()
                    }
                    
                    // Key Features
                    ProfileSectionCard(title: "Key Features") {
                        VStack(spacing: 0) {
                            FeatureRow(
                                icon: "location.fill",
                                title: "Real-time Safety Map",
                                description: "Live crime data and safe zones"
                            )
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            FeatureRow(
                                icon: "person.2.fill",
                                title: "Emergency Contacts",
                                description: "Quick access to trusted contacts"
                            )
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            FeatureRow(
                                icon: "exclamationmark.triangle.fill",
                                title: "SOS Emergency Alert",
                                description: "One-touch emergency assistance"
                            )
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            FeatureRow(
                                icon: "shield.fill",
                                title: "Crime Hotspot Alerts",
                                description: "Stay informed about unsafe areas"
                            )
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            FeatureRow(
                                icon: "tram.fill",
                                title: "Safe Transit Info",
                                description: "Metro and transport safety data"
                            )
                        }
                    }
                    
                    // Technology Stack
                    ProfileSectionCard(title: "Built With") {
                        VStack(alignment: .leading, spacing: 15) {
                            TechRow(title: "SwiftUI", description: "Modern iOS user interface")
                            TechRow(title: "MapKit", description: "Interactive safety maps")
                            TechRow(title: "CoreLocation", description: "Precise location services")
                            TechRow(title: "Real-time APIs", description: "Live crime and safety data")
                        }
                        .padding()
                    }
                    
                    // Team
                    ProfileSectionCard(title: "Development Team") {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("This app was developed with a focus on user privacy, reliability, and effectiveness. Our team consists of developers, UX designers, and safety experts who are passionate about women's safety.")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .lineSpacing(6)
                        }
                        .padding()
                    }
                    
                    // Data Sources
                    ProfileSectionCard(title: "Data Sources") {
                        VStack(alignment: .leading, spacing: 12) {
                            DataSourceRow(
                                title: "Police Station Data",
                                source: "Official government databases"
                            )
                            DataSourceRow(
                                title: "Crime Statistics",
                                source: "National Crime Records Bureau"
                            )
                            DataSourceRow(
                                title: "Transport Information",
                                source: "Public transport authorities"
                            )
                            DataSourceRow(
                                title: "News Updates",
                                source: "Verified news sources"
                            )
                        }
                        .padding()
                    }
                    
                    // Privacy Note
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Privacy First")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Your privacy and data security are our top priorities. All personal information is encrypted and stored locally on your device. Location data is only used for safety features and is never shared without your explicit consent.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(AppTheme.darkGray)
                    .cornerRadius(15)
                    
                    // Contact Info
                    VStack(spacing: 15) {
                        Text("Contact Us")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            if let url = URL(string: "mailto:support@nyx-safety.com") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("support@nyx-safety.com")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.primaryPurple)
                        }
                        
                        Text("© 2024 Nyx Safety. All rights reserved.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
        }
        .navigationBarTitle("About", displayMode: .inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(AppTheme.primaryPurple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal)
    }
}

struct TechRow: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Text("•")
                .font(.headline)
                .foregroundColor(AppTheme.primaryPurple)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

struct DataSourceRow: View {
    let title: String
    let source: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            
            Text(source)
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AboutView()
} 