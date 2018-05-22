//
//  CityChoiceViewController.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 17.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import UIKit

class CityChoiceViewController: UIViewController, Territory, Forecast {

    @IBOutlet weak var cityTextField: UITextField!
    
    var city = CityInfo()
    var territoryDelegate: Territory?
    var forecastDelegate: Forecast?
    var apiKey = ""

    @IBAction func doneButtonPressed(_ sender: Any) {
        guard let city = cityTextField.text else { return }
        self.city.locationDelegate = self
        self.city.forecastDelegate = self
        if city != "" {
            self.city.getJsonFromUrl(city, apiKey)
            self.dismiss(animated: true, completion: nil)
        }
        else { self.dismiss(animated: true, completion: nil) }
    }
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        forecastDelegate?.addHourlyForecast(value: value, city: city)
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        forecastDelegate?.addDailyForecast(value: value, city: city)
    }
    
    func addTerritory(withNameAndKey value: TerritoryInfo) {
        territoryDelegate?.addTerritory(withNameAndKey: value)
    }
    
    func addLocation(withNameAndKey value: TerritoryInfo) {
        territoryDelegate?.addLocation(withNameAndKey: value)
    }
}
