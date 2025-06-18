import UIKit

class toSelectPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Fotoğraf görüntüleme alanı
    @IBOutlet weak var imageView: UIImageView!
    
    // Kaydet butonu
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.isEnabled = false // Başlangıçta kaydet butonu pasif
        
        // Fotoğraf eklemek için imageView'a dokunma özelliği ekle
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    
    // Foto seçmek için resmin üstüne tıklayınca çağırılır
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary // Kitaplıktaki albümden foto seçilecek
        picker.allowsEditing = false // Seçtikten sonra düzenleme yapılabilecek
        present(picker, animated: true, completion: nil)
    }
    
    
    // Kullanıcı bir resim seçip işlemi tamamladığında çağırılır
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // Kaydet butonuna tıklanınca çağırılır
    @IBAction func saveThePhotoClicked(_ sender: Any) {
    }
}
