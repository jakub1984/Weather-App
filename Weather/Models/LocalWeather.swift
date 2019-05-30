//
//  LocalWeather.swift
//  strvTestTask
//
//  Created by Jakub Perich on 30/04/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import Foundation

struct Main : Codable {
    var temp : Float?
    var pressure : Float?
    var humidity : Float?
}

struct Wind : Codable {
    var speed : Float?
    var deg : Float?
}

struct Weather : Codable {
    var icon : String?
    var description: String?
}

struct Sys : Codable {
    var country : String?
}

struct Rain : Codable {
    var threeHours : Float?
    
    enum CodingKeys: String, CodingKey {
        case threeHours = "3h"
    }
    
}

struct LocalWeather : Codable {
    var name : String?
    var weather : [Weather]
    var main : Main
    var wind : Wind
    var rain : Rain?
    var sys : Sys
}
