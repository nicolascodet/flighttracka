import Foundation

class FlightAPIService {
    
    func fetchFlight(flightNumber: String) async throws -> Flight {
        // In a real app, this would call an actual flight API like FlightAware or AviationStack
        // For now, we'll generate mock data based on the flight number
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Generate mock flight data
        let airlines = ["AA": "American Airlines", "UA": "United Airlines", "DL": "Delta", "SW": "Southwest"]
        let airlineCode = String(flightNumber.prefix(2))
        let airline = airlines[airlineCode] ?? "Unknown Airlines"
        
        let airports = [
            Airport(code: "JFK", name: "John F. Kennedy International", city: "New York", latitude: 40.6413, longitude: -73.7781),
            Airport(code: "LAX", name: "Los Angeles International", city: "Los Angeles", latitude: 33.9425, longitude: -118.4081),
            Airport(code: "ORD", name: "O'Hare International", city: "Chicago", latitude: 41.9742, longitude: -87.9073),
            Airport(code: "DFW", name: "Dallas/Fort Worth International", city: "Dallas", latitude: 32.8998, longitude: -97.0403),
            Airport(code: "SFO", name: "San Francisco International", city: "San Francisco", latitude: 37.6213, longitude: -122.3790)
        ]
        
        let origin = airports.randomElement()!
        let destination = airports.filter { $0.code != origin.code }.randomElement()!
        
        let now = Date()
        let departureTime = now.addingTimeInterval(Double.random(in: 7200...86400)) // 2-24 hours from now
        let flightDuration = Double.random(in: 3600...18000) // 1-5 hours
        let arrivalTime = departureTime.addingTimeInterval(flightDuration)
        
        let statuses: [FlightStatus] = [.scheduled, .scheduled, .scheduled, .delayed, .boarding]
        let status = statuses.randomElement()!
        
        let delay = status == .delayed ? Int.random(in: 15...120) : nil
        let gate = ["A\(Int.random(in: 1...30))", "B\(Int.random(in: 1...30))", "C\(Int.random(in: 1...30))"].randomElement()
        let terminal = String(Int.random(in: 1...4))
        
        return Flight(
            flightNumber: flightNumber.uppercased(),
            airline: airline,
            origin: origin,
            destination: destination,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            status: status,
            gate: gate,
            terminal: terminal,
            delay: delay
        )
    }
} 