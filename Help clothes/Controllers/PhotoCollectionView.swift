import Foundation
import UIKit
import RealmSwift

enum MainSection: Int, CaseIterable {
    case tops
    case bottoms
    case shoes
}

final class PhotoCollectionView: UIViewController {

    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var itemNumber: UILabel!
    // 受け渡し用
    var tempPickerNum: Int?
    var itemPickerNum: Int?
    var tempData: String?
    var photoData: Data?
    // セクション毎のレイアウト
    private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, _ : NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case MainSection.tops.rawValue:
                return self?.createLayout()

            case MainSection.bottoms.rawValue:
                return self?.createLayout() // レイアウト変える時はここのメソッド

            case MainSection.shoes.rawValue:
                return self?.createLayout() // レイアウト変える時はここのメソッド
            default:
                fatalError()
            }
        }
        return layout
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSetup()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = compositionalLayout
        //　コレクションセルの登録
        let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "collectionCell")
        // ヘッダーセルの登録
        collectionView?.register(CollectionHeaderView.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.identifier)

    }

    private func layoutSetup() {
        registerButton.layer.cornerRadius = 32
        registerButton.backgroundColor = UIColor(red: 19/255, green: 15/255, blue: 64/255, alpha: 1.0)
        collectionView.backgroundColor = UIColor(red: 225/255, green: 240/255, blue: 249/255, alpha: 1.0)
        view.backgroundColor = UIColor(red: 225/255, green: 240/255, blue: 249/255, alpha: 1.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
        itemNumberCount()
    }

    private func itemNumberCount() {
        let realm = try! Realm()
        let results = realm.objects(RealmDataModel.self)
        itemNumber.text = String("Item  \(results.count)")
        itemNumber.textColor = .lightGray
    }

    @IBAction private func addButtonTapped(_ sender: Any) {
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
        case MainSection.tops.rawValue:
            let filtedResult = result.filter("itemData == 'TOPS'")
            return filtedResult.count

        case MainSection.bottoms.rawValue:
            let filtedResult = result.filter("itemData == 'BOTTOMS'")
            return filtedResult.count

        case MainSection.shoes.rawValue:
            let filtedResult = result.filter("itemData == 'SHOES'")
            return filtedResult.count

        default:
            fatalError("セクションに分けられない")
        }

    }
    //　セルの中身
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
        let realm = try! Realm()
        let results = realm.objects(RealmDataModel.self)

        cell.setUp()

        switch indexPath.section {
        case MainSection.tops.rawValue:
            let tops = results.filter("itemData == 'TOPS'")
            let imageData = UIImage(data: tops[indexPath.row].photoData!)
            cell.stylePhoto.image = imageData
            cell.stylePhoto.contentMode = .scaleAspectFill

        case MainSection.bottoms.rawValue:
            let bottoms = results.filter("itemData == 'BOTTOMS'")
            let imageData = UIImage(data: bottoms[indexPath.row].photoData!)
            cell.stylePhoto.image = imageData
            cell.stylePhoto.contentMode = .scaleAspectFill

        case MainSection.shoes.rawValue:
            let shoes = results.filter("itemData == 'SHOES'")
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
            //　なんか変かも？
            header.titleLabel.text = header.sectionTitle(section: indexPath.section)
            header.titleLabel.textColor = .lightGray
            return header
        }

        return UICollectionReusableView()
    }
    // レイアウト
    private func createLayout() -> NSCollectionLayoutSection {

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

        let realm = try! Realm()
        let results = realm.objects(RealmDataModel.self)
        // データを次の画面に渡す準備1
        switch indexPath.section {
        case MainSection.tops.rawValue:
            let tops = results.filter("itemData == 'TOPS'")
            tempData = tops[indexPath.row].tempData
            itemPickerNum = 0
            photoData = tops[indexPath.row].photoData

        case MainSection.bottoms.rawValue:
            let bottoms = results.filter("itemData == 'BOTTOMS'")
            tempData = bottoms[indexPath.row].tempData
            itemPickerNum = 1
            photoData = bottoms[indexPath.row].photoData

        case MainSection.shoes.rawValue:
            let shoes = results.filter("itemData == 'SHOES'")
            tempData = shoes[indexPath.row].tempData
            itemPickerNum = 2
            photoData = shoes[indexPath.row].photoData

        default :
            print("error")
        }

        switch tempData {
        case "Hot day":
            tempPickerNum = 0
        case "Warm day":
            tempPickerNum = 1
        case "Cool day":
            tempPickerNum = 2
        case "Cold day":
            tempPickerNum = 3
        case "Always":
            tempPickerNum = 4
        default:
            print("filterできない")
        }

        performSegue(withIdentifier: "segue", sender: nil)

    }
    // セルの中の情報を渡す準備2
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let destinationViewController = segue.destination as? RegisterViewController else { return }
        // タップして遷移する場合（このif書かなくていい？）
//        if let indexPath = collectionView.indexPathsForSelectedItems, segue.identifier == "segue" {
            destinationViewController.itemPickerNum = itemPickerNum
            destinationViewController.tempPickerNum = tempPickerNum
            destinationViewController.photoData = photoData
            destinationViewController.modalPresentationStyle = .fullScreen
//        }
    }

}
