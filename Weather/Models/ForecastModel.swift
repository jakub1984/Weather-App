//
//  ForecastModel.swift
//  strvTestTask
//
//  Created by Jakub Perich on 03/05/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import Foundation

struct ForecastModel : Codable {
    var city : City
    var list : [ForecastList]
}

struct City : Codable {
    var name : String?
}

struct ForecastList : Codable {
    var main : MainTemperature
    var weather : [MainWeather]
    var date : String?
    
    enum CodingKeys: String, CodingKey {
        case main = "main"
        case weather = "weather"
        case date = "dt_txt"
    }
}

struct MainTemperature : Codable {
    var temp : Float?
}

struct MainWeather : Codable {
    var icon : String?
    var description : String?
}

struct PredictedCell {
    var icon : String
    var description : String
    var temperature : String
    var date : String
    var time : String
    
    init(icon: String, description: String, temperature: String, date : String, time: String) {
        self.icon = icon
        self.description = description
        self.temperature = temperature
        self.date = date
        self.time = time
    }
}

struct DaySection : Comparable {
    var date : String
    var headlines : [PredictedCell]
    
    static func < (lhs:DaySection, rhs: DaySection) -> Bool {
        return lhs.date < rhs.date
    }
    
    static func == (lhs:DaySection, rhs: DaySection) -> Bool {
        return lhs.date == rhs.date
    }
    
}
