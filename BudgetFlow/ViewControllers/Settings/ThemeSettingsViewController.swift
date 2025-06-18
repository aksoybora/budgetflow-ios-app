//
//  ThemeSettingsViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 15.06.2025.
//

import UIKit

// Tema ayarları ekranını yöneten ViewController
class ThemeSettingsViewController: UIViewController {

    // MARK: - UI Elemanları
    private let tableView = UITableView(frame: .zero, style: .insetGrouped) // Tema seçeneklerini gösteren tablo
    private let themes = ["System", "Light", "Dark"] // Tema seçenekleri
    private var selectedTheme: String {
        get { UserDefaults.standard.string(forKey: "AppTheme") ?? "System" } // Seçili temayı getir
        set { UserDefaults.standard.set(newValue, forKey: "AppTheme") } // Seçili temayı kaydet
    }
    
    // MARK: - Yaşam Döngüsü Metodları
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // UI kurulumunu yap
    }
    
    // MARK: - UI Kurulumu
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        title = "Theme"
        
        // Tabloyu ayarla
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ThemeCell")
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
}

// MARK: - UITableViewDataSource
extension ThemeSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count // Tema sayısı
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath)
        let theme = themes[indexPath.row]
        
        cell.textLabel?.text = theme
        cell.accessoryType = theme == selectedTheme ? .checkmark : .none // Seçili temayı işaretle
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ThemeSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTheme = themes[indexPath.row]
        self.selectedTheme = selectedTheme
        
        // UI'yı güncelle
        tableView.reloadData()
        
        // Temayı uygula
        switch selectedTheme {
        case "Light":
            overrideUserInterfaceStyle = .light
        case "Dark":
            overrideUserInterfaceStyle = .dark
        default:
            overrideUserInterfaceStyle = .unspecified
        }
        
        // Diğer view controller'lara tema değişikliğini bildir
        NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
    }
}
