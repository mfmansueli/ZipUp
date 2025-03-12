//
//  TripType.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 11/03/25.
//

enum TripType: String, CaseIterable, Identifiable {
    case adventure = "Adventure"
    case relaxation = "Relaxation"
    case beach = "Beach"
    case culture = "Culture"
    case business = "Business"
    
    var id: String { self.rawValue }
    
    var image: String {
        switch self {
        case .adventure:
            return "AdventureTrip"
        case .relaxation:
            return "RelaxationTrip"
        case .beach:
            return "BeachTrip"
        case .culture:
            return "CultureTrip"
        case .business:
            return "BusinessTrip"
        }
    }
}
