//
//  TransactionDetailViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 18.03.2025.
//

import UIKit

class TransactionDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // Transaction modeli
    var transaction: Transaction? {
        didSet {
            // transaction değişkeni ayarlandığında UI'ı güncelle
            if isViewLoaded { // Eğer view yüklendiyse UI'ı güncelle
                setupUI()
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    
    
    private func setupUI() {
        guard let transaction = transaction else {
            print("Transaction is nil")
            return
        }

        titleLabel.text = String(transaction.title)
        descriptionLabel.text = transaction.description
        amountLabel.text = transaction.amount
        currencyLabel.text = transaction.currency
        categoryLabel.text = transaction.category
        typeLabel.text = transaction.type
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm" // Tarih ve saat bilgisini göster
        dateLabel.text = dateFormatter.string(from: transaction.date.dateValue())
    }
    
}
