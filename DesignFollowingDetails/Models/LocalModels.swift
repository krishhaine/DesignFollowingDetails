import Foundation

// Consolidated local models without Firebase dependencies
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

struct Room: Identifiable, Codable {
    var id: String? = UUID().uuidString
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

struct User: Identifiable, Codable {
    var id: String? = UUID().uuidString
    var email: String
    var name: String
    var role: UserRole
    var permissions: UserPermissions
    var createdAt: Date
    var lastLogin: Date
    
    enum UserRole: String, CaseIterable, Codable {
        case fbDirector = "F&B Director"
        case fbManager = "F&B Manager"
        case administrator = "Administrator"
        case staff = "Staff"
        
        var hierarchy: Int {
            switch self {
            case .fbDirector: return 4
            case .fbManager: return 3
            case .administrator: return 2
            case .staff: return 1
            }
        }
    }
}

struct UserPermissions: Codable {
    var canEditAllEvents: Bool
    var canApproveChanges: Bool
    var canManageUsers: Bool
    var canViewReports: Bool
    var approvalThreshold: Double
    var canOverrideChanges: Bool
    
    static func permissions(for role: User.UserRole) -> UserPermissions {
        switch role {
        case .fbDirector:
            return UserPermissions(
                canEditAllEvents: true,
                canApproveChanges: true,
                canManageUsers: true,
                canViewReports: true,
                approvalThreshold: 0,
                canOverrideChanges: true
            )
        case .fbManager:
            return UserPermissions(
                canEditAllEvents: true,
                canApproveChanges: true,
                canManageUsers: false,
                canViewReports: true,
                approvalThreshold: 500,
                canOverrideChanges: false
            )
        case .administrator:
            return UserPermissions(
                canEditAllEvents: false,
                canApproveChanges: false,
                canManageUsers: false,
                canViewReports: true,
                approvalThreshold: 0,
                canOverrideChanges: false
            )
        case .staff:
            return UserPermissions(
                canEditAllEvents: false,
                canApproveChanges: false,
                canManageUsers: false,
                canViewReports: false,
                approvalThreshold: 0,
                canOverrideChanges: false
            )
        }
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