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
    var vehicle: Vehicle?
    var customer: Customer?
    
    // State variables for the form fields
    @State private var vehicleID: Int?
    @State private var customerID: Int?
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var odometerStart: Int?
    @State private var odometerEnd: Int?
    @State private var status: String = "pending"
    
    @State private var showOverlapAlert = false
    
    var isFormValid: Bool {
        vehicleID != nil && customerID != nil
    }
    
    var isFormComplete: Bool {
        vehicleID != nil && customerID != nil && odometerStart != nil && odometerEnd != nil
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
                Button("Save") {
                    let formattedStartDate = formatDate(startDate)
                    let formattedEndDate = formatDate(endDate)
                    
                    rideViewModel.isVehicleAvailable(vehicleID: vehicleID!, startDate: formattedStartDate, endDate: formattedEndDate) { isAvailable in
                        if isAvailable {
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
                        } else {
                            showOverlapAlert = true
                        }
                    }
                }
                .disabled(!isFormValid)
                
                Button("Complete ride") {
                    let formattedStartDate = formatDate(startDate)
                    let formattedEndDate = formatDate(endDate)
                    
                    if let ride = ride {
                        rideViewModel.completeRide(
                            id: ride.id!,
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
                .disabled(!isFormComplete)
                
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .confirmationDialog("Booking Conflict", isPresented: $showOverlapAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text("The selected vehicle is not available at these dates")
        })
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
            
            if let vehicle = vehicle {
                vehicleID = vehicle.id
            }
            
            if let customer = customer {
                customerID = customer.id
            }
        }
        .padding()
    }
}

#Preview {
    RideFormView(rideViewModel: RideViewModel(), customerViewModel: CustomerViewModel(), vehicleViewModel: VehicleViewModel())
}
