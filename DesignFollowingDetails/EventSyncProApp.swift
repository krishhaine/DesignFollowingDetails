import SwiftUI
import Firebase

@main
struct EventSyncProApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(EventManager())
                .environmentObject(UserManager())
                .environmentObject(RoomManager())
        }
    }
}