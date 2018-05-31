//
//  MapViewController.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 25.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mkMapView: MKMapView!
    
    var locationDelegate: Territory?
    var forecastDelegate: Forecast?
    var spinnerDelegate: Spinner?
    
    var location = Geolocation()
    var city = CityInfo()
    var imageView = UIImageView()
    
    var annotation = MKPointAnnotation()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.insertSubview(imageView, at: 0)
        mkMapView.delegate = self
        mkMapView.showsUserLocation = true
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        self.spinnerDelegate?.addSpinner()
        self.location.locationDelegate = self
        self.location.forecastDelegate = forecastDelegate
        self.location.spinnerDelegate = spinnerDelegate
        self.city.locationDelegate = self
        self.city.forecastDelegate = forecastDelegate
        self.city.spinnerDelegate = spinnerDelegate
        location.parseJSON(annotation.coordinate)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
