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
    
    let daily = DailyWeather()
    let hourly = HourlyWeather()
    
    var locationManager: CLLocationManager!
    var userLocation = CLLocation()
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse { locationManager?.startMonitoringSignificantLocationChanges() }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
        daily.forecastDelegate = self
        hourly.forecastDelegate = self
        getJsonFromUrl()
    }
    
    func getJsonFromUrl() {
        let coordinate = userLocation.coordinate
        print(coordinate.latitude)
        let city = "https://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(apiKey)&q=\(coordinate.latitude)%2C\(coordinate.longitude)"
        guard let cityURL = URL(string: city) else { return }
        URLSession.shared.dataTask(with: cityURL, completionHandler: {(data, response, error) -> Void in
            guard let data = data else { return }
            do {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                print(json)
                let city = try JSONDecoder().decode(City.self, from: data)
                print(city)
                let cityName = city.name
                let cityKey = city.key
                let territory = TerritoryInfo(name: cityName, key: cityKey)
                self.locationDelegate?.addLocation(withNameAndKey: territory)
                self.daily.getJsonFromUrl(territory, self.apiKey)
                self.hourly.getJsonFromUrl(territory, self.apiKey)
            } catch { print("It`s error here") }
        }).resume()
    }
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        forecastDelegate?.addHourlyForecast(value: value, city: city)
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        forecastDelegate?.addDailyForecast(value: value, city: city)
    }
}
