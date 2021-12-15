import Foundation
import RealmSwift

class RealmDataModel: Object {
    @objc dynamic var itemData: String = ""
    @objc dynamic var tempData: String = ""
    @objc dynamic var photoData: Data?
}
