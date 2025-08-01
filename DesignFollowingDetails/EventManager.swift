import Foundation
import FirebaseFirestore
import Combine

class EventManager: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchEvents()
    }
    
    deinit {
        listener?.remove()
    }
    
    func fetchEvents() {
        isLoading = true
        
        listener = db.collection("events")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    self?.events = documents.compactMap { document in
                        try? document.data(as: Event.self)
                    }
                }
            }
    }
    
    func addEvent(_ event: Event) {
        do {
            _ = try db.collection("events").addDocument(from: event)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateEvent(_ event: Event) {
        guard let id = event.id else { return }
        
        do {
            try db.collection("events").document(id).setData(from: event)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteEvent(_ event: Event) {
        guard let id = event.id else { return }
        
        db.collection("events").document(id).delete { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func checkConflicts(for event: Event) -> [Event] {
        return events.filter { existingEvent in
            existingEvent.id != event.id &&
            existingEvent.room == event.room &&
            existingEvent.status != .cancelled &&
            timesOverlap(event.time, existingEvent.time)
        }
    }
    
    private func timesOverlap(_ time1: String, _ time2: String) -> Bool {
        // Simple time overlap check - you can enhance this with proper date parsing
        return time1 == time2
    }
}