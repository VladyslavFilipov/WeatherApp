//
//  cityNameModel.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 22.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation

class CityInfo : Forecast {
  
    var locationDelegate: Territory?
    var forecastDelegate: Forecast?
    var error = Bool() {
        didSet {
            if self.error { self.locationDelegate?.territoryError(self.error) } } }
    
    let hourly = HourlyWeather()
    let daily = DailyWeather()
    
    func parseJsonFromUrl(_ city: String, _ apiKey: String) {
        hourly.forecastDelegate = self
        daily.forecastDelegate = self
        let cityURLString = "https://dataservice.accuweather.com/locations/v1/cities/search?apikey=\(apiKey)&q=\(city)"
        guard let cityURL = URL(string: cityURLString) else { return }
        Session.parseJSON(with: cityURL, type: [City].self) { city in
            guard let city = city else { self.error = true; return }
            if city != [City]() {
                let territory = TerritoryInfo(name: city[0].name, key: city[0].key)
                self.hourly.parseJsonFromUrl(territory, apiKey)
                self.daily.parseJsonFromUrl(territory, apiKey)
                if !self.hourly.error && !self.daily.error {
                    self.locationDelegate?.addTerritory(withNameAndKey: territory)
                    self.error = false
                }
            } else { self.error = true }
        }
    }
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        if !error { forecastDelegate?.addHourlyForecast(value: value, city: city) }
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        if !error { forecastDelegate?.addDailyForecast(value: value, city: city) }
    }
    
    func forecastError(_ status: Bool) {
        if !error { forecastDelegate?.forecastError(status) }
    }
}
