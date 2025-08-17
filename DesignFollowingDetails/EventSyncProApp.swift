import SwiftUI

@main
struct EventSyncProApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(EventManager())
                .environmentObject(UserManager())
                .environmentObject(RoomManager())
        }
    }
}