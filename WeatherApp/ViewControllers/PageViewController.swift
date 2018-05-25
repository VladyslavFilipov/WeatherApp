//
//  PageViewController.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 15.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import UIKit
import CoreLocation

enum ErrorType {
    case none
    case territory
    case internet
    case forecast
}

class PageViewController: UIViewController, Territory, Forecast, Spinner, Connection {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var connectionTroublesLabel: UILabel!
    @IBOutlet weak var addCityByNameButton: UIButton!
    @IBOutlet weak var addCityByMapButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    
    let location = Geolocation()
    let basic = Basic()
    
    var error : ErrorType = .none
    
    var pageViewController: UIPageViewController?
    var pendingIndex: Int?
    var spinner = UIView()
    var territoryArray = [TerritoryInfo]()
    var weather = (byDay: [WeatherByDay](), byHour: [[WeatherByHour]]()) {
        didSet { DispatchQueue.main.async {
            if self.weather.byDay.count == self.weather.byHour.count {
                self.pageControl.numberOfPages = self.territoryArray.count
                self.createPageViewController( self.pageControl.currentPage ) } } }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        location.forecastDelegate = self
        location.locationDelegate = self
        location.spinnerDelegate = self
        location.apiKey = basic.apiKey
        pageControl.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        if territoryArray.count == 0 {
            checkConnection(InternetConnection.isConnectedToNetwork())
        }
    }
    
    func getWeatherViewController(withIndex index: Int) -> WeatherViewController? {
        if index < territoryArray.count {
            let weatherVC = self.storyboard?.instantiateViewController(withIdentifier: "weatherVC") as? WeatherViewController
            weatherVC?.itemIndex = index
            weatherVC?.apiKey = basic.apiKey
            weatherVC?.territoryNameAndKey = territoryArray[index]
            weatherVC?.weatherArrayByDay = weather.byDay[index].forecast
            weatherVC?.weatherArrayByHour = weather.byHour[index]
            weatherVC?.locationDelegate = self
            weatherVC?.forecastDelegate = self
            weatherVC?.connectionDelegate = self
            return weatherVC
        }
        return nil
    }
    
    private func getBackgroundImage (by index: Int) -> UIImageView {
        let imageView = UIImageView(frame: view.bounds)
        let phrase = weather.byHour[index][0].phrase.components(separatedBy: "w/")
        for weather in basic.weatherTypeArray {
            if phrase[phrase.count - 1].containsIgnoringCase(find: weather) {
                imageView.image = UIImage(named: weather)
                break
            }
        }
        return imageView
    }
    
    private func createPageViewController(_ index: Int) {
        let pageVC = self.storyboard?.instantiateViewController(withIdentifier: "pageVC") as? UIPageViewController
        pageVC?.dataSource = self
        pageVC?.delegate = self
        if territoryArray.count > 0 {
            guard let controller = getWeatherViewController(withIndex: index) else { return }
            let controllers = [controller]
            pageVC?.setViewControllers(controllers, direction: .forward, animated: true, completion: nil)
        }
        pageViewController = pageVC
        removeSubviewIfExist()
        self.addChildViewController(pageViewController!)
        self.view.insertSubview(pageViewController!.view, belowSubview: pageControl)
        pageViewController!.didMove(toParentViewController: self)
    }
    
    private func createCityVC() -> CityChoiceViewController? {
        let cityVC = self.storyboard?.instantiateViewController(withIdentifier: "cityVC") as? CityChoiceViewController
        cityVC?.territoryDelegate = self
        cityVC?.forecastDelegate = self
        cityVC?.apiKey = basic.apiKey
        if territoryArray.count > 0 && (Geolocation.isEnabled() && InternetConnection.isConnectedToNetwork()) {
            cityVC?.imageView = getBackgroundImage(by: pageControl.currentPage) }
        else { cityVC?.imageView = UIImageView(frame: view.bounds)
            cityVC?.imageView.image = UIImage(named: "sun")
        }
        return cityVC
    }
    
    private func performingError(_ status: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        connectionTroublesLabel.isHidden = status
        retryButton.isHidden = status
        addCityByNameButton.isHidden = !status
        addCityByMapButton.isHidden = !status
        pageControl.isHidden = !status
        if status {
            if !Geolocation.isEnabled() && territoryArray.count == 0 {
                guard let cityVC = createCityVC() else { return }
                self.present(cityVC, animated: true, completion: nil)
            }
            location.determineMyCurrentLocation()
        } else {
            removeSubviewIfExist()
        }
    }
    
    private func removeSubviewIfExist() {
        if self.childViewControllers.count == 1 {
            view.subviews[1].removeFromSuperview() // view.subviews[1] (if exist) - always pageViewController.view
            self.childViewControllers[0].removeFromParentViewController() // self.childViewControllers[0] (if exist) - pageViewController
        }
    }
    
    func addLocation(withNameAndKey value: TerritoryInfo) {
        if territoryArray.count == 0 { territoryArray.append(value) }
        else { territoryArray[0] = value }
    }
    
    func addTerritory(withNameAndKey value: TerritoryInfo) {
        if !territoryArray.contains(value) { territoryArray.append(value) }
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
    
    func addSpinner() {
        spinner = self.displaySpinner(onView: self.view)
        view.addSubview(spinner)
    }
    
    func removeSpinner() {
        self.removeSpinner(spinner: spinner)
    }
    
    func forecastError(_ status: Bool) {
        DispatchQueue.main.async {
            self.connectionTroublesLabel.text = "Forecast troubles"
            self.performingError(!status)
        }
        error = .forecast
    }
    
    func territoryError(_ status: Bool) {
        DispatchQueue.main.async {
            self.connectionTroublesLabel.text = "Territory determination troubles"
            self.performingError(!status)
        }
        error = .territory
    }
    
    func checkConnection(_ status: Bool) {
        DispatchQueue.main.async {
            self.connectionTroublesLabel.text = "Internet connection troubles"
            self.performingError(status)
        }
        error = .internet
    }
    
    @IBAction func addCityByNameButtonTapped(_ sender: Any) {
        guard let cityVC = createCityVC() else { return }
        self.present(cityVC, animated: true, completion: nil)
    }
    
    @IBAction func addCityByMapButtonTapped(_ sender: Any) {
        guard let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "mapVC") as? MapViewController else { return }
        mapVC.territoryDelegate = self
        mapVC.forecastDelegate = self
        mapVC.apiKey = basic.apiKey
        if territoryArray.count > 0 && (Geolocation.isEnabled() && InternetConnection.isConnectedToNetwork()) {
            mapVC.imageView = getBackgroundImage(by: pageControl.currentPage) }
        else { mapVC.imageView = UIImageView(frame: view.bounds)
            mapVC.imageView.image = UIImage(named: "sun")
        }
        self.present(mapVC, animated: true, completion: nil)
    }
    
    @IBAction func retryButtonTapped(_ sender: Any) {
        switch error {
        case .internet:
            checkConnection(InternetConnection.isConnectedToNetwork())
        case .forecast:
            forecastError(false)
        case .territory:
            territoryError(false)
        default:
            print("Something went wrong")
        }
    }
}

protocol Territory {
    func addTerritory(withNameAndKey value: TerritoryInfo)
    func addLocation(withNameAndKey value: TerritoryInfo)
    func territoryError(_ status: Bool)
}

protocol Forecast {
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo)
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo)
    func forecastError(_ status: Bool)
}

protocol Spinner {
    func addSpinner()
    func removeSpinner()
}

protocol Connection {
    func checkConnection(_ status: Bool)
}
