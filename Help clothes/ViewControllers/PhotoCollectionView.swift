import Foundation
import UIKit
import RealmSwift

class PhotoCollectionView: UIViewController  {


    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!


    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        registerButton.layer.cornerRadius = 32
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0 // 水平方向セル間マージン
        flowLayout.minimumLineSpacing = 30
        collectionView.collectionViewLayout = flowLayout

        let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "collectionCell")

    }

    @IBAction func addButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Register", bundle: nil)
        let registerView = storyboard.instantiateViewController(withIdentifier: "register")
        registerView.modalPresentationStyle = .fullScreen
        self.present(registerView, animated: true, completion: nil)
    }

}

extension PhotoCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let realm = try! Realm()
        let result = realm.objects(RealmDataModel.self)

        return 6
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
        let realm = try! Realm()
        let result = realm.objects(RealmDataModel.self)

        //URL型にキャスト
        let fileURL = URL(string: result[indexPath.row].photoData)

        //パス型に変換
        let filePath = fileURL?.path

        print(filePath)

        cell.setUp()
        cell.backgroundColor = .lightGray
        cell.stylePhoto.image = UIImage(contentsOfFile: filePath!)
        return cell
    }

    //　セクションの中身
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader else {
                fatalError("エラー")
            }

            if kind == UICollectionView.elementKindSectionHeader {
                header.sectionLabel.text = "section \(indexPath.section)"
                return header
            }
            return UICollectionReusableView()
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth:CGFloat = self.view.frame.width/2.5
        let cellHeight:CGFloat = self.view.frame.width/2
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            //外枠のマージン
        return UIEdgeInsets(top: 0 , left: 10 , bottom: 0 , right: 10 )
        }

}
