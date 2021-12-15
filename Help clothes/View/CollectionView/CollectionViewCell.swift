import UIKit
import RealmSwift

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var stylePhoto: UIImageView!

    func setUp() {
        layer.cornerRadius = 12
        // realmから情報を持ってくる
        let realm = try! Realm()
        let result = realm.objects(RealmDataModel.self)

//        let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            //URL型にキャスト
            let fileURL = URL(string: result[0].photoData)
            //パス型に変換
            let filePath = fileURL?.path
            stylePhoto.image = UIImage(contentsOfFile: filePath!)

    }
}
