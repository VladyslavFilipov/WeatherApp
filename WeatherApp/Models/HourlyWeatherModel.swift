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
    
    func getJsonFromUrl(_ city: TerritoryInfo, _ apiKey: String) {
        let weatherByHourString = "https://dataservice.accuweather.com/forecasts/v1/hourly/12hour/\(city.key)?apikey=\(apiKey)&metric=true"
        guard let weatherByHourURL = URL(string: weatherByHourString) else { return }
        URLSession.shared.dataTask(with: weatherByHourURL, completionHandler: {(data, response, error) -> Void in
            guard let data = data else { return }
            do {
                let weather = try JSONDecoder().decode([WeatherByHour].self, from: data)
                self.forecastDelegate?.addHourlyForecast(value: weather, city: city)
            } catch { print("Hourly forecast getting error")
                self.forecastDelegate?.forecastError(false)
            }
        }).resume()
    }
}
