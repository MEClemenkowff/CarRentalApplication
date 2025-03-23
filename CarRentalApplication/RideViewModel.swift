//
//  RideViewModel.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

enum RideStatus: String, CaseIterable, Identifiable, Codable {
    //case pending = "pending"
    case active = "active"
    case completed = "completed"
    //case cancelled = "cancelled"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        //case .pending:
        //    return "Pending"
        case .active:
            return "Active"
        case .completed:
            return "Completed"
        //case .cancelled:
        //    return "Cancelled"
        }
    }
}

struct Ride: Identifiable, Codable {
    var id: Int?
    var vehicle: Int
    var customer: Int
    var start_date: String
    var end_date: String
    var odometer_start: Int?
    var odometer_end: Int?
    var status: RideStatus
}

class RideViewModel: ObservableObject {
    @Published var rides: [Ride] = []
    
    let baseURL = "http://127.0.0.1:8000/rides/"
    
    // Fetch all rides from the API
    func fetchRides() {
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching rides: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                // Decode the response data into Ride objects
                let decoder = JSONDecoder()
                let rides = try decoder.decode([Ride].self, from: data)
                
                DispatchQueue.main.async {
                    self.rides = rides  // Update the UI on the main thread
                }
            } catch {
                print("Error decoding rides: \(error)")
            }
        }
        task.resume()
    }

    func addRide(vehicle: Int, customer: Int, start_date: String, end_date: String, odometer_start: Int? = nil, odometer_end: Int? = nil) {
        let url = URL(string: baseURL)!
        
        // Check if the vehicle is available first
        isVehicleAvailable(vehicleID: vehicle, startDate: start_date, endDate: end_date) { isAvailable in
            if isAvailable {
                print("The vehicle is available.")
                
                // Proceed with adding the ride after confirming availability
                let newRide: [String: Any] = [
                    "vehicle": vehicle,
                    "customer": customer,
                    "start_date": start_date,
                    "end_date": end_date,
                    "odometer_start": odometer_start ?? 0,
                    "odometer_end": odometer_end ?? 0
                ]
                
                // Encode the ride data as JSON
                guard let jsonData = try? JSONSerialization.data(withJSONObject: newRide) else {
                    print("Error encoding ride data")
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
                    
                    // Optionally, parse the response here to confirm success
                    if let data = data {
                        do {
                            // Attempt to decode the response, e.g., to get the new ride ID
                            let decoder = JSONDecoder()
                            let createdRide = try decoder.decode(Ride.self, from: data)
                            print("Created Ride: \(createdRide)")
                            
                            // Optionally, update the local list of rides
                            DispatchQueue.main.async {
                                self.rides.append(createdRide)
                            }
                        } catch {
                            print("Error decoding response: \(error)")
                        }
                    }
                }
                task.resume()
            } else {
                print("The vehicle is not available.")
            }
        }
    }

    func updateRide(id: Int, vehicle: Int, customer: Int, start_date: String, end_date: String, odometer_start: Int? = nil, odometer_end: Int? = nil) {
        let url = URL(string: "\(baseURL)\(id)/")!
        
        // Check if the vehicle is available before proceeding with the update
        isVehicleAvailable(vehicleID: vehicle, startDate: start_date, endDate: end_date, excludingRideID: id) { isAvailable in
            if isAvailable {
                print("The vehicle is available.")
                
                // Proceed with updating the ride after confirming availability
                let updatedRide = Ride(id: id, vehicle: vehicle, customer: customer, start_date: start_date, end_date: end_date, odometer_start: odometer_start, odometer_end: odometer_end, status: RideStatus.active)
                
                // Encode the updated ride data as JSON
                guard let jsonData = try? JSONEncoder().encode(updatedRide) else {
                    print("Error encoding ride data")
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                // Perform the PUT request using URLSession
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error making PUT request: \(error)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        // Update the local rides list after the PUT request
                        if let index = self.rides.firstIndex(where: { $0.id == id }) {
                            self.rides[index] = updatedRide
                        }
                    }
                }
                task.resume()
            } else {
                print("The vehicle is not available.")
            }
        }
    }

    func isVehicleAvailable(vehicleID: Int, startDate: String, endDate: String, excludingRideID excludedRideID: Int? = nil, completion: @escaping (Bool) -> Void) {
        // Prepare the URL for the request
        let urlString = "http://127.0.0.1:8000/availability/"
        guard var urlComponents = URLComponents(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        // Add query parameters
        var queryItems = [
            URLQueryItem(name: "vehicle", value: String(vehicleID)),
            URLQueryItem(name: "start_date", value: startDate),
            URLQueryItem(name: "end_date", value: endDate)
        ]
        
        if let excludedRideID = excludedRideID {
            queryItems.append(URLQueryItem(name: "excluded_ride", value: String(excludedRideID)))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            print("Invalid URL components")
            completion(false)
            return
        }
        
        // Create a GET request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Make the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle error
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Handle response and check if the ride is available
            guard let data = data else {
                print("No data received")
                completion(false)
                return
            }
            
            // Parse the response JSON
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let available = jsonResponse["available"] as? Bool {
                    // Return the availability status
                    completion(available)
                } else {
                    print("Invalid response format")
                    completion(false)
                }
            } catch {
                print("Error parsing response: \(error.localizedDescription)")
                completion(false)
            }
        }
        
        task.resume()
    }

    func getRide(for vehicleID: Int, on date: Date) -> Ride? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        // Find the first ride for the given vehicle and date
        return rides.first { ride in
            ride.vehicle == vehicleID &&
            ride.start_date <= dateString &&
            ride.end_date >= dateString
        }
    }


}
