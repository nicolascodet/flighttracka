import SwiftUI

struct ContentView: View {
    @EnvironmentObject var flightManager: FlightManager
    @State private var showingAddFlight = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Flight Tracker")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                Text("Track your flights, never miss a departure")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: { showingSettings = true }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Tracked Flights
                        if flightManager.trackedFlights.isEmpty {
                            EmptyStateView()
                                .padding(.horizontal)
                                .padding(.top, 60)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(flightManager.trackedFlights) { flight in
                                    FlightCard(flight: flight)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddFlight = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Add Flight")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(Color.black)
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddFlight) {
                AddFlightView()
                    .environmentObject(flightManager)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(flightManager)
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "airplane")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No flights tracked")
                .font(.system(size: 20, weight: .semibold))
            
            Text("Add a flight to get started")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FlightManager())
    }
} 