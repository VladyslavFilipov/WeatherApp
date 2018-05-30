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
    var error: ErrorType = .none {
        didSet {
            if self.error == .forecast { self.forecastDelegate?.forecastError(true) } } }
    
    func parseJsonFromUrl(_ city: TerritoryInfo, _ apiKey: String) {
        let weatherByHourString = "https://dataservice.accuweather.com/forecasts/v1/hourly/12hour/\(city.key)?apikey=\(apiKey)&metric=true"
        guard let weatherByHourURL = URL(string: weatherByHourString) else { return }
        Session.parseJSONWithAlamofire(with: weatherByHourURL, type: [WeatherByHour].self) { weather in
            guard var weather = weather else { self.error = .forecast; return }
            if weather != [WeatherByHour]() {
                self.error = .none
                for index in 0..<weather.count {
                    var separator = ""
                    if weather[index].dateTime.contains("+") { separator = "+" }
                    else if weather[index].dateTime.contains("-") { separator = "-" }
                    weather[index].dateTime = weather[index].dateTime.getSeparated(by: "T", on: 1).getSeparated(by: separator, on: 0)
                    weather[index].phrase = weather[index].phrase.getAllPhrase(separatedBy: "w/").getAllPhrase(separatedBy: "t-")
                }
                self.forecastDelegate?.addHourlyForecast(value: weather, city: city)
            } else { self.error = .forecast }
        }
    }
}
