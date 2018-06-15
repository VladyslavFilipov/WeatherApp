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
    var error: ErrorType = .none {
        didSet {
            if self.error == .forecast { self.forecastDelegate?.forecastError(true) } } }
    
    func parseJsonFromUrl(_ city: TerritoryInfo, _ apiKey: String) {
        self.error = .none
        let weatherByDayString = "https://dataservice.accuweather.com/forecasts/v1/daily/5day/\(city.key)?apikey=\(apiKey)&metric=true"
        guard let weatherByDayURL = URL(string: weatherByDayString) else { return }
        Session.parseJSONWithAlamofire(with: weatherByDayURL, type: WeatherByDay.self) { weather in
            guard var weather = weather else { self.error = .forecast; return }
            for index in 0..<weather.forecast.count {
                weather.forecast[index].date = weather.forecast[index].date.getSeparated(by: "T", on: 0).getSeparated(by: "-", on: 2)
                weather.forecast[index].day.phrase = weather.forecast[index].day.phrase.getAllPhrase(separatedBy: "w/").getAllPhrase(separatedBy: "t-")
            }
            self.forecastDelegate?.addDailyForecast(value: weather, city: city)
        }
    }
}
