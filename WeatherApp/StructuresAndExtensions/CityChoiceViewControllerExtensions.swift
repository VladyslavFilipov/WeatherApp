//
//  CityChoiceViewControllerExtensions.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 31.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation

extension CityChoiceViewController : Territory {
    
    func addTerritory(withNameAndKey value: TerritoryInfo) {
        territoryDelegate?.addTerritory(withNameAndKey: value)
    }
    
    func addLocation(withNameAndKey value: TerritoryInfo) {
        territoryDelegate?.addLocation(withNameAndKey: value)
    }
    
    func territoryError(_ status: Bool) {
        territoryDelegate?.territoryError(status)
    }
    
    func locationError(_ status: Bool) {
        territoryDelegate?.locationError(status)
    }
}

extension CityChoiceViewController : Forecast {
    
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
