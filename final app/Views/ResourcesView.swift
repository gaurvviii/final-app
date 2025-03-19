import SwiftUI

struct ResourcesView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("Resources").tag(0)
                    Text("Contacts").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    SafetyResourcesList()
                } else {
                    EmergencyContactsList()
                }
            }
            .navigationTitle("Safety Resources")
        }
    }
}

struct SafetyResourcesList: View {
    let resources = [
        SafetyResource(
            title: "Emergency Services",
            description: "Quick access to emergency numbers and services",
            icon: "phone.circle.fill"
        ),
        SafetyResource(
            title: "Safety Guidelines",
            description: "Learn about personal safety best practices",
            icon: "shield.checkerboard"
        ),
        SafetyResource(
            title: "Support Centers",
            description: "Find nearby women's support centers",
            icon: "house.fill"
        ),
        SafetyResource(
            title: "Legal Resources",
            description: "Information about legal rights and assistance",
            icon: "text.book.closed.fill"
        ),
        SafetyResource(
            title: "Self-Defense Classes",
            description: "Find local self-defense training",
            icon: "figure.martial.arts"
        )
    ]
    
    var body: some View {
        List(resources) { resource in
            NavigationLink(destination: ResourceDetailView(resource: resource)) {
                HStack {
                    Image(systemName: resource.icon)
                        .font(.title2)
                        .foregroundColor(AppTheme.primaryPurple)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading) {
                        Text(resource.title)
                            .font(.headline)
                        Text(resource.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

struct EmergencyContactsList: View {
    @State private var contacts: [EmergencyContact] = [
        EmergencyContact(name: "Police", number: "911", type: .emergency),
        EmergencyContact(name: "Women's Helpline", number: "1-800-799-7233", type: .helpline),
        EmergencyContact(name: "Local Hospital", number: "408-555-0123", type: .medical)
    ]
    @State private var showingAddContact = false
    
    var body: some View {
        List {
            ForEach(contacts) { contact in
                EmergencyContactRow(contact: contact)
            }
            .onDelete(perform: deleteContact)
            
            Button(action: { showingAddContact = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Emergency Contact")
                }
            }
        }
        .sheet(isPresented: $showingAddContact) {
            AddContactView(contacts: $contacts)
        }
    }
    
    func deleteContact(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }
}

struct EmergencyContactRow: View {
    let contact: EmergencyContact
    
    var body: some View {
        HStack {
            Image(systemName: contact.type.icon)
                .font(.title2)
                .foregroundColor(contact.type.color)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(.headline)
                Text(contact.number)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                guard let url = URL(string: "tel://\(contact.number)"),
                      UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url)
            }) {
                Image(systemName: "phone.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.primaryPurple)
            }
        }
        .padding(.vertical, 8)
    }
}

struct SafetyResource: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

struct ResourceDetailView: View {
    let resource: SafetyResource
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Resource header
                HStack {
                    Image(systemName: resource.icon)
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.primaryPurple)
                    
                    Text(resource.title)
                        .font(.title)
                        .bold()
                }
                .padding()
                
                // Resource content
                Text("Detailed information about \(resource.title) will be displayed here. This section will include relevant links, contact information, and step-by-step guides when applicable.")
                    .padding()
                
                // Additional resources
                ResourceActionButtons()
            }
        }
    }
}

struct ResourceActionButtons: View {
    var body: some View {
        VStack(spacing: 15) {
            ActionButton(title: "Call for Assistance", icon: "phone.fill") {
                // Handle call action
            }
            
            ActionButton(title: "Share Location", icon: "location.fill") {
                // Handle location sharing
            }
            
            ActionButton(title: "View Guidelines", icon: "doc.text.fill") {
                // Show guidelines
            }
        }
        .padding()
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(AppTheme.deepBlue.opacity(0.1))
            .foregroundColor(AppTheme.deepBlue)
            .cornerRadius(10)
        }
    }
}

struct AddContactView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var contacts: [EmergencyContact]
    @State private var name = ""
    @State private var number = ""
    @State private var type: ContactType = .personal
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Contact Name", text: $name)
                TextField("Phone Number", text: $number)
                    .keyboardType(.phonePad)
                
                Picker("Contact Type", selection: $type) {
                    Text("Personal").tag(ContactType.personal)
                    Text("Emergency").tag(ContactType.emergency)
                    Text("Medical").tag(ContactType.medical)
                    Text("Helpline").tag(ContactType.helpline)
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    let contact = EmergencyContact(
                        name: name,
                        number: number,
                        type: type
                    )
                    contacts.append(contact)
                    dismiss()
                }
                .disabled(name.isEmpty || number.isEmpty)
            )
        }
    }
}

#Preview {
    ResourcesView()
} 