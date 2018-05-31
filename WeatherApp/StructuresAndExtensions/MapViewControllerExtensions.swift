//
//  MapViewControllerExtensions.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 31.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation
import MapKit

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
        locationDelegate?.addTerritory(withNameAndKey: value)
    }
    
    func addLocation(withNameAndKey value: TerritoryInfo) {
        self.city.parseJsonFromUrl(value.name)
    }
    
    func territoryError(_ status: Bool) {
        locationDelegate?.territoryError(status)
    }
    
    func locationError(_ status: Bool) {
        print(status)
        locationDelegate?.locationError(status)
    }
}
