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
    var date: String
    
    init(minTempF: Int, maxTempF: Int, date: String) {
        self.minTempF = minTempF
        self.maxTempF = maxTempF
        self.date = date
    }
    
    init?(with dict: [String:Any]) {
        if let minTemp = dict["minTempF"] as? Int,
            let maxTemp = dict["maxTempF"] as? Int,
            let timestamp = dict["dateTimeISO"] as? String {
            
            self.minTempF = minTemp
            self.maxTempF = maxTemp
            
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
