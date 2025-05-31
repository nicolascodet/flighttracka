import Foundation

class FlightAPIService {
    private let apiKey = "7016a5748bd1baff290a35f6248a1185"
    private let baseURL = "https://api.aviationstack.com/v1"
    
    func fetchFlight(flightNumber: String) async throws -> Flight {
        // Construct the API URL for flight search
        var components = URLComponents(string: "\(baseURL)/flights")!
        components.queryItems = [
            URLQueryItem(name: "access_key", value: apiKey),
            URLQueryItem(name: "flight_iata", value: flightNumber.uppercased()),
            URLQueryItem(name: "limit", value: "1")
        ]
        
        guard let url = components.url else {
            throw FlightAPIError.invalidURL
        }
        
        // Make the API request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FlightAPIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw FlightAPIError.httpError(httpResponse.statusCode)
        }
        
        // Parse the response
        let apiResponse = try JSONDecoder().decode(AviationStackResponse.self, from: data)
        
        guard let flightData = apiResponse.data.first else {
            throw FlightAPIError.flightNotFound
        }
        
        // Convert API response to our Flight model
        return try convertToFlight(from: flightData, requestedFlightNumber: flightNumber)
    }
    
    private func convertToFlight(from apiData: AviationStackFlight, requestedFlightNumber: String) throws -> Flight {
        // Create airports
        let origin = Airport(
            code: apiData.departure.iata,
            name: apiData.departure.airport,
            city: extractCityFromAirportName(apiData.departure.airport),
            latitude: getCoordinatesForAirport(apiData.departure.iata).latitude,
            longitude: getCoordinatesForAirport(apiData.departure.iata).longitude
        )
        
        let destination = Airport(
            code: apiData.arrival.iata,
            name: apiData.arrival.airport,
            city: extractCityFromAirportName(apiData.arrival.airport),
            latitude: getCoordinatesForAirport(apiData.arrival.iata).latitude,
            longitude: getCoordinatesForAirport(apiData.arrival.iata).longitude
        )
        
        // Parse departure and arrival times
        let departureTime = parseDateTime(apiData.departure.scheduled) ?? Date().addingTimeInterval(3600)
        let arrivalTime = parseDateTime(apiData.arrival.scheduled) ?? departureTime.addingTimeInterval(7200)
        
        // Convert flight status
        let status = convertFlightStatus(apiData.flight_status)
        
        // Calculate delay in minutes
        let delay = calculateDelay(
            scheduled: apiData.departure.scheduled,
            estimated: apiData.departure.estimated,
            actual: apiData.departure.actual
        )
        
        return Flight(
            flightNumber: requestedFlightNumber.uppercased(),
            airline: apiData.airline.name,
            origin: origin,
            destination: destination,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            status: status,
            gate: apiData.departure.gate,
            terminal: apiData.departure.terminal,
            delay: delay
        )
    }
    
    private func parseDateTime(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return formatter.date(from: dateString) ?? {
            // Fallback to simpler format
            let simpleFormatter = DateFormatter()
            simpleFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return simpleFormatter.date(from: dateString)
        }()
    }
    
    private func convertFlightStatus(_ apiStatus: String) -> FlightStatus {
        switch apiStatus.lowercased() {
        case "scheduled":
            return .scheduled
        case "active":
            return .boarding
        case "landed":
            return .landed
        case "cancelled":
            return .cancelled
        case "delayed":
            return .delayed
        case "diverted":
            return .cancelled
        default:
            return .scheduled
        }
    }
    
    private func calculateDelay(scheduled: String?, estimated: String?, actual: String?) -> Int? {
        guard let scheduledTime = parseDateTime(scheduled) else { return nil }
        
        let compareTime = parseDateTime(actual) ?? parseDateTime(estimated)
        guard let delayedTime = compareTime else { return nil }
        
        let delaySeconds = delayedTime.timeIntervalSince(scheduledTime)
        let delayMinutes = Int(delaySeconds / 60)
        
        return delayMinutes > 0 ? delayMinutes : nil
    }
    
    private func extractCityFromAirportName(_ airportName: String) -> String {
        // Simple city extraction - in practice you'd want a more sophisticated approach
        let components = airportName.components(separatedBy: " ")
        return components.first ?? airportName
    }
    
    private func getCoordinatesForAirport(_ iataCode: String) -> (latitude: Double, longitude: Double) {
        // Basic airport coordinates - in a real app you'd maintain a comprehensive database
        let airportCoordinates: [String: (Double, Double)] = [
            "JFK": (40.6413, -73.7781),
            "LAX": (33.9425, -118.4081),
            "ORD": (41.9742, -87.9073),
            "DFW": (32.8998, -97.0403),
            "SFO": (37.6213, -122.3790),
            "BOS": (42.3656, -71.0096),
            "SEA": (47.4502, -122.3088),
            "MIA": (25.7959, -80.2870),
            "LAS": (36.0840, -115.1537),
            "PHX": (33.4373, -112.0078),
            "ATL": (33.6407, -84.4277),
            "CLT": (35.2144, -80.9473),
            "DEN": (39.8561, -104.6737),
            "MSP": (44.8848, -93.2223),
            "DTW": (42.2162, -83.3554)
        ]
        
        return airportCoordinates[iataCode] ?? (0.0, 0.0)
    }
}

// MARK: - API Response Models
struct AviationStackResponse: Codable {
    let pagination: Pagination
    let data: [AviationStackFlight]
}

struct Pagination: Codable {
    let limit: Int
    let offset: Int
    let count: Int
    let total: Int
}

struct AviationStackFlight: Codable {
    let flight_date: String
    let flight_status: String
    let departure: FlightLocation
    let arrival: FlightLocation
    let airline: AviationStackAirline
    let flight: FlightInfo
}

struct FlightLocation: Codable {
    let airport: String
    let timezone: String?
    let iata: String
    let icao: String?
    let terminal: String?
    let gate: String?
    let delay: Int?
    let scheduled: String?
    let estimated: String?
    let actual: String?
}

struct AviationStackAirline: Codable {
    let name: String
    let iata: String
    let icao: String
}

struct FlightInfo: Codable {
    let number: String
    let iata: String
    let icao: String
}

// MARK: - Error Types
enum FlightAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case flightNotFound
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .flightNotFound:
            return "Flight not found. Please check the flight number."
        case .decodingError:
            return "Error parsing flight data"
        }
    }
} 