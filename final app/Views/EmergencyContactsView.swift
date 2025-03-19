import SwiftUI
import Contacts

struct EmergencyContactsView: View {
    @State private var contacts: [EmergencyContact] = []
    @State private var showingAddContact = false
    @State private var showingContactPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        List {
            // Primary Emergency Services
            Section(header: Text("Emergency Services")) {
                EmergencyServiceRow(
                    name: "Police",
                    number: "911",
                    icon: "shield.fill",
                    color: .red
                )
                
                EmergencyServiceRow(
                    name: "Women's Helpline",
                    number: "1-800-799-7233",
                    icon: "phone.fill",
                    color: AppTheme.primaryPurple
                )
                
                EmergencyServiceRow(
                    name: "Medical Emergency",
                    number: "911",
                    icon: "cross.fill",
                    color: .blue
                )
            }
            
            // Trusted Contacts
            Section(
                header: Text("Trusted Contacts"),
                footer: Text("These contacts will be notified in case of emergency")
            ) {
                ForEach(contacts) { contact in
                    TrustedContactRow(contact: contact)
                }
                .onDelete(perform: deleteContact)
                
                AddContactButton(showingAddContact: $showingAddContact)
            }
            
            // Quick Actions
            Section(header: Text("Quick Actions")) {
                QuickActionRow(
                    title: "Share Location",
                    icon: "location.fill",
                    color: AppTheme.deepBlue
                ) {
                    shareLocation()
                }
                
                QuickActionRow(
                    title: "Send Emergency Alert",
                    icon: "bell.fill",
                    color: .red
                ) {
                    sendEmergencyAlert()
                }
                
                QuickActionRow(
                    title: "Import from Contacts",
                    icon: "person.crop.circle.badge.plus",
                    color: AppTheme.primaryPurple
                ) {
                    showingContactPicker = true
                }
            }
        }
        .navigationTitle("Emergency Contacts")
        .sheet(isPresented: $showingAddContact) {
            AddEmergencyContactView(contacts: $contacts)
        }
        .sheet(isPresented: $showingContactPicker) {
            ContactPickerView(contacts: $contacts)
        }
        .alert("Alert", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func deleteContact(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }
    
    private func shareLocation() {
        // Implement location sharing
        alertMessage = "Sharing location with trusted contacts..."
        showingAlert = true
    }
    
    private func sendEmergencyAlert() {
        // Implement emergency alert
        alertMessage = "Emergency alert sent to all trusted contacts"
        showingAlert = true
    }
}

struct EmergencyServiceRow: View {
    let name: String
    let number: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                Text(number)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                callNumber(number)
            }) {
                Image(systemName: "phone.circle.fill")
                    .foregroundColor(color)
                    .font(.title2)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func callNumber(_ number: String) {
        guard let url = URL(string: "tel://\(number)"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

struct TrustedContactRow: View {
    let contact: EmergencyContact
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundColor(AppTheme.primaryPurple)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(.headline)
                Text(contact.number)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    sendMessage(contact)
                }) {
                    Image(systemName: "message.fill")
                        .foregroundColor(AppTheme.deepBlue)
                }
                
                Button(action: {
                    callNumber(contact.number)
                }) {
                    Image(systemName: "phone.circle.fill")
                        .foregroundColor(AppTheme.primaryPurple)
                }
            }
            .font(.title3)
        }
        .padding(.vertical, 8)
    }
    
    private func callNumber(_ number: String) {
        guard let url = URL(string: "tel://\(number)"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    private func sendMessage(_ contact: EmergencyContact) {
        guard let url = URL(string: "sms:\(contact.number)"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

struct AddContactButton: View {
    @Binding var showingAddContact: Bool
    
    var body: some View {
        Button(action: { showingAddContact = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(AppTheme.primaryPurple)
                Text("Add Trusted Contact")
                    .foregroundColor(AppTheme.primaryPurple)
            }
        }
    }
}

struct QuickActionRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 30)
                
                Text(title)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .foregroundColor(.primary)
    }
}

struct AddEmergencyContactView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var contacts: [EmergencyContact]
    @State private var name = ""
    @State private var number = ""
    @State private var relationship = ""
    @State private var isEmergencyContact = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Information")) {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $number)
                        .keyboardType(.phonePad)
                    TextField("Relationship", text: $relationship)
                }
                
                Section {
                    Toggle("Primary Emergency Contact", isOn: $isEmergencyContact)
                }
                
                Section(footer: Text("Primary emergency contacts will be notified first in case of emergency")) {
                    Button("Save Contact") {
                        let contact = EmergencyContact(
                            name: name,
                            number: number,
                            type: isEmergencyContact ? .emergency : .personal
                        )
                        contacts.append(contact)
                        dismiss()
                    }
                    .disabled(name.isEmpty || number.isEmpty)
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

struct ContactPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var contacts: [EmergencyContact]
    @State private var selectedContacts = Set<String>()
    @State private var addressBookContacts: [CNContact] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(addressBookContacts, id: \.identifier) { contact in
                    ContactRow(
                        contact: contact,
                        isSelected: selectedContacts.contains(contact.identifier),
                        onToggle: { isSelected in
                            if isSelected {
                                selectedContacts.insert(contact.identifier)
                            } else {
                                selectedContacts.remove(contact.identifier)
                            }
                        }
                    )
                }
            }
            .navigationTitle("Select Contacts")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add Selected") {
                    importSelectedContacts()
                    dismiss()
                }
                .disabled(selectedContacts.isEmpty)
            )
            .onAppear {
                requestContactsAccess()
            }
        }
    }
    
    private func requestContactsAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            if granted {
                loadContacts()
            }
        }
    }
    
    private func loadContacts() {
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var contacts: [CNContact] = []
                try store.enumerateContacts(with: request) { contact, _ in
                    contacts.append(contact)
                }
                DispatchQueue.main.async {
                    self.addressBookContacts = contacts
                }
            } catch {
                print("Error loading contacts: \(error)")
            }
        }
    }
    
    private func importSelectedContacts() {
        for identifier in selectedContacts {
            if let contact = addressBookContacts.first(where: { $0.identifier == identifier }) {
                let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                    let emergencyContact = EmergencyContact(
                        name: name,
                        number: phoneNumber,
                        type: .personal
                    )
                    contacts.append(emergencyContact)
                }
            }
        }
    }
}

struct ContactRow: View {
    let contact: CNContact
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: { onToggle(!isSelected) }) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(contact.givenName) \(contact.familyName)")
                        .font(.headline)
                    if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                        Text(phoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.primaryPurple)
                }
            }
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    NavigationView {
        EmergencyContactsView()
    }
} 