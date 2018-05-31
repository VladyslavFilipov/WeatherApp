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
    
    var territoryDelegate: Territory?
    var forecastDelegate: Forecast?
    var spinnerDelegate: Spinner?
    var city = CityInfo()
    
    var imageView = UIImageView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.insertSubview(imageView, at: 0)
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        guard var city = cityTextField.text else { return }
        city = city.getOnlySymbols(separatedBy: " ")
        self.city.locationDelegate = territoryDelegate
        self.city.forecastDelegate = forecastDelegate
        self.city.spinnerDelegate = spinnerDelegate
        if city != "" {
            self.city.parseJsonFromUrl(city)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
