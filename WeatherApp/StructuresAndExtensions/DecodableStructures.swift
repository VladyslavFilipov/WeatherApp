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
        if lhs.name == rhs.name && lhs.key == rhs.key {
            return true
        }
        return false
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
        if lhs.name == rhs.name && lhs.key == rhs.key { return true }
        return false
    }
}

struct WeatherByHour: Decodable, Equatable {
    
    let dateTime : String
    let phrase : String
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
        if lhs.phrase == rhs.phrase && lhs.dateTime == rhs.dateTime && lhs.temperature == rhs.temperature { return true }
        return false
    }
}

struct Temperature : Decodable, Equatable {
    let unit : String
    let value : Double
    
    private enum Key: String, CodingKey {
        case unit = "Unit"
        case value = "Value"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.unit = try container.decode(String.self, forKey: .unit)
        self.value = try container.decode(Double.self, forKey: .value)
    }
    static func == (lhs: Temperature, rhs: Temperature) -> Bool {
        if lhs.unit == rhs.unit && lhs.value == rhs.value { return true }
        return false
    }
}

struct WeatherByDay: Decodable , Equatable {
    let forecast : [DailyForecast]
    
    private enum Key: String, CodingKey {
        case forecast = "DailyForecasts"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.forecast = try container.decode([DailyForecast].self, forKey: .forecast)
    }
    
    static func == (lhs: WeatherByDay, rhs: WeatherByDay) -> Bool {
        if lhs.forecast == rhs.forecast { return true }
        return false
    }
}

struct DailyForecast : Decodable, Equatable {
    
    let date : String
    let day : WeatherInDayPhrase
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
        if lhs.date == rhs.date && lhs.day == rhs.day && lhs.temperature == rhs.temperature { return true }
        return false
    }
}

struct WeatherInDayPhrase: Decodable , Equatable {
    let phrase : String
    
    private enum Key: String, CodingKey {
        case phrase = "IconPhrase"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.phrase = try container.decode(String.self, forKey: .phrase)
    }
    
    static func == (lhs: WeatherInDayPhrase, rhs: WeatherInDayPhrase) -> Bool {
        if lhs.phrase == rhs.phrase  { return true }
        return false
    }
}

struct TemperatureExtremums : Decodable , Equatable {
    let max : Temperature
    let min : Temperature
    
    private enum Key: String, CodingKey {
        case max = "Maximum"
        case min = "Minimum"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.max = try container.decode(Temperature.self, forKey: .max)
        self.min = try container.decode(Temperature.self, forKey: .min)
    }
    
    static func == (lhs: TemperatureExtremums, rhs: TemperatureExtremums) -> Bool {
        if lhs.max == rhs.max && lhs.min == rhs.min  { return true }
        return false
    }
}
