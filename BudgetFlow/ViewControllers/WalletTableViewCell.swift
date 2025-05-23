//
//  WalletTableViewCell.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 11.04.2025.
//

import UIKit

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Configure cell appearance
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        // Configure content view
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true
        
        // Configure shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 8
        self.layer.masksToBounds = false
        
        // Configure labels
        walletNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        walletNameLabel.textColor = .darkGray
        
        currencyLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        balanceLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        // Configure icon
        walletIconImageView.contentMode = .scaleAspectFit
        walletIconImageView.tintColor = .darkGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Add a subtle animation when selected
        UIView.animate(withDuration: 0.2) {
            self.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
    
    func configure(with wallet: Wallet) {
        // Set wallet name based on currency
        walletNameLabel.text = "\(wallet.currency) Wallet"
        
        // Set currency
        currencyLabel.text = wallet.currency
        
        // Format balance with currency symbol and thousands separator
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        if let formattedBalance = formatter.string(from: NSNumber(value: wallet.balance)) {
            balanceLabel.text = formattedBalance
        }
        
        // Set wallet icon based on currency
        let iconName: String
        switch wallet.currency {
        case "TRY":
            iconName = "turkishlirasign.circle.fill"
        case "USD":
            iconName = "dollarsign.circle.fill"
        case "EUR":
            iconName = "eurosign.circle.fill"
        default:
            iconName = "creditcard.fill"
        }
        walletIconImageView.image = UIImage(systemName: iconName)
    }
}
