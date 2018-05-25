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
    
    var territoryDelegate: Territory?
    var forecastDelegate: Forecast?
    var spinnerDelegate: Spinner?
    
    var city = CityInfo()
    var imageView = UIImageView()
    var apiKey = ""
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.insertSubview(imageView, at: 0)
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        self.spinnerDelegate?.addSpinner()
        guard var city = cityTextField.text else { return }
        city = city.getAllPhrase(separatedBy: " ")
        self.city.locationDelegate = self
        self.city.forecastDelegate = self
        if city != "" {
            self.city.parseJsonFromUrl(city, apiKey)
            self.dismiss(animated: true, completion: nil)
            self.spinnerDelegate?.removeSpinner()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    func forecastError(_ status: Bool) {
        forecastDelegate?.forecastError(status)
    }
    
    func territoryError(_ status: Bool) {
        territoryDelegate?.territoryError(status)
    }
}
