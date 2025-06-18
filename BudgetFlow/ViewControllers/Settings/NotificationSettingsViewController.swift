//
//  NotificationSettingsViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 15.06.2025.
//

import UIKit
import UserNotifications

// Bildirim ayarları ekranını yöneten ViewController
class NotificationSettingsViewController: UIViewController {

    // MARK: - UI Elemanları
    private let tableView = UITableView(frame: .zero, style: .insetGrouped) // Bildirim seçeneklerini gösteren tablo
    private let notificationTypes = [
        ("Transaction Notifications", "bell.fill"), // İşlem bildirimleri
        ("Budget Alerts", "exclamationmark.triangle.fill"), // Bütçe uyarıları
        ("Reminders", "clock.fill") // Hatırlatıcılar
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
    
    // MARK: - Yaşam Döngüsü Metodları
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // UI kurulumunu yap
        requestNotificationPermission() // Bildirim izni iste
    }
    
    // MARK: - UI Kurulumu
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        title = "Notifications"
        
        // Tabloyu ayarla
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NotificationCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Otomatik yerleşim kısıtlamaları
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Bildirim Metodları
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
        return notificationTypes.count // Bildirim türü sayısı
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

// MARK: - Aksiyonlar
extension NotificationSettingsViewController {
    @objc private func switchChanged(_ sender: UISwitch) {
        let (title, _) = notificationTypes[sender.tag]
        var settings = notificationSettings
        settings[title] = sender.isOn
        notificationSettings = settings
        
        // Sistem bildirim ayarlarını güncelle
        updateNotificationSettings()
    }
    
    private func updateNotificationSettings() {
        // Burada genellikle kullanıcının tercihlerine göre bildirim planlama mantığı güncellenir
        print("Notification settings updated:", notificationSettings)
    }
}

// MARK: - Yardımcı Metodlar
extension NotificationSettingsViewController {
    private func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}
