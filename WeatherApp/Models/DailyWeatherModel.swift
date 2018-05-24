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
    
    func getJsonFromUrl(_ city: TerritoryInfo, _ apiKey: String) {
        let weatherByDayString = "https://dataservice.accuweather.com/forecasts/v1/daily/5day/\(city.key)?apikey=\(apiKey)&metric=true"
        guard let weatherByDayURL = URL(string: weatherByDayString) else { return }
        URLSession.shared.dataTask(with: weatherByDayURL, completionHandler: {(data, response, error) -> Void in
            guard let data = data else { return }
            do {
                let weather = try JSONDecoder().decode(WeatherByDay.self, from: data)
                self.forecastDelegate?.addDailyForecast(value: weather, city: city)
            } catch { print("Daily forecast getting error")
                self.forecastDelegate?.forecastError(false)
            }
        }).resume()
    }
}
