import SwiftUI

struct FlightCard: View {
    let flight: Flight
    @EnvironmentObject var flightManager: FlightManager
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(spacing: 0) {
                // Top section
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(flight.flightNumber)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(flight.airline)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: flight.status, delay: flight.delay)
                }
                .padding()
                
                Divider()
                    .padding(.horizontal)
                
                // Route section
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text(flight.origin.code)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text(flight.displayDepartureTime)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: "airplane")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(90))
                    
                    VStack(spacing: 4) {
                        Text(flight.destination.code)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text(flight.displayArrivalTime)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let gate = flight.gate {
                        VStack(spacing: 4) {
                            Text("Gate")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text(gate)
                                .font(.system(size: 20, weight: .semibold))
                        }
                    }
                }
                .padding()
                
                // Leave time indicator
                if let leaveTime = flightManager.calculateLeaveTime(for: flight) {
                    Divider()
                        .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "car.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text("Leave at \(formatTime(leaveTime))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.systemGray5))
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            FlightDetailView(flight: flight)
                .environmentObject(flightManager)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct StatusBadge: View {
    let status: FlightStatus
    let delay: Int?
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(displayText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(statusColor.opacity(0.1))
        .cornerRadius(20)
    }
    
    private var statusColor: Color {
        switch status {
        case .scheduled, .boarding:
            return .green
        case .delayed:
            return .orange
        case .departed, .enRoute:
            return .blue
        case .landed:
            return .gray
        case .cancelled:
            return .red
        }
    }
    
    private var displayText: String {
        if status == .delayed, let delay = delay {
            return "\(delay) min delay"
        }
        return status.rawValue
    }
} 