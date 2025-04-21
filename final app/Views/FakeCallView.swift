import SwiftUI
import AVFoundation

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}

class FakeCallViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var shouldDismiss = false
    private var audioPlayer: AVAudioPlayer?
    private var audioDelegate: AudioPlayerDelegate?
    private var systemSoundID: SystemSoundID?
    
    func setupAudio(for callerName: String, onFinish: @escaping () -> Void) {
        print("🎵 Setting up audio for caller: \(callerName)")
        
        if callerName == "Mom" {
            if let path = Bundle.main.path(forResource: "mom", ofType: "mp3") {
                print("🎵 Found mom.mp3 at path: \(path)")
                let url = URL(fileURLWithPath: path)
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)
                    
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.prepareToPlay()
                    
                    // Set up delegate to handle audio completion
                    audioDelegate = AudioPlayerDelegate(onFinish: {
                        self.isPlaying = false
                        self.shouldDismiss = true
                        onFinish()
                    })
                    audioPlayer?.delegate = audioDelegate
                    
                    if audioPlayer?.play() == true {
                        print("🎵 Started playing mom's audio")
                        isPlaying = true
                    } else {
                        print("❌ Failed to start playing audio")
                        playSystemSound()
                    }
                } catch {
                    print("❌ Audio setup error: \(error.localizedDescription)")
                    playSystemSound()
                }
            } else {
                print("❌ Could not find mom.mp3 in bundle")
                playSystemSound()
            }
        } else {
            playSystemSound()
        }
    }
    
    private func playSystemSound() {
        print("🔊 Playing system sound")
        var soundID: SystemSoundID = 0
        if let soundURL = Bundle.main.url(forResource: "ringtone", withExtension: "mp3") {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
            systemSoundID = soundID
            AudioServicesPlaySystemSound(soundID)
            isPlaying = true
            
            // For system sounds, we need to manually set a timer since there's no completion callback
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                self.stopAudio()
                self.shouldDismiss = true
            }
        } else {
            AudioServicesPlaySystemSound(1322)
            isPlaying = true
            
            // For default system sound
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                self.stopAudio()
                self.shouldDismiss = true
            }
        }
    }
    
    func stopAudio() {
        if let player = audioPlayer {
            player.stop()
            isPlaying = false
        }
        if let soundID = systemSoundID {
            AudioServicesDisposeSystemSoundID(soundID)
            systemSoundID = nil
        }
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

struct FakeCallView: View {
    let callerName: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FakeCallViewModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                
                Text(callerName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(viewModel.isPlaying ? "Call in progress..." : "Incoming call...")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: endCall) {
                    Image(systemName: "phone.down.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                        .foregroundColor(.red)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            viewModel.setupAudio(for: callerName, onFinish: endCall)
        }
        .onChange(of: viewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
    
    private func endCall() {
        viewModel.stopAudio()
        viewModel.shouldDismiss = true
    }
}

#Preview {
    FakeCallView(callerName: "Mom")
} 