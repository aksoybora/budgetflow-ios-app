//
//  EditProfileViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 15.06.2025.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class EditProfileViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Profile"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editInfoCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let editInfoHeader: UILabel = {
        let label = UILabel()
        label.text = "Personal Info"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let surnameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Surname"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "New Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm New Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Changes", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let db = Firestore.firestore()
    private var currentUser: User?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add views to hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(editInfoCard)
        
        editInfoCard.addSubview(editInfoHeader)
        editInfoCard.addSubview(nameTextField)
        editInfoCard.addSubview(surnameTextField)
        editInfoCard.addSubview(passwordTextField)
        editInfoCard.addSubview(confirmPasswordTextField)
        editInfoCard.addSubview(saveButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            editInfoCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            editInfoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            editInfoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            editInfoCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            
            editInfoHeader.topAnchor.constraint(equalTo: editInfoCard.topAnchor, constant: 16),
            editInfoHeader.leadingAnchor.constraint(equalTo: editInfoCard.leadingAnchor, constant: 16),
            editInfoHeader.trailingAnchor.constraint(equalTo: editInfoCard.trailingAnchor, constant: -16),
            
            nameTextField.topAnchor.constraint(equalTo: editInfoHeader.bottomAnchor, constant: 16),
            nameTextField.leadingAnchor.constraint(equalTo: editInfoCard.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: editInfoCard.trailingAnchor, constant: -16),
            
            surnameTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            surnameTextField.leadingAnchor.constraint(equalTo: editInfoCard.leadingAnchor, constant: 16),
            surnameTextField.trailingAnchor.constraint(equalTo: editInfoCard.trailingAnchor, constant: -16),
            
            passwordTextField.topAnchor.constraint(equalTo: surnameTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: editInfoCard.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: editInfoCard.trailingAnchor, constant: -16),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: editInfoCard.leadingAnchor, constant: 16),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: editInfoCard.trailingAnchor, constant: -16),
            
            saveButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: editInfoCard.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: editInfoCard.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: editInfoCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Data Loading
    private func loadUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userID).collection("info").document("userInfo").getDocument { [weak self] (document, error) in
            guard let self = self,
                  let document = document,
                  document.exists,
                  let data = document.data() else { return }
            
            self.nameTextField.text = data["name"] as? String
            self.surnameTextField.text = data["surname"] as? String
        }
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Validate password if provided
        if !passwordTextField.text!.isEmpty {
            guard passwordTextField.text == confirmPasswordTextField.text else {
                showAlert(title: "Error", message: "Passwords do not match")
                return
            }
            
            guard passwordTextField.text!.count >= 6 else {
                showAlert(title: "Error", message: "Password must be at least 6 characters")
                return
            }
            
            // Update password
            Auth.auth().currentUser?.updatePassword(to: passwordTextField.text!) { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
        
        // Update user info
        let userInfo: [String: Any] = [
            "name": nameTextField.text ?? "",
            "surname": surnameTextField.text ?? ""
        ]
        
        db.collection("users").document(userID).collection("info").document("userInfo").updateData(userInfo) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self?.showAlert(title: "Success", message: "Profile updated successfully") { _ in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
}
