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

// Cüzdan detaylarını gösteren ViewController
class WalletInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Veriler
    var wallet: Wallet? // Cüzdan bilgisi
    var transactions: [Transaction] = [] // İşlemler
    private var userName: String = "" // Kullanıcı adı
    
    // MARK: - UI Elemanları
    let scrollView = UIScrollView() // Kaydırma görünümü
    let contentView = UIView() // İçerik görünümü
    let walletCardView = UIView() // Cüzdan kartı
    let walletNameLabel = UILabel() // Cüzdan adı
    let balanceLabel = UILabel() // Bakiye
    let currencyLabel = UILabel() // Para birimi
    let cardLogoImageView = UIImageView() // Kart logosu
    let cardholderNameLabel = UILabel() // Kart sahibi adı
    let transactionsTitleLabel = UILabel() // İşlemler başlığı
    let transactionsTableView = UITableView() // İşlemler tablosu

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        loadUserName() // Kullanıcı adını yükle
        // Initialize and add all views to hierarchy
        setupViewHierarchy() // Görünüm hiyerarşisini ayarla
        // Set up constraints and styling
        setupUI() // UI ayarlarını yap
        updateWalletInfo() // Cüzdan bilgilerini güncelle
        loadTransactionsForWallet() // İşlemleri yükle
    }
    
    private func setupViewHierarchy() {
        // Add ScrollView to main view
        view.addSubview(scrollView) // ScrollView'ı ana görünüme ekle
        
        // Add ContentView to ScrollView
        scrollView.addSubview(contentView) // ContentView'ı ScrollView'a ekle
        
        // Add WalletCardView to ContentView
        contentView.addSubview(walletCardView) // WalletCardView'ı ContentView'a ekle
        
        // Add Card Logo
        cardLogoImageView.contentMode = .scaleAspectFit // Kart logosunu ayarla
        walletCardView.addSubview(cardLogoImageView) // Kart logosunu WalletCardView'a ekle
        
        // Add labels to WalletCardView
        walletCardView.addSubview(walletNameLabel) // Cüzdan adı etiketini ekle
        walletCardView.addSubview(balanceLabel) // Bakiye etiketini ekle
        walletCardView.addSubview(currencyLabel) // Para birimi etiketini ekle
        walletCardView.addSubview(cardholderNameLabel) // Kart sahibi adı etiketini ekle
        
        // Add Transactions title and TableView to ContentView
        contentView.addSubview(transactionsTitleLabel) // İşlemler başlığını ekle
        contentView.addSubview(transactionsTableView) // İşlemler tablosunu ekle
        
        // Configure TableView
        transactionsTableView.delegate = self // TableView delegesini ayarla
        transactionsTableView.dataSource = self // TableView veri kaynağını ayarla
        transactionsTableView.backgroundColor = .clear // Arka planı temizle
        transactionsTableView.separatorStyle = .none // Ayırıcı çizgileri kaldır
        transactionsTableView.register(TransactionInfoTableViewCell.self, forCellReuseIdentifier: "TransactionInfoCell") // Hücre kaydını yap
        transactionsTableView.showsVerticalScrollIndicator = false // Dikey kaydırma göstergesini gizle
        transactionsTableView.isScrollEnabled = false // Tablo kaydırmayı devre dışı bırak, scroll view yönetsin
        
        // Set up translatesAutoresizingMaskIntoConstraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        walletCardView.translatesAutoresizingMaskIntoConstraints = false
        cardLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        walletNameLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        cardholderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        transactionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up initial text
        transactionsTitleLabel.text = "Transactions" // İşlemler başlığını ayarla
    }
    
    private func setupUI() {
        // Set up constraints
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor),
            
            // WalletCardView constraints
            walletCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            walletCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            walletCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            walletCardView.heightAnchor.constraint(equalToConstant: 160),
            
            // Card logo
            cardLogoImageView.topAnchor.constraint(equalTo: walletCardView.topAnchor, constant: 16),
            cardLogoImageView.trailingAnchor.constraint(equalTo: walletCardView.trailingAnchor, constant: -16),
            cardLogoImageView.widthAnchor.constraint(equalToConstant: 32),
            cardLogoImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // Wallet name label constraints
            walletNameLabel.topAnchor.constraint(equalTo: walletCardView.topAnchor, constant: 16),
            walletNameLabel.leadingAnchor.constraint(equalTo: walletCardView.leadingAnchor, constant: 16),
            
            // Balance label constraints
            balanceLabel.topAnchor.constraint(equalTo: walletNameLabel.bottomAnchor, constant: 8),
            balanceLabel.leadingAnchor.constraint(equalTo: walletCardView.leadingAnchor, constant: 16),
            
            // Currency label constraints
            currencyLabel.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            currencyLabel.leadingAnchor.constraint(equalTo: balanceLabel.trailingAnchor, constant: 8),
            
            // Cardholder name constraints
            cardholderNameLabel.leadingAnchor.constraint(equalTo: walletCardView.leadingAnchor, constant: 16),
            cardholderNameLabel.bottomAnchor.constraint(equalTo: walletCardView.bottomAnchor, constant: -16),
            
            // Transactions title constraints
            transactionsTitleLabel.topAnchor.constraint(equalTo: walletCardView.bottomAnchor, constant: 24),
            transactionsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // TransactionsTableView constraints
            transactionsTableView.topAnchor.constraint(equalTo: transactionsTitleLabel.bottomAnchor, constant: 16),
            transactionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transactionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            transactionsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        // Style the wallet card view based on currency
        if let wallet = wallet {
            switch wallet.currency {
            case "TRY":
                cardLogoImageView.image = UIImage(systemName: "turkishlirasign.circle.fill")
                walletCardView.backgroundColor = UIColor(red: 0.91, green: 0.97, blue: 0.89, alpha: 1) // Açık yeşil
                let walletColor = UIColor(red: 0.22, green: 0.65, blue: 0.32, alpha: 1) // Koyu yeşil
                walletCardView.layer.borderColor = walletColor.cgColor
                walletNameLabel.textColor = walletColor
                balanceLabel.textColor = walletColor
                currencyLabel.textColor = walletColor
                cardLogoImageView.tintColor = walletColor
            case "USD":
                cardLogoImageView.image = UIImage(systemName: "dollarsign.circle.fill")
                walletCardView.backgroundColor = UIColor(red: 0.89, green: 0.94, blue: 0.98, alpha: 1) // Açık mavi
                let walletColor = UIColor(red: 0.13, green: 0.36, blue: 0.75, alpha: 1) // Koyu mavi
                walletCardView.layer.borderColor = walletColor.cgColor
                walletNameLabel.textColor = walletColor
                balanceLabel.textColor = walletColor
                currencyLabel.textColor = walletColor
                cardLogoImageView.tintColor = walletColor
            case "EUR":
                cardLogoImageView.image = UIImage(systemName: "eurosign.circle.fill")
                walletCardView.backgroundColor = UIColor(red: 1.0, green: 0.96, blue: 0.86, alpha: 1) // Açık sarı
                let walletColor = UIColor(red: 0.98, green: 0.60, blue: 0.18, alpha: 1) // Koyu turuncu
                walletCardView.layer.borderColor = walletColor.cgColor
                walletNameLabel.textColor = walletColor
                balanceLabel.textColor = walletColor
                currencyLabel.textColor = walletColor
                cardLogoImageView.tintColor = walletColor
            default:
                cardLogoImageView.image = UIImage(systemName: "creditcard.fill")
                walletCardView.backgroundColor = UIColor(white: 0.97, alpha: 1)
                let walletColor = UIColor.systemPurple
                walletCardView.layer.borderColor = walletColor.cgColor
                walletNameLabel.textColor = walletColor
                balanceLabel.textColor = walletColor
                currencyLabel.textColor = walletColor
                cardLogoImageView.tintColor = walletColor
            }
        }
        
        walletCardView.layer.cornerRadius = 16
        walletCardView.layer.borderWidth = 2
        walletCardView.clipsToBounds = true
        
        // Configure labels
        walletNameLabel.font = .systemFont(ofSize: 18, weight: .medium)
        balanceLabel.font = .systemFont(ofSize: 32, weight: .bold)
        currencyLabel.font = .systemFont(ofSize: 24, weight: .bold)
        cardholderNameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        cardholderNameLabel.textColor = .gray
        
        // Configure TableView appearance
        transactionsTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        transactionsTitleLabel.textColor = .black
        
        // Configure table view
        transactionsTableView.backgroundColor = .clear
        transactionsTableView.separatorStyle = .none
        transactionsTableView.showsVerticalScrollIndicator = false
    }
    
    private func loadUserName() {
        // Kullanıcı adını Firestore'dan çek
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(userID).collection("info").getDocuments { [weak self] (snapshot, error) in
            if let document = snapshot?.documents.first {
                let name = document.data()["name"] as? String ?? ""
                let surname = document.data()["surname"] as? String ?? ""
                let fullName = "\(name) \(surname)".trimmingCharacters(in: .whitespaces)
                DispatchQueue.main.async {
                    self?.userName = fullName
                    self?.updateWalletInfo()
                }
            }
        }
    }
    
    // MARK: - Wallet Bilgisi Güncelle
    func updateWalletInfo() {
        guard let wallet = wallet else { return }
        walletNameLabel.text = "\(wallet.currency) Wallet"
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        if let formattedBalance = formatter.string(from: NSNumber(value: wallet.balance)) {
            balanceLabel.text = formattedBalance
        }
        currencyLabel.text = wallet.currency
        cardholderNameLabel.text = userName.uppercased()
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
                    
                    // Sort transactions by date (newest first)
                    self?.transactions.sort { $0.date.dateValue() > $1.date.dateValue() }
                    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionInfoCell", for: indexPath)
        let transaction = transactions[indexPath.row]
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: transaction.date.dateValue())
        
        // Configure cell content
        var content = cell.defaultContentConfiguration()
        content.text = transaction.title
        content.secondaryText = "\(transaction.amount) \(transaction.currency) - \(dateString)"
        
        // Set text color based on transaction type
        if transaction.type == "Income" {
            content.secondaryTextProperties.color = UIColor(hex: "#3E7B27")
            cell.backgroundColor = UIColor(hex: "#A7D477", alpha: 0.2)
        } else if transaction.type == "Expense" {
            content.secondaryTextProperties.color = .systemRed
            cell.backgroundColor = UIColor(hex: "#F44336", alpha: 0.2)
        }
        
        // Configure icon based on transaction description
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image: UIImage?
        
        switch transaction.title.lowercased() {
        case let title where title.contains("coffee"):
            image = UIImage(systemName: "cup.and.saucer.fill", withConfiguration: imageConfig)
        case let title where title.contains("transport") || title.contains("uber"):
            image = UIImage(systemName: "car.fill", withConfiguration: imageConfig)
        case let title where title.contains("shopping") || title.contains("market"):
            image = UIImage(systemName: "cart.fill", withConfiguration: imageConfig)
        case let title where title.contains("bill") || title.contains("utilities"):
            image = UIImage(systemName: "doc.text.fill", withConfiguration: imageConfig)
        case let title where title.contains("entertainment") || title.contains("movie"):
            image = UIImage(systemName: "tv.fill", withConfiguration: imageConfig)
        case let title where title.contains("health") || title.contains("medical"):
            image = UIImage(systemName: "heart.fill", withConfiguration: imageConfig)
        case let title where title.contains("education") || title.contains("school"):
            image = UIImage(systemName: "book.fill", withConfiguration: imageConfig)
        case let title where title.contains("salary") || title.contains("income"):
            image = UIImage(systemName: "dollarsign.circle.fill", withConfiguration: imageConfig)
        case let title where title.contains("food") || title.contains("restaurant"):
            image = UIImage(systemName: "fork.knife", withConfiguration: imageConfig)
        case let title where title.contains("tech") || title.contains("technology"):
            image = UIImage(systemName: "laptopcomputer", withConfiguration: imageConfig)
        case let title where title.contains("app") || title.contains("software"):
            image = UIImage(systemName: "app.fill", withConfiguration: imageConfig)
        case let title where title.contains("stay") || title.contains("hotel"):
            image = UIImage(systemName: "house.fill", withConfiguration: imageConfig)
        case let title where title.contains("rent") || title.contains("housing"):
            image = UIImage(systemName: "building.2.fill", withConfiguration: imageConfig)
        case let title where title.contains("groceries"):
            image = UIImage(systemName: "basket.fill", withConfiguration: imageConfig)
        default:
            image = UIImage(systemName: "banknote.fill", withConfiguration: imageConfig)
        }
        
        content.image = image
        content.imageProperties.tintColor = transaction.type == "Income" ? UIColor(hex: "#3E7B27") : .systemRed
        content.imageProperties.maximumSize = CGSize(width: 32, height: 32)
        content.imageToTextPadding = 16
        
        cell.contentConfiguration = content
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // Match HomeViewController cell height
    }

    // MARK: - Segue ile veri aktarımı
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWalletInfo",
           let dest = segue.destination as? WalletInfoViewController,
           let wallet = sender as? Wallet {
            dest.wallet = wallet
        }
    }
}
