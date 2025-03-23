//
//  VehicleViewModel.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct Vehicle: Identifiable, Codable, Hashable {
    var id: Int?
    var make: String
    var model: String
    var year: Int
    var registration: String
    var seats: Int
    var odometer: Int
}

class VehicleViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    
    let baseURL = "http://127.0.0.1:8000/vehicles/"
    
    // Fetch all vehicles from the API
    func fetchVehicles() {
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching vehicles: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                // Decode the response data into Vehicle objects
                let decoder = JSONDecoder()
                let vehicles = try decoder.decode([Vehicle].self, from: data)
                
                DispatchQueue.main.async {
                    self.vehicles = vehicles  // Update the UI on the main thread
                }
            } catch {
                print("Error decoding vehicles: \(error)")
            }
        }
        task.resume()
    }

    func addVehicle(make: String, model: String, year: Int, registration: String, seats: Int) {
        let url = URL(string: baseURL)!
        
        let newVehicle: [String: Any] = [
                "make": make,
                "model": model,
                "year": year,
                "registration": registration,
                "seats": seats,
        ]
        
        // Encode the vehicle data as JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: newVehicle) else {
            print("Error encoding vehicle data")
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
                    // Attempt to decode the response, e.g., to get the new vehicle ID
                    let decoder = JSONDecoder()
                    let createdVehicle = try decoder.decode(Vehicle.self, from: data)
                    print("Created Vehicle: \(createdVehicle)")
                } catch {
                    print("Error decoding response: \(error)")
                }
            }
        }
        task.resume()
    }
    
    func updateVehicle(id: Int, make: String, model: String, year: Int, registration: String, seats: Int, odometer: Int) {
        let url = URL(string: "\(baseURL)\(id)/")!
        
        let updatedVehicle = Vehicle(id: id, make: make, model: model, year: year, registration: registration, seats: seats, odometer: odometer)
        
        guard let jsonData = try? JSONEncoder().encode(updatedVehicle) else {
            print("Error encoding vehicle data")
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
                if let index = self.vehicles.firstIndex(where: { $0.id == id }) {
                    self.vehicles[index] = updatedVehicle
                }
            }
        }
        task.resume()
    }
}
