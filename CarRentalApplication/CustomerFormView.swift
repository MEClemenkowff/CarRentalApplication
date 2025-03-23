//
//  CustomerFormView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI
import Foundation

struct CustomerFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CustomerViewModel
    var customer: Customer?
    
    @State private var first_name: String = ""
    @State private var last_name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    
    init(viewModel: CustomerViewModel, customer: Customer? = nil) {
        self.viewModel = viewModel
        self.customer = customer
        
        // Initialize state variables with customer data if editing
        _first_name = State(initialValue: customer?.first_name ?? "")
        _last_name = State(initialValue: customer?.last_name ?? "")
        _email = State(initialValue: customer?.email ?? "")
        _phone = State(initialValue: customer?.phone ?? "")
    }
    
    var isFormValid: Bool {
        !first_name.isEmpty && !last_name.isEmpty && !email.isEmpty && !phone.isEmpty
    }
    
    var body: some View {
        Form {
            TextField("First Name", text: $first_name)
            TextField("Last Name", text: $last_name)
            TextField("Email address", text: $email)
            TextField("Phone", text: $phone)
            
            HStack {
                Button {
                    if let customer = customer {
                        // Update existing customer
                        viewModel.updateCustomer(id: customer.id!, first_name: first_name, last_name: last_name, email: email, phone: phone)
                    } else {
                        // Add new customer
                        viewModel.addCustomer(first_name: first_name, last_name: last_name, email: email, phone: phone)
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
    CustomerFormView(viewModel: CustomerViewModel())
}
