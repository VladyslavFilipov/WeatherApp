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
    
    func parseJsonFromUrl(_ city: TerritoryInfo) {
        self.error = .none
        let path = Basic().dailyURL + "\(city.key)?apikey=\(Basic().apiKey)&metric=true"
        guard let weatherByDayURL = URL(string: path) else { return }
        Session.parseJSONWithAlamofire(with: weatherByDayURL, type: WeatherByDay.self) { weather in
            guard var weather = weather else { self.error = .forecast; return }
            weather.forecast.forEach {
                $0.date = $0.date.getSeparated(by: "T", on: 0).getSeparated(by: "-", on: 2)
                $0.day.phrase = $0.day.phrase.getAllPhrase(separatedBy: "w/").getAllPhrase(separatedBy: "t-")
            }
            self.forecastDelegate?.addDailyForecast(value: weather, city: city)
        }
    }
}
