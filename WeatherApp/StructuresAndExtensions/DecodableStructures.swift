//
//  DecodableStructures.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 17.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation

struct City: Decodable {
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
}

struct WeatherByHour: Decodable {
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
}

struct Temperature : Decodable {
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
}

struct WeatherByDay: Decodable {
    let forecast : [DailyForecast]
    
    private enum Key: String, CodingKey {
        case forecast = "DailyForecasts"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.forecast = try container.decode([DailyForecast].self, forKey: .forecast)
    }
}

struct DailyForecast : Decodable {
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
}

struct WeatherInDayPhrase: Decodable {
    let phrase : String
    
    private enum Key: String, CodingKey {
        case phrase = "IconPhrase"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.phrase = try container.decode(String.self, forKey: .phrase)
    }
}

struct TemperatureExtremums : Decodable {
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
}
