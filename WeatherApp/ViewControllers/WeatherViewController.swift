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
    
    let pageView = PageViewController()
    
    var itemIndex = 0
    var apiKey = ""
    var territoryNameAndKey: (String, String) = ("", "")
    
    var weatherArrayByDay = [DailyForecast]() {
        didSet { DispatchQueue.main.async {
            self.weatherByDayTableView.reloadData() } }
    }
    
    var weatherArrayByHour = [WeatherByHour]() {
        didSet { DispatchQueue.main.async {
            let weather = self.weatherArrayByHour[0]
            self.temperatureLabel.text = "\(weather.temperature.value) in \(weather.temperature.unit)"
            self.weatherLabel.text = weather.phrase
            self.cityLabel.text = self.territoryNameAndKey.0
            self.weatherByHourCollectionView.reloadData() } }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let result = formatter.string(from: date)
        dateLabel.text = result
        getJsonFromUrl()
    }
    
    func getJsonFromUrl() {
            let weatherByHourString = "https://dataservice.accuweather.com/forecasts/v1/hourly/12hour/\(self.territoryNameAndKey.1)?apikey=\(self.apiKey)&metric=true"
            guard let weatherByHourURL = URL(string: weatherByHourString) else { return }
            URLSession.shared.dataTask(with: weatherByHourURL, completionHandler: {(data, response, error) -> Void in
                guard let data = data else { return }
                do {
                    let weather = try JSONDecoder().decode([WeatherByHour].self, from: data)
                    self.weatherArrayByHour = weather
                } catch { print("It`s an error here") }
            }).resume()
            let weatherByDayString = "https://dataservice.accuweather.com/forecasts/v1/daily/5day/\(self.territoryNameAndKey.1)?apikey=\(self.apiKey)&metric=true"
            guard let weatherByDayURL = URL(string: weatherByDayString) else { return }
            URLSession.shared.dataTask(with: weatherByDayURL, completionHandler: {(data, response, error) -> Void in
                guard let data = data else { return }
                do {
                    let weather = try JSONDecoder().decode(WeatherByDay.self, from: data)
                    self.weatherArrayByDay = weather.forecast
                } catch { print("It`s an error here") }
            }).resume()
    }
    
    func parseJSONasArray(_ data: Data, _ key: String) -> [Any]? {
        do { if let json = try JSONSerialization.jsonObject(with: data) as? [Any] { print(json); return json }
        else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] { return json[key] as? [Any] } }
        catch { print("Error"); return nil }
        return nil
    }
}


