//
//  geolocationModel.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 22.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation
import CoreLocation

class Geolocation : CLLocationManager {
    
    var locationDelegate: Territory?
    var forecastDelegate: Forecast?
    var spinnerDelegate: Spinner?
    var error: ErrorType = .none {
        didSet {
            if self.error == .location { self.locationDelegate?.locationError(true) } } }
    
    let daily = DailyWeather()
    let hourly = HourlyWeather()
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocation?
    
    class func isEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
    }
    
    func parseJSON(_ coordinates: CLLocationCoordinate2D?) {
        guard let coordinate = coordinates else { return }
        let path = Basic().locationURL + "\(Basic().apiKey)&q=\(coordinate.latitude)%2C\(coordinate.longitude)"
        JSONGetting(spinnerDelegate).getJSON( path , type: City.self) { location in
            guard let location = location else { self.error = .location; return }
            let territory = TerritoryInfo(name: location.name, key: location.key)
            self.daily.parseJsonFromUrl(territory)
            self.hourly.parseJsonFromUrl(territory)
            self.locationDelegate?.addLocation(withNameAndKey: territory)
            self.error = .none
        }
    }
}

