//
//  AccountInfoVC.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 29.04.2025.
//

import UIKit

class AccountInfoVC: UIViewController {

    let titleLabel = UILabel() // Navigation bardaki başlık
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Account Info"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }


}
