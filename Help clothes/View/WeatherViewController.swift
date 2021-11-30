import UIKit
import Alamofire
import CoreLocation

class WeatherViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var tempImage: UIImageView!

    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        weatherManager.delegate = self
        searchTextField.delegate = self
        locationManager.delegate = self //　デリゲートを先にセット
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchTextField.endEditing(true)
    }
    @IBAction func locationButtonTapped(_ sender: Any) {
        locationManager.requestLocation()
    }

}
// MARK: - CLLocationManager
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchLocation(latitude: lat, longitude: lon)
        }

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
}
// MARK: - TextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "都市名を入力"
            return false
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            weatherManager.fetchCityName(cityName: city)
        }
        searchTextField.text = ""
    }
}
// MARK: - WeatherDelegate
extension WeatherViewController: WeatherDelegate {
    func didUpdateWeather(_ requests: WeatherManager, weather: WeatherModel) { //このdelegateを引き起こすオブジェクトをparamerterに指定する
        //各種配置につける
        DispatchQueue.main.async {
            self.cityLabel.text = weather.cityName
            self.temperatureLabel.text = weather.temperatureString
            self.tempImage.image = UIImage(systemName: weather.conditionName)
        }

    }
}

