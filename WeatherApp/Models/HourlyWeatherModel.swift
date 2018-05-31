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
    
    func parseJsonFromUrl(_ city: TerritoryInfo) {
        let path = Basic().hourlyURL + "\(city.key)?apikey=\(Basic().apiKey)&metric=true"
        guard let weatherByHourURL = URL(string: path) else { return }
        Session.parseJSONWithAlamofire(with: weatherByHourURL, type: [WeatherByHour].self) { weather in
            guard var weather = weather else { self.error = .forecast; return }
            if weather.count > 0 {
                self.error = .none
                weather.forEach {
                    var separator = ""
                    if $0.dateTime.contains("+") { separator = "+" }
                    else if $0.dateTime.contains("-") { separator = "-" }
                    $0.dateTime = $0.dateTime.getSeparated(by: "T", on: 1).getSeparated(by: separator, on: 0)
                    $0.phrase = $0.phrase.getAllPhrase(separatedBy: "w/").getAllPhrase(separatedBy: "t-")
                }
                self.forecastDelegate?.addHourlyForecast(value: weather, city: city)
            } else { self.error = .forecast }
        }
    }
}
