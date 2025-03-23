//
//  CustomerListView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct CustomerListView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel
    //@EnvironmentObject var rideViewModel: RideViewModel
    @State private var selectedCustomer: Customer?
    @State private var showDeleteConfirmation = false
    @State private var customerToDelete: Customer?

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
                
                Menu {
                    Button("Edit") {
                        selectedCustomer = customer
                    }
                    Button("Delete", role: .destructive) {
                        customerToDelete = customer
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
                .confirmationDialog("Are you sure you want to delete this customer?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        if let customer = customerToDelete {
                            customerViewModel.deleteCustomer(id: customer.id!)
                            customerViewModel.fetchCustomers()
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
            }/*.onTapGesture {
                selectedCustomer = customer
            }*/
            .padding()
        }
        .sheet(item: $selectedCustomer) { customer in
            CustomerFormView(viewModel: customerViewModel, customer: customer)
        }
        .onAppear {
            customerViewModel.fetchCustomers()
        }
    }
}

#Preview {
    CustomerListView()
}
