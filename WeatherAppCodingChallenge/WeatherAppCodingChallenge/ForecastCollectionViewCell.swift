//
//  ForecastCollectionViewCell.swift
//  WeatherAppCodingChallenge
//
//  Created by Erica Y Stevens on 8/3/17.
//  Copyright © 2017 Erica Y Stevens. All rights reserved.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var forecastDateLabel: UILabel!
    @IBOutlet weak var forecastLowTempLabel: UILabel!
    @IBOutlet weak var forecastHighTempLabel: UILabel!
    @IBOutlet weak var forecastIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
