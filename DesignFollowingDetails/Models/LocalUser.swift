import Foundation

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