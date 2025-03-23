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
    
    func isAvailable(vehicle: Vehicle) -> Bool {
        //!rideViewModel.isVehicleBooked(vehicleID: vehicle.id!, date: Date())
        true
    }

    var body: some View {
        List(vehicleViewModel.vehicles) { vehicle in
            HStack {
                Circle()
                    .fill(isAvailable(vehicle: vehicle) ? .green : .red)
                    .frame(width: 10, height: 10)
                    .help(Text(isAvailable(vehicle: vehicle) ? "Available" : "Rented"))
                
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
                
                Menu {
                    Button("Edit") {
                        selectedVehicle = vehicle
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(10)
                        .clipShape(Circle())
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }/*.onTapGesture {
                selectedVehicle = vehicle
            }*/
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
