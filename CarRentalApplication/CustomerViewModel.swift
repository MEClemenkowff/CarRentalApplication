//
//  CustomerViewModel.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct Customer: Identifiable, Codable, Hashable {
    var id: Int?
    var first_name: String
    var last_name: String
    var email: String
    var phone: String
}

class CustomerViewModel: ObservableObject {
    @Published var customers: [Customer] = []
    
    let baseURL = "http://127.0.0.1:8000/customers/"
    
    // Fetch all customers from the API
    func fetchCustomers() {
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching customers: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                // Decode the response data into Customer objects
                let decoder = JSONDecoder()
                let customers = try decoder.decode([Customer].self, from: data)
                
                DispatchQueue.main.async {
                    self.customers = customers  // Update the UI on the main thread
                }
            } catch {
                print("Error decoding customers: \(error)")
            }
        }
        task.resume()
    }

    func addCustomer(first_name: String, last_name: String, email: String, phone: String) {
        let url = URL(string: baseURL)!
        
        let newCustomer: [String: Any] = [
                "first_name": first_name,
                "last_name": last_name,
                "email": email,
                "phone": phone
        ]
        
        // Encode the customer data as JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: newCustomer) else {
            print("Error encoding customer data")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Perform the POST request using URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making POST request: \(error)")
                return
            }
            
            if let data = data {
                do {
                    // Attempt to decode the response, e.g., to get the new customer ID
                    let decoder = JSONDecoder()
                    let createdCustomer = try decoder.decode(Customer.self, from: data)
                    print("Created Customer: \(createdCustomer)")
                } catch {
                    print("Error decoding response: \(error)")
                }
            }
        }
        task.resume()
    }
    
    func updateCustomer(id: Int, first_name: String, last_name: String, email: String, phone: String) {
        let url = URL(string: "\(baseURL)\(id)/")!
        
        let updatedCustomer = Customer(id: id, 
                                       first_name: first_name,
                                       last_name: last_name,
                                       email: email,
                                       phone: phone)
        
        guard let jsonData = try? JSONEncoder().encode(updatedCustomer) else {
            print("Error encoding customer data")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making PUT request: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                if let index = self.customers.firstIndex(where: { $0.id == id }) {
                    self.customers[index] = updatedCustomer
                }
            }
        }
        task.resume()
    }
    
    func deleteCustomer(id: Int) {
        let url = URL(string: "\(baseURL)\(id)/")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making DELETE request: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                // Remove the deleted customer from the local list
                self.customers.removeAll { $0.id == id }
            }
        }
        task.resume()
    }
}
