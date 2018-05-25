//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 15.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, UIScrollViewDelegate, Territory, Forecast {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherByDayTableView: UITableView!
    @IBOutlet weak var weatherByHourCollectionView: UICollectionView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var locationDelegate: Territory?
    var forecastDelegate: Forecast?
    var connectionDelegate: Connection?
    
    var itemIndex = 0
    var apiKey = ""
    var refreshControl = UIRefreshControl()
    var territoryNameAndKey: TerritoryInfo?
    var weatherArrayByDay = [DailyForecast]()
    var weatherArrayByHour = [WeatherByHour]()
    var imageView = UIImageView()
    
    let location = Geolocation()
    let basic = Basic()
    
    override func viewWillAppear(_ animated: Bool) {
        scrollView.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        scrollView.refreshControl = refreshControl
        setupMainInfo()
        setupTodaysDate()
    }
    
    private func setupMainInfo() {
        imageView = getBackgroundImage()
        backgroundView.insertSubview(imageView, at: 0)
        
        let weather = self.weatherArrayByHour[0]
        let image = imageView.image
        
        switch image {
        case UIImage(named: "hot"), UIImage(named: "clear"), UIImage(named: "storm"), UIImage(named: "rain"), UIImage(named: "shower"):
            setupMainLabelsBackground(UIColor.white)
            UIApplication.shared.statusBarStyle = .lightContent
        default :
            setupMainLabelsBackground(UIColor.black)
            UIApplication.shared.statusBarStyle = .default
        }
        
        self.cityLabel.text = self.territoryNameAndKey?.name
        self.temperatureLabel.text = "\(weather.temperature.value) in \(weather.temperature.unit)"
        self.weatherLabel.text = weatherArrayByHour[0].phrase.getAllPhrase(separatedBy: "w/").getAllPhrase(separatedBy: "t-")
    }
    
    func setupMainLabelsBackground(_ color: UIColor) {
        cityLabel.textColor = color
        cityLabel.shadowColor = color.invert()
        temperatureLabel.textColor = color
        temperatureLabel.shadowColor = color.invert()
        weatherLabel.textColor = color
        weatherLabel.shadowColor = color.invert()
        dateLabel.textColor = color
        dateLabel.shadowColor = color.invert()
        scrollView.refreshControl?.tintColor = color
        scrollView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedStringKey.foregroundColor: color])
    }
    
    private func setupTodaysDate() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let result = formatter.string(from: date)
        self.dateLabel.text = result
    }
    
    @objc func refresh(sender: AnyObject) {
        location.locationDelegate = self
        location.forecastDelegate = self
        location.apiKey = apiKey
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setupMainInfo()
        refreshControl.endRefreshing()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview!)
        if translation.y > 200 {
            if !InternetConnection.isConnectedToNetwork() {
                connectionDelegate?.checkConnection(InternetConnection.isConnectedToNetwork())
                return
            } else if !Geolocation.isEnabled() {
                locationDelegate?.territoryError(!Geolocation.isEnabled())
                return
            }
        }
    }
    
    func getBackgroundImage () -> UIImageView {
        let imageView = UIImageView(frame: view.bounds)
        let phrase = weatherArrayByHour[0].phrase.components(separatedBy: "w/")
        for weather in basic.weatherTypeArray {
            if phrase[phrase.count - 1].containsIgnoringCase(find: weather) {
                imageView.image = UIImage(named: weather)
                break
            }
        }
        return imageView
    }
    
    func addTerritory(withNameAndKey value: TerritoryInfo) {  }
    
    func addLocation(withNameAndKey value: TerritoryInfo) {
        if self.itemIndex == 0 { self.locationDelegate?.addLocation(withNameAndKey: value) }
    }
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        if weatherArrayByHour != value {
            weatherArrayByHour = value
            forecastDelegate?.addHourlyForecast(value: value, city: city)
        }
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        if weatherArrayByDay != value.forecast {
            weatherArrayByDay = value.forecast
            forecastDelegate?.addDailyForecast(value: value, city: city)
        }
    }
    
    func forecastError(_ status: Bool) {
        forecastDelegate?.forecastError(status)
    }
    
    func territoryError(_ status: Bool) {
        locationDelegate?.territoryError(status)
    }
}

