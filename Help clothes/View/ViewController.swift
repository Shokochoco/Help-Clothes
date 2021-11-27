import UIKit
import Alamofire
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var tempImage: UIImageView!

    var requestModel = Requests()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestModel.delegate = self
        searchTextField.delegate = self
        locationManager.delegate = self
    }
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchTextField.endEditing(true)
    }

}

extension ViewController: CLLocationManagerDelegate {
    
}

extension ViewController: UITextFieldDelegate {

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
            requestModel.fetchCityName(cityName: city)
        }
        searchTextField.text = ""
    }
}

extension ViewController: WeatherDelegate {
    func didUpdateWeather(_ requests: Requests, weather: WeatherModel) { //このdelegateを引き起こすオブジェクトをparamerterに指定する
        //各種配置につける
        DispatchQueue.main.async {
            self.cityLabel.text = weather.cityName
            self.temperatureLabel.text = weather.temperatureString
            self.tempImage.image = UIImage(systemName: weather.conditionName)
        }

    }
}

