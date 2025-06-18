//
//  AccountInfoVC.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 29.04.2025.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AccountInfoViewController: UIViewController {

    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray6
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let editImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .black
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let personalInfoCard: UIView = {
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
    
    private let personalInfoHeader: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Personal info"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        let editButton = UIButton(type: .system)
        editButton.setTitle("Edit", for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 16)
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(editButton)
        return stack
    }()
    
    private let personalInfoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let db = Firestore.firestore()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add views to hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(editImageButton)
        contentView.addSubview(personalInfoCard)
        
        personalInfoCard.addSubview(personalInfoHeader)
        personalInfoCard.addSubview(personalInfoStack)
        
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
            
            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            editImageButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            editImageButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            editImageButton.widthAnchor.constraint(equalToConstant: 30),
            editImageButton.heightAnchor.constraint(equalToConstant: 30),
            
            personalInfoCard.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 32),
            personalInfoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            personalInfoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            personalInfoCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            
            personalInfoHeader.topAnchor.constraint(equalTo: personalInfoCard.topAnchor, constant: 16),
            personalInfoHeader.leadingAnchor.constraint(equalTo: personalInfoCard.leadingAnchor, constant: 16),
            personalInfoHeader.trailingAnchor.constraint(equalTo: personalInfoCard.trailingAnchor, constant: -16),
            
            personalInfoStack.topAnchor.constraint(equalTo: personalInfoHeader.bottomAnchor, constant: 16),
            personalInfoStack.leadingAnchor.constraint(equalTo: personalInfoCard.leadingAnchor, constant: 16),
            personalInfoStack.trailingAnchor.constraint(equalTo: personalInfoCard.trailingAnchor, constant: -16),
            personalInfoStack.bottomAnchor.constraint(equalTo: personalInfoCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func createInfoRow(icon: String, title: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImage = UIImageView()
        iconImage.image = UIImage(systemName: icon)
        iconImage.tintColor = .systemGray2
        iconImage.contentMode = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(valueLabel)
        
        container.addSubview(iconImage)
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            iconImage.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconImage.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 24),
            iconImage.heightAnchor.constraint(equalToConstant: 24),
            
            stack.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 16),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func updateUI(with data: [String: Any]) {
        personalInfoStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add personal info rows with icons
        // Name and Surname
        let name = data["name"] as? String ?? "-"
        let surname = data["surname"] as? String ?? "-"
        personalInfoStack.addArrangedSubview(createInfoRow(icon: "person.fill", 
                                                         title: "Name", 
                                                         value: "\(name) \(surname)"))
        
        // Email
        personalInfoStack.addArrangedSubview(createInfoRow(icon: "envelope.fill", 
                                                         title: "E-mail", 
                                                         value: data["email"] as? String ?? "-"))
        
        // Birthday
        personalInfoStack.addArrangedSubview(createInfoRow(icon: "calendar", 
                                                         title: "Birthday", 
                                                         value: data["birthday"] as? String ?? "-"))
        
        // Created At
        if let timestamp = data["createdAt"] as? Timestamp {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            personalInfoStack.addArrangedSubview(createInfoRow(icon: "clock.fill", 
                                                             title: "Member Since", 
                                                             value: dateFormatter.string(from: timestamp.dateValue())))
        }
        
        // Set profile image if available
        if let imageUrlString = data["profileImage"] as? String,
           let imageUrl = URL(string: imageUrlString) {
            URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                    }
                }
            }.resume()
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .systemGray4
        }
    }

    // MARK: - Data Methods
    private func loadUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // Fetch from info subcollection
        db.collection("users").document(userID).collection("info").getDocuments { [weak self] snapshot, error in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            
            guard let self = self else { return }
            
            if let error = error {
                let errorRow = self.createInfoRow(icon: "exclamationmark.triangle",
                                                title: "Error",
                                                value: error.localizedDescription)
                self.personalInfoStack.addArrangedSubview(errorRow)
                return
            }
            
            if let document = snapshot?.documents.first {
                let data = document.data()
                self.updateUI(with: data)
            } else {
                let noDataRow = self.createInfoRow(icon: "exclamationmark.triangle",
                                                 title: "No Data",
                                                 value: "No user info found.")
                self.personalInfoStack.addArrangedSubview(noDataRow)
            }
        }
    }
}
