//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 15.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherByDayTableView: UITableView!
    @IBOutlet weak var weatherByHourCollectionView: UICollectionView!
    
    var itemIndex = 0
    var apiKey = ""
    var territoryNameAndKey: TerritoryInfo?
    var weatherArrayByDay = [DailyForecast]()
    var weatherArrayByHour = [WeatherByHour]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cityLabel.text = territoryNameAndKey?.name
        let weather = weatherArrayByHour[0]
        self.temperatureLabel.text = "\(weather.temperature.value) in \(weather.temperature.unit)"
        self.weatherLabel.text = weather.phrase
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let result = formatter.string(from: date)
        self.dateLabel.text = result
    }
}

