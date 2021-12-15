import Foundation
import UIKit
import RealmSwift

enum MainSection: Int, CaseIterable {
    case Tops
    case Bottoms
    case Onepiece
}

class PhotoCollectionView: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    // データの差分更新（表示状態を管理）
    //    private var snapshot: NSDiffableDataSourceSnapshot<MainSection, RealmDataModel>!
    // セル要素に表示するためのデータを結びつける
    //    private var dataSource: UICollectionViewDiffableDataSource<MainSection, RealmDataModel>! = nil

    // セクション毎のレイアウト
    private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case MainSection.Tops.rawValue:
                return self?.createTopsLayout()

            case MainSection.Bottoms.rawValue:
                return self?.createTopsLayout() // 一旦BottomもTopsのメソッドで

            case MainSection.Onepiece.rawValue:
                return self?.createTopsLayout() // 一旦BottomもTopsのメソッドで
            default:
                fatalError()
            }
        }
        return layout
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        registerButton.layer.cornerRadius = 32
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = compositionalLayout
        //　コレクションセルの登録
        let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "collectionCell")
        // ヘッダーセルの登録
        collectionView?.register(CollectionHeaderView.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.identifier)
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Register", bundle: nil)
        let registerView = storyboard.instantiateViewController(withIdentifier: "register")
        registerView.modalPresentationStyle = .fullScreen
        self.present(registerView, animated: true, completion: nil)
    }
}

// MARK: - CollectionView
extension PhotoCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        6 // result.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3 // enumで設定したセクションの数と合わせる
    }
    //　セルの中身
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .lightGray
        cell.setUp()
        return cell
    }

    //　ヘッダーの中身
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {

            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionHeaderView", for: indexPath) as? CollectionHeaderView else {
                fatalError("Could not find proper header")
            }
            //　なんか変↓
            header.titleLabel.text = header.sectionTitle(section: indexPath.section)
            return header
        }

        return UICollectionReusableView()
    }
    // レイアウト
    private func createTopsLayout() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalWidth(1/2))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        group.contentInsets = .zero

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 16, trailing: 10)
        // スクロールの止まり方
        section.orthogonalScrollingBehavior = .continuous
        // ヘッダーのレイアウト
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

}


//extension PhotoCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 3
//    }
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 3
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
//        let realm = try! Realm()
//        let result = realm.objects(RealmDataModel.self)
//
//        var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        do {
//            let urls = try FileManager.default.contentsOfDirectory(at:documentDirectoryFileURL, includingPropertiesForKeys: nil)
//            let filePath = urls[16].path
//            print(filePath)
//            cell.stylePhoto.image = UIImage(contentsOfFile: filePath)
//        } catch let error {
//            print(error)
//        }
//        //URL型にキャスト
////        let fileURL = URL(string: result[indexPath.row].photoData)
//
//        //パス型に変換
////        let filePath = fileURL?.path
//
//        cell.setUp()
//        cell.backgroundColor = .lightGray
////        cell.stylePhoto.image = UIImage(contentsOfFile: filePath!)
//        return cell
//    }
//    //　セクションの中身
//        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader else {
//                fatalError("エラー")
//            }
//
//            if kind == UICollectionView.elementKindSectionHeader {
//                header.sectionLabel.text = "section \(indexPath.section)"
//                return header
//            }
//            return UICollectionReusableView()
//        }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let cellWidth:CGFloat = self.view.frame.width/2.5
//        let cellHeight:CGFloat = self.view.frame.width/2
//        return CGSize(width: cellWidth, height: cellHeight)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//            //外枠のマージン
//        return UIEdgeInsets(top: 0 , left: 10 , bottom: 0 , right: 10 )
//        }
//
//}
