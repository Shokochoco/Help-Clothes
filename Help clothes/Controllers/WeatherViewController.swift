import UIKit
import CoreLocation

final class WeatherViewController: UIViewController {
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var tempImage: UIImageView!
    @IBOutlet private weak var style1Button: UIButton!
    @IBOutlet private weak var style2Button: UIButton!

    private var weatherManager = WeatherManager()
    private let locationManager = CLLocationManager()
    var weatherTempData: String? // 気温の変数
    var weatherMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSetup()
        pushNotification()
        locationManager.delegate = self //　デリゲートを先にセット
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        searchTextField?.delegate = self
        weatherManager.delegate = self
    }

    private func layoutSetup() {
        addBackground(name: "background")
        cityLabel?.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        style1Button?.backgroundColor = .clear
        style1Button?.layer.borderWidth = 3
        style1Button?.layer.borderColor = UIColor.white.cgColor
        style1Button?.layer.cornerRadius = 30
        style1Button?.setTitleColor(UIColor.white, for: UIControl.State.normal)

        style2Button?.backgroundColor = .clear
        style2Button?.layer.borderWidth = 3
        style2Button?.layer.borderColor = UIColor.white.cgColor
        style2Button?.layer.cornerRadius = 30
        style2Button?.setTitleColor(UIColor.white, for: UIControl.State.normal)

    }

    private func addBackground(name: String) {

            let width = UIScreen.main.bounds.size.width
            let height = UIScreen.main.bounds.size.height

            let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            imageViewBackground.image = UIImage(named: name)
            imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
            view.addSubview(imageViewBackground)
            view.sendSubviewToBack(imageViewBackground)
        }
    // MARK: - Button Tapped
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
        }

    @IBAction private func searchButtonTapped(_ sender: Any) {
        searchTextField.endEditing(true)
    }

    @IBAction private func locationButtonTapped(_ sender: Any) {
        locationManager.requestLocation()
    }

    @IBAction private func styleButton1Tapped(_ sender: Any) {

        if let weatherTempData = weatherTempData {
            let storyboard = UIStoryboard(name: "StyleScreen1", bundle: nil)
            guard let screen1 = storyboard.instantiateViewController(withIdentifier: "StyleScreen1") as? StyleScreen1ViewController else { return }
            screen1.weatherTempData = weatherTempData
            screen1.weatherMessage = weatherMessage
            self.present(screen1, animated: true, completion: nil)
        } else {
            UIAlertController.alertShow(vcon: self, title: "Get weather data firstly", message: "" )
        }

    }

    @IBAction private func styleButton2Tapped(_ sender: Any) {

        if let weatherTempData = weatherTempData {
            let storyboard = UIStoryboard(name: "StyleScreen2", bundle: nil)
            guard let screen2 = storyboard.instantiateViewController(withIdentifier: "StyleScreen2") as? StyleScreen2ViewController else { return }
            screen2.weatherTempData = weatherTempData
            self.present(screen2, animated: true, completion: nil)
        } else {
            UIAlertController.alertShow(vcon: self, title: "Get weather data firstly", message: "" )
        }
    }

    // MARK: - Push Notification

    private func pushNotification() {
        // contents決める
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = "Did you choose to wear for today?"
        content.body = "今日の服装決まった🌞☂️☁️？"
        content.sound = UNNotificationSound.default
        // Trigger決める
        let date = DateComponents(hour: 7, minute: 30)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: date, repeats: false)
        // リクエストをセットしてaddする
        let request: UNNotificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

}
// MARK: - CLLocationManager
extension WeatherViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 位置情報許可
            switch status {
            case .authorizedAlways:
                manager.requestLocation()
            case .authorizedWhenInUse:
                manager.requestAlwaysAuthorization()
            case .notDetermined:
                break
            case .restricted:
                break
            case .denied:
                break
            default:
                break
            }
        }

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
            textField.placeholder = "In English without any space"
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
            self.temperatureLabel.text = "\(weather.temperatureString)℃"
            self.tempImage.image = UIImage(systemName: weather.conditionName)
        }
    }

    func didFailWithError(error: Error) {

        print(error)
    }
}
// MARK: - UIAlertController
extension UIAlertController {

    static func alertShow(vcon: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        vcon.present(alert, animated: true, completion: nil)
    }
}
