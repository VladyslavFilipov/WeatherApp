//
//  PageViewController.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 15.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import UIKit
import CoreLocation

class PageViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var connectionTroublesLabel: UILabel!
    @IBOutlet weak var addCityByNameButton: UIButton!
    @IBOutlet weak var addCityByMapButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    
    let location = Geolocation()
    
    var error : ErrorType = .none
    
    var pageViewController: UIPageViewController?
    var pendingIndex: Int?
    var spinner = UIView()
    var territories = [TerritoryInfo]()
    var weather = (byDay: [WeatherByDay](), byHour: [[WeatherByHour]]()) {
        didSet { DispatchQueue.main.async {
            if self.weather.byDay.count == self.weather.byHour.count {
                self.pageControl.numberOfPages = self.territories.count
                self.createPageViewController( self.pageControl.currentPage ) } } }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        location.forecastDelegate = self
        location.locationDelegate = self
        location.spinnerDelegate = self
        pageControl.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        locationError(!Geolocation.isEnabled())
        if territories.count == 0 {
            updateWithConnectionAvailability(InternetConnection.isConnectedToNetwork())
        }
    }
    
    func getWeatherViewController(withIndex index: Int) -> WeatherViewController? {
        if index < weather.byDay.count && (weather.byDay.count == weather.byHour.count) {
            guard let weatherVC = self.storyboard?.instantiateViewController(withIdentifier: "weatherVC") as? WeatherViewController else { return WeatherViewController() }
            weatherVC.itemIndex = index
            weatherVC.territoryNameAndKey = territories[index]
            weatherVC.weatherByDayCollection = weather.byDay[index].forecast
            weatherVC.weatherByHourCollection = weather.byHour[index]
            weatherVC.locationDelegate = self
            weatherVC.forecastDelegate = self
            weatherVC.connectionDelegate = self
            return weatherVC
        }
        return nil
    }
    
    private func createPageViewController(_ index: Int) {
        let pageVC = self.storyboard?.instantiateViewController(withIdentifier: "pageVC") as? UIPageViewController
        pageVC?.dataSource = self
        pageVC?.delegate = self
        if territories.count > 0 {
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
        guard let cityVC = self.storyboard?.instantiateViewController(withIdentifier: "cityVC") as? CityChoiceViewController else { return CityChoiceViewController() }
        cityVC.territoryDelegate = self
        cityVC.forecastDelegate = self
        cityVC.imageView = UIImageView(frame: view.bounds)
        cityVC.imageView.image = UIImage(named: "wind")
        return cityVC
    }
    
    func performingError(_ status: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        connectionTroublesLabel.isHidden = status
        retryButton.isHidden = status
        addCityByNameButton.isHidden = !status
        addCityByMapButton.isHidden = !status
        pageControl.isHidden = !status
        if status {
            if !Geolocation.isEnabled() {
                if territories.count == 0 {
                    guard let cityVC = createCityVC() else { return }
                    self.present(cityVC, animated: true, completion: nil)
                }
            }
        } else {
            removeSubviewIfExist()
        }
    }
    
    private func removeSubviewIfExist() {
        if self.childViewControllers.count > 0 && view.subviews.count > 1 {
            view.subviews[1].removeFromSuperview() // view.subviews[1] (if exist) - always pageViewController.view
            self.childViewControllers[0].removeFromParentViewController() // self.childViewControllers[0] (if exist) - pageViewController
        }
    }
    
    @IBAction func addCityByNameButtonTapped(_ sender: Any) {
        guard let cityVC = createCityVC() else { return }
        self.present(cityVC, animated: true, completion: nil)
    }
    
    @IBAction func addCityByMapButtonTapped(_ sender: Any) {
        guard let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "mapVC") as? MapViewController else { return }
        mapVC.locationDelegate = self
        mapVC.forecastDelegate = self
        mapVC.imageView = UIImageView(frame: view.bounds)
        mapVC.imageView.image = UIImage(named: "wind")
        self.present(mapVC, animated: true, completion: nil)
    }
    
    @IBAction func retryButtonTapped(_ sender: Any) {
        switch error {
        case .internet:
            updateWithConnectionAvailability(InternetConnection.isConnectedToNetwork())
        case .forecast:
            forecastError(false)
        case .territory:
            territoryError(false)
        default:
            print("Something went wrong")
        }
    }
}

