//
//  TripsListViewModel.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 11/03/25.
//

import Foundation

class TripsListViewModel: BaseViewModel {
    @Published var trips: [Trip] = []
    @Published var showTripPlanner = false
    @Published var selectedTrip: Trip?
    
}

