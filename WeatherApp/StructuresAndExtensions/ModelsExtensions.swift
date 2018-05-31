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
        spinnerDelegate?.addSpinner()
        userLocation = locations[0] as CLLocation
        daily.forecastDelegate = self
        hourly.forecastDelegate = self
        parseJSON(userLocation?.coordinate)
        self.locationManager.stopUpdatingLocation()
    }
}

extension Geolocation : Forecast {
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        if error == .none { forecastDelegate?.addHourlyForecast(value: value, city: city) }
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        if error == .none { forecastDelegate?.addDailyForecast(value: value, city: city) }
    }
    
    func forecastError(_ status: Bool) {
        if error == .none { forecastDelegate?.forecastError(status) }
    }
}

extension CityInfo : Forecast {
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        if error == .none { forecastDelegate?.addHourlyForecast(value: value, city: city) }
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        if error == .none { forecastDelegate?.addDailyForecast(value: value, city: city) }
    }
    
    func forecastError(_ status: Bool) {
        if error == .none { forecastDelegate?.forecastError(status) }
    }
}
