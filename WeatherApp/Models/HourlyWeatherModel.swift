//
//  HourlyWeatherModel.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 22.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation

class HourlyWeather {
    
    var forecastDelegate: Forecast?
    var error = Bool() {
        didSet {
            if self.error { self.forecastDelegate?.forecastError(self.error) } } }
    
    func parseJsonFromUrl(_ city: TerritoryInfo, _ apiKey: String) {
        let weatherByHourString = "https://dataservice.accuweather.com/forecasts/v1/hourly/12hour/\(city.key)?apikey=\(apiKey)&metric=true"
        guard let weatherByHourURL = URL(string: weatherByHourString) else { return }
        Session.parseJSON(with: weatherByHourURL, type: [WeatherByHour].self) { weather in
            guard let weather = weather else { self.error = true; return }
            if weather != [WeatherByHour]() {
                self.error = false
                self.forecastDelegate?.addHourlyForecast(value: weather, city: city)
            } else { print("Hourly forecast getting error")
                self.error = true
            }
        }
    }
}
