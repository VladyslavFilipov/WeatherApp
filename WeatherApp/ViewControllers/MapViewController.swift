//
//  MapViewController.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 25.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, Territory, Forecast {
    
    @IBOutlet weak var mkMapView: MKMapView!
    var territoryDelegate: Territory?
    var forecastDelegate: Forecast?
    var spinnerDelegate: Spinner?
    
    var location = Geolocation()
    var city = CityInfo()
    var imageView = UIImageView()
    var apiKey = ""
    
    var annotation = MKPointAnnotation()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.insertSubview(imageView, at: 0)
        
        annotation.title = "I chose it"
        mkMapView.delegate = self
        mkMapView.showsUserLocation = true
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self.mkMapView)
            let location = self.mkMapView.convert(touchPoint, toCoordinateFrom: self.mkMapView)
            annotation.coordinate = location
            mkMapView.addAnnotation(annotation)
        }
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        self.spinnerDelegate?.addSpinner()
        self.location.locationDelegate = self
        self.location.forecastDelegate = self
        self.city.forecastDelegate = self
        self.city.locationDelegate = self
        self.location.apiKey = apiKey
        location.parseJSON(annotation.coordinate)
        self.dismiss(animated: true, completion: nil)
        self.spinnerDelegate?.removeSpinner()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addHourlyForecast(value: [WeatherByHour], city: TerritoryInfo) {
        forecastDelegate?.addHourlyForecast(value: value, city: city)
    }
    
    func addDailyForecast(value: WeatherByDay, city: TerritoryInfo) {
        forecastDelegate?.addDailyForecast(value: value, city: city)
    }
    
    func addTerritory(withNameAndKey value: TerritoryInfo) {
        territoryDelegate?.addTerritory(withNameAndKey: value)
    }
    
    func addLocation(withNameAndKey value: TerritoryInfo) {
        self.city.parseJsonFromUrl(value.name, apiKey)
    }
    func forecastError(_ status: Bool) {
        forecastDelegate?.forecastError(status)
    }
    
    func territoryError(_ status: Bool) {
        territoryDelegate?.territoryError(status)
    }
    
}
