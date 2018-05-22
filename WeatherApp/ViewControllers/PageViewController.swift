//
//  PageViewController.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 15.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import UIKit
import CoreLocation

class PageViewController: UIViewController, Territory, Forecast {

    @IBOutlet weak var pageControl: UIPageControl!
    
    let apiKey = "KAwlbrGFXgnsAHhyhtCYT2OWEZuoAeO1"
    
    let location = Geolocation()
    let daily = DailyWeather()
    
    var pageViewController: UIPageViewController?
    var pendingIndex: Int?
    var territoryArray = [TerritoryInfo]() {
        didSet { DispatchQueue.main.async { self.pageControl.numberOfPages = self.territoryArray.count } }
    }
    var weather = (byDay: [WeatherByDay](), byHour: [[WeatherByHour]]()) {
        didSet { DispatchQueue.main.async {
            if self.weather.byDay.count == self.weather.byHour.count { self.createPageViewController()} } }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        location.forecastDelegate = self
        location.locationDelegate = self
        location.apiKey = apiKey
        location.determineMyCurrentLocation()
    }
    
    func getWeatherViewController(withIndex index: Int) -> WeatherViewController? {
        if index < territoryArray.count {
            let weatherVC = self.storyboard?.instantiateViewController(withIdentifier: "weatherVC") as? WeatherViewController
            weatherVC?.itemIndex = index
            weatherVC?.apiKey = apiKey
            weatherVC?.territoryNameAndKey = territoryArray[index]
            weatherVC?.weatherArrayByDay = weather.byDay[index].forecast
            weatherVC?.weatherArrayByHour = weather.byHour[index]
            pageControl.currentPage = index
            return weatherVC
        }
        return nil
    }
    
    private func createPageViewController() {
        let pageVC = self.storyboard?.instantiateViewController(withIdentifier: "pageVC") as? UIPageViewController
        pageVC?.dataSource = self
//        pageVC?.delegate = self
        if territoryArray.count > 0 {
            guard let controller = getWeatherViewController(withIndex: territoryArray.count - 1) else { return }
            let controllers = [controller]
            pageVC?.setViewControllers(controllers, direction: .forward, animated: true, completion: nil)
        }
        pageViewController = pageVC
        self.addChildViewController(pageViewController!)
        self.view.insertSubview(pageViewController!.view, belowSubview: pageControl)
        pageViewController!.didMove(toParentViewController: self)
    }
    
    func addLocation(withNameAndKey value: TerritoryInfo) {
        if territoryArray.count == 0 { territoryArray.append(value) }
        else { territoryArray[0] = value }
    }
    
    func addTerritory(withNameAndKey value: TerritoryInfo) {
        territoryArray.append(value)
    }
    
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
    
    @IBAction func addCity(_ sender: Any) {
        cityVCPresent()
    }
    
    private func cityVCPresent() {
        let cityVC = self.storyboard?.instantiateViewController(withIdentifier: "cityVC") as? CityChoiceViewController
        cityVC?.territoryDelegate = self
        cityVC?.forecastDelegate = self
        cityVC?.apiKey = apiKey
        self.present(cityVC!, animated: true, completion: nil)
    }
}

protocol Territory {
    func addTerritory(withNameAndKey value: TerritoryInfo)
    func addLocation(withNameAndKey value: TerritoryInfo)
}

protocol Forecast {
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo)
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo)
}
