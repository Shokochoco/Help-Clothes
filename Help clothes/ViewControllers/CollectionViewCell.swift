import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var stylePhoto: UIImageView!

    func setUp() {
        layer.cornerRadius = 12
    }

}
