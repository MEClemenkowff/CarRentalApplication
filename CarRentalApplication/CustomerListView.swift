//
//  CustomerListView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct CustomerListView: View {
    
    enum SheetType: Identifiable, Hashable {
        case newCustomer
        case editCustomer(Customer)
        case newRide(Customer)

        var id: Int {
            hashValue
        }
    }
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel
    @EnvironmentObject var rideViewModel: RideViewModel
    @State private var selectedCustomer: Customer?
    @State private var showDeleteConfirmation = false
    @State private var customerToDelete: Customer?
    
    @State private var sheetType: SheetType?

    var body: some View {
        HStack {
            Button() {
                sheetType = .newCustomer
            } label: {
                Image(systemName: "plus")
            }
            .help(Text("Add new customer"))
            .buttonStyle(.plain)
            .padding(10)
            .clipShape(Circle())
            .contentShape(Rectangle())
            
            Spacer()
        }
        
        List(customerViewModel.customers) { customer in
            HStack {
                Text("\(customer.id!)")
                    .font(.headline)
                    .frame(maxWidth: 60, alignment: .leading)
                
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
                        sheetType = .editCustomer(selectedCustomer!)
                    }
                    Button("New Ride") {
                        selectedCustomer = customer
                        sheetType = .newRide(selectedCustomer!)
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
            }.onTapGesture {
                selectedCustomer = customer
                sheetType = .newRide(selectedCustomer!)
            }
            .padding()
        }
        .sheet(item: $sheetType) { sheet in
            switch sheet {
            case .editCustomer(let customer):
                CustomerFormView(viewModel: customerViewModel, customer: customer)
            case .newRide(let customer):
                RideFormView(rideViewModel: rideViewModel, customerViewModel: customerViewModel, vehicleViewModel: vehicleViewModel, customer: customer)
            case .newCustomer:
                CustomerFormView(viewModel: customerViewModel)
            }
        }
        .onAppear {
            customerViewModel.fetchCustomers()
        }
    }
}

#Preview {
    CustomerListView()
}
