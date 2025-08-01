import Foundation
import Combine

// Local version without Firebase for testing
class EventManager: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadSampleEvents()
    }
    
    private func loadSampleEvents() {
        // Sample data for testing
        events = [
            Event(
                time: "09:00-17:00",
                function: "Water Station",
                room: "208",
                capacity: 50,
                colleagues: ["Staff1", "Staff2"],
                eventType: .waterStation,
                status: .scheduled,
                notes: "Continuous water service",
                createdAt: Date(),
                updatedAt: Date(),
                createdBy: "test@example.com",
                assignedStaff: [],
                resources: []
            ),
            Event(
                time: "12:00-14:00",
                function: "Lunch Buffet",
                room: "208",
                capacity: 100,
                colleagues: ["Chef", "Server1", "Server2"],
                eventType: .lunchBuffet,
                status: .scheduled,
                notes: "Standard lunch setup",
                createdAt: Date(),
                updatedAt: Date(),
                createdBy: "test@example.com",
                assignedStaff: [],
                resources: []
            )
        ]
    }
    
    func fetchEvents() {
        // Simulate loading
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
        }
    }
    
    func addEvent(_ event: Event) {
        var newEvent = event
        newEvent.id = UUID().uuidString
        events.append(newEvent)
    }
    
    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
    }
    
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
    }
    
    func checkConflicts(for event: Event) -> [Event] {
        return events.filter { existingEvent in
            existingEvent.id != event.id &&
            existingEvent.room == event.room &&
            existingEvent.status != .cancelled &&
            existingEvent.time == event.time
        }
    }
}