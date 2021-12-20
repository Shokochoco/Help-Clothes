import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var tempImage: UIImageView!

    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var weatherTempData: String? // 気温の変数
    var weatherMessage: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self //　デリゲートを先にセット
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        searchTextField.delegate = self
        weatherManager.delegate = self
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchTextField.endEditing(true)
    }

    @IBAction func locationButtonTapped(_ sender: Any) {
        locationManager.requestLocation()
    }

    @IBAction func styleButton1Tapped(_ sender: Any) {
        // 天気データ取得できてるか確認する
        if let weatherTempData = weatherTempData {
            let storyboard = UIStoryboard(name: "StyleScreen1", bundle: nil)
            guard let screen1 = storyboard.instantiateViewController(withIdentifier: "StyleScreen1") as? StyleScreen1ViewController else { return }
            screen1.weatherData = weatherTempData // 変数名は統一して良いか？
            screen1.weatherMessage = weatherMessage
            self.present(screen1, animated: true, completion: nil)
        } else {
            alertAction(title: "天気データを先に取得してください", message: "")
        }

    }

    @IBAction func styleButton2Tapped(_ sender: Any) {

        if let weatherTempData = weatherTempData {
            let storyboard = UIStoryboard(name: "StyleScreen2", bundle: nil)
            guard let screen2 = storyboard.instantiateViewController(withIdentifier: "StyleScreen2") as? StyleScreen2ViewController else { return }
            screen2.tempName = weatherTempData // 変数は統一して良いか？
            self.present(screen2, animated: true, completion: nil)
        } else {
            alertAction(title: "天気データを先に取得してください", message: "")
        }
    }

    func alertAction(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }

}
// MARK: - CLLocationManager
extension WeatherViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchLocation(latitude: lat, longitude: lon)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました")
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
    func didUpdateWeather(_ requests: WeatherManager, weather: WeatherModel) {
        
        weatherTempData = weather.weatherTemp
        weatherMessage = weather.conditionMessage

        DispatchQueue.main.async {
            self.cityLabel.text = weather.cityName
            self.temperatureLabel.text = weather.temperatureString
            self.tempImage.image = UIImage(systemName: weather.conditionName)
        }
    }

    func didFailWithError(error: Error) {
        print(error)
    }
}

