//
//  WeatherViewControllerExtensions.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 31.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation
import UIKit

extension WeatherViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = weatherArrayByHour.count
        return count
    }
}

extension WeatherViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as? WeatherCollectionViewCell else { return UICollectionViewCell() }
        let weather = self.weatherArrayByHour[indexPath.row]
        cell.timeLabel.text = weather.dateTime
        cell.weatherTypeLabel.text = weather.phrase
        cell.temperatureLabel.text = weather.temperature.text
        cell.backgroundColor = UIColor.clear.withAlphaComponent(0.4)
        return cell
    }
}

extension WeatherViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = weatherArrayByDay.count
        return count
    }
}

extension WeatherViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell") as? WeatherTableViewCell else { return UITableViewCell() }
        let weather = self.weatherArrayByDay[indexPath.row]
        cell.timeLabel.text = weather.date
        cell.weatherTypeLabel.text = weather.day.phrase
        cell.temperatureLabel.text = weather.temperature.text
        cell.backgroundColor = UIColor.clear.withAlphaComponent(0.4)
        return cell
    }
}

extension WeatherViewController : UIScrollViewDelegate {
    
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
                locationDelegate?.locationError(true)
                return
            }
            locationDelegate?.locationError(false)
        }
    }
}

extension WeatherViewController : Territory {
    
    func addTerritory(withNameAndKey value: TerritoryInfo) {  }
    
    func addLocation(withNameAndKey value: TerritoryInfo) {
        if self.itemIndex == 0 { self.locationDelegate?.addLocation(withNameAndKey: value) }
    }
    
    func territoryError(_ status: Bool) {
        locationDelegate?.territoryError(status)
    }
    
    func locationError(_ status: Bool) {
        locationDelegate?.locationError(status)
    }
}

extension WeatherViewController : Forecast {
    
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
}
