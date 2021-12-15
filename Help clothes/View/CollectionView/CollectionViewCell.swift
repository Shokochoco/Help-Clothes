import UIKit
import RealmSwift

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var stylePhoto: UIImageView!

    func setUp() {
        layer.cornerRadius = 12

//        func loadImageFromName(_ imgName: String) {
//            // realmから情報を持ってくる
//            let realm = try! Realm()
//            let result = realm.objects(RealmDataModel.self)
//            print(Realm.Configuration.defaultConfiguration.fileURL!)
//
//            //URL型にキャスト
//            let fileURL = URL(string: result[0].photoData)
//            //パス型に変換
//            let imagePath = fileURL!.path
//            stylePhoto.image = loadImageFromPath(imagePath)
//        }
    }

//    func loadImageFromPath(_ path: String) -> UIImage? {
//
//            let image = UIImage(contentsOfFile: path as String)
//
//            if image == nil {
//                return UIImage()
//            } else{
//                return image
//            }
//        }
}
