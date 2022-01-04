import UIKit
import RealmSwift

final class StyleScreen2ViewController: UIViewController {

    @IBOutlet private weak var topsImage: UIImageView! {
    didSet {
        self.topsImage.image = UIImage(named: "cant-find")
    }
    }
    @IBOutlet private weak var bottomsImage: UIImageView! {
        didSet {
            self.bottomsImage.image = UIImage(named: "cant-find")
        }
    }
    @IBOutlet private weak var shoesImage: UIImageView! {
        didSet {
            self.shoesImage.image = UIImage(named: "cant-find")
        }
    }

    var weatherTempData: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        select3ImageFromRealm()
        view.backgroundColor = UIColor(red: 225/255, green: 240/255, blue: 249/255, alpha: 1.0)
    }

    func select3ImageFromRealm() {

        DispatchQueue.main.async { [self] in
        let realm = try! Realm()
        guard let weatherTempData = weatherTempData else { return }
        let predicate = NSPredicate(format: "tempData == %@", weatherTempData)
        let result = realm.objects(RealmDataModel.self).filter(predicate)

            let section = MainSection.tops

            switch section {
            case .tops:
                let sectionResult = result.filter("itemData == 'TOPS'")
                if let topsResult = sectionResult.randomElement() {
                    self.topsImage.image = UIImage(data: topsResult.photoData!)
                    topsImage.contentMode = .scaleAspectFill
                } else {
                    topsImage.image = UIImage(named: "cant-find")
                }
                fallthrough
            case .bottoms:
                let sectionResult = result.filter("itemData == 'BOTTOMS'")
                if let bottomsResult = sectionResult.randomElement() {
                    self.bottomsImage.image = UIImage(data: bottomsResult.photoData!)
                    bottomsImage.contentMode = .scaleAspectFill
                } else {
                    bottomsImage.image = UIImage(named: "cant-find")
                }

                fallthrough
            case .shoes:
                let sectionResult = result.filter("itemData == 'SHOES'")
                if let shoesResult = sectionResult.randomElement() {
                    self.shoesImage.image = UIImage(data: shoesResult.photoData!)
                    shoesImage.contentMode = .scaleAspectFill
                } else {
                    shoesImage.image = UIImage(named: "cant-find")
                }

        }
    }

}
}
