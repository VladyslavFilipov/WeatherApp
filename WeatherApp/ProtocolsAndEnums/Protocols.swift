//
//  Protocols.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 30.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation

protocol Territory {
    func addTerritory(withNameAndKey value: TerritoryInfo)
    func addLocation(withNameAndKey value: TerritoryInfo)
    func territoryError(_ status: Bool)
    func locationError(_ status: Bool)
}

protocol Forecast {
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo)
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo)
    func forecastError(_ status: Bool)
}

protocol Spinner {
    func addSpinner()
    func removeSpinner()
}

protocol Connection {
    func checkConnection(_ status: Bool)
}

public protocol EnumCollection: Hashable {
    static func cases() -> AnySequence<Self>
    static var allValues: [Self] { get }
}
