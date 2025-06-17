//
//  WalletCardCollectionViewCell.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 17.06.2025.
//

import UIKit

class WalletCardCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elemanları
    let cardBackgroundView = UIView() // Kartın arka planı
    let walletNameLabel = UILabel()   // Cüzdan adı
    let balanceLabel = UILabel()      // Bakiye
    let currencyLabel = UILabel()     // Para birimi
    let last4DigitsLabel = UILabel()  // Son 4 hane
    let detailsButton = UIButton(type: .system) // Detaylar butonu
    let cardLogoImageView = UIImageView() // Kart logosu

    // Kart rengi
    var walletColor: UIColor = UIColor.systemPurple {
        didSet {
            cardBackgroundView.layer.borderColor = walletColor.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }

    // UI elemanlarını oluştur ve özelleştir
    private func setupViews() {
        // Kart arka planı
        cardBackgroundView.backgroundColor = UIColor.white
        cardBackgroundView.layer.cornerRadius = 20
        cardBackgroundView.layer.masksToBounds = true
        cardBackgroundView.layer.borderWidth = 3
        cardBackgroundView.layer.borderColor = walletColor.cgColor
        contentView.addSubview(cardBackgroundView)
        cardBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        // Kart logosu
        cardLogoImageView.contentMode = .scaleAspectFit
        cardBackgroundView.addSubview(cardLogoImageView)
        cardLogoImageView.translatesAutoresizingMaskIntoConstraints = false

        // Cüzdan adı
        walletNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        walletNameLabel.textColor = UIColor.black
        cardBackgroundView.addSubview(walletNameLabel)
        walletNameLabel.translatesAutoresizingMaskIntoConstraints = false

        // Bakiye
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 28)
        balanceLabel.textColor = UIColor.black
        cardBackgroundView.addSubview(balanceLabel)
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false

        // Para birimi
        currencyLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        currencyLabel.textColor = UIColor.black
        cardBackgroundView.addSubview(currencyLabel)
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false

        // Son 4 hane
        last4DigitsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        last4DigitsLabel.textColor = UIColor.darkGray
        cardBackgroundView.addSubview(last4DigitsLabel)
        last4DigitsLabel.translatesAutoresizingMaskIntoConstraints = false

        // Detaylar butonu
        detailsButton.setTitle("Details", for: .normal)
        detailsButton.setTitleColor(.black, for: .normal)
        detailsButton.backgroundColor = UIColor.white
        detailsButton.layer.cornerRadius = 12
        detailsButton.layer.borderWidth = 2
        detailsButton.layer.borderColor = UIColor.systemPurple.cgColor
        detailsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cardBackgroundView.addSubview(detailsButton)
        detailsButton.translatesAutoresizingMaskIntoConstraints = false
    }

    // Otomatik yerleşim (Auto Layout) kuralları
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            cardBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            cardBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            cardBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            cardBackgroundView.widthAnchor.constraint(equalToConstant: 240),
            cardBackgroundView.heightAnchor.constraint(equalToConstant: 140),
            cardLogoImageView.topAnchor.constraint(equalTo: cardBackgroundView.topAnchor, constant: 12),
            cardLogoImageView.trailingAnchor.constraint(equalTo: cardBackgroundView.trailingAnchor, constant: -16),
            cardLogoImageView.widthAnchor.constraint(equalToConstant: 32),
            cardLogoImageView.heightAnchor.constraint(equalToConstant: 32),
            walletNameLabel.topAnchor.constraint(equalTo: cardBackgroundView.topAnchor, constant: 16),
            walletNameLabel.leadingAnchor.constraint(equalTo: cardBackgroundView.leadingAnchor, constant: 16),
            walletNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardLogoImageView.leadingAnchor, constant: -8),
            balanceLabel.topAnchor.constraint(equalTo: walletNameLabel.bottomAnchor, constant: 16),
            balanceLabel.leadingAnchor.constraint(equalTo: cardBackgroundView.leadingAnchor, constant: 16),
            currencyLabel.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            currencyLabel.leadingAnchor.constraint(equalTo: balanceLabel.trailingAnchor, constant: 8),
            last4DigitsLabel.leadingAnchor.constraint(equalTo: cardBackgroundView.leadingAnchor, constant: 16),
            last4DigitsLabel.bottomAnchor.constraint(equalTo: cardBackgroundView.bottomAnchor, constant: -16),
            detailsButton.trailingAnchor.constraint(equalTo: cardBackgroundView.trailingAnchor, constant: -16),
            detailsButton.bottomAnchor.constraint(equalTo: cardBackgroundView.bottomAnchor, constant: -16),
            detailsButton.widthAnchor.constraint(equalToConstant: 90),
            detailsButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    // Cüzdan ile hücreyi doldur
    func configure(with wallet: Wallet, last4: String) {
        walletNameLabel.text = "\(wallet.currency) Wallet"
        currencyLabel.text = wallet.currency
        last4DigitsLabel.text = "•••• \(last4)"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        if let formattedBalance = formatter.string(from: NSNumber(value: wallet.balance)) {
            balanceLabel.text = formattedBalance
        }
        // Kart logosu ve renkler
        switch wallet.currency {
        case "TRY":
            cardLogoImageView.image = UIImage(systemName: "turkishlirasign.circle.fill")
            cardBackgroundView.backgroundColor = UIColor(red: 0.91, green: 0.97, blue: 0.89, alpha: 1) // Açık yeşil
            walletColor = UIColor(red: 0.22, green: 0.65, blue: 0.32, alpha: 1) // Koyu yeşil
            walletNameLabel.textColor = walletColor
            balanceLabel.textColor = walletColor
            currencyLabel.textColor = walletColor
        case "USD":
            cardLogoImageView.image = UIImage(systemName: "dollarsign.circle.fill")
            cardBackgroundView.backgroundColor = UIColor(red: 0.89, green: 0.94, blue: 0.98, alpha: 1) // Açık mavi
            walletColor = UIColor(red: 0.13, green: 0.36, blue: 0.75, alpha: 1) // Koyu mavi
            walletNameLabel.textColor = walletColor
            balanceLabel.textColor = walletColor
            currencyLabel.textColor = walletColor
        case "EUR":
            cardLogoImageView.image = UIImage(systemName: "eurosign.circle.fill")
            cardBackgroundView.backgroundColor = UIColor(red: 1.0, green: 0.96, blue: 0.86, alpha: 1) // Açık sarı
            walletColor = UIColor(red: 0.98, green: 0.60, blue: 0.18, alpha: 1) // Koyu turuncu
            walletNameLabel.textColor = walletColor
            balanceLabel.textColor = walletColor
            currencyLabel.textColor = walletColor
        default:
            cardLogoImageView.image = UIImage(systemName: "creditcard.fill")
            cardBackgroundView.backgroundColor = UIColor(white: 0.97, alpha: 1)
            walletColor = UIColor.systemPurple
            walletNameLabel.textColor = walletColor
            balanceLabel.textColor = walletColor
            currencyLabel.textColor = walletColor
        }
        cardBackgroundView.layer.borderColor = walletColor.cgColor
        detailsButton.layer.borderColor = UIColor.systemPurple.cgColor
    }
}
