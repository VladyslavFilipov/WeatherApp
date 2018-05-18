//
//  CityChoiceViewController.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 17.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import UIKit

class CityChoiceViewController: UIViewController {

    @IBOutlet weak var cityTextField: UITextField!
    
    var delegate: Territory?
    
    var apiKey = ""

    @IBAction func doneButtonPressed(_ sender: Any) {
        guard let city = cityTextField.text else { return }
        getJsonFromUrl(city)
    }
}
