import SwiftUI
import Contacts
import MessageUI
import CoreLocation

struct EmergencyContactsView: View {
    @AppStorage("emergencyContacts") private var emergencyContactsData = Data()
    @State private var showingAddContact = false
    @State private var showingDeleteAlert = false
    @State private var showingSOSMessage = false
    @State private var contactToDelete: EmergencyContact?
    @State private var sosMessage = "I'm in an emergency situation and need help!"
    @State private var showingSendConfirmation = false
    let emergencyNumbers: [(String, String)]
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()
    
    private var emergencyContacts: [EmergencyContact] {
        if let decoded = try? JSONDecoder().decode([EmergencyContact].self, from: emergencyContactsData) {
            return decoded
        }
        return []
    }
    
    private func saveContacts(_ contacts: [EmergencyContact]) {
        if let encoded = try? JSONEncoder().encode(contacts) {
            emergencyContactsData = encoded
        }
    }
    
    private func deleteContact(_ contact: EmergencyContact) {
        var contacts = emergencyContacts
        contacts.removeAll { $0.id == contact.id }
        saveContacts(contacts)
    }
    
    private func sendSOSMessages() {
        let location = locationManager.location?.coordinate
        
        // Send to emergency contacts
        for contact in emergencyContacts {
            sendSOSMessage(to: contact, location: location)
        }
        
        // Show confirmation
        showingSendConfirmation = true
    }
    
    private func sendSOSMessage(to contact: EmergencyContact, location: CLLocationCoordinate2D?) {
        let message = contact.generateSOSMessage(location: location)
        
        // Create SMS URL
        let smsURL = "sms:\(contact.phone)&body=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: smsURL) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.nightBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Default SOS Message Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Default SOS Message")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            TextEditor(text: $sosMessage)
                                .frame(height: 100)
                                .padding()
                                .background(AppTheme.darkGray)
                                .cornerRadius(15)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        
                        // Emergency Services Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Emergency Services")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            EmergencyServiceRow(
                                icon: "phone.fill",
                                title: "Police",
                                subtitle: "100",
                                color: .blue
                            )
                            
                            EmergencyServiceRow(
                                icon: "cross.fill",
                                title: "Ambulance",
                                subtitle: "102",
                                color: .red
                            )
                            
                            EmergencyServiceRow(
                                icon: "flame.fill",
                                title: "Fire",
                                subtitle: "101",
                                color: .orange
                            )
                        }
                        
                        // Emergency Contacts Section
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Emergency Contacts")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { showingAddContact = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(AppTheme.primaryPurple)
                                        .font(.title2)
                                }
                            }
                            .padding(.horizontal)
                            
                            if emergencyContacts.isEmpty {
                                Text("Add emergency contacts who should be notified in case of emergency")
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(AppTheme.darkGray)
                                    .cornerRadius(15)
                                    .padding(.horizontal)
                            } else {
                                ForEach(emergencyContacts) { contact in
                                    EmergencyContactRow(
                                        contact: contact,
                                        onDelete: {
                                            contactToDelete = contact
                                            showingDeleteAlert = true
                                        },
                                        onEdit: {
                                            // Edit contact functionality can be added here
                                        }
                                    )
                                }
                            }
                        }
                        
                        // Test SOS Button
                        Button(action: {
                            showingSOSMessage = true
                        }) {
                            Text("Test SOS Message")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.primaryPurple)
                                .cornerRadius(15)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Emergency Contacts")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddContact) {
                AddEmergencyContactView(defaultMessage: sosMessage) { contact in
                    var contacts = emergencyContacts
                    contacts.append(contact)
                    saveContacts(contacts)
                }
            }
            .alert("Delete Contact", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let contact = contactToDelete {
                        deleteContact(contact)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this contact?")
            }
            .alert("Send Test SOS?", isPresented: $showingSOSMessage) {
                Button("Cancel", role: .cancel) { }
                Button("Send") {
                    sendSOSMessages()
                }
            } message: {
                Text("This will send a test SOS message to all your emergency contacts.")
            }
            .alert("SOS Messages Sent", isPresented: $showingSendConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Emergency messages have been sent to all your contacts.")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                locationManager.requestLocationPermissions()
            }
        }
    }
}

struct EmergencyServiceRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        Button(action: {
            if let url = URL(string: "tel://\(subtitle)") {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "phone.circle.fill")
                    .foregroundColor(AppTheme.primaryPurple)
            }
            .padding()
            .background(AppTheme.darkGray)
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }
}

struct EmergencyContactRow: View {
    let contact: EmergencyContact
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .foregroundColor(.white)
                    Text(contact.phone)
                        .font(.caption)
                        .foregroundColor(.gray)
                    if !contact.relationship.isEmpty {
                        Text(contact.relationship)
                            .font(.caption2)
                            .foregroundColor(AppTheme.primaryPurple)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: {
                        if let url = URL(string: "tel://\(contact.phone)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "phone.circle.fill")
                            .foregroundColor(AppTheme.primaryPurple)
                    }
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(AppTheme.primaryPurple)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .font(.title2)
            }
            
            if !contact.customMessage.isEmpty {
                Text("SOS Message: " + contact.customMessage)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct AddEmergencyContactView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var phone = ""
    @State private var relationship = ""
    @State private var customMessage: String
    @State private var sendLocation = true
    let onAdd: (EmergencyContact) -> Void
    
    init(defaultMessage: String, onAdd: @escaping (EmergencyContact) -> Void) {
        _customMessage = State(initialValue: defaultMessage)
        self.onAdd = onAdd
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.nightBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        TextField("Name", text: $name)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        TextField("Phone Number", text: $phone)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.phonePad)
                        
                        TextField("Relationship", text: $relationship)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        VStack(alignment: .leading) {
                            Text("Custom SOS Message")
                                .foregroundColor(.white)
                                .font(.caption)
                            
                            TextEditor(text: $customMessage)
                                .frame(height: 100)
                                .padding()
                                .background(AppTheme.darkGray)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        Toggle("Share Location in SOS", isOn: $sendLocation)
                            .foregroundColor(.white)
                            .padding()
                            .background(AppTheme.darkGray)
                            .cornerRadius(10)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let contact = EmergencyContact(
                            name: name,
                            phone: phone,
                            relationship: relationship,
                            customMessage: customMessage,
                            sendLocation: sendLocation
                        )
                        onAdd(contact)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                }
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(AppTheme.darkGray)
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}

#Preview {
    EmergencyContactsView(emergencyNumbers: [("Police", "100"), ("Ambulance", "102"), ("Fire", "101")])
} 