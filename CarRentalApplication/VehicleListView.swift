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
    @EnvironmentObject var rideViewModel: RideViewModel
    @State private var vehicles: [Vehicle] = []
    @State private var selectedVehicle: Vehicle?
    @State private var vehicleAvailability: [Int: Bool] = [:]
    
    func isAvailable(vehicle: Vehicle, completion: @escaping (Bool) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        rideViewModel.isVehicleAvailable(vehicleID: vehicle.id!, startDate: dateString, endDate: dateString) { isAvailable in
            completion(isAvailable)
        }
    }

    var body: some View {
        List(vehicleViewModel.vehicles) { vehicle in
            HStack {
                Circle()
                    .fill(self.vehicleAvailability[vehicle.id!] ?? false ? .green : .red)
                    .frame(width: 10, height: 10)
                    .help(Text(self.vehicleAvailability[vehicle.id!] ?? false ? "Available" : "Rented"))
                                
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
            .onAppear {
                isAvailable(vehicle: vehicle) { isAvailable in
                    self.vehicleAvailability[vehicle.id!] = isAvailable
                }
            }
            .onReceive(Timer.publish(every: 2, on: .main, in: .common).autoconnect()) { _ in
                isAvailable(vehicle: vehicle) { isAvailable in
                    self.vehicleAvailability[vehicle.id!] = isAvailable
                }
            }
            .padding()
        }
        .sheet(item: $selectedVehicle) { vehicle in
            VehicleFormView(viewModel: vehicleViewModel, vehicle: vehicle)
        }
        .onAppear {
            vehicleViewModel.fetchVehicles()
        }
        .onReceive(Timer.publish(every: 2, on: .main, in: .common).autoconnect()) { _ in
            vehicleViewModel.fetchVehicles()
            rideViewModel.fetchRides()
        }
    }
}

#Preview {
    VehicleListView()
}
