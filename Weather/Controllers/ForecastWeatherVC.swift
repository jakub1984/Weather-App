//
//  ForecastWeatherVC.swift
//  Weather
//
//  Created by Jakub Perich on 30/04/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import UIKit
import Alamofire

class ForecastWeatherVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentCity: UILabel!
    private var weatherData = [ForecastList]()
    private var weatherForecast = [ForecastModel]()
    private var predictedArray = [PredictedCell]()
    private var predictedTemperature = [String]()
    private var predictedDate = [String]()
    private var predictedDescription = [String]()
    private var predictedIcon = [String]()
    private var sections = [DaySection]()
    @IBOutlet weak var apiRequestLoading: UIActivityIndicatorView!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var reloadDataButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.reloadDataButton.isHidden = true
        self.errorMessage.isHidden = true
        
        getWeatherForecast(latitude: myLatitude, longitude: myLongitude, apiKey: apiKey) { (weather) in
            if let localWeather = weather {
                self.weatherData = localWeather.list
                self.setTableview(weatherData: self.weatherData)
                
                self.loadingView.isHidden = true
                self.apiRequestLoading.isHidden = true
            }
        }
    }
    
    func setTableview(weatherData:[ForecastList]) {
        self.currentCity.text = self.weatherForecast[0].city.name?.capitalizingFirstLetter() ?? "Weather Forecast"
        for i in 0 ..< self.weatherData.count {
            self.predictedDate.append(self.weatherData[i].date ?? "2019-05-06 18:00:00")
            self.predictedDescription.append(self.weatherData[i].weather[0].description!.capitalizingFirstLetter())
            self.predictedIcon.append(self.weatherData[i].weather[0].icon!)
            self.predictedTemperature.append(String(self.weatherData[i].main.temp!))
            self.predictedArray.append(PredictedCell(icon: self.weatherData[i].weather[0].icon!, description: self.weatherData[i].weather[0].description!.capitalizingFirstLetter(), temperature: String(format: "%.0f", self.weatherData[i].main.temp!), date: self.weatherData[i].date ?? "2019-05-06 18:00:00", time: self.weatherData[i].date ?? "2019-05-06 18:00:00"))
        }
        
        let groups = Dictionary(grouping: self.predictedArray, by: { (headlines) in
            return self.utcToMonth(date: headlines.date)
        })
        self.sections = groups.map(DaySection.init(date:headlines:)).sorted()
        
        self.tableView.reloadData()
        
    }
    
    
    //    In case of error, user has an option to fetch data again.
    @IBAction func reloadData(_ sender: UIButton) {
        apiRequestLoading.isHidden = false
        getWeatherForecast(latitude: myLatitude, longitude: myLongitude, apiKey: apiKey) { (weather) in
            if let localWeather = weather {
                self.weatherData = localWeather.list
                self.setTableview(weatherData: self.weatherData)
                
                self.loadingView.isHidden = true
                self.apiRequestLoading.isHidden = true
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headlineView = UIView()
        let label = UILabel()
        label.font = UIFont.init(name: "ProximaNova-Bold", size: 14)
        headlineView.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        label.frame = CGRect(x: 20, y: 0, width: 200, height: 44)
        headlineView.addSubview(label)
        
        
        switch section {
        case 0:
            label.text = String("TODAY")
            return headlineView
        case 1...5:
            let date = utcToDayName(date: self.sections[section].date)
            let capitalizedDate = date.uppercased()
            label.text = "\(capitalizedDate)"
            return headlineView
        default:
            label.text = String("NEXT DAY")
            return headlineView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].headlines.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    //    Sets up a tableview cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastTableViewCell
        let headline = self.sections[indexPath.section].headlines[indexPath.row]
        
        cell.hourLabel.text = self.utcToLocalHours(date: headline.time)
        cell.weatherDescriptionLabel.text = headline.description
        cell.temperatureLabel.text = "\(headline.temperature)°"
        cell.weatherIco.image = UIImage(named: "60x60 \(headline.icon)")
        return cell
    }
    
    //    Converts time from UTC date to local time
    func utcToLocalHours(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: dt!)
    }
    
    //    Converts time from UTC date to name day
    func utcToDayName(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: dt!)
    }
    
    func utcToMonth(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: dt!)
    }
    
    
    //    Alamofire request which fetches data from remote API and saves it to ForecastModel struct.
    func getWeatherForecast(latitude: String, longitude: String, apiKey: String,  completion: @escaping ForecastCompletion) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric") else { return }
        
        Alamofire.request(url).responseJSON { response in
            if let error = response.result.error {
                debugPrint(error.localizedDescription)
                self.apiRequestLoading.isHidden = true
                self.reloadDataButton.isHidden = false
                self.errorMessage.isHidden = false
                self.errorMessage.text = "\(error.localizedDescription.capitalizingFirstLetter())"
                completion(nil)
                return
            }
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
                
                guard let data = response.data else { return completion(nil)}
                let jsonDecoder = JSONDecoder()
                do {
                    let forecast = try jsonDecoder.decode(ForecastModel.self, from: data)
                    self.weatherForecast.append(forecast)
                    completion(forecast)
                    
                } catch {
                    debugPrint(error)
                    completion(nil)
                }
            }
        }
    }
}

