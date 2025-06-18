//
//  ChangePasswordViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 15.06.2025.
//

import UIKit
import Firebase
import FirebaseAuth

// Şifre değiştirme ekranını yöneten ViewController
class ChangePasswordViewController: UIViewController {

    // MARK: - UI Elemanları
    private let scrollView = UIScrollView() // Kaydırılabilir ana görünüm
    private let containerView = UIView() // İçerik için ana konteyner
    private let stackView = UIStackView() // Dikey yığın görünümü
    private let currentPasswordTextField = UITextField() // Mevcut şifre alanı
    private let newPasswordTextField = UITextField() // Yeni şifre alanı
    private let confirmPasswordTextField = UITextField() // Yeni şifre tekrar alanı
    private let saveButton = UIButton(type: .system) // Kaydet butonu
    
    // MARK: - Yaşam Döngüsü Metodları
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // UI kurulumunu yap
    }
    
    // MARK: - UI Kurulumu
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        title = "Change Password"
        
        // ScrollView & Container
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        scrollView.addSubview(containerView)
        
        // StackView
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        // Alanları stack'e ekle
        let currentField = createLabeledField(label: "Current Password", textField: currentPasswordTextField, icon: "lock.fill", isSecure: true)
        let newField = createLabeledField(label: "New Password", textField: newPasswordTextField, icon: "lock.fill", isSecure: true)
        let confirmField = createLabeledField(label: "Confirm New Password", textField: confirmPasswordTextField, icon: "lock.fill", isSecure: true)
        stackView.addArrangedSubview(currentField)
        stackView.addArrangedSubview(newField)
        stackView.addArrangedSubview(confirmField)
        
        // Kaydet butonu
        saveButton.setTitle("Update Password", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        saveButton.backgroundColor = UIColor(hex: "#007AFF")
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(saveButton)
        
        // Otomatik yerleşim kısıtlamaları
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    // Etiketli ve ikonlu textfield oluşturan yardımcı fonksiyon
    private func createLabeledField(label: String, textField: UITextField, icon: String, isSecure: Bool = false) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 6
        
        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        labelView.textColor = .darkGray
        
        textField.placeholder = label
        textField.isSecureTextEntry = isSecure
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: "#E0E0E0").cgColor
        textField.backgroundColor = UIColor(hex: "#F8F8F8")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        textField.borderStyle = .none
        
        // Sol tarafta ikon gösterimi
        let leftContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor(hex: "#007AFF")
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        leftContainerView.addSubview(iconView)
        textField.leftView = leftContainerView
        textField.leftViewMode = .always
        
        container.addArrangedSubview(labelView)
        container.addArrangedSubview(textField)
        return container
    }
    
    // MARK: - Aksiyonlar
    @objc private func saveButtonTapped() {
        guard let currentPassword = currentPasswordTextField.text,
              let newPassword = newPasswordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            makeAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        // Şifreleri doğrula
        guard newPassword == confirmPassword else {
            makeAlert(title: "Error", message: "New passwords do not match")
            return
        }
        
        guard newPassword.count >= 6 else {
            makeAlert(title: "Error", message: "New password must be at least 6 characters")
            return
        }
        
        // Yükleniyor göstergesi ekle
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // Kullanıcıyı tekrar doğrula (reauthenticate)
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            makeAlert(title: "Error", message: "User not found")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        user.reauthenticate(with: credential) { [weak self] _, error in
            if let error = error {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self?.makeAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            // Şifreyi güncelle
            user.updatePassword(to: newPassword) { error in
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
                if let error = error {
                    self?.makeAlert(title: "Error", message: error.localizedDescription)
                } else {
                    self?.makeAlert(title: "Success", message: "Password updated successfully")
                    self?.navigationController?.popViewController(animated: true)
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
