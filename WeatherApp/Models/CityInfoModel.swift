//
//  cityNameModel.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 22.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation

class CityInfo {
  
    var locationDelegate: Territory?
    var forecastDelegate: Forecast?
    var error: ErrorType = .none {
        didSet {
            if self.error == .territory { self.locationDelegate?.territoryError(true) } } }
    
    let hourly = HourlyWeather()
    let daily = DailyWeather()
    
    func parseJsonFromUrl(_ city: String, _ apiKey: String) {
        hourly.forecastDelegate = self
        daily.forecastDelegate = self
        let cityURLString = "https://dataservice.accuweather.com/locations/v1/cities/search?apikey=\(apiKey)&q=\(city)"
        guard let cityURL = URL(string: cityURLString) else { return }
        Session.parseJSONWithAlamofire(with: cityURL, type: [City].self) { city in
            guard let city = city else { self.error = .territory; return }
            if city != [City]() {
                let territory = TerritoryInfo(name: city[0].name, key: city[0].key)
                self.hourly.parseJsonFromUrl(territory, apiKey)
                self.daily.parseJsonFromUrl(territory, apiKey)
                if self.hourly.error == .none && self.daily.error == .none {
                    self.locationDelegate?.addTerritory(withNameAndKey: territory)
                    self.error = .none
                }
            } else { self.error = .territory }
        }
    }
}
