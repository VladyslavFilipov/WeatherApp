//
//  geolocationModel.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 22.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation
import CoreLocation

class Geolocation : CLLocationManager, CLLocationManagerDelegate, Forecast {
    
    var apiKey = ""
    var locationDelegate: Territory?
    var forecastDelegate: Forecast?
    var spinnerDelegate: Spinner?
    
    let daily = DailyWeather()
    let hourly = HourlyWeather()
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocation?
    
    func isEnabled() -> Bool {
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
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if self.isEnabled() { locationManager.startUpdatingLocation() }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        spinnerDelegate?.addSpinner()
        userLocation = locations[0] as CLLocation
        daily.forecastDelegate = self
        hourly.forecastDelegate = self
        getJsonFromUrl()
        self.locationManager.stopUpdatingLocation()
    }
    
    func getJsonFromUrl() {
        guard let coordinate = userLocation?.coordinate else { return }
        let city = "https://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(apiKey)&q=\(coordinate.latitude)%2C\(coordinate.longitude)"
        guard let cityURL = URL(string: city) else { return }
        URLSession.shared.dataTask(with: cityURL, completionHandler: {(data, response, error) -> Void in
            guard let data = data else { return }
            do {
                let city = try JSONDecoder().decode(City.self, from: data)
                let territory = TerritoryInfo(name: city.name, key: city.key)
                self.locationDelegate?.addLocation(withNameAndKey: territory)
                self.daily.getJsonFromUrl(territory, self.apiKey)
                self.hourly.getJsonFromUrl(territory, self.apiKey)
                self.spinnerDelegate?.removeSpinner()
            } catch { print("City getting by geolocation error", error)
                self.locationDelegate?.territoryError(false)
            }
        }).resume()
    }
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        forecastDelegate?.addHourlyForecast(value: value, city: city)
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        forecastDelegate?.addDailyForecast(value: value, city: city)
    }
    
    func forecastError(_ status: Bool) {
        forecastDelegate?.forecastError(status)
    }
}
