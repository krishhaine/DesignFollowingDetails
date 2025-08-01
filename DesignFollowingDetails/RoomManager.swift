import Foundation
import FirebaseFirestore
import Combine

class RoomManager: ObservableObject {
    @Published var rooms: [Room] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchRooms()
        setupDefaultRooms()
    }
    
    deinit {
        listener?.remove()
    }
    
    func fetchRooms() {
        isLoading = true
        
        listener = db.collection("rooms")
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    self?.rooms = documents.compactMap { document in
                        try? document.data(as: Room.self)
                    }
                }
            }
    }
    
    private func setupDefaultRooms() {
        let defaultRooms = [
            Room(number: "208", name: "Main Conference", capacity: 100, currentOccupancy: 0, status: .available, equipment: ["Projector", "Sound System"], location: "2nd Floor", isAvailable: true),
            Room(number: "216", name: "MR 216", capacity: 56, currentOccupancy: 0, status: .available, equipment: ["Whiteboard"], location: "2nd Floor", isAvailable: true),
            Room(number: "222", name: "Meeting Room 222", capacity: 30, currentOccupancy: 0, status: .available, equipment: ["TV Screen"], location: "2nd Floor", isAvailable: true),
            Room(number: "224", name: "Meeting Room 224", capacity: 25, currentOccupancy: 0, status: .available, equipment: ["Conference Phone"], location: "2nd Floor", isAvailable: true),
            Room(id: "brand-room", number: "BMO", name: "BMO Brand Room", capacity: 340, currentOccupancy: 0, status: .available, equipment: ["Luxury Bar", "Sound System", "Lighting"], location: "Main Floor", isAvailable: true),
            Room(id: "crystal-ballroom", number: "CB", name: "Crystal Ballroom", capacity: 300, currentOccupancy: 0, status: .available, equipment: ["Stage", "Dance Floor", "Premium Audio"], location: "Main Floor", isAvailable: true)
        ]
        
        // Add rooms if they don't exist
        for room in defaultRooms {
            addRoomIfNotExists(room)
        }
    }
    
    private func addRoomIfNotExists(_ room: Room) {
        let roomExists = rooms.contains { $0.number == room.number }
        if !roomExists {
            addRoom(room)
        }
    }
    
    func addRoom(_ room: Room) {
        do {
            _ = try db.collection("rooms").addDocument(from: room)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateRoom(_ room: Room) {
        guard let id = room.id else { return }
        
        do {
            try db.collection("rooms").document(id).setData(from: room)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func getRoomByNumber(_ number: String) -> Room? {
        return rooms.first { $0.number == number }
    }
}