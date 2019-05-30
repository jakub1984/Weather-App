//
//  ForecastTableViewCell.swift
//  strvTestTask
//
//  Created by Jakub Perich on 30/04/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    @IBOutlet weak var weatherIco: UIImageView!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
