
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

// Kayıt (Hesap Oluşturma) ekranını yöneten ViewController
class SignUpViewController: UIViewController {

    // MARK: - UI Elemanları
    private let scrollView = UIScrollView() // Kaydırılabilir ana görünüm
    private let containerView = UIView() // İçerik için ana konteyner
    private let emailTextField = UITextField() // E-posta giriş alanı
    private let passwordTextField = UITextField() // Şifre giriş alanı
    private let confirmPasswordTextField = UITextField() // Şifre tekrar giriş alanı
    private let nameTextField = UITextField() // İsim giriş alanı
    private let surnameTextField = UITextField() // Soyisim giriş alanı
    private let birthdayTextField = UITextField() // Doğum günü giriş alanı
    private let signUpButton = UIButton(type: .system) // Kayıt ol butonu
    private let datePicker = UIDatePicker() // Doğum günü için tarih seçici
    
    private let db = Firestore.firestore() // Firestore veritabanı referansı
    
    // MARK: - Yaşam Döngüsü Metodları
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // UI elemanlarını kur
        setupDatePicker() // Tarih seçiciyi ayarla
    }
    
    // MARK: - UI Kurulumu
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        title = "Create Account"
        
        // Başlık etiketi ekle
        let titleLabel = UILabel()
        titleLabel.text = "Create Account"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textColor = UIColor(hex: "#007AFF")
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // ScrollView ayarları
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // ContainerView ayarları
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        scrollView.addSubview(containerView)
        
        // TextField'ları ayarla
        setupTextField(nameTextField, placeholder: "Name", icon: "person.fill")
        setupTextField(surnameTextField, placeholder: "Surname", icon: "person.fill")
        setupTextField(emailTextField, placeholder: "Email", icon: "envelope.fill")
        setupTextField(passwordTextField, placeholder: "Password", icon: "lock.fill", isSecure: true)
        setupTextField(confirmPasswordTextField, placeholder: "Confirm Password", icon: "lock.fill", isSecure: true)
        setupTextField(birthdayTextField, placeholder: "Birthday", icon: "calendar")
        
        // Kayıt ol butonunu ayarla
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        signUpButton.backgroundColor = UIColor(hex: "#007AFF")
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 8
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        containerView.addSubview(signUpButton)
        
        // Otomatik yerleşim kısıtlamaları
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            surnameTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 12),
            surnameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            surnameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            surnameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            emailTextField.topAnchor.constraint(equalTo: surnameTextField.bottomAnchor, constant: 12),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            birthdayTextField.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 12),
            birthdayTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            birthdayTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            birthdayTextField.heightAnchor.constraint(equalToConstant: 40),
            
            signUpButton.topAnchor.constraint(equalTo: birthdayTextField.bottomAnchor, constant: 24),
            signUpButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            signUpButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            signUpButton.heightAnchor.constraint(equalToConstant: 40),
            signUpButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String, icon: String, isSecure: Bool = false) {
        textField.placeholder = placeholder // Placeholder metni ayarla
        textField.isSecureTextEntry = isSecure // Şifre alanı ise gizli göster
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: "#E0E0E0").cgColor
        textField.backgroundColor = UIColor(hex: "#F8F8F8")
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Sol tarafta ikon gösterimi
        let leftContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor(hex: "#007AFF")
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        leftContainerView.addSubview(iconView)
        
        textField.leftView = leftContainerView
        textField.leftViewMode = .always
        containerView.addSubview(textField)
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date // Sadece tarih seçimi
        datePicker.preferredDatePickerStyle = .wheels // Tekerlek stili
        datePicker.maximumDate = Date() // Bugünden ileri tarih seçilemez
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        birthdayTextField.inputView = datePicker // Doğum günü alanına tarih seçici ekle
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)
        birthdayTextField.inputAccessoryView = toolbar // Tarih seçiciye tamam butonu ekle
    }
    
    // MARK: - Aksiyonlar
    @objc private func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy" // Tarih formatı
        birthdayTextField.text = formatter.string(from: datePicker.date) // Seçilen tarihi göster
    }
    
    @objc private func doneButtonTapped() {
        birthdayTextField.resignFirstResponder() // Tarih seçiciyi kapat
    }
    
    @objc private func signUpTapped() {
        // Tüm alanların dolu olup olmadığını kontrol et
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              let name = nameTextField.text,
              let surname = surnameTextField.text,
              let birthday = birthdayTextField.text else {
            makeAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        // Şifrelerin eşleşip eşleşmediğini kontrol et
        guard password == confirmPassword else {
            makeAlert(title: "Error", message: "Passwords do not match")
            return
        }
        
        // Yükleniyor göstergesi ekle
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // Firebase Auth ile kullanıcı oluştur
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self?.makeAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            guard let userID = authResult?.user.uid else { return }
            
            // Firestore'da kullanıcı bilgisi oluştur
            let infoRef = self?.db.collection("users").document(userID).collection("info").document()
            let infoID = infoRef?.documentID ?? UUID().uuidString
            
            let userInfo: [String: Any] = [
                "infoID": infoID,
                "userID": userID,
                "name": name,
                "surname": surname,
                "email": email,
                "birthday": birthday,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            infoRef?.setData(userInfo) { error in
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
                if let error = error {
                    self?.makeAlert(title: "Error", message: error.localizedDescription)
                } else {
                    self?.performSegue(withIdentifier: "toHomeFromSignUp", sender: nil)
                }
            }
        }
    }
    
    // MARK: - Yardımcı Metodlar
    private func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}
