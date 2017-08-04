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
    @IBOutlet weak var toggleFahrenheitCelsiusSegmentedControl: UISegmentedControl!
    
    // MARK: - Stored Properties
    
    var forecasts: [Forecast] = []
    var showFahrenheitTemps = true
    
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
        switch indexPath.row {
        case 0:
            cell.forecastDateLabel.text = "Today"
        default:
            cell.forecastDateLabel.text = forecast.date
        }
        
        switch toggleFahrenheitCelsiusSegmentedControl.selectedSegmentIndex {
        case 0:
           DispatchQueue.main.async {
                cell.forecastLowTempLabel.text = "LOW: \(forecast.minTempF)\u{00B0}F"
                cell.forecastHighTempLabel.text = "HIGH: \(forecast.maxTempF)\u{00B0}F"
                self.forecastCollectionView.reloadData()

            }
        case 1:
            DispatchQueue.main.async {
                cell.forecastLowTempLabel.text = "LOW: \(forecast.minTempC)\u{00B0}C"
                cell.forecastHighTempLabel.text = "HIGH: \(forecast.maxTempC)\u{00B0}C"
                self.forecastCollectionView.reloadData()
            }
        default:
            break
        }
        
        cell.forecastIconImageView.image = getImageFor(iconFilename: forecast.iconPath)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: forecastCollectionView.frame.size.width / 3, height: forecastCollectionView.frame.size.height)
        return size
    }
    
}

extension ForecastViewController {
    
    // MARK: - Image Setter Helper Method
    
    func getImageFor(iconFilename: String) -> UIImage {
        var returnImage = UIImage()
        
        let iconPath = iconFilename.components(separatedBy: ".").first!
        
        switch iconPath {
        case iconPath where iconPath == ForecastIconDescription.am_pcloudy.rawValue:
            returnImage = #imageLiteral(resourceName: "am_pcloudy")
        case iconPath where iconPath == ForecastIconDescription.am_pcloudyr.rawValue:
            returnImage = #imageLiteral(resourceName: "am_pcloudyr")
        case iconPath where iconPath == ForecastIconDescription.am_showers.rawValue:
            returnImage = #imageLiteral(resourceName: "am_showers")
        case iconPath where iconPath == ForecastIconDescription.am_showshowers.rawValue:
            returnImage = #imageLiteral(resourceName: "am_showshowers")
        case iconPath where iconPath == ForecastIconDescription.am_tstorm.rawValue:
            returnImage = #imageLiteral(resourceName: "am_tstorm")
        case iconPath where iconPath == ForecastIconDescription.blizzard.rawValue:
            returnImage = #imageLiteral(resourceName: "blizzard")
        case iconPath where iconPath == ForecastIconDescription.blizzardn.rawValue:
            returnImage = #imageLiteral(resourceName: "blizzardn")
        case iconPath where iconPath == ForecastIconDescription.blowingsnow.rawValue:
            returnImage = #imageLiteral(resourceName: "blowingsnow")
        case iconPath where iconPath == ForecastIconDescription.blowingsnown.rawValue:
            returnImage = #imageLiteral(resourceName: "blowingsnown")
        case iconPath where iconPath == ForecastIconDescription.chancetstorm.rawValue:
            returnImage = #imageLiteral(resourceName: "chancetstorm")
        case iconPath where iconPath == ForecastIconDescription.chancetstormn.rawValue:
            returnImage = #imageLiteral(resourceName: "chancetstormn")
        case iconPath where iconPath == ForecastIconDescription.clear.rawValue:
            returnImage = #imageLiteral(resourceName: "clear")
        case iconPath where iconPath == ForecastIconDescription.clearn.rawValue:
            returnImage = #imageLiteral(resourceName: "clearn")
        case iconPath where iconPath == ForecastIconDescription.clearw.rawValue:
            returnImage = #imageLiteral(resourceName: "clearw")
        case iconPath where iconPath == ForecastIconDescription.clearwn.rawValue:
            returnImage = #imageLiteral(resourceName: "clearwn")
        case iconPath where iconPath == ForecastIconDescription.cloudy.rawValue:
            returnImage = #imageLiteral(resourceName: "cloudy")
        case iconPath where iconPath == ForecastIconDescription.cloudyn.rawValue:
            returnImage = #imageLiteral(resourceName: "cloudyn")
        case iconPath where iconPath == ForecastIconDescription.cloudyw.rawValue:
            returnImage = #imageLiteral(resourceName: "cloudyw")
        case iconPath where iconPath == ForecastIconDescription.cloudywn.rawValue:
            returnImage = #imageLiteral(resourceName: "cloudywn")
        case iconPath where iconPath == ForecastIconDescription.drizzle.rawValue:
            returnImage = #imageLiteral(resourceName: "drizzle")
        case iconPath where iconPath == ForecastIconDescription.drizzlef.rawValue:
            returnImage = #imageLiteral(resourceName: "drizzlef")
        case iconPath where iconPath == ForecastIconDescription.drizzlen.rawValue:
            returnImage = #imageLiteral(resourceName: "drizzlen")
        case iconPath where iconPath == ForecastIconDescription.dust.rawValue:
            returnImage = #imageLiteral(resourceName: "dust")
        case iconPath where iconPath == ForecastIconDescription.fair.rawValue:
            returnImage = #imageLiteral(resourceName: "fair")
        case iconPath where iconPath == ForecastIconDescription.fairn.rawValue:
            returnImage = #imageLiteral(resourceName: "fairn")
        case iconPath where iconPath == ForecastIconDescription.fairw.rawValue:
            returnImage = #imageLiteral(resourceName: "fairw")
        case iconPath where iconPath == ForecastIconDescription.fairwn.rawValue:
            returnImage = #imageLiteral(resourceName: "fairwn")
        case iconPath where iconPath == ForecastIconDescription.fdrizzle.rawValue:
            returnImage = #imageLiteral(resourceName: "fdrizzle")
        case iconPath where iconPath == ForecastIconDescription.fdrizzlen.rawValue:
            returnImage = #imageLiteral(resourceName: "fdrizzlen")
        case iconPath where iconPath == ForecastIconDescription.flurries.rawValue:
            returnImage = #imageLiteral(resourceName: "flurries")
        case iconPath where iconPath == ForecastIconDescription.flurriesn.rawValue:
            returnImage = #imageLiteral(resourceName: "flurriesn")
        case iconPath where iconPath == ForecastIconDescription.flurriesw.rawValue:
            returnImage = #imageLiteral(resourceName: "flurriesw")
        case iconPath where iconPath == ForecastIconDescription.flurrieswn.rawValue:
            returnImage = #imageLiteral(resourceName: "flurrieswn")
        case iconPath where iconPath == ForecastIconDescription.fog.rawValue:
            returnImage = #imageLiteral(resourceName: "fog")
        case iconPath where iconPath == ForecastIconDescription.fogn.rawValue:
            returnImage = #imageLiteral(resourceName: "fogn")
        case iconPath where iconPath == ForecastIconDescription.freezingrain.rawValue:
            returnImage = #imageLiteral(resourceName: "freezingrain")
        case iconPath where iconPath == ForecastIconDescription.freezingrainn.rawValue:
            returnImage = #imageLiteral(resourceName: "freezingrainn")
        case iconPath where iconPath == ForecastIconDescription.hazy.rawValue:
            returnImage = #imageLiteral(resourceName: "hazy")
        case iconPath where iconPath == ForecastIconDescription.hazyn.rawValue:
            returnImage = #imageLiteral(resourceName: "hazyn")
        case iconPath where iconPath == ForecastIconDescription.mcloudy.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudy")
        case iconPath where iconPath == ForecastIconDescription.mcloudyn.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudyn")
        case iconPath where iconPath == ForecastIconDescription.mcloudyr.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudyr")
        case iconPath where iconPath == ForecastIconDescription.mcloudyrn.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudyrn")
        case iconPath where iconPath == ForecastIconDescription.mcloudyrw.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudyrw")
        case iconPath where iconPath == ForecastIconDescription.mcloudyrwn.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudyrwn")
        case iconPath where iconPath == ForecastIconDescription.mcloudys.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudys")
        case iconPath where iconPath == ForecastIconDescription.mcloudysfn.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudysfn")
        case iconPath where iconPath == ForecastIconDescription.mcloudysfw.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudysfw")
        case iconPath where iconPath == ForecastIconDescription.mcloudysfwn.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudysfwn")
        case iconPath where iconPath == ForecastIconDescription.mcloudysn.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudysn")
        case iconPath where iconPath == ForecastIconDescription.mcloudysw.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudysw")
        case iconPath where iconPath == ForecastIconDescription.mcloudyswn.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudyswn")
        case iconPath where iconPath == ForecastIconDescription.mcloudyt.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudyt")
        case iconPath where iconPath == ForecastIconDescription.mcloudytn.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudytn")
        case iconPath where iconPath == ForecastIconDescription.mcloudytw.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudytw")
        case iconPath where iconPath == ForecastIconDescription.mcloudytwn.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudytwn")
        case iconPath where iconPath == ForecastIconDescription.mcloudyw.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudyw")
        case iconPath where iconPath == ForecastIconDescription.mcloudywn.rawValue:
            returnImage = #imageLiteral(resourceName: "mcloudywn")
        case iconPath where iconPath == ForecastIconDescription.pcloudy.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudy")
        case iconPath where iconPath == ForecastIconDescription.pcloudyn.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudyn")
        case iconPath where iconPath == ForecastIconDescription.pcloudyr.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudyr")
        case iconPath where iconPath == ForecastIconDescription.pcloudyrn.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudyrn")
        case iconPath where iconPath == ForecastIconDescription.pcloudyrw.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudyrw")
        case iconPath where iconPath == ForecastIconDescription.pcloudyrwn.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudyrwn")
        case iconPath where iconPath == ForecastIconDescription.pcloudys.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudys")
        case iconPath where iconPath == ForecastIconDescription.pcloudysfn.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudysfn")
        case iconPath where iconPath == ForecastIconDescription.pcloudysfw.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudysfw")
        case iconPath where iconPath == ForecastIconDescription.pcloudysfwn.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudysfwn")
        case iconPath where iconPath == ForecastIconDescription.pcloudysn.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudysn")
        case iconPath where iconPath == ForecastIconDescription.pcloudysw.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudysw")
        case iconPath where iconPath == ForecastIconDescription.pcloudyswn.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudyswn")
        case iconPath where iconPath == ForecastIconDescription.pcloudyt.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudyt")
        case iconPath where iconPath == ForecastIconDescription.pcloudytn.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudytn")
        case iconPath where iconPath == ForecastIconDescription.pcloudytw.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudytw")
        case iconPath where iconPath == ForecastIconDescription.pcloudytwn.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudytwn")
        case iconPath where iconPath == ForecastIconDescription.pcloudyw.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudyw")
        case iconPath where iconPath == ForecastIconDescription.pcloudywn.rawValue:
            returnImage = #imageLiteral(resourceName: "pcloudywn")
        case iconPath where iconPath == ForecastIconDescription.pm_pcloudy.rawValue:
            returnImage = #imageLiteral(resourceName: "pm_pcloudy")
        case iconPath where iconPath == ForecastIconDescription.pm_pcloudyr.rawValue:
            returnImage = #imageLiteral(resourceName: "pm_pcloudyr")
        case iconPath where iconPath == ForecastIconDescription.pm_showers.rawValue:
            returnImage = #imageLiteral(resourceName: "pm_showers")
        case iconPath where iconPath == ForecastIconDescription.pm_snowshowers.rawValue:
            returnImage = #imageLiteral(resourceName: "pm_snowshowers")
        case iconPath where iconPath == ForecastIconDescription.pm_tstorm.rawValue:
            returnImage = #imageLiteral(resourceName: "pm_tstorm")
        case iconPath where iconPath == ForecastIconDescription.rain.rawValue:
            returnImage = #imageLiteral(resourceName: "rain")
        case iconPath where iconPath == ForecastIconDescription.rainandsnow.rawValue:
            returnImage = #imageLiteral(resourceName: "rainandsnow")
        case iconPath where iconPath == ForecastIconDescription.rainandsnown.rawValue:
            returnImage = #imageLiteral(resourceName: "rainandsnown")
        case iconPath where iconPath == ForecastIconDescription.rainn.rawValue:
            returnImage = #imageLiteral(resourceName: "rainn")
        case iconPath where iconPath == ForecastIconDescription.raintosnow.rawValue:
            returnImage = #imageLiteral(resourceName: "raintosnow")
        case iconPath where iconPath == ForecastIconDescription.raintosnown.rawValue:
            returnImage = #imageLiteral(resourceName: "raintosnown")
        case iconPath where iconPath == ForecastIconDescription.rainw.rawValue:
            returnImage = #imageLiteral(resourceName: "rainw")
        case iconPath where iconPath == ForecastIconDescription.showers.rawValue:
            returnImage = #imageLiteral(resourceName: "showers")
        case iconPath where iconPath == ForecastIconDescription.showersn.rawValue:
            returnImage = #imageLiteral(resourceName: "showersn")
        case iconPath where iconPath == ForecastIconDescription.showersw.rawValue:
            returnImage = #imageLiteral(resourceName: "showersw")
        case iconPath where iconPath == ForecastIconDescription.sleet.rawValue:
            returnImage = #imageLiteral(resourceName: "sleet")
        case iconPath where iconPath == ForecastIconDescription.sleetn.rawValue:
            returnImage = #imageLiteral(resourceName: "sleetn")
        case iconPath where iconPath == ForecastIconDescription.sleetnsnow.rawValue:
            returnImage = #imageLiteral(resourceName: "sleetsnow")
        case iconPath where iconPath == ForecastIconDescription.smoke.rawValue:
            returnImage = #imageLiteral(resourceName: "smoke")
        case iconPath where iconPath == ForecastIconDescription.snow.rawValue:
            returnImage = #imageLiteral(resourceName: "snow")
        case iconPath where iconPath == ForecastIconDescription.snown.rawValue:
            returnImage = #imageLiteral(resourceName: "snown")
        case iconPath where iconPath == ForecastIconDescription.snowshowers.rawValue:
            returnImage = #imageLiteral(resourceName: "snowshowers")
        case iconPath where iconPath == ForecastIconDescription.snowshowersn.rawValue:
            returnImage = #imageLiteral(resourceName: "snowshowersn")
        case iconPath where iconPath == ForecastIconDescription.snowshowersw.rawValue:
            returnImage = #imageLiteral(resourceName: "snowshowersw")
        case iconPath where iconPath == ForecastIconDescription.snowshowerswn.rawValue:
            returnImage = #imageLiteral(resourceName: "snowshowerswn")
        case iconPath where iconPath == ForecastIconDescription.snowtorain.rawValue:
            returnImage = #imageLiteral(resourceName: "snowtorain")
        case iconPath where iconPath == ForecastIconDescription.snowtorainn.rawValue:
            returnImage = #imageLiteral(resourceName: "snowtorainn")
        case iconPath where iconPath == ForecastIconDescription.snoww.rawValue:
            returnImage = #imageLiteral(resourceName: "snoww")
        case iconPath where iconPath == ForecastIconDescription.snowwn.rawValue:
            returnImage = #imageLiteral(resourceName: "snowwn")
        case iconPath where iconPath == ForecastIconDescription.sunny.rawValue:
            returnImage = #imageLiteral(resourceName: "sunny")
        case iconPath where iconPath == ForecastIconDescription.sunnyn.rawValue:
            returnImage = #imageLiteral(resourceName: "sunnyn")
        case iconPath where iconPath == ForecastIconDescription.sunnyw.rawValue:
            returnImage = #imageLiteral(resourceName: "sunnyw")
        case iconPath where iconPath == ForecastIconDescription.sunnywn.rawValue:
            returnImage = #imageLiteral(resourceName: "sunnywn")
        case iconPath where iconPath == ForecastIconDescription.tstorm.rawValue:
            returnImage = #imageLiteral(resourceName: "tstorm")
        case iconPath where iconPath == ForecastIconDescription.tstormn.rawValue:
            returnImage = #imageLiteral(resourceName: "tstormn")
        case iconPath where iconPath == ForecastIconDescription.tstormsw.rawValue:
            returnImage = #imageLiteral(resourceName: "tstormsw")
        case iconPath where iconPath == ForecastIconDescription.tstormswn.rawValue:
            returnImage = #imageLiteral(resourceName: "tstormswn")
        case iconPath where iconPath == ForecastIconDescription.tstormw.rawValue:
            returnImage = #imageLiteral(resourceName: "tstormw")
        case iconPath where iconPath == ForecastIconDescription.tstormwn.rawValue:
            returnImage = #imageLiteral(resourceName: "tstormwn")
        case iconPath where iconPath == ForecastIconDescription.wind.rawValue:
            returnImage = #imageLiteral(resourceName: "wind")
        case iconPath where iconPath == ForecastIconDescription.wintrymin.rawValue:
            returnImage = #imageLiteral(resourceName: "wintrymix")
        case iconPath where iconPath == ForecastIconDescription.wintryminxn.rawValue:
            returnImage = #imageLiteral(resourceName: "wintrymix")
        default:
            returnImage = #imageLiteral(resourceName: "na")
        }
        return returnImage
    }
}
