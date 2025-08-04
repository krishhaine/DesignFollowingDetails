import Foundation

struct Event: Identifiable, Codable {
    var id: String? = UUID().uuidString
    var time: String
    var function: String
    var room: String
    var capacity: Int
    var colleagues: [String]
    var eventType: EventType
    var status: EventStatus
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    var createdBy: String
    var assignedStaff: [StaffMember]
    var resources: [Resource]
    
    enum EventType: String, CaseIterable, Codable {
        case waterStation = "Water Station"
        case lunchBuffet = "Lunch Buffet"
        case brandRoomHosting = "Brand Room Hosting"
        case meeting = "Meeting"
        case agriculture = "Agriculture Speaking"
        case other = "Other"
        
        var color: String {
            switch self {
            case .waterStation: return "blue"
            case .lunchBuffet: return "orange"
            case .brandRoomHosting: return "purple"
            case .meeting: return "green"
            case .agriculture: return "red"
            case .other: return "gray"
            }
        }
    }
    
    enum EventStatus: String, CaseIterable, Codable {
        case scheduled = "Scheduled"
        case inProgress = "In Progress"
        case completed = "Completed"
        case cancelled = "Cancelled"
        case revised = "Revised"
    }
}

struct StaffMember: Identifiable, Codable {
    var id = UUID()
    var name: String
    var role: StaffRole
    var shift: Shift
    var contactInfo: ContactInfo
    
    enum StaffRole: String, CaseIterable, Codable {
        case leader = "Leader"
        case brandRoomTeam = "Brand Room Team"
        case setupCrew = "Setup Crew"
        case bartender = "Bartender"
        case server = "Server"
    }
    
    enum Shift: String, CaseIterable, Codable {
        case am = "AM"
        case pm = "PM"
        case fullDay = "Full Day"
    }
}

struct ContactInfo: Codable {
    var email: String
    var phone: String
}

struct Resource: Identifiable, Codable {
    var id = UUID()
    var name: String
    var quantity: Int
    var maxQuantity: Int
    var category: ResourceCategory
    
    enum ResourceCategory: String, CaseIterable, Codable {
        case food = "Food & Beverage"
        case equipment = "Equipment"
        case supplies = "Supplies"
        case furniture = "Furniture"
    }
}