//
//  TransactionInfoTableViewCell.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 21.02.2025.
//

import UIKit

class TransactionInfoTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func configure(with transaction: Transaction, dateString: String, icon: UIImage?) {
        // Configure cell content
        var content = defaultContentConfiguration()
        content.text = transaction.title
        content.secondaryText = "\(transaction.amount) \(transaction.currency) - \(dateString)"
        
        // Configure icon
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        content.image = icon?.withConfiguration(imageConfig)
        content.imageProperties.tintColor = transaction.type == "Income" ? UIColor(hex: "#3E7B27") : .systemRed
        content.imageProperties.maximumSize = CGSize(width: 32, height: 32)
        content.imageToTextPadding = 16
        
        // Set text color based on transaction type
        if transaction.type == "Income" {
            content.secondaryTextProperties.color = UIColor(hex: "#3E7B27")
            backgroundColor = UIColor(hex: "#A7D477", alpha: 0.2)
        } else {
            content.secondaryTextProperties.color = .systemRed
            backgroundColor = UIColor(hex: "#F44336", alpha: 0.2)
        }
        
        contentConfiguration = content
    }
}
