//
//  SettingsViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 3.02.2025.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var settingsTableView: UITableView!
    
    let titleLabel = UILabel()
    
    // Define sections
    enum SettingsSection: Int, CaseIterable {
        case profile
        case security
        case appearance
        case notifications
        case support
        case account
        
        var title: String {
            switch self {
            case .profile: return "Profile"
            case .security: return "Security"
            case .appearance: return "Appearance"
            case .notifications: return "Notifications"
            case .support: return "Support"
            case .account: return "Account"
            }
        }
        
        var items: [(title: String, icon: String)] {
            switch self {
            case .profile:
                return [
        ("Account Info", "person"),
                    ("Edit Profile", "pencil")
                ]
            case .security:
                return [
        ("Change Password", "lock"),
                    ("Two-Factor Authentication", "lock.shield")
                ]
            case .appearance:
                return [
                    ("Theme", "moon"),
                    ("Accent Color", "paintpalette")
                ]
            case .notifications:
                return [
                    ("Notification Settings", "bell"),
                    ("Email Notifications", "envelope")
                ]
            case .support:
                return [
        ("FAQ", "questionmark"),
        ("Contact Support", "envelope"),
        ("Rate the App", "star"),
                    ("Privacy Policy", "hand.raised")
                ]
            case .account:
                return [
        ("Sign Out", "arrow.backward")
    ]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
    }
        
    private func setupUI() {
        titleLabel.text = "Settings"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }
        
    private func setupTableView() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingsSection(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsSection(rawValue: section)?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SettingsCell")
        
        guard let section = SettingsSection(rawValue: indexPath.section),
              let item = section.items[safe: indexPath.row] else {
            return cell
        }

        cell.textLabel?.text = item.title
        cell.imageView?.image = UIImage(systemName: item.icon)
        cell.imageView?.tintColor = .systemBlue
        cell.accessoryType = .disclosureIndicator
        
        if item.title == "Sign Out" {
            cell.backgroundColor = UIColor(hex: "#F44336", alpha: 0.1)
        }

            return cell
        }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section),
              let item = section.items[safe: indexPath.row] else {
            return
        }

        switch item.title {
        case "Sign Out":
            handleSignOut()
        case "Account Info":
            performSegue(withIdentifier: "toAccountInfo", sender: nil)
        case "Edit Profile":
            performSegue(withIdentifier: "toEditProfile", sender: nil)
        case "Change Password":
            performSegue(withIdentifier: "toChangePassword", sender: nil)
        case "Two-Factor Authentication":
            performSegue(withIdentifier: "toTwoFactorAuth", sender: nil)
        case "Theme":
            performSegue(withIdentifier: "toThemeSettings", sender: nil)
        case "Notification Settings":
            performSegue(withIdentifier: "toNotificationSettings", sender: nil)
        case "Email Notifications":
            performSegue(withIdentifier: "toEmailNotifications", sender: nil)
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func handleSignOut() {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toVC", sender: nil)
        } catch {
            print("Sign Out failed!")
        }
    }
    }
    
// MARK: - Array Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
