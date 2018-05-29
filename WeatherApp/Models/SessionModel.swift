//
//  SessionModel.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 29.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation
import Alamofire

class Session {
    
    class func parseJSON<Type: Decodable>(with url: URL, type: Type.Type, completion:@escaping (Type?) -> Void) {
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success:
                guard let jsonData = response.data else { return }
                do {
                    let city = try JSONDecoder().decode(type.self, from: jsonData)
                    completion (city)
                } catch { completion (nil) }
            case .failure:
                completion (nil)
            }
        }
    }
}
