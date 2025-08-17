import Foundation
import Combine

// MARK: - Event Manager
class EventManager: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadSampleEvents()
    }
    
    private func loadSampleEvents() {
        events = [
            Event(
                time: "09:00-17:00",
                function: "Water Station",
                room: "208",
                capacity: 50,
                colleagues: ["Staff1", "Staff2"],
                eventType: .waterStation,
                status: .scheduled,
                notes: "Continuous water service",
                createdAt: Date(),
                updatedAt: Date(),
                createdBy: "test@example.com",
                assignedStaff: [
                    StaffMember(name: "Staff1", role: .server, shift: .fullDay, contactInfo: ContactInfo(email: "staff1@example.com", phone: "555-0001")),
                    StaffMember(name: "Staff2", role: .server, shift: .fullDay, contactInfo: ContactInfo(email: "staff2@example.com", phone: "555-0002"))
                ],
                resources: []
            ),
            Event(
                time: "12:00-14:00",
                function: "Lunch Buffet",
                room: "208",
                capacity: 100,
                colleagues: ["Chef", "Server1", "Server2"],
                eventType: .lunchBuffet,
                status: .scheduled,
                notes: "Standard lunch setup",
                createdAt: Date(),
                updatedAt: Date(),
                createdBy: "test@example.com",
                assignedStaff: [
                    StaffMember(name: "Chef", role: .server, shift: .pm, contactInfo: ContactInfo(email: "chef@example.com", phone: "555-0003")),
                    StaffMember(name: "Server1", role: .server, shift: .pm, contactInfo: ContactInfo(email: "server1@example.com", phone: "555-0004"))
                ],
                resources: []
            ),
            Event(
                time: "11:00-23:00",
                function: "CS Brand Room Hosting",
                room: "BMO",
                capacity: 340,
                colleagues: ["Kapil", "Taigo", "Alex"],
                eventType: .brandRoomHosting,
                status: .scheduled,
                notes: "Host Luxury Bar (4 bartenders)",
                createdAt: Date(),
                updatedAt: Date(),
                createdBy: "Kumudkhanal@gmail.com",
                assignedStaff: [
                    StaffMember(name: "Kapil", role: .leader, shift: .fullDay, contactInfo: ContactInfo(email: "kapil@example.com", phone: "555-0001")),
                    StaffMember(name: "Taigo", role: .brandRoomTeam, shift: .pm, contactInfo: ContactInfo(email: "taigo@example.com", phone: "555-0002")),
                    StaffMember(name: "Alex", role: .bartender, shift: .pm, contactInfo: ContactInfo(email: "alex@example.com", phone: "555-0003"))
                ],
                resources: []
            )
        ]
    }
    
    func fetchEvents() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
        }
    }
    
    func addEvent(_ event: Event) {
        var newEvent = event
        newEvent.id = UUID().uuidString
        events.append(newEvent)
    }
    
    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
    }
    
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
    }
    
    func checkConflicts(for event: Event) -> [Event] {
        return events.filter { existingEvent in
            existingEvent.id != event.id &&
            existingEvent.room == event.room &&
            existingEvent.status != .cancelled &&
            existingEvent.time == event.time
        }
    }
}

// MARK: - Room Manager
class RoomManager: ObservableObject {
    @Published var rooms: [Room] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadSampleRooms()
    }
    
    private func loadSampleRooms() {
        rooms = [
            Room(number: "208", name: "Main Conference", capacity: 100, currentOccupancy: 0, status: .available, equipment: ["Projector", "Sound System"], location: "2nd Floor", isAvailable: true),
            Room(number: "216", name: "MR 216", capacity: 56, currentOccupancy: 0, status: .available, equipment: ["Whiteboard"], location: "2nd Floor", isAvailable: true),
            Room(number: "222", name: "Meeting Room 222", capacity: 30, currentOccupancy: 0, status: .available, equipment: ["TV Screen"], location: "2nd Floor", isAvailable: true),
            Room(number: "224", name: "Meeting Room 224", capacity: 25, currentOccupancy: 0, status: .available, equipment: ["Conference Phone"], location: "2nd Floor", isAvailable: true),
            Room(id: "brand-room", number: "BMO", name: "BMO Brand Room", capacity: 340, currentOccupancy: 0, status: .available, equipment: ["Luxury Bar", "Sound System", "Lighting"], location: "Main Floor", isAvailable: true),
            Room(id: "crystal-ballroom", number: "CB", name: "Crystal Ballroom", capacity: 300, currentOccupancy: 0, status: .available, equipment: ["Stage", "Dance Floor", "Premium Audio"], location: "Main Floor", isAvailable: true)
        ]
    }
    
    func fetchRooms() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    func addRoom(_ room: Room) {
        var newRoom = room
        newRoom.id = UUID().uuidString
        rooms.append(newRoom)
    }
    
    func updateRoom(_ room: Room) {
        if let index = rooms.firstIndex(where: { $0.id == room.id }) {
            rooms[index] = room
        }
    }
    
    func getRoomByNumber(_ number: String) -> Room? {
        return rooms.first { $0.number == number }
    }
}

// MARK: - User Manager
class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = true
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        currentUser = User(
            email: "Kumudkhanal@gmail.com",
            name: "Kumud",
            role: .fbDirector,
            permissions: UserPermissions.permissions(for: .fbDirector),
            createdAt: Date(),
            lastLogin: Date()
        )
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.isAuthenticated = true
            self.currentUser = User(
                email: email,
                name: email == "Kumudkhanal@gmail.com" ? "Kumud" : "Test User",
                role: .fbDirector,
                permissions: UserPermissions.permissions(for: .fbDirector),
                createdAt: Date(),
                lastLogin: Date()
            )
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
    
    func canApproveChange(amount: Double) -> Bool {
        guard let user = currentUser else { return false }
        return amount <= user.permissions.approvalThreshold || user.permissions.canOverrideChanges
    }
}