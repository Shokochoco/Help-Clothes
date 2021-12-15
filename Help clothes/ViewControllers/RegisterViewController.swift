import Foundation
import UIKit
import RealmSwift

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var leftData = ["トップス", "ボトムス", "ワンピース"]
    var rightData = ["暑い日用", "暖かい日用","涼しい日用","寒い日用"]

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var photoImage: UIImageView! {
        didSet {
            self.photoImage.image = UIImage(named: "no-image")
        }
    }
    // ドキュメントディレクトリの「ファイルURL」（URL型）定義
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    // ドキュメントディレクトリの「パス」（String型）定義
    let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
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

//        saveImage()
        
        let itemLow = pickerView.selectedRow(inComponent: 0)
        let tempLow = pickerView.selectedRow(inComponent: 1)
        let pngUIImage = photoImage?.image?.pngData()

        let realm = try! Realm()
        let realmData = RealmDataModel()
        print(Realm.Configuration.defaultConfiguration.fileURL!)

        realmData.itemData = leftData[itemLow]
        realmData.tempData = rightData[tempLow]
//        realmData.photoData =  documentDirectoryFileURL.absoluteString
        realmData.photoData = pngUIImage

        do{
            try realm.write{
                realm.add(realmData)
            }
        }catch {
            print("Error \(error)")
        }

        self.dismiss(animated: true, completion: nil)
    }
    //保存するためのパスを作成する
//    func createLocalDataFile() {
//        // 作成するテキストファイルの名前
//        let fileName = "\(NSUUID().uuidString).png"
//        // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
//        let path = documentDirectoryFileURL.appendingPathComponent(fileName)
//        documentDirectoryFileURL = path
//        print("createLocalData:\(documentDirectoryFileURL)")
//    }

    //画像を保存する関数の部分
//    func saveImage() {
//        createLocalDataFile()
//        //pngで保存する場合
//        let pngImageData = photoImage.image?.pngData()
//        do {
//            try pngImageData!.write(to: documentDirectoryFileURL)
//            print("createLocalData:\(documentDirectoryFileURL)")
//        } catch {
//            print("PNGエラー")
//        }
//    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func deletePhotoTapped(_ sender: Any) {
        showAlert()
    }

    private func showAlert() {
        let alert = UIAlertController(title: "写真を削除しますか？", message: "", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            self.photoImage.image = UIImage(named: "no-image")}

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)

        present(alert, animated: true, completion: nil)
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

extension UIImage {
    //データサイズを変更する
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
