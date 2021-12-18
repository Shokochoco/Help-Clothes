import Foundation
import UIKit
import RealmSwift

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var leftData = ["トップス", "ボトムス", "シューズ"]
    var rightData = ["暑い日用", "暖かい日用","涼しい日用","寒い日用", "いつでも"]

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var photoImage: UIImageView! {
        didSet {
            self.photoImage.image = UIImage(named: "no-image")
        }
    }
    var itemPickerNum: Int?
    var tempPickerNum: Int?
    var photoData: Data?
    // ドキュメントディレクトリの「ファイルURL」（URL型）定義
    //    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    // ドキュメントディレクトリの「パス」（String型）定義
    //    let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        configureView()
    }

    func configureView() {
        // セルがタップされてきた場合、その情報をセット
        if let itemPickerNum = itemPickerNum,
           let tempPickerNum = tempPickerNum,
           let photoData = photoData {
            pickerView.selectRow(itemPickerNum, inComponent: 0, animated: false)
            pickerView.selectRow(tempPickerNum, inComponent: 1, animated: false)
            self.photoImage.image = UIImage(data: photoData)
        } else {
            deleteButton.isHidden = true
        }
    }

    @IBAction func deletePhotoTapped(_ sender: Any) {
        showAlert(title: "写真を削除しますか？", message: "")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            self.photoImage.image = UIImage(named: "no-image")}

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)

        present(alert, animated: true, completion: nil)
    }

    @IBAction func selectPhotoTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {

            let imagePickerView = UIImagePickerController()
            imagePickerView.sourceType = .photoLibrary
            imagePickerView.delegate = self
            self.present(imagePickerView, animated: true)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        let resizedImage = image.resized(withPercentage: 0.1)
        photoImage.image = resizedImage
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func registerButtonTapped(_ sender: Any) {

        print(Realm.Configuration.defaultConfiguration.fileURL!)
        // 新しい値
        let itemLow = pickerView.selectedRow(inComponent: 0)
        let tempLow = pickerView.selectedRow(inComponent: 1)
        let pngUIImage = photoImage?.image?.pngData()
        // 画像のnilチェック
        if photoImage.image == UIImage(named: "no-image") {
            alert(title: "画像を選択してください", message: "")
        } else {
            // 新規登録 realm用オブジェクト作る
            if itemPickerNum == nil,
               tempPickerNum == nil,
               photoData == nil {

                let realmData = RealmDataModel()

                realmData.itemData = leftData[itemLow]
                realmData.tempData = rightData[tempLow]
                realmData.photoData = pngUIImage

                let realm = try! Realm()

                do{
                    try realm.write{
                        //　新規
                        realm.add(realmData)
                    }
                }catch {
                    print("新規登録 \(error)")

                }
            } else {
                let realm = try! Realm()

                do{
                    try realm.write{
                        //　更新はこの中で
                        let predicate = NSPredicate(format: "itemData == %@ && tempData == %@ && photoData == %@", leftData[itemPickerNum!], rightData[tempPickerNum!], photoData! as CVarArg)
                        let result = realm.objects(RealmDataModel.self).filter(predicate)

                        result.first?.itemData = leftData[itemLow]
                        result.first?.tempData = rightData[tempLow]
                        result.first?.photoData = pngUIImage
                    }
                }catch {
                    print("更新\(error)")

                }

            }
            self.dismiss(animated: true, completion: nil)
        }

    }

    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func deleteItemButtonTapped(_ sender: Any) {
        let realm = try! Realm()

        let predicate = NSPredicate(format: "itemData == %@ && tempData == %@ && photoData == %@", leftData[itemPickerNum!], rightData[tempPickerNum!], photoData! as CVarArg)
        let result = realm.objects(RealmDataModel.self).filter(predicate)

        do{
          try realm.write{
              realm.delete(result)
          }
        }catch {
          print("削除 \(error)")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return leftData.count
        case 1:
            return rightData.count
        default:
            return 0
        }
    }
    // 表示する配列
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return leftData[row]
        case 1:
            return rightData[row]
        default:
            return "error"
        }
    }
    //　PickerViewの値取得
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            leftData[row]
        case 1:
            rightData[row]
        default:
            "error"
        }
    }

}
// MARK: - Compress UIImage
extension UIImage {
    //データサイズを変更する
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
