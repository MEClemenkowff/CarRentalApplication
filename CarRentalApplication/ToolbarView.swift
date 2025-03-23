//
//  ToolbarView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel
    
    var body: some View {
        Button {
            customerViewModel.fetchCustomers()
            vehicleViewModel.fetchVehicles()
        } label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .help(Text("Refresh window"))
    }
}

#Preview {
    ToolbarView()
}
