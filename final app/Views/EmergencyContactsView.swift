import SwiftUI
import Contacts

struct EmergencyContactsView: View {
    @AppStorage("emergencyContacts") private var emergencyContactsData = Data()
    @State private var showingAddContact = false
    @State private var showingDeleteAlert = false
    @State private var contactToDelete: EmergencyContact?
    let emergencyNumbers: [(String, String)]
    @Environment(\.dismiss) var dismiss
    
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
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.nightBlack.ignoresSafeArea()
                
                VStack(spacing: 20) {
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
                                    }
                                )
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Emergency Contacts")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddContact) {
                AddEmergencyContactView { contact in
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
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
    
    var body: some View {
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
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .font(.title2)
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
    let onAdd: (EmergencyContact) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.nightBlack.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    TextField("Name", text: $name)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    TextField("Phone Number", text: $phone)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.phonePad)
                    
                    TextField("Relationship", text: $relationship)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    Spacer()
                }
                .padding()
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
                            relationship: relationship
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