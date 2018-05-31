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
    var spinnerDelegate: Spinner?
    var error: ErrorType = .none {
        didSet {
            if self.error == .territory { self.locationDelegate?.territoryError(true) } } }
    
    let hourly = HourlyWeather()
    let daily = DailyWeather()
    
    func parseJsonFromUrl(_ city: String) {
        let path = Basic().cityURL + "\(Basic().apiKey)&q=\(city)"
        hourly.forecastDelegate = forecastDelegate
        daily.forecastDelegate = forecastDelegate
        JSONGetting(spinnerDelegate).getJSON(path, type: [City].self) { cities in
            guard let cities = cities else { self.error = .territory; return }
            if cities.count > 0 {
                let territory = TerritoryInfo(name: cities[0].name, key: cities[0].key)
                self.hourly.parseJsonFromUrl(territory)
                self.daily.parseJsonFromUrl(territory)
                if self.hourly.error == .none && self.daily.error == .none {
                    self.locationDelegate?.addTerritory(withNameAndKey: territory)
                    self.error = .none
                }
            } else { self.error = .territory }
        }
    }
}
