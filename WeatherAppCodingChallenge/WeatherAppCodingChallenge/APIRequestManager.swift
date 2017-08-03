//
//  APIRequestManager.swift
//  WeatherAppCodingChallenge
//
//  Created by Erica Y Stevens on 8/3/17.
//  Copyright © 2017 Erica Y Stevens. All rights reserved.
//

import Foundation

class APIRequestManager {
    static let manager = APIRequestManager()
    private init() {}
    
    func getData(endpoint: URL, callback: @escaping (Data?) -> Void) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        var request = URLRequest(url: endpoint)
        
        request.httpMethod = "GET"

        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                 print("Error during DataTask Session: \(error!)")
            }
            guard let validData = data else { return }
            callback(validData)
        }.resume()
    }
}
