//
//  JSONGettingModel.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 31.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation

class JSONGetting {
    
    let spinnerDelegate: Spinner?
    
    init( _ spinner: Spinner?) {
        self.spinnerDelegate = spinner
    }
    
    func getJSON<Type: Decodable>( _ path: String, type: Type.Type, completion:@escaping (Type?) -> Void) {
        spinnerDelegate?.addSpinner()
        guard let URL = URL(string: path) else { return }
        Session.parseJSONWithAlamofire(with: URL, type: type.self) { data in
            guard let data = data else { return }
            self.spinnerDelegate?.removeSpinner()
            completion(data)
        }
    }
}
