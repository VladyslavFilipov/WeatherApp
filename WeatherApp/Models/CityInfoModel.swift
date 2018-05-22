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
                let cityName = city[0].name
                let cityKey = city[0].key
                let territory = TerritoryInfo(name: cityName, key: cityKey)
                self.locationDelegate?.addTerritory(withNameAndKey: territory)
                self.hourly.getJsonFromUrl(territory, apiKey)
                self.daily.getJsonFromUrl(territory, apiKey)
            } catch { print("It`s an error here") }
        }).resume()
    }
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        forecastDelegate?.addHourlyForecast(value: value, city: city)
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        forecastDelegate?.addDailyForecast(value: value, city: city)
    }
}
