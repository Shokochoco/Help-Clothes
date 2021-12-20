import UIKit
import RealmSwift

class StyleScreen2ViewController: UIViewController {

    var weatherData: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        select3ImageFromRealm()
    }
    
    func select3ImageFromRealm() {

        DispatchQueue.main.async { [self] in
        let realm = try! Realm()
        let predicate = NSPredicate(format: "tempData == %@", weatherData!)
        let result = realm.objects(RealmDataModel.self).filter(predicate)
        print(result)
        //  取得した写真データから3アイテムごとに分けて、ランダムでimagePhotoに入れる

        if let randomResult = result.randomElement() {
//            self.imagePhoto.image = UIImage(data: randomResult.photoData!)
        }
        }
    }

}
