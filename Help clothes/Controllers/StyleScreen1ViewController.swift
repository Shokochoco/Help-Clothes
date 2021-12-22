import UIKit
import RealmSwift

class StyleScreen1ViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var imagePhoto: UIImageView! {
        didSet {
            self.imagePhoto.image = UIImage(named: "cant-find")
        }
    }

    var weatherData: String?
    var weatherMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        selectImageFromRealm()
        selectMessage()
        view.backgroundColor = UIColor(red: 225/255, green: 240/255, blue: 249/255, alpha: 1.0)
    }

    func selectMessage() {
        messageLabel.text = weatherMessage
    }

    func selectImageFromRealm() {
        // メインスレッドで行う？
        //　平均気温に応じて、realmからfilter
        DispatchQueue.main.async { [self] in
        let realm = try! Realm()
        let predicate = NSPredicate(format: "tempData == %@", weatherData!)
        let result = realm.objects(RealmDataModel.self).filter(predicate)
        //  気温で取得したデータからランダムでimagePhotoに入れる
        if let randomResult = result.randomElement() {
            self.imagePhoto.image = UIImage(data: randomResult.photoData!)
            imagePhoto.contentMode = .scaleAspectFill
        }
        }
    }
}
