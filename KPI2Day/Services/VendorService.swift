//
//  VendorService.swift
//  KPI2Day
//
//  Created by Inquisitor on 01.06.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import Foundation
import GoogleMaps

class VendorService {
    
    static func start() {
        setupGoogleMaps()
    }
    
    private static func setupGoogleMaps() {
        var googleMapsAPIKey = ""
        var myDict: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "ServerKeys", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict, let apiKey = dict["googleAPIKey"] as? String {
            googleMapsAPIKey = apiKey
        }
        
        GMSServices.provideAPIKey(googleMapsAPIKey)
    }
}
