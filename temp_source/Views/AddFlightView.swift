import SwiftUI

struct AddFlightView: View {
    @EnvironmentObject var flightManager: FlightManager
    @Environment(\.dismiss) var dismiss
    @State private var flightNumber = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Flight Number")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("e.g. AA1234", text: $flightNumber)
                            .textFieldStyle(MinimalTextFieldStyle())
                            .focused($isTextFieldFocused)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    if flightManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
                    }
                    
                    if let error = flightManager.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    Button(action: addFlight) {
                        Text("Track Flight")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .cornerRadius(12)
                            .opacity(flightNumber.isEmpty ? 0.5 : 1.0)
                    }
                    .disabled(flightNumber.isEmpty || flightManager.isLoading)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Add Flight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    private func addFlight() {
        guard !flightNumber.isEmpty else { return }
        
        flightManager.addFlight(flightNumber: flightNumber)
        
        // Dismiss after a short delay to show loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if !flightManager.isLoading {
                dismiss()
            }
        }
    }
}

struct MinimalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 18))
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
} 