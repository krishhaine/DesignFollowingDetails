import Foundation
import Combine

// Local version without Firebase
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