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

    override func viewDidLoad() {
        super.viewDidLoad()
        selectImageFromRealm()
    }

    func selectImageFromRealm() {
        // メインスレッドで行う？
        //　平均気温に応じて、realmからfilter
        DispatchQueue.main.async { [self] in
        let realm = try! Realm()
        let predicate = NSPredicate(format: "tempData == %@", weatherData!)
        let result = realm.objects(RealmDataModel.self).filter(predicate)
        //  取得した写真データをランダムでimagePhotoに入れる
        if let randomResult = result.randomElement() {
            self.imagePhoto.image = UIImage(data: randomResult.photoData!)
        }
        }
    }
}
