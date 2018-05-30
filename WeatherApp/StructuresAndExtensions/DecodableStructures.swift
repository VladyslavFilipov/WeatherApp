//
//  DecodableStructures.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 17.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation

struct TerritoryInfo : Equatable {
    let name: String
    let key: String
    
    static func == (lhs: TerritoryInfo, rhs: TerritoryInfo) -> Bool {
        return lhs.name == rhs.name && lhs.key == rhs.key
    }
}

struct City: Decodable , Equatable{
    let name : String
    let key : String
    
    private enum Key: String, CodingKey {
        case name = "EnglishName"
        case key = "Key"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.key = try container.decode(String.self, forKey: .key)
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.name == rhs.name && lhs.key == rhs.key
    }
}

struct WeatherByHour: Decodable, Equatable {
    
    var dateTime : String
    var phrase : String
    let temperature : Temperature
    
    private enum Key: String, CodingKey {
        case dateTime = "DateTime"
        case phrase = "IconPhrase"
        case temperature = "Temperature"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.dateTime = try container.decode(String.self, forKey: .dateTime)
        self.phrase = try container.decode(String.self, forKey: .phrase)
        self.temperature = try container.decode(Temperature.self, forKey: .temperature)
    }
    
    static func == (lhs: WeatherByHour, rhs: WeatherByHour) -> Bool {
        return lhs.phrase == rhs.phrase && lhs.dateTime == rhs.dateTime && lhs.temperature == rhs.temperature
    }
}

struct Temperature : Decodable, Equatable {
    let unit : String
    let value : Double
    let text : String
    
    private enum Key: String, CodingKey {
        case unit = "Unit"
        case value = "Value"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.unit = try container.decode(String.self, forKey: .unit)
        self.value = try container.decode(Double.self, forKey: .value)
        self.text = "\(self.value.toString()) in \(self.unit)"
    }
    static func == (lhs: Temperature, rhs: Temperature) -> Bool {
        return lhs.unit == rhs.unit && lhs.value == rhs.value
    }
}

struct WeatherByDay: Decodable , Equatable {
    var forecast : [DailyForecast]
    
    private enum Key: String, CodingKey {
        case forecast = "DailyForecasts"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.forecast = try container.decode([DailyForecast].self, forKey: .forecast)
    }
    
    static func == (lhs: WeatherByDay, rhs: WeatherByDay) -> Bool {
        return lhs.forecast == rhs.forecast
    }
}

struct DailyForecast : Decodable, Equatable {
    
    var date : String
    var day : WeatherInDayPhrase
    let temperature : TemperatureExtremums
    
    private enum Key: String, CodingKey {
        case date = "Date"
        case day = "Day"
        case temperature = "Temperature"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.date = try container.decode(String.self, forKey: .date)
        self.day = try container.decode(WeatherInDayPhrase.self, forKey: .day)
        self.temperature = try container.decode(TemperatureExtremums.self, forKey: .temperature)
    }
    
    static func == (lhs: DailyForecast, rhs: DailyForecast) -> Bool {
        return lhs.date == rhs.date && lhs.day == rhs.day && lhs.temperature == rhs.temperature
    }
}

struct WeatherInDayPhrase: Decodable , Equatable {
    var phrase : String
    
    private enum Key: String, CodingKey {
        case phrase = "IconPhrase"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.phrase = try container.decode(String.self, forKey: .phrase)
    }
    
    static func == (lhs: WeatherInDayPhrase, rhs: WeatherInDayPhrase) -> Bool {
        return lhs.phrase == rhs.phrase
    }
}

struct TemperatureExtremums : Decodable , Equatable {
    let max : Temperature
    let min : Temperature
    let text : String
    
    private enum Key: String, CodingKey {
        case max = "Maximum"
        case min = "Minimum"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.max = try container.decode(Temperature.self, forKey: .max)
        self.min = try container.decode(Temperature.self, forKey: .min)
        self.text = "From \(self.min.value.toString()) to \(self.max.value.toString())"
    }
    
    static func == (lhs: TemperatureExtremums, rhs: TemperatureExtremums) -> Bool {
        return lhs.max == rhs.max && lhs.min == rhs.min
    }
}
