import SwiftUI

@main
struct EventSyncProApp: App {
    
    init() {
        // Firebase configuration removed for local development
        print("EventSync Pro starting in local mode")
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