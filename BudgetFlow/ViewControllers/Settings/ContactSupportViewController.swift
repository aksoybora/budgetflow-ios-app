//
//  ContactSupportViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 18.06.2025.
//

import UIKit
import MessageUI

class ContactSupportViewController: UIViewController {
    
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
        label.text = "Contact Support"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let supportCard: UIView = {
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
    
    private let developerLabel: UILabel = {
        let label = UILabel()
        label.text = "Developer"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Bora Aksoy"
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "bora.aksoy@ogr.gelisim.edu.tr"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemBlue
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "For any questions, feedback, or support, please don't hesitate to contact me via email. I'll get back to you as soon as possible."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Email", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add views to hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(supportCard)
        
        supportCard.addSubview(developerLabel)
        supportCard.addSubview(nameLabel)
        supportCard.addSubview(emailLabel)
        supportCard.addSubview(messageLabel)
        supportCard.addSubview(emailButton)
        
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
            
            supportCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            supportCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            supportCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            supportCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            
            developerLabel.topAnchor.constraint(equalTo: supportCard.topAnchor, constant: 24),
            developerLabel.centerXAnchor.constraint(equalTo: supportCard.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: developerLabel.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: supportCard.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.centerXAnchor.constraint(equalTo: supportCard.centerXAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 24),
            messageLabel.leadingAnchor.constraint(equalTo: supportCard.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: supportCard.trailingAnchor, constant: -24),
            
            emailButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 32),
            emailButton.leadingAnchor.constraint(equalTo: supportCard.leadingAnchor, constant: 24),
            emailButton.trailingAnchor.constraint(equalTo: supportCard.trailingAnchor, constant: -24),
            emailButton.heightAnchor.constraint(equalToConstant: 50),
            emailButton.bottomAnchor.constraint(equalTo: supportCard.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupActions() {
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(emailLabelTapped))
        emailLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func emailButtonTapped() {
        sendEmail()
    }
    
    @objc private func emailLabelTapped() {
        sendEmail()
    }
    
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(["bora.aksoy@ogr.gelisim.edu.tr"])
            mailComposer.setSubject("BudgetFlow Support")
            present(mailComposer, animated: true)
        } else {
            // If email is not configured, copy email to clipboard
            UIPasteboard.general.string = "bora.aksoy@ogr.gelisim.edu.tr"
            showAlert(title: "Email Not Configured", message: "Email address has been copied to clipboard. Please use your email app to send a message.")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension ContactSupportViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
