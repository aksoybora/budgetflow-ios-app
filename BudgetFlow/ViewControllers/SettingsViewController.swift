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
    
    let titleLabel = UILabel() // Navigation bardaki başlık
    
    let settingsItems: [(title: String, icon: String)] = [
        ("Account Info", "person"),
        ("Change Password", "lock"),
        ("Default Currency", "dollarsign"),
        ("Notifications", "bell"),
        ("FAQ", "questionmark"),
        ("Contact Support", "envelope"),
        ("Rate the App", "star"),
        ("Privacy Policy", "hand.raised"),
        ("Sign Out", "arrow.backward")
    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //userEmailLabel.text = Auth.auth().currentUser?.email
        
        titleLabel.text = "Settings"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsItems.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let item = settingsItems[indexPath.row]

        cell.textLabel?.text = item.title
        cell.imageView?.image = UIImage(systemName: item.icon)
        cell.imageView?.tintColor = .systemBlue
        cell.accessoryType = .disclosureIndicator
        
        if item.title == "Sign Out" {
            cell.backgroundColor = UIColor(hex: "#F44336", alpha: 0.1) // Açık kırmızı arka plan
        }

            return cell
        }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = settingsItems[indexPath.row].title

        switch selectedItem {
        case "Sign Out":
            do {
                try Auth.auth().signOut()
                performSegue(withIdentifier: "toVC", sender: nil)
            } catch {
                print("Sign Out failed!")
            }

        case "Account Info":
            performSegue(withIdentifier: "toAccountInfo", sender: nil)
            break
            
        case "Change Password":
            // Navigate to Password Change screen
            break
            
        // diğer case'leri buraya ekle
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    // Sign out & redirect to login page
    @IBAction func logOutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toVC", sender: nil)
        } catch {
            print("Sign Out failed!")
        }
    }
    
    
}
