//
//  ExtensionsOfBasicTypes.swift
//  WeatherApp
//
//  Created by Vladislav Filipov on 30.05.2018.
//  Copyright © 2018 Vladislav Filipov. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    func getAllPhrase(separatedBy string: String) -> String {
        var phrase = self
        var phraseArray = phrase.components(separatedBy: string)
        phrase = phraseArray[0]
        phraseArray.removeFirst()
        if phraseArray.count > 0 {
            for component in phraseArray {
                phrase += " " + component
            }
        }
        return phrase
    }
    
    func getOnlySymbols(separatedBy string: String) -> String {
        var phrase = self
        var phraseArray = phrase.components(separatedBy: string)
        phrase = phraseArray[0]
        phraseArray.removeFirst()
        if phraseArray.count > 0 {
            for component in phraseArray {
                phrase += component
            }
        }
        return phrase
    }
    
    func getSeparated(by string: String, on position: Int) -> String {
        let phrase = self.components(separatedBy: string)[position]
        return phrase
    }
}

extension Double {
    
    func toString() -> String {
        let value = self
        return String(format: "%.1f", value)
    }
}

extension UIViewController {
    
    func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(activityIndicator)
            onView.addSubview(spinnerView)
        }
        return spinnerView
    }
    
    func removeSpinner(spinner : UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension UIColor {
    
    func invert() -> UIColor {
        var red         :   CGFloat  =   255.0
        var green       :   CGFloat  =   255.0
        var blue        :   CGFloat  =   255.0
        var alpha       :   CGFloat  =   1.0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red     =   255.0 - (red * 255.0)
        green   =   255.0 - (green * 255.0)
        blue    =   255.0 - (blue * 255.0)
        
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}

extension EnumCollection {
    
    public static func cases() -> AnySequence<Self> {
        return AnySequence { () -> AnyIterator<Self> in
            var raw = 0
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: self, capacity: 1) { $0.pointee } }
                guard current.hashValue == raw else {
                    return nil
                }
                raw += 1
                return current
            }
        }
    }
    
    public static var allValues: [Self] {
        return Array(self.cases())
    }
}

extension Array {
    mutating func forEach(body: (inout Element) throws -> Void) rethrows {
        for index in self.indices {
            try body(&self[index])
        }
    }
}
