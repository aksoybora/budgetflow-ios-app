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

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let stackView = UIStackView()
    private let nameTextField = UITextField()
    private let emailTextField = UITextField()
    private let saveButton = UIButton(type: .system)
    private let db = Firestore.firestore()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        title = "Edit Profile"
        
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
        
        // Add fields to stack
        let nameField = createLabeledField(label: "Name", textField: nameTextField, icon: "person.fill")
        let emailField = createLabeledField(label: "Email", textField: emailTextField, icon: "envelope.fill")
        stackView.addArrangedSubview(nameField)
        stackView.addArrangedSubview(emailField)
        
        // Save Button
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        saveButton.backgroundColor = UIColor(hex: "#007AFF")
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(saveButton)
        
        // Layout
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
    
    private func createLabeledField(label: String, textField: UITextField, icon: String) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 6
        
        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        labelView.textColor = .darkGray
        
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: "#E0E0E0").cgColor
        textField.backgroundColor = UIColor(hex: "#F8F8F8")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Left icon
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
    
    // MARK: - Data Methods
    private func loadUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userID).collection("info").getDocuments { [weak self] snapshot, error in
            if let error = error {
                self?.makeAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            if let document = snapshot?.documents.first {
                self?.nameTextField.text = document.data()["name"] as? String
                self?.emailTextField.text = document.data()["email"] as? String
            }
        }
    }
    
    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let userID = Auth.auth().currentUser?.uid else {
            makeAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        // Show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // Update email in Firebase Auth
        Auth.auth().currentUser?.updateEmail(to: email) { [weak self] error in
            if let error = error {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self?.makeAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            // Update user info in Firestore
            self?.db.collection("users").document(userID).collection("info").getDocuments { snapshot, error in
                if let error = error {
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                    self?.makeAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
                if let document = snapshot?.documents.first {
                    document.reference.updateData([
                        "name": name,
                        "email": email
                    ]) { error in
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        
                        if let error = error {
                            self?.makeAlert(title: "Error", message: error.localizedDescription)
                        } else {
                            self?.makeAlert(title: "Success", message: "Profile updated successfully")
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}
