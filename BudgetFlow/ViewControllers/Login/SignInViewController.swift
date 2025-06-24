import UIKit
import Firebase
import FirebaseAuth

// Giriş ekranını yöneten ViewController
class SignInViewController: UIViewController {
    
    // MARK: - UI Elemanları
    @IBOutlet weak var emailText: UITextField! // E-posta giriş alanı
    @IBOutlet weak var passwordText: UITextField! // Şifre giriş alanı
    @IBOutlet weak var signInButton: UIButton! // Giriş yap butonu
    @IBOutlet weak var signUpButton: UIButton! // Hesap oluştur butonu
    @IBOutlet weak var containerView: UIView! // Ana konteyner görünümü
    
    // MARK: - Logo ve Başlık için StackView oluşturma
    private let logoTitleStackView = UIStackView() // Logo ve başlık için yığın görünümü
    private let logoImageView = UIImageView() // Logo görüntüsü
    private let appNameLabel = UILabel() // Uygulama adı etiketi
    
    // MARK: - Yaşam Döngüsü Metodları
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // UI ayarlarını yap
        setupLogoAndTitle() // Logo ve başlığı ayarla
        setupKeyboardDismissal() // Klavye kapatma özelliğini ayarla
    }
    
    // MARK: - UI Kurulumu
    private func setupUI() {
        // Arka plan rengini ayarla
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        
        // Container view'ı ayarla
        containerView.layer.cornerRadius = 20
        containerView.backgroundColor = .white
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        
        // Text field'ları ayarla
        setupTextField(emailText, placeholder: "Email")
        setupTextField(passwordText, placeholder: "Password")
        
        // Butonları ayarla
        setupButton(signInButton, title: "Sign In", isPrimary: true)
        setupButton(signUpButton, title: "Create Account", isPrimary: false)
    }
    
    private func setupLogoAndTitle() {
        // StackView ayarları
        logoTitleStackView.axis = .horizontal
        logoTitleStackView.alignment = .center
        logoTitleStackView.spacing = 8 // Logo ile yazı arası boşluk
        logoTitleStackView.translatesAutoresizingMaskIntoConstraints = false

        // Logo ayarları
        logoImageView.image = UIImage(named: "AppIcon.png") // Assets'teki icon
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        // Başlık ayarları
        appNameLabel.text = "BudgetFlow"
        appNameLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        appNameLabel.textColor = UIColor(hex: "#007AFF")

        // StackView'a ekle
        logoTitleStackView.addArrangedSubview(logoImageView)
        logoTitleStackView.addArrangedSubview(appNameLabel)

        // Ana view'a ekle
        view.addSubview(logoTitleStackView)

        // StackView'ı emailText'in üstüne ortala
        NSLayoutConstraint.activate([
            logoTitleStackView.bottomAnchor.constraint(equalTo: emailText.topAnchor, constant: -45),
            logoTitleStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // Text field ayarları
    private func setupTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: "#E0E0E0").cgColor
        textField.backgroundColor = UIColor(hex: "#F8F8F8")
        
        // Sol padding ve icon için container view
        let leftContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: textField.frame.height))
        
        if textField == emailText {
            // E-posta ikonu
            let emailIcon = UIImageView(image: UIImage(systemName: "envelope.fill"))
            emailIcon.tintColor = UIColor(hex: "#007AFF")
            emailIcon.contentMode = .scaleAspectFit
            emailIcon.frame = CGRect(x: 10, y: 0, width: 20, height: textField.frame.height)
            leftContainerView.addSubview(emailIcon)
        } else {
            // Şifre ikonu
            let passwordIcon = UIImageView(image: UIImage(systemName: "lock.fill"))
            passwordIcon.tintColor = UIColor(hex: "#007AFF")
            passwordIcon.contentMode = .scaleAspectFit
            passwordIcon.frame = CGRect(x: 10, y: 0, width: 20, height: textField.frame.height)
            leftContainerView.addSubview(passwordIcon)
        }
        
        textField.leftView = leftContainerView
        textField.leftViewMode = .always
    }
    
    // Buton ayarları
    private func setupButton(_ button: UIButton, title: String, isPrimary: Bool) {
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 8
        
        if isPrimary {
            button.backgroundColor = UIColor(hex: "#007AFF")
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .white
            button.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(hex: "#007AFF").cgColor
        }
        
        // Buton gölgesi
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
    }
    
    // MARK: - Aksiyonlar
    @IBAction func signInClicked(_ sender: Any) {
        // Giriş işlemi
        if emailText.text != "" && passwordText.text != "" {
            // Yükleniyor göstergesi ekle
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.center = view.center
            activityIndicator.startAnimating()
            view.addSubview(activityIndicator)
            
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { [weak self] authdata, error in
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
                if let error = error {
                    self?.makeAlert(titleInput: "Error!", messageInput: error.localizedDescription)
                } else {
                    self?.performSegue(withIdentifier: "toHomeVC", sender: nil)
                }
            }
        } else {
            makeAlert(titleInput: "Error!", messageInput: "Please fill in email and password fields.")
        }
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        performSegue(withIdentifier: "toSignUp", sender: nil)
    }
    
    // MARK: - Yardımcı Metodlar
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    // MARK: - Klavye Kapatma Özelliği
    private func setupKeyboardDismissal() {
        // Boş alana tıklandığında klavyeyi kapatmak için tap gesture recognizer ekle
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Diğer touch event'lerin çalışmasına izin ver
        view.addGestureRecognizer(tapGesture)
    }
    
    // Klavyeyi kapatma fonksiyonu
    @objc private func dismissKeyboard() {
        view.endEditing(true) // Aktif text field'ı kapat ve klavyeyi gizle
    }
}

