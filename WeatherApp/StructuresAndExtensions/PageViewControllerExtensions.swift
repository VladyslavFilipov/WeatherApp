//
//  PageViewControllerExtensions.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 31.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation
import UIKit

extension PageViewController : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let weatherVC = viewController as? WeatherViewController, weatherVC.itemIndex > 0 else { return nil }
        return getWeatherViewController(withIndex: weatherVC.itemIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let weatherVC = viewController as? WeatherViewController, weatherVC.itemIndex + 1 < territoryArray.count  else { return nil }
        return getWeatherViewController(withIndex: weatherVC.itemIndex + 1)
    }
}

extension PageViewController : UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = (pendingViewControllers.first as! WeatherViewController).itemIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let currentIndex = pendingIndex
            if let index = currentIndex {
                self.pageControl.currentPage = index
            }
        }
    }
}

extension PageViewController : Territory {
    
    func addLocation(withNameAndKey value: TerritoryInfo) {
        if territoryArray.count == 0 { territoryArray.append(value) }
        else { territoryArray[0] = value }
    }
    
    func addTerritory(withNameAndKey value: TerritoryInfo) {
        if !territoryArray.contains(value) { territoryArray.append(value) }
    }
    
    func territoryError(_ status: Bool) {
        DispatchQueue.main.async {
            self.connectionTroublesLabel.text = "Territory determination troubles"
            self.performingError(!status)
        }
        error = .territory
    }
    
    func locationError(_ status: Bool) {
        addCityByMapButton.isEnabled = !status
        if status { addCityByMapButton.setTitle("Geolocation error", for: .normal) }
        else {
            addCityByMapButton.setTitle("Add by map", for: .normal)
            location.determineMyCurrentLocation()
        }
    }
}

extension PageViewController : Forecast {
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        guard let index = territoryArray.index(of: city) else { return }
        if index == weather.byHour.count { weather.byHour.append(value) }
        else { weather.byHour[index] = value }
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        guard let index = territoryArray.index(of: city) else { return }
        if index == weather.byDay.count { weather.byDay.append(value) }
        else { weather.byDay[index] = value }
    }
    
    func forecastError(_ status: Bool) {
        DispatchQueue.main.async {
            self.connectionTroublesLabel.text = "Forecast troubles"
            self.performingError(!status)
        }
        error = .forecast
    }
}

extension PageViewController : Spinner {
    
    func addSpinner() {
        spinner = self.displaySpinner(onView: self.view)
        view.addSubview(spinner)
    }
    
    func removeSpinner() {
        self.removeSpinner(spinner: spinner)
    }
}

extension PageViewController : Connection {
    
    func checkConnection(_ status: Bool) {
        DispatchQueue.main.async {
            self.connectionTroublesLabel.text = "Internet connection troubles"
            self.performingError(status)
        }
        error = .internet
    }
}
