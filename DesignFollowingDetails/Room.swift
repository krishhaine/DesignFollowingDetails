import Foundation
import FirebaseFirestore

struct Room: Identifiable, Codable {
    @DocumentID var id: String?
    var number: String
    var name: String
    var capacity: Int
    var currentOccupancy: Int
    var status: RoomStatus
    var equipment: [String]
    var location: String
    var isAvailable: Bool
    
    enum RoomStatus: String, CaseIterable, Codable {
        case available = "Available"
        case occupied = "Occupied"
        case maintenance = "Maintenance"
        case reserved = "Reserved"
        
        var color: String {
            switch self {
            case .available: return "green"
            case .occupied: return "red"
            case .maintenance: return "orange"
            case .reserved: return "blue"
            }
        }
    }
}