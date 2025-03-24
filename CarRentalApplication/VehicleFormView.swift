//
//  VehicleFormView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI
import Foundation

struct VehicleFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: VehicleViewModel
    var vehicle: Vehicle?
    
    @State private var make: String = ""
    @State private var model: String = ""
    @State private var year: Int = 0
    @State private var registration: String = ""
    @State private var seats: Int = 0
    @State private var odometer: Int?
    
    var isFormValid: Bool {
        !make.isEmpty && !model.isEmpty && !registration.isEmpty
    }
    
    var body: some View {
        Form {
            TextField("Make", text: $make)
            TextField("Model", text: $model)
            TextField("Year", value: $year, formatter: yearFormatter)
            TextField("Registration", text: $registration)
            TextField("Seats", value: $seats, format: .number)
            
            HStack {
                Button {
                    if let vehicle = vehicle {
                        // Update existing vehicle
                        viewModel.updateVehicle(id: vehicle.id!, make: make, model: model, year: year, registration: registration, seats: seats, odometer: odometer!)
                    } else {
                        // Add new vehicle
                        viewModel.addVehicle(make: make, model: model, year: year, registration: registration, seats: seats)
                    }
                    dismiss()
                } label: {
                    Text("Save")
                }.disabled(!isFormValid)
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
        }
        .onAppear {
            viewModel.fetchVehicles()
            
            // If editing, set initial values
            if let vehicle = vehicle {
                make = vehicle.make
                model = vehicle.model
                year = vehicle.year
                registration = vehicle.registration
                seats = vehicle.seats
                odometer = vehicle.odometer
            }
        }.padding()
    }
}

#Preview {
    VehicleFormView(viewModel: VehicleViewModel())
}
