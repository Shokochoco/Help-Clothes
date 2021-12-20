import UIKit
import RealmSwift

class StyleScreen2ViewController: UIViewController {

    @IBOutlet weak var topsImage: UIImageView!
    @IBOutlet weak var bottomsImage: UIImageView!
    @IBOutlet weak var shoesImage: UIImageView!
    
    var tempName: String?
    var weatherMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        select3ImageFromRealm()
    }
    
    func select3ImageFromRealm() {

        DispatchQueue.main.async { [self] in
        let realm = try! Realm()
        guard let tempName = tempName else { return }
        let predicate = NSPredicate(format: "tempData == %@", tempName)
        let result = realm.objects(RealmDataModel.self).filter(predicate)

            let section = MainSection.Tops

            switch section {
            case .Tops:
                let sectionResult = result.filter("itemData == 'トップス'")
                guard let topsResult = sectionResult.randomElement() else { return }
                self.topsImage.image = UIImage(data: topsResult.photoData!)
                topsImage.contentMode = .scaleAspectFill
                fallthrough
            case .Bottoms:
                let sectionResult = result.filter("itemData == 'ボトムス'")
                guard let bottomsResult = sectionResult.randomElement() else { return }
                self.bottomsImage.image = UIImage(data: bottomsResult.photoData!)
                bottomsImage.contentMode = .scaleAspectFill
                fallthrough
            case .Shoes:
                let sectionResult = result.filter("itemData == 'シューズ'")
                guard let shoesResult = sectionResult.randomElement() else { return }
                self.shoesImage.image = UIImage(data: shoesResult.photoData!)
                shoesImage.contentMode = .scaleAspectFill
        }
    }

}
}
