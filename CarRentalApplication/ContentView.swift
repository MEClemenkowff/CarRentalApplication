//
//  ContentView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel
    @EnvironmentObject var rideViewModel: RideViewModel
    
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink(destination: RideListView()) {
                    HStack {
                        Image(systemName: "calendar")
                            .frame(width: 24)
                        Text("Ride Calendar")
                    }
                }
                NavigationLink(destination: CustomerListView()) {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .frame(width: 24)
                        Text("Customers")
                    }
                }
                NavigationLink(destination: VehicleListView()) {
                    HStack {
                        Image(systemName: "car.2.fill")
                            .frame(width: 24)
                        Text("Vehicles")
                    }
                }
                NavigationLink(destination: RideHistoryListView()) {
                    HStack {
                        Image(systemName: "archivebox.fill")
                            .frame(width: 24)
                        Text("Ride History")
                    }
                }
            }
            .navigationTitle("Sidebar").frame(minWidth:200)
        } detail: {
            ContentUnavailableView("", systemImage: "car.2.fill")
        }.toolbar {
            ToolbarView()
        }.sheet(isPresented: $appState.shouldPresentCustomerSheet) {
            
        } content: {
            CustomerFormView(viewModel: customerViewModel).frame(minWidth:400)
        }.sheet(isPresented: $appState.shouldPresentVehicleSheet) {
            
        } content: {
            VehicleFormView(viewModel: vehicleViewModel).frame(minWidth:400)
        }
        .sheet(isPresented: $appState.shouldPresentRideSheet) {
            
        } content: {
            RideFormView(rideViewModel: rideViewModel, customerViewModel: customerViewModel, vehicleViewModel: vehicleViewModel).frame(minWidth:400)
        }
    }
}

#Preview {
    ContentView()
}
