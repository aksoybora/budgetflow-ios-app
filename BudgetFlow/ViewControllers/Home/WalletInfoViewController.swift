//
//  WalletInfoViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 17.06.2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SDWebImage

class WalletInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Veriler
    var wallet: Wallet?
    var transactions: [Transaction] = []
    
    // MARK: - UI Elemanları
    let scrollView = UIScrollView()
    let contentView = UIView()
    let walletCardView = UIView()
    let walletNameLabel = UILabel()
    let balanceLabel = UILabel()
    let currencyLabel = UILabel()
    let transactionsTitleLabel = UILabel()
    let transactionsTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupUI()
        updateWalletInfo()
        loadTransactionsForWallet()
    }
    
    // MARK: - UI Kurulumu
    func setupUI() {
        // ScrollView ve contentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Wallet Card
        walletCardView.layer.cornerRadius = 24
        walletCardView.layer.borderWidth = 3
        walletCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(walletCardView)
        
        walletNameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        walletNameLabel.textColor = .black
        walletNameLabel.translatesAutoresizingMaskIntoConstraints = false
        walletCardView.addSubview(walletNameLabel)
        
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 32)
        balanceLabel.textColor = .black
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        walletCardView.addSubview(balanceLabel)
        
        currencyLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        currencyLabel.textColor = .black
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        walletCardView.addSubview(currencyLabel)
        
        // Transactions title
        transactionsTitleLabel.text = "Transactions"
        transactionsTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        transactionsTitleLabel.textColor = .black
        transactionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(transactionsTitleLabel)
        
        // Transactions TableView
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        transactionsTableView.backgroundColor = UIColor.white
        transactionsTableView.separatorStyle = .none
        transactionsTableView.layer.cornerRadius = 16
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(transactionsTableView)
        transactionsTableView.register(TransactionInfoTableViewCell.self, forCellReuseIdentifier: "TransactionInfoCell")
        
        // Otomatik yerleşim (Auto Layout)
        NSLayoutConstraint.activate([
            walletCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            walletCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            walletCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            walletCardView.heightAnchor.constraint(equalToConstant: 120),
            
            walletNameLabel.topAnchor.constraint(equalTo: walletCardView.topAnchor, constant: 20),
            walletNameLabel.leadingAnchor.constraint(equalTo: walletCardView.leadingAnchor, constant: 20),
            
            balanceLabel.topAnchor.constraint(equalTo: walletNameLabel.bottomAnchor, constant: 12),
            balanceLabel.leadingAnchor.constraint(equalTo: walletCardView.leadingAnchor, constant: 20),
            
            currencyLabel.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            currencyLabel.leadingAnchor.constraint(equalTo: balanceLabel.trailingAnchor, constant: 8),
            
            transactionsTitleLabel.topAnchor.constraint(equalTo: walletCardView.bottomAnchor, constant: 32),
            transactionsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            transactionsTableView.topAnchor.constraint(equalTo: transactionsTitleLabel.bottomAnchor, constant: 12),
            transactionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transactionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            transactionsTableView.heightAnchor.constraint(equalToConstant: 400),
            transactionsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    // MARK: - Wallet Bilgisi Güncelle
    func updateWalletInfo() {
        guard let wallet = wallet else { return }
        walletNameLabel.text = "\(wallet.currency) Wallet"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        if let formattedBalance = formatter.string(from: NSNumber(value: wallet.balance)) {
            balanceLabel.text = formattedBalance
        }
        currencyLabel.text = wallet.currency
        // Kart rengi
        switch wallet.currency {
        case "TRY":
            walletCardView.backgroundColor = UIColor.white
            walletCardView.layer.borderColor = UIColor(red: 0.22, green: 0.65, blue: 0.32, alpha: 1).cgColor // Yeşil
        case "USD":
            walletCardView.backgroundColor = UIColor.white
            walletCardView.layer.borderColor = UIColor(red: 0.13, green: 0.36, blue: 0.75, alpha: 1).cgColor // Mavi
        case "EUR":
            walletCardView.backgroundColor = UIColor.white
            walletCardView.layer.borderColor = UIColor(red: 0.98, green: 0.82, blue: 0.18, alpha: 1).cgColor // Sarı
        default:
            walletCardView.backgroundColor = UIColor.white
            walletCardView.layer.borderColor = UIColor.systemPurple.cgColor
        }
    }
    
    // MARK: - İşlemleri Yükle
    func loadTransactionsForWallet() {
        guard let wallet = wallet else { return }
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let db = Firestore.firestore()
        db.collection("transactions")
            .whereField("userID", isEqualTo: userID)
            .whereField("currency", isEqualTo: wallet.currency)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self?.transactions = querySnapshot?.documents.compactMap { document in
                        let data = document.data()
                        return Transaction(
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            amount: {
                                if let amountStr = data["amount"] as? String {
                                    return amountStr
                                } else if let amountDouble = data["amount"] as? Double {
                                    return String(format: "%.2f", amountDouble)
                                } else {
                                    return ""
                                }
                            }(),
                            currency: data["currency"] as? String ?? "",
                            category: data["category"] as? String ?? "",
                            type: data["type"] as? String ?? "",
                            date: data["date"] as? Timestamp ?? Timestamp(),
                            walletID: ""
                        )
                    } ?? []
                    DispatchQueue.main.async {
                        self?.transactionsTableView.reloadData()
                    }
                }
            }
    }

    // MARK: - Wallet Operations
    func getWalletID(userID: String, currency: String) -> String {
        var walletID = ""
        let db = Firestore.firestore()
        let walletsRef = db.collection("users").document(userID).collection("wallets")

        walletsRef.whereField("currency", isEqualTo: currency).getDocuments { snapshot, error in
            if let error = error {
                print("Error getting wallet ID: \(error)")
            } else if let document = snapshot?.documents.first {
                walletID = document.documentID
            }
        }
        return walletID
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionInfoCell", for: indexPath) as! TransactionInfoTableViewCell
        let transaction = transactions[indexPath.row]
        
        // Tarihi formatla
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: transaction.date.dateValue())
        
        // Hücre içeriğini ayarla
        var content = cell.defaultContentConfiguration()
        content.text = transaction.title
        content.secondaryText = "\(transaction.amount) \(transaction.currency) - \(dateString)"
        
        // İşlem tipine göre renk ayarla
        if transaction.type == "Income" {
            content.secondaryTextProperties.color = UIColor(hex: "#3E7B27")
            cell.backgroundColor = UIColor(hex: "#A7D477", alpha: 0.2)
        } else if transaction.type == "Expense" {
            content.secondaryTextProperties.color = .systemRed
            cell.backgroundColor = UIColor(hex: "#F44336", alpha: 0.2)
        }
        
        // İkon ayarla
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image: UIImage?
        
        switch transaction.description.lowercased() {
        case let desc where desc.contains("food") || desc.contains("restaurant"):
            image = UIImage(systemName: "fork.knife", withConfiguration: imageConfig)
        case let desc where desc.contains("transport") || desc.contains("car"):
            image = UIImage(systemName: "car.fill", withConfiguration: imageConfig)
        case let desc where desc.contains("shopping"):
            image = UIImage(systemName: "cart.fill", withConfiguration: imageConfig)
        case let desc where desc.contains("bills") || desc.contains("utilities"):
            image = UIImage(systemName: "doc.text.fill", withConfiguration: imageConfig)
        case let desc where desc.contains("entertainment"):
            image = UIImage(systemName: "tv.fill", withConfiguration: imageConfig)
        case let desc where desc.contains("health"):
            image = UIImage(systemName: "heart.fill", withConfiguration: imageConfig)
        case let desc where desc.contains("education"):
            image = UIImage(systemName: "book.fill", withConfiguration: imageConfig)
        case let desc where desc.contains("salary") || desc.contains("income"):
            image = UIImage(systemName: "dollarsign.circle.fill", withConfiguration: imageConfig)
        default:
            image = UIImage(systemName: "circle.fill", withConfiguration: imageConfig)
        }
        
        content.image = image
        content.imageProperties.tintColor = transaction.type == "Income" ? UIColor(hex: "#3E7B27") : .systemRed
        content.imageToTextPadding = 12
        
        cell.contentConfiguration = content
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true
        
        return cell
    }
}

// MARK: - TransactionInfoTableViewCell
class TransactionInfoTableViewCell: UITableViewCell {
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let amountLabel = UILabel()
    let badgeLabel = UILabel()
    let container = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        backgroundColor = .clear
        container.backgroundColor = UIColor.white
        container.layer.cornerRadius = 14
        container.layer.borderWidth = 2
        container.layer.borderColor = UIColor.systemPurple.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.cornerRadius = 22
        iconImageView.clipsToBounds = true
        iconImageView.backgroundColor = UIColor(white: 1, alpha: 0.2)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconImageView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        dateLabel.textColor = UIColor.gray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(dateLabel)
        
        amountLabel.font = UIFont.boldSystemFont(ofSize: 16)
        amountLabel.textAlignment = .right
        amountLabel.textColor = .black
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(amountLabel)
        
        badgeLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.clipsToBounds = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(badgeLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 44),
            iconImageView.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            amountLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: badgeLabel.leadingAnchor, constant: -8),
            amountLabel.widthAnchor.constraint(equalToConstant: 80),
            
            badgeLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            badgeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            badgeLabel.widthAnchor.constraint(equalToConstant: 48),
            badgeLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with transaction: Transaction, dateString: String, icon: UIImage?) {
        titleLabel.text = transaction.title
        dateLabel.text = dateString
        amountLabel.text = "\(transaction.amount) \(transaction.currency)"
        if transaction.type == "Income" {
            badgeLabel.text = "+"
            badgeLabel.backgroundColor = UIColor(red: 0.22, green: 0.65, blue: 0.32, alpha: 1)
            amountLabel.textColor = UIColor(red: 0.22, green: 0.65, blue: 0.32, alpha: 1)
        } else {
            badgeLabel.text = "-"
            badgeLabel.backgroundColor = UIColor(red: 0.98, green: 0.22, blue: 0.22, alpha: 1)
            amountLabel.textColor = UIColor(red: 0.98, green: 0.22, blue: 0.22, alpha: 1)
        }
        iconImageView.image = icon
    }
}
