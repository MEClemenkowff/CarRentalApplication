//
//  RideHistoryListView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct RideHistoryListView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel
    @EnvironmentObject var rideViewModel: RideViewModel
    @State private var selectedRide: Ride?
    @State private var showDeleteConfirmation = false
    @State private var rideToDelete: Ride?

    var body: some View {
        List(rideViewModel.rides.sorted(by: { $0.start_date < $1.start_date })) { ride in
            if ride.status == RideStatus.completed {
                HStack {
                    if let vehicle = vehicleViewModel.vehicles.first(where: { $0.id == ride.vehicle }) {
                        Text("Vehicle: \(vehicle.registration)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if let customer = customerViewModel.customers.first(where: { $0.id == ride.customer }) {
                        Text("\(customer.first_name) \(customer.last_name)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("Deleted customer")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text("Pickup date: \(ride.start_date)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Return date: \(ride.end_date)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Distance: \(ride.odometer_end!-ride.odometer_start!) km")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                }
                .padding()
            }
        }
        .onAppear {
            customerViewModel.fetchCustomers()
            vehicleViewModel.fetchVehicles()
            rideViewModel.fetchRides()
        }
    }
}

#Preview {
    RideHistoryListView()
}
