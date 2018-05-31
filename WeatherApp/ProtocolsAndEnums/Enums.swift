//
//  Enums.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 30.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation
import UIKit

enum WeatherPictures: String, EnumCollection {
    
    case sun = "sun"
    case cloud = "cloud"
    case rain = "rain"
    case snow = "snow"
    case storm = "storm"
    case clear = "clear"
    case fog = "fog"
    case flur = "flur"
    case ice = "ice"
    case sleet = "sleet"
    case rainAndSnow = "rain and snow"
    case wind = "wind"
    case cold = "cold"
    case hot = "hot"
    
    var image: UIImage {
        return UIImage(named: self.rawValue)!
    }
}

enum ErrorType {
    case none
    case territory
    case location
    case internet
    case forecast
}
