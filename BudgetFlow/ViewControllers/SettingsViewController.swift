//
//  SettingsViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 3.02.2025.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {

    
    @IBOutlet weak var userEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userEmailLabel.text = Auth.auth().currentUser?.email
        
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
