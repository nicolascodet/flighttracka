import SwiftUI

struct FlightDetailView: View {
    let flight: Flight
    @EnvironmentObject var flightManager: FlightManager
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Flight Header
                    VStack(alignment: .center, spacing: 16) {
                        Text(flight.flightNumber)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                        
                        Text(flight.airline)
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                        
                        StatusBadge(status: flight.status, delay: flight.delay)
                            .scaleEffect(1.2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    // Route Section
                    VStack(spacing: 20) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("FROM")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(flight.origin.code)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                
                                Text(flight.origin.city)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                
                                Text(flight.displayDepartureTime)
                                    .font(.system(size: 18, weight: .medium))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "airplane")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                                .rotationEffect(.degrees(90))
                                .padding(.top, 30)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("TO")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(flight.destination.code)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                
                                Text(flight.destination.city)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                
                                Text(flight.displayArrivalTime)
                                    .font(.system(size: 18, weight: .medium))
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(16)
                    
                    // Flight Information
                    VStack(spacing: 16) {
                        InfoRow(label: "Date", value: flight.displayDate)
                        
                        if let terminal = flight.terminal {
                            InfoRow(label: "Terminal", value: terminal)
                        }
                        
                        if let gate = flight.gate {
                            InfoRow(label: "Gate", value: gate)
                        }
                        
                        if let leaveTime = flightManager.calculateLeaveTime(for: flight) {
                            InfoRow(
                                label: "Leave Home By",
                                value: formatDateTime(leaveTime),
                                icon: "car.fill"
                            )
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(16)
                    
                    // Delete Button
                    Button(action: { showingDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Stop Tracking")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Flight Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Stop Tracking?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Stop Tracking", role: .destructive) {
                    flightManager.removeFlight(flight)
                    dismiss()
                }
            } message: {
                Text("You will no longer receive notifications for this flight.")
            }
        }
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var icon: String? = nil
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(width: 24)
            }
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .medium))
        }
    }
} 