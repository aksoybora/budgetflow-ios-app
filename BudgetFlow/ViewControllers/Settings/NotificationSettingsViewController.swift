//
//  NotificationSettingsViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 15.06.2025.
//

import UIKit
import UserNotifications

class NotificationSettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let notificationTypes = [
        ("Transaction Notifications", "bell.fill"),
        ("Budget Alerts", "exclamationmark.triangle.fill"),
        ("Reminders", "clock.fill")
    ]
    
    private var notificationSettings: [String: Bool] {
        get {
            UserDefaults.standard.dictionary(forKey: "NotificationSettings") as? [String: Bool] ?? [
                "Transaction Notifications": true,
                "Budget Alerts": true,
                "Reminders": true
            ]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "NotificationSettings")
        }
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestNotificationPermission()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        title = "Notifications"
        
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NotificationCell")
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
    
    // MARK: - Notification Methods
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else if let error = error {
                    self.makeAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension NotificationSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
        let (title, icon) = notificationTypes[indexPath.row]
        
        cell.textLabel?.text = title
        cell.imageView?.image = UIImage(systemName: icon)
        cell.imageView?.tintColor = UIColor(hex: "#007AFF")
        
        let switchView = UISwitch()
        switchView.isOn = notificationSettings[title] ?? true
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotificationSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Actions
extension NotificationSettingsViewController {
    @objc private func switchChanged(_ sender: UISwitch) {
        let (title, _) = notificationTypes[sender.tag]
        var settings = notificationSettings
        settings[title] = sender.isOn
        notificationSettings = settings
        
        // Update notification settings in the system
        updateNotificationSettings()
    }
    
    private func updateNotificationSettings() {
        // Here you would typically update your notification scheduling logic
        // based on the user's preferences
        print("Notification settings updated:", notificationSettings)
    }
}

// MARK: - Helper Methods
extension NotificationSettingsViewController {
    private func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}
