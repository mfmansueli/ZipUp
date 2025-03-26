//
//  MKPlacemark+Extension.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 26/03/25.
//

import MapKit

extension MKPlacemark {
    func itemName() -> String {
        var text = ""
        let locality = locality ?? ""
        let state = administrativeArea ?? ""
        let country = country ?? ""
        
        if !locality.isEmpty {
            text = "\(locality), "
        }
        if !state.isEmpty {
            text += "\(state) "
        }
        if !country.isEmpty {
            text += "\(country)"
        }
        
        return text
    }
}
