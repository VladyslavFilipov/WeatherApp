//
//  weatherByDayModel.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 22.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation

class DailyWeather {
    
    var forecastDelegate: Forecast?
    var error = Bool() {
        didSet {
            if self.error { self.forecastDelegate?.forecastError(self.error) }
        }
    }
    
    func parseJsonFromUrl(_ city: TerritoryInfo, _ apiKey: String) {
        self.error = false
        let weatherByDayString = "https://dataservice.accuweather.com/forecasts/v1/daily/5day/\(city.key)?apikey=\(apiKey)&metric=true"
        guard let weatherByDayURL = URL(string: weatherByDayString) else { return }
        URLSession.shared.dataTask(with: weatherByDayURL, completionHandler: {(data, response, error) -> Void in
            guard let data = data else { return }
            do {
                let weather = try JSONDecoder().decode(WeatherByDay.self, from: data)
                self.forecastDelegate?.addDailyForecast(value: weather, city: city)
            } catch { print("Daily forecast getting error")
                self.error = true
            }
        }).resume()
    }
}
