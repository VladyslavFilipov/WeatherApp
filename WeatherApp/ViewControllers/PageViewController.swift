//
//  PageViewController.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 15.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import UIKit
import CoreLocation

class PageViewController: UIViewController, Territory {

    @IBOutlet weak var pageControl: UIPageControl!
    
    let apiKey = "OI2gyTjifTOzaSBtMJyk4iFUKVPmu6L5"
    
    var locationManager:CLLocationManager!
    var userLocation = CLLocation()
    var pageViewController: UIPageViewController?
    var pendingIndex: Int?
    var territoryArray = [(String, String)]() {
        didSet { DispatchQueue.main.async {
            self.pageControl.numberOfPages = self.territoryArray.count
            self.createPageViewController()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineMyCurrentLocation()
    }
    
    func getWeatherViewController(withIndex index: Int) -> WeatherViewController? {
        if index < territoryArray.count {
            let weatherVC = self.storyboard?.instantiateViewController(withIdentifier: "weatherVC") as? WeatherViewController
            weatherVC?.itemIndex = index
            weatherVC?.apiKey = apiKey
            weatherVC?.territoryNameAndKey = territoryArray[index]
            pageControl.currentPage = index
            return weatherVC
        }
        return nil
    }
    
    func createPageViewController() {
        let pageVC = self.storyboard?.instantiateViewController(withIdentifier: "pageVC") as? UIPageViewController
        pageVC?.dataSource = self
        pageVC?.delegate = self
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
    
    func addTerritory(withNameAndKey value: (String, String)) {
        territoryArray.append(value)
    }
    
    @IBAction func addCity(_ sender: Any) {
        let cityVC = self.storyboard?.instantiateViewController(withIdentifier: "cityVC") as? CityChoiceViewController
        cityVC?.delegate = self
        cityVC?.apiKey = apiKey
        present(cityVC!, animated: true, completion: nil)
    }
}

protocol Territory {
    func addTerritory(withNameAndKey value: (String, String))
}
