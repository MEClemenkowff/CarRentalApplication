//
//  CarRentalApplicationApp.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var shouldPresentCustomerSheet: Bool = false
    @Published var shouldPresentVehicleSheet: Bool = false
    @Published var shouldPresentRideSheet: Bool = false
}

var yearFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.groupingSize = 0
    return formatter
}

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    //formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter.string(from: date)
}

func dateFromString(_ dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    //formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure UTC if needed
    formatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent parsing
    return formatter.date(from: dateString)
}

func formattedYear(_ year: Int) -> String {
    // Use the formatter to convert the year into a string without decimals
    if let formattedYear = yearFormatter.string(from: NSNumber(value: year)) {
        return formattedYear
    } else {
        return "\(year)"
    }
}

@main
struct CarRentalApplicationApp: App {
    @StateObject private var appState = AppState()
    @ObservedObject var customerViewModel = CustomerViewModel()
    @ObservedObject var vehicleViewModel = VehicleViewModel()
    @ObservedObject var rideViewModel = RideViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.commands {
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Button("New Customer") {
                    appState.shouldPresentCustomerSheet = true
                }
                .keyboardShortcut("C", modifiers: [.command])
                Button("New Vehicle") {
                    appState.shouldPresentVehicleSheet = true
                }
                .keyboardShortcut("V", modifiers: [.command])
                Button("New Ride") {
                    appState.shouldPresentRideSheet = true
                }
                .keyboardShortcut("R", modifiers: [.command])
            }
        }.environmentObject(appState)
            .environmentObject(customerViewModel)
            .environmentObject(vehicleViewModel)
            .environmentObject(rideViewModel)
    }
}
