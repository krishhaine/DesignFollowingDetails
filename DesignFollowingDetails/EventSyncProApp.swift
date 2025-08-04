import SwiftUI

@main
struct EventSyncProApp: App {
    
    init() {
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