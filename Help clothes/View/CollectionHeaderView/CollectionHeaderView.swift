//
//  CollectionHeaderView.swift
//  Help clothes
//
//  Created by 鈴木淳子 on 2021/12/15.
//

import UIKit

class CollectionHeaderView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    // 自分のidentifierを設定する
    static let identifier: String = "CollectionHeaderView"

    static func nib() -> UINib {
            return UINib(nibName: CollectionHeaderView.identifier, bundle: nil)
        }

    func sectionTitle(section: Int) -> String {

        switch section {
        case 0:
            return "Tops"
        case 1:
            return "Bottoms"
        case 2:
            return "Shoes"
        default:
            return ""
        }
    }

    
}
