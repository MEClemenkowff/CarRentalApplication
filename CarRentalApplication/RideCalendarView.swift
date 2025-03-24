//
//  RideCalendarView.swift
//  CarRentalApplication
//
//  Created by Martijn Clemenkowff on 23/03/2025.
//

import SwiftUI

struct RideCalendarView: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @EnvironmentObject var vehicleViewModel: VehicleViewModel
    @EnvironmentObject var rideViewModel: RideViewModel
    
    @State private var selectedVehicle: Vehicle?
    @State private var selectedDate: Date?
    @State private var selectedRide: Ride?
    
    func isAvailable(vehicle: Vehicle, date: Date, completion: @escaping (Bool) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        rideViewModel.isVehicleAvailable(vehicleID: vehicle.id!, startDate: dateString, endDate: dateString) { isAvailable in
            completion(isAvailable)
        }
    }
    
    let dates: [Date] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<365).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }()
    
    var body: some View {
        HStack {
            VStack {
                VStack {}.frame(height: 120)
                ForEach(vehicleViewModel.vehicles) { vehicle in
                    Text("\(vehicle.registration)").frame(width: 120, height: 40)
                }
            }
            .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(dates, id: \.self) { date in
                        VStack {
                            VStack {
                                Text(date, format: .dateTime.month(.abbreviated).year())
                                    .font(.headline)
                                    .padding(8)
                                Text(date, format: .dateTime.weekday(.abbreviated))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(date, format: .dateTime.day())
                                    .font(.headline)
                                    .padding(8)
                            }
                            .frame(width: 120, height: 120)
                            
                            VStack {
                                ForEach(vehicleViewModel.vehicles) { vehicle in
                                    var bisAvailable = false
                                    Rectangle()
                                        .fill(bisAvailable ? Color.red : Color.clear)
                                        .frame(height: 40)
                                        .onTapGesture {
                                            selectedVehicle = vehicle
                                            selectedDate = date
                                            // Make sure to get the ride from the RideViewModel
                                            if let ride = rideViewModel.getRide(for: vehicle.id!, on: date) {
                                                selectedRide = ride
                                            } else {
                                                selectedRide = nil // No ride found for this vehicle and date
                                            }
                                        }.onAppear {
                                            // Check availability for this vehicle when the cell appears
                                            isAvailable(vehicle: vehicle, date: date) { isAvailable in
                                                // Update the availability status in the state
                                                bisAvailable = isAvailable
                                            }
                                        }

                                }
                            }
                            .frame(width: 120, height: CGFloat(vehicleViewModel.vehicles.count)*40)
                        }
                    }
                }
                /*.sheet(item: $selectedRide) { ride in
                    RideFormView(rideViewModel: rideViewModel, customerViewModel: customerViewModel, vehicleViewModel: vehicleViewModel, ride: ride)
                }*/
                .onAppear() {
                    vehicleViewModel.fetchVehicles()
                    //rideViewModel.fetchRides()
                }
                .padding()
            }
        }
        Spacer()
    }
}

#Preview {
    RideCalendarView()
}
