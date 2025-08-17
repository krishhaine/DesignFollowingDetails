import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var roomManager: RoomManager
    @State private var selectedDate = Date()
    
    var todaysEvents: [Event] {
        eventManager.events.filter { event in
            event.status != .cancelled
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Stats
                    HStack(spacing: 15) {
                        StatCard(
                            title: "Today's Events",
                            value: "\(todaysEvents.count)",
                            icon: "calendar",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Active Rooms",
                            value: "\(roomManager.rooms.filter { $0.status == .occupied }.count)",
                            icon: "building.2",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Staff On Duty",
                            value: "\(totalStaffOnDuty)",
                            icon: "person.3",
                            color: .orange
                        )
                    }
                    
                    // Timeline View
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Today's Schedule")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("View All") {
                                // Navigate to full schedule
                            }
                            .foregroundColor(.blue)
                        }
                        
                        LazyVStack(spacing: 10) {
                            ForEach(todaysEvents.prefix(5)) { event in
                                EventTimelineCard(event: event)
                            }
                        }
                    }
                    
                    // Room Status Overview
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Room Status")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                            ForEach(roomManager.rooms.prefix(6)) { room in
                                RoomStatusCard(room: room)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("EventSync Pro")
            .refreshable {
                eventManager.fetchEvents()
                roomManager.fetchRooms()
            }
        }
    }
    
    private var totalStaffOnDuty: Int {
        let allStaff = todaysEvents.flatMap { $0.assignedStaff }
        return Set(allStaff.map { $0.name }).count
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EventTimelineCard: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 15) {
            VStack {
                Circle()
                    .fill(Color(event.eventType.color))
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 2, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.function)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(event.time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label(event.room, systemImage: "building.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label("\(event.capacity)", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !event.colleagues.isEmpty {
                    Text("Staff: \(event.colleagues.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct RoomStatusCard: View {
    let room: Room
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(room.number)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Circle()
                    .fill(Color(room.status.color))
                    .frame(width: 10, height: 10)
            }
            
            Text(room.name)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("\(room.currentOccupancy)/\(room.capacity)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(room.status.rawValue)
                    .font(.caption2)
                    .foregroundColor(Color(room.status.color))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    DashboardView()
        .environmentObject(EventManager())
        .environmentObject(RoomManager())
}