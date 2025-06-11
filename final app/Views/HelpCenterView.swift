import SwiftUI

struct HelpCenterView: View {
    var body: some View {
        ZStack {
            AppTheme.nightBlack.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 15) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.primaryPurple)
                        
                        Text("Help Center")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        Text("Find answers to common questions and get help with using the app")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 20)
                    
                    // FAQ Section
                    ProfileSectionCard(title: "Frequently Asked Questions") {
                        VStack(spacing: 0) {
                            FAQRow(
                                question: "How do I set up emergency contacts?",
                                answer: "Go to Profile > Emergency Settings > Emergency Contacts to add trusted contacts who will receive your SOS messages."
                            )
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            FAQRow(
                                question: "How does the SOS feature work?",
                                answer: "Press and hold the red SOS button for 2 seconds. This will send your location and emergency message to your contacts and optionally call emergency services."
                            )
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            FAQRow(
                                question: "Can I use the app without internet?",
                                answer: "Basic safety features work offline, but real-time crime data and news updates require an internet connection."
                            )
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            FAQRow(
                                question: "How accurate is the safety data?",
                                answer: "We use official crime statistics and police station data. Crime hotspots are updated regularly based on reported incidents."
                            )
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            FAQRow(
                                question: "Why does the app need location access?",
                                answer: "Location access is essential for showing nearby safety resources, sending accurate emergency alerts, and providing location-based safety information."
                            )
                        }
                    }
                    
                    // Quick Actions Section
                    ProfileSectionCard(title: "Quick Actions") {
                        VStack(spacing: 0) {
                            SettingRow(
                                title: "Contact Emergency Services",
                                icon: "phone.fill",
                                color: .red
                            ) {
                                if let url = URL(string: "tel://100") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            SettingRow(
                                title: "Report a Bug",
                                icon: "exclamationmark.triangle.fill",
                                color: .orange
                            ) {
                                if let url = URL(string: "mailto:support@safetyfirst.com?subject=Bug Report") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            SettingRow(
                                title: "Feature Request",
                                icon: "lightbulb.fill",
                                color: .yellow
                            ) {
                                if let url = URL(string: "mailto:support@safetyfirst.com?subject=Feature Request") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                    }
                    
                    // Safety Tips Section
                    ProfileSectionCard(title: "Safety Tips") {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("• Always share your location with trusted contacts when traveling alone")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            
                            Text("• Keep your emergency contacts updated and test the SOS feature regularly")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            
                            Text("• Stay aware of your surroundings, especially in unfamiliar areas")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            
                            Text("• Trust your instincts - if something feels wrong, seek help immediately")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            
                            Text("• Keep your phone charged and consider carrying a portable charger")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        .padding()
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
        }
        .navigationBarTitle("Help Center", displayMode: .inline)
    }
}

struct FAQRow: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 15)
                .padding(.horizontal)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(answer)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                    .transition(.opacity.combined(with: .slide))
            }
        }
    }
}

#Preview {
    HelpCenterView()
} 