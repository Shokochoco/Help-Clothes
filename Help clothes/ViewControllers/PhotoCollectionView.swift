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
        let realm = try! Realm()
        let result = realm.objects(RealmDataModel.self)
        return result.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3 // enumで設定したセクションの数と合わせる
    }
    //　セルの中身
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
        let realm = try! Realm()
        let result = realm.objects(RealmDataModel.self)

        cell.setUp()

        if let ImageData = UIImage(data: result[indexPath.row].photoData!) {

            cell.stylePhoto.image = ImageData
            cell.backgroundColor = .lightGray
        } else {
            cell.backgroundColor = .lightGray
        }

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
