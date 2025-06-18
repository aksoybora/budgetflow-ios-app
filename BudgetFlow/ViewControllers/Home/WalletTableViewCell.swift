//
//  WalletTableViewCell.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 11.04.2025.
//

import UIKit

// Cüzdan bilgilerini gösteren TableView hücresi
class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var balanceLabel: UILabel! // Bakiye etiketi
    @IBOutlet weak var currencyLabel: UILabel! // Para birimi etiketi
    @IBOutlet weak var walletNameLabel: UILabel! // Cüzdan adı etiketi
    @IBOutlet weak var walletIconImageView: UIImageView! // Cüzdan ikonu
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Hücre görünümünü ayarla
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        // İçerik görünümünü ayarla
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true
        
        // Gölge ayarlarını yap
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 8
        self.layer.masksToBounds = false
        
        // Etiketleri ayarla
        walletNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        walletNameLabel.textColor = .darkGray
        
        currencyLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        balanceLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        // İkonu ayarla
        walletIconImageView.contentMode = .scaleAspectFit
        walletIconImageView.tintColor = .darkGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Seçildiğinde hafif bir animasyon ekle
        UIView.animate(withDuration: 0.2) {
            self.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
    
    func configure(with wallet: Wallet) {
        // Para birimine göre cüzdan adını ayarla
        walletNameLabel.text = "\(wallet.currency) Wallet"
        
        // Para birimini ayarla
        currencyLabel.text = wallet.currency
        
        // Bakiyeyi para birimi sembolü ve binlik ayracı ile formatla
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        if let formattedBalance = formatter.string(from: NSNumber(value: wallet.balance)) {
            balanceLabel.text = formattedBalance
        }
        
        // Para birimine göre cüzdan ikonunu ayarla
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
