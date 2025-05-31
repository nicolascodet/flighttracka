import Foundation

struct Flight: Identifiable, Codable {
    let id = UUID()
    let flightNumber: String
    let airline: String
    let origin: Airport
    let destination: Airport
    let departureTime: Date
    let arrivalTime: Date
    let status: FlightStatus
    let gate: String?
    let terminal: String?
    let delay: Int? // in minutes
    
    var displayDepartureTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: departureTime)
    }
    
    var displayArrivalTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: arrivalTime)
    }
    
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: departureTime)
    }
}

struct Airport: Codable {
    let code: String
    let name: String
    let city: String
    let latitude: Double
    let longitude: Double
}

enum FlightStatus: String, Codable {
    case scheduled = "Scheduled"
    case delayed = "Delayed"
    case boarding = "Boarding"
    case departed = "Departed"
    case enRoute = "En Route"
    case landed = "Landed"
    case cancelled = "Cancelled"
    
    var color: String {
        switch self {
        case .scheduled, .boarding:
            return "green"
        case .delayed:
            return "orange"
        case .departed, .enRoute:
            return "blue"
        case .landed:
            return "gray"
        case .cancelled:
            return "red"
        }
    }
} 