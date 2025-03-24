//
//  RideListView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct RideListView: View {
    
    enum SheetType: Identifiable, Hashable {
        case newRide
        case editRide(Ride)

        var id: Int {
            hashValue
        }
    }
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel
    @EnvironmentObject var rideViewModel: RideViewModel
    @State private var selectedRide: Ride?
    @State private var showDeleteConfirmation = false
    @State private var rideToDelete: Ride?
    
    @State private var sheetType: SheetType?
    
    var body: some View {
        HStack {
            Button() {
                sheetType = .newRide
            } label: {
                Image(systemName: "plus")
            }
            .help(Text("Add new ride"))
            .buttonStyle(.plain)
            .padding(10)
            .clipShape(Circle())
            .contentShape(Rectangle())
            
            Spacer()
        }
        
        List(rideViewModel.rides.sorted(by: { $0.start_date < $1.start_date })) { ride in
            if ride.status == RideStatus.active {
                HStack {
                    if Date() >= dateFromString(ride.start_date)! {
                        Image(systemName: "car.fill")
                            .font(.headline)
                            .frame(maxWidth: 40, alignment: .leading)
                    } else {
                        Image(systemName: "calendar")
                            .font(.headline)
                            .frame(maxWidth: 40, alignment: .leading)
                    }
                    
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
                    
                    // Menu for actions (Edit/Delete)
                    Menu {
                        Button("Edit/Complete") {
                            selectedRide = ride
                            sheetType = .editRide(selectedRide!)
                        }
                        Button("Delete", role: .destructive) {
                            rideToDelete = ride
                            showDeleteConfirmation = true
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
                    .confirmationDialog("Are you sure you want to delete this ride?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            if let ride = rideToDelete {
                                rideViewModel.deleteRide(id: ride.id!)
                                rideViewModel.fetchRides()
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                }
                .onTapGesture {
                    selectedRide = ride
                }
                .padding()
            }
        }
        .sheet(item: $sheetType) { sheet in
            switch sheet {
            case .editRide(let ride):
                RideFormView(rideViewModel: rideViewModel, customerViewModel: customerViewModel, vehicleViewModel: vehicleViewModel, ride: ride)
            case .newRide:
                RideFormView(rideViewModel: rideViewModel, customerViewModel: customerViewModel, vehicleViewModel: vehicleViewModel)
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
    RideListView()
}
