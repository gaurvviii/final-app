import SwiftUI
import AVFoundation

struct FakeCallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var fakeCallManager = FakeCallManager()
    @State private var selectedContact = "Mom"
    @State private var delaySeconds = 5.0
    
    let contacts = ["Mom", "Dad", "Sister", "Brother", "Friend"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Contact Selection
                Picker("Select Contact", selection: $selectedContact) {
                    ForEach(contacts, id: \.self) { contact in
                        Text(contact).tag(contact)
                    }
                }
                .pickerStyle(.wheel)
                
                // Delay Slider
                VStack(alignment: .leading) {
                    Text("Call Delay")
                        .font(.headline)
                    
                    HStack {
                        Slider(value: $delaySeconds, in: 0...30, step: 5)
                        Text("\(Int(delaySeconds)) seconds")
                    }
                }
                .padding()
                
                // Start Call Button
                Button(action: {
                    fakeCallManager.scheduleFakeCall(
                        contact: selectedContact,
                        delay: delaySeconds
                    )
                    dismiss()
                }) {
                    Text("Schedule Fake Call")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryPurple)
                        .cornerRadius(15)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Fake Call Setup")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

class FakeCallManager: ObservableObject {
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    func scheduleFakeCall(contact: String, delay: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.startFakeCall(contact: contact)
        }
    }
    
    private func startFakeCall(contact: String) {
        // Show incoming call UI
        let content = UNMutableNotificationContent()
        content.title = "Incoming Call"
        content.body = "Call from \(contact)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                          content: content,
                                          trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        // Play ringtone
        if let url = Bundle.main.url(forResource: "ringtone", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = -1 // Loop indefinitely
                player?.play()
                
                // Stop playing after 30 seconds
                Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { [weak self] _ in
                    self?.player?.stop()
                }
            } catch {
                print("Could not play ringtone: \(error)")
            }
        }
    }
}

#Preview {
    FakeCallView()
} 