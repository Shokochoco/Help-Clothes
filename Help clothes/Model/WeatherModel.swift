import Foundation

struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperature: Double

    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }

    var weatherTemp: String {
        switch temperature {
        case -10.0 ..< 13.0:
            return "寒い日用"
        case 13.0 ..< 20.0:
            return "涼しい日用"
        case 20.0 ..< 25.0:
            return "暖かい日用"
        case 25.0...40.0:
            return "暑い日用"
        default:
            return "いつでも"
        }
    }

    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...502:
            return "cloud.rain"
        case 503...511:
            return "cloud.heavyrain"
        case 520...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud"
        default:
            return "cloud"
        }
    }

    var conditionMessage: String {
        switch conditionId {
        case 200...232:
            return "雨が降るかも☂️傘を忘れずに！"
        case 500...531:
            return "雨に気をつけて☂️傘を忘れずに！"
        case 600...622:
            return "雪が降るかも❄️あったかい格好で出かけよう"
        case 701...781:
            return "霧が多いかも☁️気をつけて〜"
        case 800:
            return "晴れだね🌞良い１日を！"
        case 801...804:
            return "曇りが多いかも☁️良い１日を！"
        default:
            return "曇りが多いかも☁️良い１日を！"
        }
    }
}
