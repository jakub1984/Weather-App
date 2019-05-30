
//
//  Constants.swift
//  Weather
//
//  Created by Jakub Perich on 30/04/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import UIKit

// replace with your own free API key from https://openweathermap.org/api

let apiKey = "c6245bbeaa41dc827871f51ecb1b1790"
var myLongitude = String()
var myLatitude = String()




typealias WeatherCompletion = (LocalWeather?) -> Void
typealias ForecastCompletion = (ForecastModel?) -> Void



