//
//  VehicleListView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct VehicleListView: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel
    //@EnvironmentObject var rideViewModel: RideViewModel
    @State private var vehicles: [Vehicle] = []
    @State private var selectedVehicle: Vehicle?

    var body: some View {
        List(vehicleViewModel.vehicles) { vehicle in
            HStack {
                /*Circle()
                    .fill(rideViewModel.isVehicleBooked(vehicleID: vehicle.id!, date: Date()) ? .red : .green)
                    .frame(width: 10, height: 10)
                    .help(Text(rideViewModel.isVehicleBooked(vehicleID: vehicle.id!, date: Date()) ? "Rented" : "Available"))*/
                
                Text("\(vehicle.make) \(vehicle.model) (\(formattedYear(vehicle.year)))")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(vehicle.registration)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Seats: \(vehicle.seats)")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Mileage: \(vehicle.odometer) km")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.onTapGesture {
                selectedVehicle = vehicle
            }
            .padding()
        }
        .sheet(item: $selectedVehicle) { vehicle in
            VehicleFormView(viewModel: vehicleViewModel, vehicle: vehicle)
        }
        .onAppear {
            vehicleViewModel.fetchVehicles()
            //rideViewModel.fetchRides()
        }
    }
}

#Preview {
    VehicleListView()
}
