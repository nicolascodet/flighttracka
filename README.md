# Flight Tracker

A minimalistic iOS app for tracking flights with real-time notifications and smart departure reminders.

## Features

- **Flight Tracking**: Track multiple flights by entering flight numbers
- **Push Notifications**: Get notified about flight status changes, delays, and gate changes
- **Smart Departure Reminders**: Calculates when you should leave home based on your location
- **Email Alerts**: Receive email notifications for flight updates
- **Minimalistic UI**: Clean, Notion-inspired interface
- **Offline Support**: Tracked flights are saved locally

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## Setup

1. Open the project in Xcode:
   ```bash
   cd FlightTracker
   open -a Xcode .
   ```

2. Select your development team in the project settings

3. Build and run the app on your device or simulator

## Usage

1. **Add a Flight**: Tap the "Add Flight" button and enter a flight number (e.g., AA1234)

2. **Configure Settings**: 
   - Tap the gear icon to access settings
   - Enter your email for email notifications
   - Add your home address for accurate departure time calculations

3. **View Flight Details**: Tap on any tracked flight to see detailed information

4. **Notifications**: The app will notify you:
   - 2 hours before departure
   - When it's time to leave for the airport
   - When flight status changes

## Architecture

- **SwiftUI**: Modern declarative UI framework
- **Combine**: For reactive updates
- **UserNotifications**: Push notifications
- **CoreLocation**: Location-based features
- **UserDefaults**: Local data persistence

## Project Structure

```
FlightTracker/
├── Models/
│   └── Flight.swift
├── Views/
│   ├── ContentView.swift
│   ├── FlightCard.swift
│   ├── AddFlightView.swift
│   ├── FlightDetailView.swift
│   └── SettingsView.swift
├── Services/
│   ├── FlightManager.swift
│   └── FlightAPIService.swift
└── FlightTrackerApp.swift
```

## Notes

- The app currently uses mock flight data for demonstration
- In production, integrate with a real flight API (e.g., FlightAware, AviationStack)
- Email notifications require a backend service implementation

## License

This project is available for personal use. 