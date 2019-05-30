//
//  CurrentWeatherVC.swift
//  strvTestTask
//
//  Created by Jakub Perich on 30/04/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import CoreLocation

class CurrentWeatherVC: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var weatherIco: UIImageView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentWeatherDescription: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var percipitationLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDirectionLabel: UILabel!
    @IBOutlet weak var apiRequestLoading: UIActivityIndicatorView!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var reloadDataButton: UIButton!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorMessage.isHidden = true
        self.reloadDataButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineMyCurrentLocation()

    }
    
    //    Getting a device's location
    func determineMyCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    //    After the location is retrieved, longitude and latitude are set and OpenWeatherMap API request is processed.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let myLocation:CLLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        myLatitude = "\(myLocation.coordinate.latitude)"
        myLongitude = "\(myLocation.coordinate.longitude)"
        getLocalWeather(latitude: myLatitude, longitude: myLongitude, apiKey: apiKey) { (weather) in
            if let localWeather = weather {
                self.setView(localWeather: localWeather)
                self.apiRequestLoading.isHidden = true
                self.loadingView.isHidden = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.apiRequestLoading.isHidden = true
        self.loadingView.isHidden = false
        self.errorMessage.isHidden = false
        self.errorMessage.text = "Failed to get current location"
    }
    
    //    When the OpenWeatherMap API request is successful, the view is populated with returned values
    func setView(localWeather: LocalWeather) {
        self.currentLocationLabel.text = "\(localWeather.name ?? ""), \(self.getCountryName(from: "\(localWeather.sys.country ?? "CZ")"))"
        self.currentTemperature.text = "\(String(format:"%.0f", localWeather.main.temp ?? 0))"
        self.humidityLabel.text = "\(String(format:"%.0f", localWeather.main.humidity ?? 0))%"
        self.pressureLabel.text = "\(String(format:"%.0f", localWeather.main.pressure ?? 0)) hPa"
        self.windSpeedLabel.text = "\(String(format:"%.0f",localWeather.wind.speed ?? 0)) km/h"
        self.windDirectionLabel.text = "\(self.getWindDirection(deg:localWeather.wind.deg ?? 0))"
        self.percipitationLabel.text = "\(String(format:"%.1f", localWeather.rain?.threeHours ?? 0)) mm"
        self.currentWeatherDescription.text = "\(localWeather.weather[0].description?.capitalizingFirstLetter() ?? "Sunny")"
        self.weatherIco.image = UIImage(named: "100x100 \(localWeather.weather[0].icon ?? "02d")")
    }
    
    //    In case of error, user has an option to fetch data again.
    @IBAction func reloadData(_ sender: UIButton) {
        self.apiRequestLoading.isHidden = false
        getLocalWeather(latitude: myLatitude, longitude: myLongitude, apiKey: apiKey) { (weather) in
            if let localWeather = weather {
                self.setView(localWeather: localWeather)
                self.apiRequestLoading.isHidden = true
                self.loadingView.isHidden = true
            }
        }
    }
    
    //    Alamofire request which fetches data from remote API and saves it to LocalWeather struct.
    func getLocalWeather(latitude: String, longitude: String, apiKey: String, completion: @escaping WeatherCompletion) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric") else { return }
        
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
                    let weather = try jsonDecoder.decode(LocalWeather.self, from: data)
                    completion(weather)
                } catch {
                    debugPrint(error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }
    
    func getWindDirection(deg: Float) -> String {
        var windDirection = String()
        if(deg > 23 && deg <= 67){
            windDirection = "NE";
        } else if(deg > 68 && deg <= 112){
            windDirection = "E";
        } else if(deg > 113 && deg <= 167){
            windDirection = "SE";
        } else if(deg > 168 && deg <= 202){
            windDirection = "S";
        } else if(deg > 203 && deg <= 247){
            windDirection = "SW";
        } else if(deg > 248 && deg <= 293){
            windDirection = "W";
        } else if(deg > 294 && deg <= 337){
            windDirection = "NW";
        } else if(deg >= 338 || deg <= 22){
            windDirection = "N";
        }
        
        return windDirection
    }
    
    //    Converts country name from unicode country code
    func getCountryName(from countryCode: String) -> String {
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            // Country name was found
            return name
        } else {
            // Country name cannot be found
            return countryCode
        }
    }
    
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        let items: [Any] = ["Make your own Weather App with Open Weather Map API", URL(string: "https://openweathermap.org/api")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
}

extension String {
    //    Capitalizes the first letter of the string
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
