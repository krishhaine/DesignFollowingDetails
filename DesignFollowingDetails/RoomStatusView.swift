import SwiftUI

struct RoomStatusView: View {
    @EnvironmentObject var roomManager: RoomManager
    @EnvironmentObject var eventManager: EventManager
    @State private var selectedRoom: Room?
    @State private var showingRoomDetails = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                    ForEach(roomManager.rooms) { room in
                        RoomCard(room: room) {
                            selectedRoom = room
                            showingRoomDetails = true
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Room Status")
            .refreshable {
                roomManager.fetchRooms()
            }
        }
        .sheet(item: $selectedRoom) { room in
            RoomDetailView(room: room)
        }
    }
}

struct RoomCard: View {
    let room: Room
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(room.number)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(room.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    StatusIndicator(status: room.status)
                }
                
                // Capacity bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Occupancy")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(room.currentOccupancy)/\(room.capacity)")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(occupancyColor)
                                .frame(width: occupancyWidth(for: geometry.size.width), height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
                
                // Equipment tags
                if !room.equipment.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(room.equipment.prefix(3), id: \.self) { equipment in
                                Text(equipment)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(4)
                            }
                            
                            if room.equipment.count > 3 {
                                Text("+\(room.equipment.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var occupancyPercentage: Double {
        guard room.capacity > 0 else { return 0 }
        return Double(room.currentOccupancy) / Double(room.capacity)
    }
    
    private var occupancyColor: Color {
        switch occupancyPercentage {
        case 0..<0.5: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }
    
    private func occupancyWidth(for totalWidth: CGFloat) -> CGFloat {
        return totalWidth * occupancyPercentage
    }
}

struct StatusIndicator: View {
    let status: Room.RoomStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(status.color))
                .frame(width: 8, height: 8)
            
            Text(status.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
        }
    }
}

struct RoomDetailView: View {
    let room: Room
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var eventManager: EventManager
    
    var roomEvents: [Event] {
        eventManager.events.filter { $0.room == room.number }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Room Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(room.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            StatusIndicator(status: room.status)
                        }
                        
                        Text("Room \(room.number) • \(room.location)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Capacity Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Capacity Information")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Current")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(room.currentOccupancy)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Maximum")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(room.capacity)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Equipment
                    if !room.equipment.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Available Equipment")
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(room.equipment, id: \.self) { equipment in
                                    HStack {
                                        Image(systemName: equipmentIcon(for: equipment))
                                            .foregroundColor(.blue)
                                        Text(equipment)
                                            .font(.caption)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                    
                    // Current Events
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Scheduled Events")
                            .font(.headline)
                        
                        if roomEvents.isEmpty {
                            Text("No events scheduled for this room")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        } else {
                            ForEach(roomEvents) { event in
                                EventTimelineCard(event: event)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Room Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {