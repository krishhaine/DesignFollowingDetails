import SwiftUI

struct StaffView: View {
    @EnvironmentObject var eventManager: EventManager
    @State private var selectedShift: StaffMember.Shift?
    @State private var selectedRole: StaffMember.StaffRole?
    
    var allStaff: [StaffMember] {
        let staffFromEvents = eventManager.events.flatMap { $0.assignedStaff }
        return Array(Set(staffFromEvents.map { $0.name })).map { name in
            staffFromEvents.first { $0.name == name } ?? StaffMember(
                name: name,
                role: .server,
                shift: .fullDay,
                contactInfo: ContactInfo(email: "\(name.lowercased())@example.com", phone: "555-0000")
            )
        }
    }
    
    var filteredStaff: [StaffMember] {
        var staff = allStaff
        
        if let shift = selectedShift {
            staff = staff.filter { $0.shift == shift }
        }
        
        if let role = selectedRole {
            staff = staff.filter { $0.role == role }
        }
        
        return staff
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterChip(
                            title: "All Shifts",
                            isSelected: selectedShift == nil
                        ) {
                            selectedShift = nil
                        }
                        
                        ForEach(StaffMember.Shift.allCases, id: \.self) { shift in
                            FilterChip(
                                title: shift.rawValue,
                                isSelected: selectedShift == shift
                            ) {
                                selectedShift = selectedShift == shift ? nil : shift
                            }
                        }
                        
                        Divider()
                            .frame(height: 20)
                        
                        FilterChip(
                            title: "All Roles",
                            isSelected: selectedRole == nil
                        ) {
                            selectedRole = nil
                        }
                        
                        ForEach(StaffMember.StaffRole.allCases, id: \.self) { role in
                            FilterChip(
                                title: role.rawValue,
                                isSelected: selectedRole == role
                            ) {
                                selectedRole = selectedRole == role ? nil : role
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGray6))
                
                // Staff List
                if filteredStaff.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No staff found")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Staff will appear here when events are created with assigned team members.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(filteredStaff) { staff in
                            StaffRow(staff: staff)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Staff")
        }
    }
}

struct StaffRow: View {
    let staff: StaffMember
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(staff.name.prefix(2).uppercased())
                        .font(.headline)
                        .foregroundColor(.blue)
                )
            
            // Staff Info
            VStack(alignment: .leading, spacing: 4) {
                Text(staff.name)
                    .font(.headline)
                
                HStack {
                    Label(staff.role.rawValue, systemImage: "briefcase")
                    Label(staff.shift.rawValue, systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                HStack {
                    Label(staff.contactInfo.email, systemImage: "envelope")
                    Label(staff.contactInfo.phone, systemImage: "phone")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status indicator
            VStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("Active")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StaffView()
        .environmentObject(EventManager())
}