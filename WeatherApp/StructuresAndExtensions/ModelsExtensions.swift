//
//  ModelsExtensions.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 16.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation
import CoreLocation

extension Geolocation : CLLocationManagerDelegate {
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if Geolocation.isEnabled() { locationManager.startUpdatingLocation() }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
        daily.forecastDelegate = forecastDelegate
        hourly.forecastDelegate = forecastDelegate
        parseJSON(userLocation?.coordinate)
        self.locationManager.stopUpdatingLocation()
    }
}

