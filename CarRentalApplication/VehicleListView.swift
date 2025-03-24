//
//  VehicleListView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct VehicleListView: View {
    
    enum SheetType: Identifiable, Hashable {
        case newVehicle
        case editVehicle(Vehicle)
        case newRide(Vehicle)

        var id: Int {
            hashValue
        }
    }
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel
    @EnvironmentObject var rideViewModel: RideViewModel
    @State private var vehicles: [Vehicle] = []
    @State private var selectedVehicle: Vehicle?
    @State private var vehicleAvailability: [Int: Bool] = [:]
    
    @State private var sheetType: SheetType?
    
    func isAvailable(vehicle: Vehicle, completion: @escaping (Bool) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        rideViewModel.isVehicleAvailable(vehicleID: vehicle.id!, startDate: dateString, endDate: dateString) { isAvailable in
            completion(isAvailable)
        }
    }

    var body: some View {
        HStack {
            Button() {
                sheetType = .newVehicle
            } label: {
                Image(systemName: "plus")
            }
            .help(Text("Add new vehicle"))
            .buttonStyle(.plain)
            .padding(10)
            .clipShape(Circle())
            .contentShape(Rectangle())
            
            Spacer()
        }
        
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
                    .font(.headline)
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
                        sheetType = .editVehicle(selectedVehicle!)
                    }
                    Button("New Ride") {
                        selectedVehicle = vehicle
                        sheetType = .newRide(selectedVehicle!)
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
            }.onTapGesture {
                selectedVehicle = vehicle
                sheetType = .newRide(selectedVehicle!)
            }
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
        .sheet(item: $sheetType) { sheet in
            switch sheet {
            case .editVehicle(let vehicle):
                VehicleFormView(viewModel: vehicleViewModel, vehicle: vehicle)
            case .newRide(let vehicle):
                RideFormView(rideViewModel: rideViewModel, customerViewModel: customerViewModel, vehicleViewModel: vehicleViewModel, vehicle: vehicle)
            case .newVehicle:
                VehicleFormView(viewModel: vehicleViewModel)
            }
        }
        .onAppear {
            vehicleViewModel.fetchVehicles()
        }
    }
}

#Preview {
    VehicleListView()
}
