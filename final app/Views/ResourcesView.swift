import SwiftUI
import MapKit
import AVFoundation

// Add FakeCall model
struct FakeCall: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let delay: TimeInterval
}

struct ResourcesView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab selectors
            HStack {
                TabButton(title: "Safety Stats", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabButton(title: "Resources", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
            }
            .padding()
            .background(AppTheme.darkGray)
            
            // Tab content
            TabView(selection: $selectedTab) {
                SafetyStatsView()
                    .tag(0)
                
                ResourceContentView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(AppTheme.nightBlack)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(isSelected ? AppTheme.primaryPurple : Color.clear)
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ResourceContentView: View {
    @State private var showingFakeCallSheet = false
    @State private var selectedFakeCall: FakeCall?
    
    let resources = [
        Resource(title: "Emergency Helpline", description: "Women's Helpline: 1091", icon: "phone.fill"),
        Resource(title: "Police Control Room", description: "Dial 100", icon: "building.columns.fill"),
        Resource(title: "Women's Commission", description: "State Commission for Women: 080-22100435", icon: "person.2.fill"),
        Resource(title: "Legal Aid", description: "Free legal counsel for women", icon: "doc.text.fill"),
        Resource(title: "Medical Help", description: "Emergency medical assistance", icon: "cross.case.fill"),
        Resource(title: "Shelter Homes", description: "Safe shelter for women in distress", icon: "house.fill"),
        Resource(title: "Counseling Services", description: "Professional mental health support", icon: "brain.head.profile"),
        Resource(title: "Transport Services", description: "Safe transportation options", icon: "car.fill")
    ]
    
    let fakeCallers = [
        FakeCall(name: "Mom", image: "person.circle.fill", delay: 30),
        FakeCall(name: "Dad", image: "person.circle.fill", delay: 30),
        FakeCall(name: "Police", image: "building.columns.fill", delay: 15),
        FakeCall(name: "Custom", image: "person.fill.questionmark", delay: 30)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Fake Call Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Fake Call")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    Text("Schedule a fake call to help you exit uncomfortable situations")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(fakeCallers) { caller in
                                Button(action: {
                                    print("🔘 Selected caller: \(caller.name)")
                                    selectedFakeCall = caller
                                    showingFakeCallSheet = true
                                }) {
                                    FakeCallerCard(caller: caller)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.vertical)
                
                // Existing Emergency Resources section
                Text("Emergency Resources")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                ForEach(resources) { resource in
                    ResourceCard(resource: resource)
                }
                
                // Nearby Police Stations
                VStack(alignment: .leading) {
                    Text("Women's Police Stations")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ForEach(bangalorePoliceStations.filter { $0.name.contains("Women") }) { station in
                        PoliceStationRow(station: station)
                    }
                    
                    Button(action: {
                        // View all stations
                    }) {
                        Text("View All Police Stations")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.primaryPurple)
                            .cornerRadius(15)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .padding(.bottom, 30)
        }
        .background(AppTheme.nightBlack)
        .sheet(isPresented: $showingFakeCallSheet, onDismiss: {
            print("📱 Sheet dismissed")
            selectedFakeCall = nil
        }) {
            if let fakeCall = selectedFakeCall {
                FakeCallSheet(isPresented: $showingFakeCallSheet, fakeCall: fakeCall)
                    .interactiveDismissDisabled()
            }
        }
    }
}

struct Resource: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

struct ResourceCard: View {
    let resource: Resource
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: resource.icon)
                .font(.system(size: 30))
                .foregroundColor(AppTheme.primaryPurple)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(resource.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(resource.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct PoliceStationRow: View {
    let station: PoliceStation
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "building.columns.fill")
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(station.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(station.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                guard let url = URL(string: "tel:\(station.phoneNumber.replacingOccurrences(of: "-", with: ""))") else { return }
                UIApplication.shared.open(url)
            }) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                    .padding(8)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct FakeCallerCard: View {
    let caller: FakeCall
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: caller.image)
                .font(.system(size: 40))
                .foregroundColor(AppTheme.primaryPurple)
            
            Text(caller.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text("\(Int(caller.delay))s")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 100, height: 120)
        .background(AppTheme.darkGray)
        .cornerRadius(15)
    }
}

struct FakeCallSheet: View {
    @Binding var isPresented: Bool
    let fakeCall: FakeCall
    @State private var customName: String = ""
    @State private var selectedDelay: TimeInterval = 30
    @State private var isScheduled = false
    @State private var remainingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingFakeCall = false
    
    let availableDelays: [TimeInterval] = [15, 30, 60, 120]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.nightBlack.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Image(systemName: fakeCall.image)
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.primaryPurple)
                    
                    if fakeCall.name == "Custom" {
                        TextField("Enter caller name", text: $customName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    } else {
                        Text(fakeCall.name)
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Call in:")
                            .foregroundColor(.white)
                        
                        Picker("Delay", selection: $selectedDelay) {
                            ForEach(availableDelays, id: \.self) { delay in
                                Text("\(Int(delay)) seconds")
                                    .foregroundColor(.white)
                                    .tag(delay)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding()
                    
                    if isScheduled {
                        Text("Call coming in \(Int(remainingTime)) seconds")
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Button(action: scheduleFakeCall) {
                        HStack {
                            Image(systemName: isScheduled ? "xmark.circle.fill" : "phone.circle.fill")
                            Text(isScheduled ? "Cancel Call" : "Schedule Call")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isScheduled ? Color.red : AppTheme.primaryPurple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationBarItems(trailing: Button("Close") {
                if !isScheduled {
                    isPresented = false
                }
            })
        }
        .onDisappear {
            timer?.invalidate()
        }
        .fullScreenCover(isPresented: $showingFakeCall) {
            FakeCallView(callerName: fakeCall.name == "Custom" ? customName : fakeCall.name)
        }
    }
    
    private func scheduleFakeCall() {
        if isScheduled {
            // Cancel the call
            timer?.invalidate()
            timer = nil
            isScheduled = false
        } else {
            // Schedule the call
            isScheduled = true
            remainingTime = selectedDelay
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    // Time to show the fake call
                    timer.invalidate()
                    showingFakeCall = true
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    ResourcesView()
} 