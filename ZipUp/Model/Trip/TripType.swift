//
//  TripType.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 11/03/25.
//

import SwiftUI

enum TripType: LocalizedStringResource, CaseIterable, Identifiable {
    case adventure = "Adventure"
    case relaxation = "Relaxation"
    case beach = "Beach"
    case culture = "Culture"
    case business = "Business"
    
    var id: String { self.rawValue.key }
    
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
    
    var title: LocalizedStringKey {
        switch self {
        case .adventure:
            return "Adventure"
        case .relaxation:
            return "Relaxation"
        case .beach:
            return "Beach"
        case .culture:
            return "Culture"
        case .business:
            return "Business"
        }
    }
}
