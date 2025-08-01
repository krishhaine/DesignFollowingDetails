import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var userManager: UserManager
    @State private var showingAddEvent = false
    @State private var searchText = ""
    @State private var selectedEventType: Event.EventType?
    @State private var selectedStatus: Event.EventStatus?
    
    var filteredEvents: [Event] {
        var events = eventManager.events
        
        if !searchText.isEmpty {
            events = events.filter { event in
                event.function.localizedCaseInsensitiveContains(searchText) ||
                event.room.localizedCaseInsensitiveContains(searchText) ||
                event.colleagues.joined(separator: " ").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let eventType = selectedEventType {
            events = events.filter { $0.eventType == eventType }
        }
        
        if let status = selectedStatus {
            events = events.filter { $0.status == status }
        }
        
        return events
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 10) {
                    SearchBar(text: $searchText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(
                                title: "All Types",
                                isSelected: selectedEventType == nil
                            ) {
                                selectedEventType = nil
                            }
                            
                            ForEach(Event.EventType.allCases, id: \.self) { type in
                                FilterChip(
                                    title: type.rawValue,
                                    isSelected: selectedEventType == type
                                ) {
                                    selectedEventType = selectedEventType == type ? nil : type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                
                // Events List
                if eventManager.isLoading {
                    Spacer()
                    ProgressView("Loading events...")
                    Spacer()
                } else if filteredEvents.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No events found")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        if userManager.currentUser?.permissions.canEditAllEvents == true {
                            Button("Add First Event") {
                                showingAddEvent = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredEvents) { event in
                            EventRow(event: event)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    if userManager.currentUser?.permissions.canEditAllEvents == true {
                                        Button("Edit") {
                                            // Edit event
                                        }
                                        .tint(.blue)
                                        
                                        Button("Delete") {
                                            eventManager.deleteEvent(event)
                                        }
                                        .tint(.red)
                                    }
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if userManager.currentUser?.permissions.canEditAllEvents == true {
                        Button("Add Event") {
                            showingAddEvent = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView()
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search events, rooms, or staff...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct EventRow: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Event type indicator
                Rectangle()
                    .fill(Color(event.eventType.color))
                    .frame(width: 4, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(event.function)
                            .font(.headline)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        StatusBadge(status: event.status)
                    }
                    
                    HStack {
                        Label(event.time, systemImage: "clock")
                        Label(event.room, systemImage: "building.2")
                        Label("\(event.capacity)", systemImage: "person.2")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    if !event.colleagues.isEmpty {
                        Text("Staff: \(event.colleagues.joined(separator: ", "))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    if !event.notes.isEmpty {
                        Text(event.notes)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: Event.EventStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch status {
        case .scheduled: return .blue
        case .inProgress: return .green
        case .completed: return .gray
        case .cancelled: return .red
        case .revised: return .orange
        }
    }
}

#Preview {
    ScheduleView()
        .environmentObject(EventManager())
        .environmentObject(UserManager())
}