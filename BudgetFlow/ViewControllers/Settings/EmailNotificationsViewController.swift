//
//  EmailNotificationsViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 15.06.2025.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class EmailNotificationsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emailTypes = [
        ("Weekly Reports", "chart.bar.fill"),
        ("Budget Alerts", "exclamationmark.triangle.fill"),
        ("Account Updates", "envelope.fill"),
        ("Promotional Emails", "megaphone.fill")
    ]
    
    private var emailSettings: [String: Bool] {
        get {
            UserDefaults.standard.dictionary(forKey: "EmailSettings") as? [String: Bool] ?? [
                "Weekly Reports": true,
                "Budget Alerts": true,
                "Account Updates": true,
                "Promotional Emails": false
            ]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "EmailSettings")
        }
    }
    
    private let db = Firestore.firestore()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadEmailSettings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        title = "Email Notifications"
        
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EmailCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Layout
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Methods
    private func loadEmailSettings() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userID).collection("settings").document("email").getDocument { [weak self] snapshot, error in
            if let error = error {
                self?.makeAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            if let data = snapshot?.data() {
                var settings = self?.emailSettings ?? [:]
                for (key, value) in data {
                    if let boolValue = value as? Bool {
                        settings[key] = boolValue
                    }
                }
                self?.emailSettings = settings
                self?.tableView.reloadData()
            }
        }
    }
    
    private func saveEmailSettings() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userID).collection("settings").document("email").setData(emailSettings) { [weak self] error in
            if let error = error {
                self?.makeAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension EmailNotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmailCell", for: indexPath)
        let (title, icon) = emailTypes[indexPath.row]
        
        cell.textLabel?.text = title
        cell.imageView?.image = UIImage(systemName: icon)
        cell.imageView?.tintColor = UIColor(hex: "#007AFF")
        
        let switchView = UISwitch()
        switchView.isOn = emailSettings[title] ?? true
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension EmailNotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Actions
extension EmailNotificationsViewController {
    @objc private func switchChanged(_ sender: UISwitch) {
        let (title, _) = emailTypes[sender.tag]
        var settings = emailSettings
        settings[title] = sender.isOn
        emailSettings = settings
        
        // Save to Firestore
        saveEmailSettings()
    }
}

// MARK: - Helper Methods
extension EmailNotificationsViewController {
    private func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}
