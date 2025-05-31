import Foundation
import UserNotifications
import CoreLocation
import MessageUI

class FlightManager: NSObject, ObservableObject {
    @Published var trackedFlights: [Flight] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var homeAddress: String = ""
    @Published var userEmail: String = ""
    
    private let locationManager = CLLocationManager()
    private var timer: Timer?
    private let flightService = FlightAPIService()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        loadStoredFlights()
        loadUserSettings()
        startMonitoring()
    }
    
    func addFlight(flightNumber: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let flight = try await flightService.fetchFlight(flightNumber: flightNumber)
                await MainActor.run {
                    if !self.trackedFlights.contains(where: { $0.flightNumber == flight.flightNumber }) {
                        self.trackedFlights.append(flight)
                        self.saveFlights()
                        self.scheduleNotifications(for: flight)
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to add flight: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func removeFlight(_ flight: Flight) {
        trackedFlights.removeAll { $0.id == flight.id }
        saveFlights()
        cancelNotifications(for: flight)
    }
    
    func refreshFlights() {
        Task {
            for flight in trackedFlights {
                do {
                    let updatedFlight = try await flightService.fetchFlight(flightNumber: flight.flightNumber)
                    await MainActor.run {
                        if let index = self.trackedFlights.firstIndex(where: { $0.flightNumber == flight.flightNumber }) {
                            let oldFlight = self.trackedFlights[index]
                            self.trackedFlights[index] = updatedFlight
                            
                            // Check for changes
                            if oldFlight.status != updatedFlight.status ||
                               oldFlight.delay != updatedFlight.delay ||
                               oldFlight.gate != updatedFlight.gate {
                                self.sendUpdateNotification(oldFlight: oldFlight, newFlight: updatedFlight)
                                self.sendEmailUpdate(oldFlight: oldFlight, newFlight: updatedFlight)
                            }
                        }
                    }
                } catch {
                    print("Failed to refresh flight \(flight.flightNumber): \(error)")
                }
            }
        }
    }
    
    private func scheduleNotifications(for flight: Flight) {
        // Schedule departure reminder
        let content = UNMutableNotificationContent()
        content.title = "Flight Departure Reminder"
        content.body = "Your flight \(flight.flightNumber) to \(flight.destination.city) departs in 2 hours"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, flight.departureTime.timeIntervalSinceNow - 7200),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "departure-\(flight.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
        
        // Schedule leave home notification
        scheduleTravelTimeNotification(for: flight)
    }
    
    private func scheduleTravelTimeNotification(for flight: Flight) {
        guard let userLocation = locationManager.location else { return }
        
        let airportLocation = CLLocation(
            latitude: flight.origin.latitude,
            longitude: flight.origin.longitude
        )
        
        let distance = userLocation.distance(from: airportLocation)
        let estimatedTravelTime = distance / 15.0 // Assuming 15 m/s average speed
        let bufferTime = 5400.0 // 1.5 hours buffer for check-in and security
        
        let leaveTime = flight.departureTime.timeIntervalSinceNow - estimatedTravelTime - bufferTime
        
        if leaveTime > 0 {
            let content = UNMutableNotificationContent()
            content.title = "Time to Leave!"
            content.body = "Leave now to arrive at the airport on time for flight \(flight.flightNumber)"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: leaveTime, repeats: false)
            let request = UNNotificationRequest(
                identifier: "leave-\(flight.id)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    private func sendUpdateNotification(oldFlight: Flight, newFlight: Flight) {
        let content = UNMutableNotificationContent()
        content.title = "Flight Update"
        
        if oldFlight.status != newFlight.status {
            content.body = "Flight \(newFlight.flightNumber) status changed to \(newFlight.status.rawValue)"
        } else if let delay = newFlight.delay, delay > 0 {
            content.body = "Flight \(newFlight.flightNumber) is delayed by \(delay) minutes"
        } else if oldFlight.gate != newFlight.gate, let gate = newFlight.gate {
            content.body = "Flight \(newFlight.flightNumber) gate changed to \(gate)"
        }
        
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "update-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func sendEmailUpdate(oldFlight: Flight, newFlight: Flight) {
        guard !userEmail.isEmpty else { return }
        
        // In a real app, this would use a backend service to send emails
        // For now, we'll just prepare the email content
        var emailBody = "Flight Update for \(newFlight.flightNumber)\n\n"
        
        if oldFlight.status != newFlight.status {
            emailBody += "Status changed from \(oldFlight.status.rawValue) to \(newFlight.status.rawValue)\n"
        }
        
        if let delay = newFlight.delay, delay > 0 {
            emailBody += "Flight is delayed by \(delay) minutes\n"
        }
        
        if oldFlight.gate != newFlight.gate, let gate = newFlight.gate {
            emailBody += "Gate changed to \(gate)\n"
        }
        
        emailBody += "\nNew departure time: \(newFlight.displayDepartureTime)\n"
        emailBody += "New arrival time: \(newFlight.displayArrivalTime)"
        
        // Store email for sending when backend is available
        print("Email to send: \(emailBody)")
    }
    
    private func cancelNotifications(for flight: Flight) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["departure-\(flight.id)", "leave-\(flight.id)"]
        )
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            self.refreshFlights()
        }
    }
    
    private func saveFlights() {
        if let encoded = try? JSONEncoder().encode(trackedFlights) {
            UserDefaults.standard.set(encoded, forKey: "trackedFlights")
        }
    }
    
    private func loadStoredFlights() {
        if let data = UserDefaults.standard.data(forKey: "trackedFlights"),
           let flights = try? JSONDecoder().decode([Flight].self, from: data) {
            trackedFlights = flights
        }
    }
    
    private func loadUserSettings() {
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        homeAddress = UserDefaults.standard.string(forKey: "homeAddress") ?? ""
    }
    
    func calculateLeaveTime(for flight: Flight) -> Date? {
        guard let userLocation = locationManager.location else { return nil }
        
        let airportLocation = CLLocation(
            latitude: flight.origin.latitude,
            longitude: flight.origin.longitude
        )
        
        let distance = userLocation.distance(from: airportLocation)
        let estimatedTravelTime = distance / 15.0
        let bufferTime = 5400.0
        
        return Date(timeIntervalSince1970: flight.departureTime.timeIntervalSince1970 - estimatedTravelTime - bufferTime)
    }
}

extension FlightManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location updates handled here
    }
} 