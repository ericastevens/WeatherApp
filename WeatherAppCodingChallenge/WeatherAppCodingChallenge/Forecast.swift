//
//  Forecast.swift
//  WeatherAppCodingChallenge
//
//  Created by Erica Y Stevens on 8/3/17.
//  Copyright © 2017 Erica Y Stevens. All rights reserved.
//

import Foundation

class Forecast {
    var minTempF: Int
    var maxTempF: Int
    var minTempC: Int
    var maxTempC: Int
    var date: String
    var iconPath: String
    
    init(minTempF: Int, maxTempF: Int, date: String, iconPath: String, minTempC: Int, maxTempC: Int) {
        self.minTempF = minTempF
        self.maxTempF = maxTempF
        self.minTempC = minTempC
        self.maxTempC = maxTempC
        self.date = date
        self.iconPath = iconPath
    }
    
    init?(with dict: [String:Any]) {
        if let minTempF = dict["minTempF"] as? Int,
            let maxTempF = dict["maxTempF"] as? Int,
            let minTempC = dict["minTempC"] as? Int,
            let maxTempC = dict["maxTempC"] as? Int,
            let timestamp = dict["dateTimeISO"] as? String,
            let iconPath = dict["icon"] as? String {
            
            self.minTempF = minTempF
            self.maxTempF = maxTempF
            self.minTempC = minTempC
            self.maxTempC = maxTempC
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let date = dateFormatter.date(from:timestamp)!
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            let finalDate = calendar.date(from:components)
            dateFormatter.dateFormat = "MM/dd"
            let formattedDateString = dateFormatter.string(from: finalDate!)
            
            self.date = formattedDateString
            self.iconPath = iconPath
            
        } else {
            return nil
        }
    }
    
    static func forecasts(from forecastsArray: [[String:Any]]) -> [Forecast] {
        var forecasts: [Forecast] = []
        
        for dict in forecastsArray {
            if let forecast = Forecast(with: dict) {
                forecasts.append(forecast)
            }
        }
        return forecasts
    }
}
