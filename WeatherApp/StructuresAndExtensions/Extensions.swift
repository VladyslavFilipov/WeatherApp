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

extension PageViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let weatherVC = viewController as? WeatherViewController else { return nil }
        if weatherVC.itemIndex > 0 {
            return getWeatherViewController(withIndex: weatherVC.itemIndex - 1)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let weatherVC = viewController as? WeatherViewController else { return nil }
        if weatherVC.itemIndex + 1 < territoryArray.count {
            return getWeatherViewController(withIndex: weatherVC.itemIndex + 1)
        }
        return nil
    }
    
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
        if weather.dateTime.contains("+") { cell.timeLabel.text = weather.dateTime.getSeparated(by: "T", on: 1).getSeparated(by: "+", on: 0) }
        else if weather.dateTime.contains("-") { cell.timeLabel.text = weather.dateTime.getSeparated(by: "T", on: 1).getSeparated(by: "-", on: 0) }
        cell.temperatureLabel.text = "\(weather.temperature.value.toString()) in \(weather.temperature.unit)"
        cell.weatherTypeLabel.text = weather.phrase.getAllPhrase(separatedBy: "w/").getAllPhrase(separatedBy: "t-")
        cell.backgroundColor = UIColor.clear.withAlphaComponent(0.4)
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
        cell.timeLabel.text = weather.date.getSeparated(by: "T", on: 0).getSeparated(by: "-", on: 2)
        cell.temperatureLabel.text = "From \(weather.temperature.min.value.toString()) to \(weather.temperature.max.value.toString())"
        cell.weatherTypeLabel.text = weather.day.phrase.getAllPhrase(separatedBy: "w/").getAllPhrase(separatedBy: "t-")
        cell.backgroundColor = UIColor.clear.withAlphaComponent(0.4)
        return cell
    }
}

extension String {
    
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    func getAllPhrase(separatedBy string: String) -> String {
        var phrase = self
        var phraseArray = phrase.components(separatedBy: string)
        phrase = phraseArray[0]
        phraseArray.removeFirst()
        if phraseArray.count > 0 {
            for component in phraseArray {
                phrase += " " + component
            }
        }
        return phrase
    }
    
    func getSeparated(by string: String,on position: Int) -> String {
        let phrase = self.components(separatedBy: string)[position]
        return phrase
    }
}

extension Double {
    
    func toString() -> String {
        let value = self
        return String(format: "%.1f", value)
    }
}

extension UIViewController {
    
    func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(activityIndicator)
            onView.addSubview(spinnerView)
        }
        return spinnerView
    }
    
    func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension UIColor {
    
    func invert() -> UIColor {
        var red         :   CGFloat  =   255.0
        var green       :   CGFloat  =   255.0
        var blue        :   CGFloat  =   255.0
        var alpha       :   CGFloat  =   1.0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red     =   255.0 - (red * 255.0)
        green   =   255.0 - (green * 255.0)
        blue    =   255.0 - (blue * 255.0)
        
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}
