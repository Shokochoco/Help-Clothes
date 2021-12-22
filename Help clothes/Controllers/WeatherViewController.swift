import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var tempImage: UIImageView!
    @IBOutlet weak var style1Button: UIButton!
    @IBOutlet weak var style2Button: UIButton!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var weatherTempData: String? // 気温の変数
    var weatherMessage: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSetup()
        pushNotification()
        locationManager.delegate = self //　デリゲートを先にセット
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        searchTextField.delegate = self
        weatherManager.delegate = self
    }

    func layoutSetup() {
        addBackground(name: "background")
        cityLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        style1Button.backgroundColor = .clear
        style1Button.layer.borderWidth = 3
        style1Button.layer.borderColor = UIColor.white.cgColor
        style1Button.layer.cornerRadius = 30
        style1Button.setTitleColor(UIColor.white, for: UIControl.State.normal)

        style2Button.backgroundColor = .clear
        style2Button.layer.borderWidth = 3
        style2Button.layer.borderColor = UIColor.white.cgColor
        style2Button.layer.cornerRadius = 30
        style2Button.setTitleColor(UIColor.white, for: UIControl.State.normal)

    }

    func addBackground(name: String) {
            // スクリーンサイズの取得
            let width = UIScreen.main.bounds.size.width
            let height = UIScreen.main.bounds.size.height

            // スクリーンサイズにあわせてimageViewの配置
            let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            //imageViewに背景画像を表示
            imageViewBackground.image = UIImage(named: name)

            // 画像の表示モードを変更。
            imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill

            // subviewをメインビューに追加
            view.addSubview(imageViewBackground)
            // 加えたsubviewを、最背面に設置する
            view.sendSubviewToBack(imageViewBackground)
        }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
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

    // MARK: - Push Notification

    func pushNotification() {
        // contents決める
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = "今日の服装決まった🌞☂️☁️？"
        content.sound = UNNotificationSound.default
        // Trigger決める
        let date = DateComponents(hour:7, minute:30)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: date, repeats: true)
        // リクエストをセットしてaddする
        let request: UNNotificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
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

