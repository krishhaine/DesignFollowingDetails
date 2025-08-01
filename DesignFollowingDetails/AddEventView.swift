import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var roomManager: RoomManager
    @EnvironmentObject var userManager: UserManager
    
    @State private var time = ""
    @State private var function = ""
    @State private var selectedRoom = ""
    @State private var capacity = ""
    @State private var colleagues: [String] = []
    @State private var newColleague = ""
    @State private var selectedEventType: Event.EventType = .other
    @State private var notes = ""
    @State private var selectedStaff: [StaffMember] = []
    @State private var resources: [Resource] = []
    
    @State private var showingConflictAlert = false
    @State private var conflicts: [Event] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Time (e.g., 09:00-17:00)", text: $time)
                    
                    TextField("Function/Event Name", text: $function)
                    
                    Picker("Event Type", selection: $selectedEventType) {
                        ForEach(Event.EventType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("Room", selection: $selectedRoom) {
                        Text("Select Room").tag("")
                        ForEach(roomManager.rooms, id: \.number) { room in
                            Text("\(room.number) - \(room.name)").tag(room.number)
                        }
                    }
                    
                    TextField("Capacity", text: $capacity)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Staff Assignment")) {
                    HStack {
                        TextField("Add colleague", text: $newColleague)
                        
                        Button("Add") {
                            if !newColleague.isEmpty {
                                colleagues.append(newColleague)
                                newColleague = ""
                            }
                        }
                        .disabled(newColleague.isEmpty)
                    }
                    
                    ForEach(colleagues, id: \.self) { colleague in
                        HStack {
                            Text(colleague)
                            Spacer()
                            Button("Remove") {
                                colleagues.removeAll { $0 == colleague }
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("Additional Information")) {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Quick Templates
                Section(header: Text("Quick Templates")) {
                    Button("Water Station Template") {
                        applyWaterStationTemplate()
                    }
                    
                    Button("Lunch Buffet Template") {
                        applyLunchBuffetTemplate()
                    }
                    
                    Button("Brand Room Hosting Template") {
                        applyBrandRoomTemplate()
                    }
                }
            }
            .navigationTitle("Add Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Schedule Conflicts", isPresented: $showingConflictAlert) {
                Button("Save Anyway") {
                    saveEventForced()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This event conflicts with \(conflicts.count) existing event(s) in room \(selectedRoom). Do you want to continue?")
            }
        }
    }
    
    private var isFormValid: Bool {
        !time.isEmpty && !function.isEmpty && !selectedRoom.isEmpty && !capacity.isEmpty
    }
    
    private func saveEvent() {
        let newEvent = createEvent()
        
        // Check for conflicts
        conflicts = eventManager.checkConflicts(for: newEvent)
        
        if !conflicts.isEmpty {
            showingConflictAlert = true
            return
        }
        
        saveEventForced()
    }
    
    private func saveEventForced() {
        let newEvent = createEvent()
        eventManager.addEvent(newEvent)
        dismiss()
    }
    
    private func createEvent() -> Event {
        return Event(
            time: time,
            function: function,
            room: selectedRoom,
            capacity: Int(capacity) ?? 0,
            colleagues: colleagues,
            eventType: selectedEventType,
            status: .scheduled,
            notes: notes,
            createdAt: Date(),
            updatedAt: Date(),
            createdBy: userManager.currentUser?.email ?? "",
            assignedStaff: selectedStaff,
            resources: resources
        )
    }
    
    // Template Functions
    private func applyWaterStationTemplate() {
        selectedEventType = .waterStation
        function = "Water Station"
        time = "07:00-23:59"
        capacity = "50"
        notes = "Continuous water service throughout the day"
    }
    
    private func applyLunchBuffetTemplate() {
        selectedEventType = .lunchBuffet
        function = "Lunch Buffet"
        selectedRoom = "208"
        time = "12:00-14:00"
        capacity = "100"
        colleagues = ["Server 1", "Server 2"]
        notes = "Standard lunch buffet setup"
    }
    
    private func applyBrandRoomTemplate() {
        selectedEventType = .brandRoomHosting
        function = "CS Brand Room Hosting"
        selectedRoom = "BMO"
        time = "11:00-23:00"
        capacity = "340"
        colleagues = ["Kapil", "Taigo", "Alex"]
        notes = "Host Luxury Bar (4 bartenders)"
    }
}

#Preview {
    AddEventView()
        .environmentObject(EventManager())
        .environmentObject(RoomManager())
        .environmentObject(UserManager())
}