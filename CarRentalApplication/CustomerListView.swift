//
//  CustomerListView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct CustomerListView: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel
    //@EnvironmentObject var rideViewModel: RideViewModel
    @State private var selectedCustomer: Customer?

    var body: some View {
        List(customerViewModel.customers) { customer in
            HStack {
                Text("\(customer.first_name) \(customer.last_name)")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(customer.email)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(customer.phone)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.onTapGesture {
                selectedCustomer = customer
            }
            .padding()
        }
        /*.sheet(item: $selectedCustomer) { customer in
            CustomerFormView(viewModel: customerViewModel, customer: customer)
        }*/
        .onAppear {
            customerViewModel.fetchCustomers()
        }
    }
}

#Preview {
    CustomerListView()
}
