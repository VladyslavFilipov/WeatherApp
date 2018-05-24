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
    
    let hourly = HourlyWeather()
    let daily = DailyWeather()
    
    func getJsonFromUrl(_ city: String, _ apiKey: String) {
        hourly.forecastDelegate = self
        daily.forecastDelegate = self
        let cityURLString = "https://dataservice.accuweather.com/locations/v1/cities/search?apikey=\(apiKey)&q=\(city)"
        guard let cityURL = URL(string: cityURLString) else { return }
        URLSession.shared.dataTask(with: cityURL, completionHandler: {(data, response, error) -> Void in
            guard let data = data else { return }
            do {
                let city = try JSONDecoder().decode([City].self, from: data)
                if city != [City]() {
                    let territory = TerritoryInfo(name: city[0].name, key: city[0].key)
                    self.locationDelegate?.addTerritory(withNameAndKey: territory)
                    self.hourly.getJsonFromUrl(territory, apiKey)
                    self.daily.getJsonFromUrl(territory, apiKey)
                } else { self.locationDelegate?.territoryError(false) }
            } catch { print("City getting by name error")
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
