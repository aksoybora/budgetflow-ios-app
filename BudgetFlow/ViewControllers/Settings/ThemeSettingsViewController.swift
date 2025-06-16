//
//  ThemeSettingsViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 15.06.2025.
//

import UIKit

class ThemeSettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let themes = ["System", "Light", "Dark"]
    private var selectedTheme: String {
        get { UserDefaults.standard.string(forKey: "AppTheme") ?? "System" }
        set { UserDefaults.standard.set(newValue, forKey: "AppTheme") }
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        title = "Theme"
        
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ThemeCell")
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
}

// MARK: - UITableViewDataSource
extension ThemeSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath)
        let theme = themes[indexPath.row]
        
        cell.textLabel?.text = theme
        cell.accessoryType = theme == selectedTheme ? .checkmark : .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ThemeSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTheme = themes[indexPath.row]
        self.selectedTheme = selectedTheme
        
        // Update UI
        tableView.reloadData()
        
        // Apply theme
        switch selectedTheme {
        case "Light":
            overrideUserInterfaceStyle = .light
        case "Dark":
            overrideUserInterfaceStyle = .dark
        default:
            overrideUserInterfaceStyle = .unspecified
        }
        
        // Notify other view controllers
        NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
    }
}
