//
//  Extensions.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 16.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

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

extension PageViewController : UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let weatherVC = viewController as! WeatherViewController
        if weatherVC.itemIndex > 0 {
            return getWeatherViewController(withIndex: weatherVC.itemIndex - 1)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let weatherVC = viewController as! WeatherViewController
        if weatherVC.itemIndex + 1 < territoryArray.count {
            return getWeatherViewController(withIndex: weatherVC.itemIndex + 1)
        }
        return nil
    }
}

extension WeatherViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = weatherArrayByHour.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as? WeatherCollectionViewCell else { return UICollectionViewCell() }
        let weather = self.weatherArrayByHour[indexPath.row]
        cell.timeLabel.text = "\(weather.dateTime.components(separatedBy: "T")[1].components(separatedBy: "+")[0])"
        cell.temperatureLabel.text = "\(String(format: "%.1f", weather.temperature.value)) in \(weather.temperature.unit)"
        cell.weatherTypeLabel.text = weather.phrase.components(separatedBy: "w")[0]
        return cell
    }
}

extension WeatherViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = weatherArrayByDay.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell") as? WeatherTableViewCell else { return UITableViewCell() }
        let weather = self.weatherArrayByDay[indexPath.row]
        cell.timeLabel.text = "\(weather.date.components(separatedBy: "T")[0].components(separatedBy: "-")[2])"
        cell.temperatureLabel.text = "From \(String(format: "%.1f", weather.temperature.min.value)) to \(String(format: "%.1f", weather.temperature.max.value))"
        cell.weatherTypeLabel.text = weather.day.phrase.components(separatedBy: "w")[0]
        return cell
    }
}
