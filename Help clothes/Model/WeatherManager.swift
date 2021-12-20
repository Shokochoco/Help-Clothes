import Foundation
import UIKit
import Alamofire
import CoreLocation

protocol WeatherDelegate: AnyObject {
   func didUpdateWeather(_ requests: WeatherManager,weather: WeatherModel)
   func didFailWithError(error: Error)
}

struct WeatherManager {

    weak var delegate: WeatherDelegate?

    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=5a252d37454b5103f6a38dd6e7d7ee37&units=metric&lang=ja"

    func fetchCityName(cityName: String) {
        let cityURL = "\(weatherURL)&q=\(cityName)"
        performRequest(with: cityURL)
    }
    
    func fetchLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let cityURL = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: cityURL)
    }

    func performRequest(with weatherURL: String)  {

        let request = AF.request(weatherURL)
        request.responseJSON { response in
            guard let data = response.data else { return }
            if let safeData = self.changeForm(data) {
                //safeDataをViewに渡して各種配置につける
                self.delegate?.didUpdateWeather(self, weather: safeData)
            }
        }
    }

    func changeForm(_ weatherData: Data) -> WeatherModel? {
        do {
            //　デコードして揃える
            let decoder = JSONDecoder()
            let tenki = try decoder.decode(WeatherData.self, from: weatherData)
            //　view側で拾いやすいように、Model型に整える
            let id = tenki.weather[0].id
            let temp = tenki.main.temp
            let city = tenki.name

            let weather = WeatherModel(conditionId: id, cityName: city, temperature: temp)
            return weather

        } catch {
            print("変換に失敗\(error)")
            return nil
        }
    }


}
