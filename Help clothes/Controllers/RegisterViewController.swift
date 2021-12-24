import Foundation
import UIKit
import RealmSwift
import PhotosUI

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    var leftData = ["トップス", "ボトムス", "シューズ"]
    var rightData = ["暑い日用", "暖かい日用","涼しい日用","寒い日用", "いつでも"]

    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        layoutSetup()
        configureView()
    }

    func layoutSetup() {
        registerButton.layer.cornerRadius = 25
        registerButton.backgroundColor = UIColor(red: 19/255, green: 15/255, blue: 64/255, alpha: 1.0)
        deleteButton.layer.borderWidth = 3
        deleteButton.layer.borderColor = UIColor(red: 19/255, green: 15/255, blue: 64/255, alpha: 1.0).cgColor
        deleteButton.tintColor = .label //UIColor(red: 19/255, green: 15/255, blue: 64/255, alpha: 1.0)
        deleteButton.layer.cornerRadius = 25
        choosePhotoButton.tintColor = .lightGray
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
        if photoImage.image != UIImage(named: "no-image") {
            showAlert(title: "写真を削除しますか？", message: "")
        }

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

        if #available(iOS 14, *) {
            // カメラロール設定
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1 // 選択数
            configuration.filter = .images
            configuration.preferredAssetRepresentationMode = .current
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            // 許可状態を確認（追加のみする場合）
            let addOnlyAuth = PHPhotoLibrary.authorizationStatus(for: .addOnly)

            switch addOnlyAuth {
            case .notDetermined:
                // アクセス許可をリクエスト
                PHPhotoLibrary.requestAuthorization(for: .addOnly) {status in
                    switch status {
                        // カメラロール表示
                    case .authorized:
                        DispatchQueue.main.async { // UIの更新
                            self.present(picker, animated: true, completion: nil)
                        }
                        // カメラへのアクセスを拒否
                    default:
                        print("denied")
                    }
                }
            case .restricted:
                print("restricted")
                let alert = UIAlertController(title: "写真にアクセスできません", message: "", preferredStyle: .alert)
                let close: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(close)
                self.present(alert, animated: true, completion: nil)
            case .denied:
                print("denied")
                let alert = UIAlertController(title: "写真にアクセスできません", message: "設定からアクセス許可をしてください", preferredStyle: .alert)
                let settings = UIAlertAction(title: "設定", style: .default, handler: { (_) -> Void in
                    let settingsURL = URL(string: UIApplication.openSettingsURLString)
                    UIApplication.shared.open(settingsURL!, options: [:], completionHandler: nil)
                })
                let close: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
                alert.addAction(settings)
                alert.addAction(close)
                self.present(alert, animated: true, completion: nil)
            case .authorized:
                print("authorized")
                DispatchQueue.main.async {  // UIの更新
                    self.present(picker, animated: true, completion: nil)
                }
            case .limited:
                print("limited")
                DispatchQueue.main.async {  // UIの更新
                    self.present(picker, animated: true, completion: nil)
                }
            @unknown default:
                print("default")
            }

        } else {
            // iOS14未満
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {

                let imagePickerView = UIImagePickerController()
                imagePickerView.sourceType = .photoLibrary
                imagePickerView.delegate = self
                self.present(imagePickerView, animated: true)
            }

        }

    }

    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 写真を選択しているかどうか確認
        if results.count != 0 {
            results[0].itemProvider.loadDataRepresentation(forTypeIdentifier: "public.image", completionHandler: { data, _ in
                DispatchQueue.main.async { [self] in // UIの更新
                    if let imageData = UIImage(data: data!) {
                        photoImage.image = imageData.resized(withPercentage: 0.5) // 画像を設定
                    }

                }
            })
        }
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let image = info[.originalImage] as! UIImage
        //　1/10で圧縮すると実機で変になるので半分
        let resizedImage = image.resized(withPercentage: 0.5)
        photoImage.image = resizedImage
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func registerButtonTapped(_ sender: Any) {

        print(Realm.Configuration.defaultConfiguration.fileURL!)
        // 新しい値
        let itemLow = pickerView.selectedRow(inComponent: 0)
        let tempLow = pickerView.selectedRow(inComponent: 1)
        let newPhotoData = photoImage?.image?.pngData()
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
                realmData.photoData = newPhotoData

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
                        result.first?.photoData = newPhotoData
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

        let alert = UIAlertController(title: "本当に削除しますか？", message: "一度削除すると戻せません", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "はい", style: .default) { [weak self] _ in
            // 削除処理
            do{
                try realm.write{
                    realm.delete(result)
                }
            }catch {
                print("削除 \(error)")
            }
            self?.dismiss(animated: true, completion: nil)
        }

        let cancelButton = UIAlertAction(title: "戻る", style: .cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)

        present(alert, animated: true, completion: nil)

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
