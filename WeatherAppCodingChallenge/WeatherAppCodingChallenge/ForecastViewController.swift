//
//  ForecastViewController.swift
//  WeatherAppCodingChallenge
//
//  Created by Erica Y Stevens on 8/3/17.
//  Copyright © 2017 Erica Y Stevens. All rights reserved.
//

import UIKit

fileprivate let apiRoot = "http://api.aerisapi.com/forecasts/11101"
fileprivate let clientIDQueryKey = "client_id"
fileprivate let clientIDQueryValue = "J8XN5KmTeWSHt4DRHutuj"
fileprivate let secretKeyQueryKey = "client_secret"
fileprivate let secretKeyQueryValue = "7SU0yJd2O2Zmw1aHBFgv9InFbuvU24grphUXkFJX"
fileprivate let forecastCollectionCellReuseIdentifier = "ForecastCell"

class ForecastViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Outlets
    
    @IBOutlet weak var locationDescriptionLabel: UILabel!
    @IBOutlet weak var forecastCollectionView: UICollectionView!

    // MARK: - Stored Properties
    
    var forecasts: [Forecast] = []
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        forecastCollectionView.delegate = self
        forecastCollectionView.dataSource = self
        locationDescriptionLabel.text = "NYC 7-Day Forecast"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getForecast()
    }
    
    // MARK: - Networking Helper Methods

    func buildAPIEndpoint() -> URL? {
        guard var urlComponents = URLComponents(string: apiRoot) else { return nil }
        
        let clientIDQuery = URLQueryItem(name: clientIDQueryKey, value: clientIDQueryValue)
        let secretKeyQuery = URLQueryItem(name: secretKeyQueryKey, value: secretKeyQueryValue)
        
        urlComponents.queryItems = [clientIDQuery, secretKeyQuery]
        
        guard let url = urlComponents.url else { return nil }
        return url
    }
    
    func getForecast() {
        APIRequestManager.manager.getData(endpoint: buildAPIEndpoint()!) { (data: Data?) in
            if let validData = data {
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: validData, options: []) as? [String:AnyObject] {
                        if let response = jsonData["response"] as? [[String:AnyObject]] {
                            var forecastDataDict: [String:Any] = [:]
                            
                            for dict in response {
                                for (key, value) in dict {
                                forecastDataDict.updateValue(value, forKey: key)
                                }
                            }
                            if let periods = forecastDataDict["periods"] as? [[String:Any]] {
                                self.forecasts = Forecast.forecasts(from: periods)
                                DispatchQueue.main.async {
                                    self.forecastCollectionView.reloadData()
                                }
                            }
                        }
                    }
                }
                catch let error as NSError {
                    print("Error getting data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - UICollectionView Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: forecastCollectionCellReuseIdentifier, for: indexPath) as! ForecastCollectionViewCell
        
        let forecast = forecasts[indexPath.row]
        
        cell.forecastDateLabel.text = forecast.date
        cell.forecastLowTempLabel.text = "LOW: \(forecast.minTempF)"
        cell.forecastHighTempLabel.text = "HIGH: \(forecast.maxTempF)"
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: forecastCollectionView.frame.size.width / 3, height: forecastCollectionView.frame.size.height)
        return size
    }
    
}
