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
    
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(hex: "#F5F5F5")
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
        label.text = "Settings"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Manage your account preferences"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
                    ("Theme", "moon")
                ]
            case .notifications:
                return [
                    ("Notification Settings", "bell"),
                    ("Email Notifications", "envelope")
                ]
            case .support:
                return [
                    ("FAQ", "questionmark.circle"),
                    ("Contact Support", "envelope"),
                    ("Rate the App", "star")
                ]
            case .account:
                return [
                    ("Sign Out", "arrow.right.square")
                ]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        
        // Add views to hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(settingsTableView)
        
        // Setup table view
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            settingsTableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            settingsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        guard let section = SettingsSection(rawValue: indexPath.section),
              let item = section.items[safe: indexPath.row] else {
            return cell
        }
        
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.textProperties.font = .systemFont(ofSize: 16, weight: .regular)
        content.textProperties.color = item.title == "Sign Out" ? .systemRed : .label
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        content.image = UIImage(systemName: item.icon, withConfiguration: imageConfig)
        content.imageProperties.tintColor = item.title == "Sign Out" ? .systemRed : .systemBlue
        
        cell.contentConfiguration = content
        cell.backgroundColor = .systemBackground
        cell.layer.cornerRadius = 12
        cell.accessoryType = .disclosureIndicator
        
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
        case "Theme":
            performSegue(withIdentifier: "toThemeSettings", sender: nil)
        case "Notification Settings":
            performSegue(withIdentifier: "toNotificationSettings", sender: nil)
        case "Email Notifications":
            performSegue(withIdentifier: "toEmailNotifications", sender: nil)
        case "FAQ":
            performSegue(withIdentifier: "toFAQ", sender: nil)
        case "Contact Support":
            performSegue(withIdentifier: "toContactSupport", sender: nil)
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
    
    @IBAction func faqButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toFAQ", sender: nil)
    }
    
    @IBAction func contactSupportButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toContactSupport", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFAQ" {
            // No additional setup needed for FAQ
        } else if segue.identifier == "toContactSupport" {
            // No additional setup needed for Contact Support
        }
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
