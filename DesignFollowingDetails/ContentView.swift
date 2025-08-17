import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        Group {
            if userManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Dashboard")
                }
            
            ScheduleView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Schedule")
                }
            
            RoomsView()
                .tabItem {
                    Image(systemName: "building.2")
                    Text("Rooms")
                }
            
            StaffView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Staff")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(EventManager())
        .environmentObject(UserManager())
        .environmentObject(RoomManager())
}