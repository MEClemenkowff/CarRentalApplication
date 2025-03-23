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
    @State private var year: Int
    @State private var registration: String = ""
    @State private var seats: Int
    @State private var odometer: Int
    
    init(viewModel: VehicleViewModel, vehicle: Vehicle? = nil) {
        self.viewModel = viewModel
        self.vehicle = vehicle
        
        // Initialize state variables with vehicle data if editing
        _make = State(initialValue: vehicle?.make ?? "")
        _model = State(initialValue: vehicle?.model ?? "")
        _year = State(initialValue: vehicle?.year ?? 0)
        _registration = State(initialValue: vehicle?.registration ?? "")
        _seats = State(initialValue: vehicle?.seats ?? 0)
        _odometer = State(initialValue: vehicle?.odometer ?? 0)
    }
    
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
                        viewModel.updateVehicle(id: vehicle.id!, make: make, model: model, year: year, registration: registration, seats: seats, odometer: odometer)
                    } else {
                        // Add new vehicle
                        viewModel.addVehicle(make: make, model: model, year: year, registration: registration, seats: seats)
                    }
                    dismiss()
                } label: {
                    Text("Submit")
                }.disabled(!isFormValid)
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
        }.padding()
    }
}

#Preview {
    VehicleFormView(viewModel: VehicleViewModel())
}
