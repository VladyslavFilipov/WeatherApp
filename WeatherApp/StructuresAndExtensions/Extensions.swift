//
//  Extensions.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 16.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation
import MapKit
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

extension CityChoiceViewController : Territory {
    
    func addTerritory(withNameAndKey value: TerritoryInfo) {
        territoryDelegate?.addTerritory(withNameAndKey: value)
    }
    
    func addLocation(withNameAndKey value: TerritoryInfo) {
        territoryDelegate?.addLocation(withNameAndKey: value)
    }
    
    func territoryError(_ status: Bool) {
        territoryDelegate?.territoryError(status)
    }
    
    func locationError(_ status: Bool) {
        territoryDelegate?.locationError(status)
    }
}

extension CityChoiceViewController : Forecast {
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        forecastDelegate?.addHourlyForecast(value: value, city: city)
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        forecastDelegate?.addDailyForecast(value: value, city: city)
    }
    
    func forecastError(_ status: Bool) {
        forecastDelegate?.forecastError(status)
    }
}


extension MapViewController : MKMapViewDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self.mkMapView)
            let location = self.mkMapView.convert(touchPoint, toCoordinateFrom: self.mkMapView)
            annotation.coordinate = location
            mkMapView.addAnnotation(annotation)
        }
    }
}

extension MapViewController : Territory {
    
    func addTerritory(withNameAndKey value: TerritoryInfo) {
        territoryDelegate?.addTerritory(withNameAndKey: value)
    }
    
    func addLocation(withNameAndKey value: TerritoryInfo) {
        self.city.parseJsonFromUrl(value.name, apiKey)
    }
    
    func territoryError(_ status: Bool) {
        territoryDelegate?.territoryError(status)
    }
    
    func locationError(_ status: Bool) {
        territoryDelegate?.locationError(status)
    }
}

extension MapViewController : Forecast {
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        forecastDelegate?.addHourlyForecast(value: value, city: city)
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        forecastDelegate?.addDailyForecast(value: value, city: city)
    }
    
    func forecastError(_ status: Bool) {
        forecastDelegate?.forecastError(status)
    }
}

extension Geolocation : CLLocationManagerDelegate {
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if Geolocation.isEnabled() { locationManager.startUpdatingLocation() }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        spinnerDelegate?.addSpinner()
        userLocation = locations[0] as CLLocation
        daily.forecastDelegate = self
        hourly.forecastDelegate = self
        parseJSON(userLocation?.coordinate)
        self.locationManager.stopUpdatingLocation()
    }
}

extension Geolocation : Forecast {
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        if error == .none { forecastDelegate?.addHourlyForecast(value: value, city: city) }
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        if error == .none { forecastDelegate?.addDailyForecast(value: value, city: city) }
    }
    
    func forecastError(_ status: Bool) {
        if error == .none { forecastDelegate?.forecastError(status) }
    }
}

extension CityInfo : Forecast {
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        if error == .none { forecastDelegate?.addHourlyForecast(value: value, city: city) }
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        if error == .none { forecastDelegate?.addDailyForecast(value: value, city: city) }
    }
    
    func forecastError(_ status: Bool) {
        if error == .none { forecastDelegate?.forecastError(status) }
    }
}
