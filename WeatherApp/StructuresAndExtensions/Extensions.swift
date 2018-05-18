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

extension PageViewController : CLLocationManagerDelegate {
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() { locationManager.startUpdatingLocation() }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
        getJsonFromUrl()
    }
    
    func getJsonFromUrl() {
        let city = "https://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(apiKey)&q=\(userLocation.coordinate.latitude)%2C\(userLocation.coordinate.longitude)"
        guard let cityURL = URL(string: city) else { return }
        URLSession.shared.dataTask(with: cityURL, completionHandler: {(data, response, error) -> Void in
            guard let data = data else { return }
            do {
                let city = try JSONDecoder().decode(City.self, from: data)
                guard let cityName = city.info?.name, let cityKey = city.info?.key else { return }
                if self.territoryArray.count == 0 { self.territoryArray.append((cityName, cityKey)) }
                else { self.territoryArray[0] = (cityName, cityKey) }
            } catch { print("It`s error here") }
        }).resume()
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
        cell.weatherTypeLabel.text = weather.phrase
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
        cell.weatherTypeLabel.text = weather.day.phrase
        return cell
    }
}

extension CityChoiceViewController {
    
    func getJsonFromUrl(_ city: String) {
        let cityURLString = "https://dataservice.accuweather.com/locations/v1/cities/search?apikey=\(apiKey)&q=\(city)"
        guard let cityURL = URL(string: cityURLString) else { return }
        URLSession.shared.dataTask(with: cityURL, completionHandler: {(data, response, error) -> Void in
            guard let data = data else { return }
            do {
                let city = try JSONDecoder().decode([CityNameAndKey].self, from: data)
                guard let cityName = city[0].name, let cityKey = city[0].key else { return }
                self.delegate?.addTerritory((cityName, cityKey))
                self.dismiss(animated: false, completion: nil)
            } catch { print("It`s an error here") }
        }).resume()
    }
}

