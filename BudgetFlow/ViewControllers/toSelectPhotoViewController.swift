//
//  toSelectPhotoVC.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 6.02.2025.
//

import UIKit

class toSelectPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.isEnabled = false
        
        // Adding touch to imageView to insert an image
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    
    //Foto seçmek için resmin üstüne tıklayınca çağırılır;
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary //Kitaplıktaki albümden foto seçilecek
        picker.allowsEditing = false //Seçtikten sonra düzenleme yapılabilecek
        present(picker, animated: true, completion: nil)
    }
    
    
    //Kullanıcı bir resim seçip işlemi tamamladığında çağırılır.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveThePhotoClicked(_ sender: Any) {
    }
}
