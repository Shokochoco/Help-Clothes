import UIKit
import RealmSwift

final class StyleScreen1ViewController: UIViewController {

    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var imagePhoto: UIImageView! {
        didSet {
            self.imagePhoto.image = UIImage(named: "cant-find")
        }
    }

    var weatherTempData: String?
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

        DispatchQueue.main.async { [self] in
        let realm = try! Realm()
        guard let weatherTempData = weatherTempData else { return }
        let predicate = NSPredicate(format: "tempData == %@", weatherTempData)
        let result = realm.objects(RealmDataModel.self).filter(predicate)
        if let randomResult = result.randomElement() {
            self.imagePhoto.image = UIImage(data: randomResult.photoData!)
            imagePhoto.contentMode = .scaleAspectFill
        }
        }
    }
}
