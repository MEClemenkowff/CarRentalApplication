//
//  RideFormView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct RideFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var rideViewModel: RideViewModel
    @ObservedObject var customerViewModel: CustomerViewModel
    @ObservedObject var vehicleViewModel: VehicleViewModel
    var ride: Ride?
    
    // State variables for the form fields
    @State private var vehicleID: Int?
    @State private var customerID: Int?
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var odometerStart: Int?
    @State private var odometerEnd: Int?
    @State private var status: String = "pending"
    
    var isFormValid: Bool {
        vehicleID != nil && customerID != nil && odometerStart != nil
    }
    
    var body: some View {
        Form {
            // Vehicle Selection
            Picker("Vehicle", selection: $vehicleID) {
                ForEach(vehicleViewModel.vehicles, id: \.id) { vehicle in
                    Text("\(vehicle.make) \(vehicle.model) (\(vehicle.registration))").tag(vehicle.id as Int?)
                }
            }
            
            // Customer Selection
            Picker("Customer", selection: $customerID) {
                ForEach(customerViewModel.customers, id: \.id) { customer in
                    Text("\(customer.first_name) \(customer.last_name)").tag(customer.id as Int?)
                }
            }
            
            // Start Date
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            
            // End Date
            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            
            // Odometer Start
            TextField("Odometer Start", value: $odometerStart, format: .number)
            
            // Odometer End
            TextField("Odometer End", value: $odometerEnd, format: .number)
            
            // Submit and Cancel buttons
            HStack {
                Button("Submit") {
                    let formattedStartDate = formatDate(startDate)
                    let formattedEndDate = formatDate(endDate)
                    
                    if let ride = ride {
                        // Update existing ride
                        rideViewModel.updateRide(
                            id: ride.id!,
                            vehicle: vehicleID!,
                            customer: customerID!,
                            start_date: formattedStartDate,
                            end_date: formattedEndDate,
                            odometer_start: odometerStart,
                            odometer_end: odometerEnd
                        )
                    } else {
                        // Add new ride
                        rideViewModel.addRide(
                            vehicle: vehicleID!,
                            customer: customerID!,
                            start_date: formattedStartDate,
                            end_date: formattedEndDate,
                            odometer_start: odometerStart,
                            odometer_end: odometerEnd
                        )
                    }
                    dismiss()
                }
                .disabled(!isFormValid)
                
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            customerViewModel.fetchCustomers()
            vehicleViewModel.fetchVehicles()
            rideViewModel.fetchRides()
            
            // If editing, set initial values
            if let ride = ride {
                vehicleID = ride.vehicle
                customerID = ride.customer
                startDate = dateFromString(ride.start_date) ?? Date()
                endDate = dateFromString(ride.end_date) ?? Date()
                odometerStart = ride.odometer_start
                odometerEnd = ride.odometer_end
            }
        }
        .padding()
    }
}

#Preview {
    RideFormView(rideViewModel: RideViewModel(), customerViewModel: CustomerViewModel(), vehicleViewModel: VehicleViewModel())
}
