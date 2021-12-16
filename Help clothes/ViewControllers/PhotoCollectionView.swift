import Foundation
import UIKit
import RealmSwift

enum MainSection: Int, CaseIterable {
    case Tops
    case Bottoms
    case Shoes
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

            case MainSection.Shoes.rawValue:
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

    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
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

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3 // 注意：enumで設定したセクションの数と合わせる
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let realm = try! Realm()
        let result = realm.objects(RealmDataModel.self)

        switch section {
        case MainSection.Tops.rawValue:
            let filtedResult = result.filter("itemData == 'トップス'")
            return filtedResult.count

        case MainSection.Bottoms.rawValue:
            let filtedResult = result.filter("itemData == 'ボトムス'")
            return filtedResult.count

        case MainSection.Shoes.rawValue:
            let filtedResult = result.filter("itemData == 'シューズ'")
            return filtedResult.count

        default:
            fatalError("セクションに分けられない")
        }

    }
    //　セルの中身
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
        let realm = try! Realm()
        let result = realm.objects(RealmDataModel.self)

        cell.setUp()

        switch (indexPath.section) {
        case MainSection.Tops.rawValue:
            let tops = result.filter("itemData == 'トップス'")
            let imageData = UIImage(data: tops[indexPath.row].photoData!)
            cell.stylePhoto.image = imageData
            cell.stylePhoto.contentMode = .scaleAspectFill

        case MainSection.Bottoms.rawValue:
            let bottoms = result.filter("itemData == 'ボトムス'")
            let imageData = UIImage(data: bottoms[indexPath.row].photoData!)
            cell.stylePhoto.image = imageData
            cell.stylePhoto.contentMode = .scaleAspectFill

        case MainSection.Shoes.rawValue:
            let shoes = result.filter("itemData == 'シューズ'")
            let imageData = UIImage(data: shoes[indexPath.row].photoData!)
            cell.stylePhoto.image = imageData
            cell.stylePhoto.contentMode = .scaleAspectFill

        default:
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
            //　なんか変？
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        <#code#>
    }

}
