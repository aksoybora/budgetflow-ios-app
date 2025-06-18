//
//  HomeViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 3.02.2025.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI Elemanları
    let scrollView = UIScrollView()
    let contentView = UIView()
    let greetingLabel = UILabel()
    let welcomeLabel = UILabel()
    let profileButton = UIButton(type: .system)
    let balanceCardView = UIView()
    let balanceTitleLabel = UILabel()
    let balanceLabel = UILabel()
    let balanceCurrencyLabel = UILabel()
    let eyeButton = UIButton(type: .system)
    let addTransactionButton = UIButton(type: .system)
    let walletsTitleLabel = UILabel()
    var walletsCollectionView: UICollectionView!
    let transactionsTitleLabel = UILabel()
    let seeAllButton = UIButton(type: .system)
    let transactionsTableView = UITableView()
    
    // MARK: - Veriler
    var wallets: [Wallet] = []
    var selectedWalletIndex: Int = 0
    var transactions: [Transaction] = []
    var isBalanceHidden = false
    private var userName: String = "CARDHOLDER"
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupUI()
        loadUserName()
        loadWallets()
    }
    
    // MARK: - UI Kurulumu
    func setupUI() {
        // ScrollView ve contentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Greeting
        greetingLabel.font = UIFont.boldSystemFont(ofSize: 22)
        greetingLabel.textColor = .black
        greetingLabel.text = "Good morning, User"
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(greetingLabel)
        
        welcomeLabel.font = UIFont.systemFont(ofSize: 16)
        welcomeLabel.textColor = UIColor.gray
        welcomeLabel.text = "Welcome to BudgetFlow"
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(welcomeLabel)
        
        // Profile button
        profileButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
        profileButton.tintColor = UIColor.gray
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileButton)
        
        // Balance Card
        balanceCardView.backgroundColor = UIColor(red: 0.95, green: 0.90, blue: 1.0, alpha: 1.0) // Light purple
        balanceCardView.layer.cornerRadius = 24
        balanceCardView.layer.borderWidth = 2
        balanceCardView.layer.borderColor = UIColor.systemPurple.cgColor
        balanceCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(balanceCardView)
        
        balanceTitleLabel.text = "Your balance"
        balanceTitleLabel.font = UIFont.systemFont(ofSize: 16)
        balanceTitleLabel.textColor = UIColor.gray
        balanceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceCardView.addSubview(balanceTitleLabel)
        
        balanceLabel.text = "0.00"
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 36)
        balanceLabel.textColor = .black
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceCardView.addSubview(balanceLabel)
        
        balanceCurrencyLabel.font = UIFont.boldSystemFont(ofSize: 24)
        balanceCurrencyLabel.textColor = .black
        balanceCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceCardView.addSubview(balanceCurrencyLabel)
        
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = UIColor.gray
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        eyeButton.addTarget(self, action: #selector(toggleBalanceVisibility), for: .touchUpInside)
        balanceCardView.addSubview(eyeButton)
        
        // Add Transaction Button
        addTransactionButton.setTitle("Add Transaction", for: .normal)
        addTransactionButton.setTitleColor(.white, for: .normal)
        addTransactionButton.backgroundColor = UIColor.systemPurple
        addTransactionButton.layer.cornerRadius = 18
        addTransactionButton.layer.borderWidth = 0
        addTransactionButton.layer.borderColor = nil
        addTransactionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        addTransactionButton.translatesAutoresizingMaskIntoConstraints = false
        addTransactionButton.addTarget(self, action: #selector(addTransactionTapped), for: .touchUpInside)
        balanceCardView.addSubview(addTransactionButton)
        balanceCardView.bringSubviewToFront(addTransactionButton)
        
        // Wallets title
        walletsTitleLabel.text = "Your cards"
        walletsTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        walletsTitleLabel.textColor = .black
        walletsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(walletsTitleLabel)
        
        // Wallets CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        walletsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        walletsCollectionView.backgroundColor = .clear
        walletsCollectionView.showsHorizontalScrollIndicator = false
        walletsCollectionView.delegate = self
        walletsCollectionView.dataSource = self
        walletsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        walletsCollectionView.register(WalletCardCollectionViewCell.self, forCellWithReuseIdentifier: "WalletCardCell")
        contentView.addSubview(walletsCollectionView)
        
        // Transactions title
        transactionsTitleLabel.text = "Transactions"
        transactionsTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        transactionsTitleLabel.textColor = .black
        transactionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(transactionsTitleLabel)
        
        seeAllButton.setTitle("See all", for: .normal)
        seeAllButton.setTitleColor(UIColor.systemPurple, for: .normal)
        seeAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(seeAllButton)
        
        // Transactions TableView
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        transactionsTableView.backgroundColor = UIColor.white
        transactionsTableView.separatorStyle = .none
        transactionsTableView.layer.cornerRadius = 16
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(transactionsTableView)
        transactionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        
        // Otomatik yerleşim (Auto Layout)
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            profileButton.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor),
            profileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            profileButton.widthAnchor.constraint(equalToConstant: 36),
            profileButton.heightAnchor.constraint(equalToConstant: 36),
            welcomeLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            welcomeLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            
            balanceCardView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 24),
            balanceCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            balanceCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            balanceCardView.heightAnchor.constraint(equalToConstant: 140),
            
            balanceTitleLabel.topAnchor.constraint(equalTo: balanceCardView.topAnchor, constant: 20),
            balanceTitleLabel.leadingAnchor.constraint(equalTo: balanceCardView.leadingAnchor, constant: 20),
            
            balanceLabel.topAnchor.constraint(equalTo: balanceTitleLabel.bottomAnchor, constant: 8),
            balanceLabel.leadingAnchor.constraint(equalTo: balanceCardView.leadingAnchor, constant: 20),
            
            balanceCurrencyLabel.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            balanceCurrencyLabel.leadingAnchor.constraint(equalTo: balanceLabel.trailingAnchor, constant: 8),
            
            eyeButton.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            eyeButton.leadingAnchor.constraint(equalTo: balanceCurrencyLabel.trailingAnchor, constant: 12),
            eyeButton.widthAnchor.constraint(equalToConstant: 28),
            eyeButton.heightAnchor.constraint(equalToConstant: 28),
            
            addTransactionButton.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 16),
            addTransactionButton.leadingAnchor.constraint(equalTo: balanceCardView.leadingAnchor, constant: 20),
            addTransactionButton.trailingAnchor.constraint(equalTo: balanceCardView.trailingAnchor, constant: -20),
            addTransactionButton.heightAnchor.constraint(equalToConstant: 48),
            
            walletsTitleLabel.topAnchor.constraint(equalTo: balanceCardView.bottomAnchor, constant: 32),
            walletsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            walletsCollectionView.topAnchor.constraint(equalTo: walletsTitleLabel.bottomAnchor, constant: 12),
            walletsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            walletsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            walletsCollectionView.heightAnchor.constraint(equalToConstant: 160),
            
            transactionsTitleLabel.topAnchor.constraint(equalTo: walletsCollectionView.bottomAnchor, constant: 32),
            transactionsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            seeAllButton.centerYAnchor.constraint(equalTo: transactionsTitleLabel.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            transactionsTableView.topAnchor.constraint(equalTo: transactionsTitleLabel.bottomAnchor, constant: 12),
            transactionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transactionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            transactionsTableView.heightAnchor.constraint(equalToConstant: 300),
            transactionsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Wallets CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletCardCell", for: indexPath) as! WalletCardCollectionViewCell
        let wallet = wallets[indexPath.item]
        cell.configure(with: wallet, userName: userName)
        cell.detailsButton.tag = indexPath.item
        cell.detailsButton.addTarget(self, action: #selector(detailsButtonTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedWalletIndex = indexPath.item
        updateBalanceCard()
        loadTransactionsForSelectedWallet()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: 160)
    }
    
    // MARK: - Transactions TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(transactions.count, 4) // Show up to 4 transactions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
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
    
    // MARK: - Balance Card Güncelleme
    func updateBalanceCard() {
        guard wallets.indices.contains(selectedWalletIndex) else { return }
        let wallet = wallets[selectedWalletIndex]
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        if isBalanceHidden {
            balanceLabel.text = "••••••"
            balanceCurrencyLabel.text = "••••"
            eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else if let formattedBalance = formatter.string(from: NSNumber(value: wallet.balance)) {
            balanceLabel.text = formattedBalance
            balanceCurrencyLabel.text = wallet.currency
            eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
    }
    
    @objc func toggleBalanceVisibility() {
        isBalanceHidden.toggle()
        updateBalanceCard()
    }
    
    @objc func addTransactionTapped() {
        performSegue(withIdentifier: "toAddTransacitonFromHome", sender: nil)
    }
    
    @objc func detailsButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let wallet = wallets[index]
        performSegue(withIdentifier: "toWalletInfo", sender: wallet)
    }
    
    // MARK: - See All Button Action
    @objc private func seeAllButtonTapped() {
        let walletInfoVC = WalletInfoViewController()
        walletInfoVC.wallet = wallets[selectedWalletIndex]
        navigationController?.pushViewController(walletInfoVC, animated: true)
    }
    
    // MARK: - Firestore'dan Cüzdanları Yükle
    func loadWallets() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("wallets").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Cüzdanlar çekilirken hata:", error.localizedDescription)
                return
            }
            guard let documents = snapshot?.documents else { return }
            
            // First get all wallets
            var allWallets = documents.compactMap { Wallet(document: $0) }
            
            // Sort wallets in the desired order: TRY, USD, EUR
            let currencyOrder = ["TRY", "USD", "EUR"]
            self?.wallets = allWallets.sorted { wallet1, wallet2 in
                guard let index1 = currencyOrder.firstIndex(of: wallet1.currency),
                      let index2 = currencyOrder.firstIndex(of: wallet2.currency) else {
                    // If currency not in the order list, put it at the end
                    return false
                }
                return index1 < index2
            }
            
            DispatchQueue.main.async {
                self?.walletsCollectionView.reloadData()
                self?.updateBalanceCard()
                self?.loadTransactionsForSelectedWallet()
            }
        }
    }
    
    // MARK: - Firestore'dan İşlemleri Yükle
    func loadTransactionsForSelectedWallet() {
        guard let userID = Auth.auth().currentUser?.uid,
              selectedWalletIndex < wallets.count else { return }
        
        let selectedWallet = wallets[selectedWalletIndex]
        let db = Firestore.firestore()
        
        db.collection("transactions")
            .whereField("userID", isEqualTo: userID)
            .whereField("currency", isEqualTo: selectedWallet.currency)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("İşlemler çekilirken hata:", error.localizedDescription)
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                var allTransactions = documents.compactMap { doc in
                    let data = doc.data()
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
                }
                
                // Sort by date descending
                allTransactions.sort { (t1: Transaction, t2: Transaction) in 
                    t1.date.dateValue() > t2.date.dateValue() 
                }
                
                // Take only the first 4 transactions
                self?.transactions = Array(allTransactions.prefix(4))
                
                DispatchQueue.main.async {
                    self?.transactionsTableView.reloadData()
                }
            }
    }

    // MARK: - Segue ile veri aktarımı
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWalletInfo",
           let dest = segue.destination as? WalletInfoViewController,
           let wallet = sender as? Wallet {
            dest.wallet = wallet
        }
    }

    private func loadUserName() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(userID).collection("info").getDocuments { [weak self] (snapshot, error) in
            if let document = snapshot?.documents.first {
                let name = document.data()["name"] as? String ?? ""
                let surname = document.data()["surname"] as? String ?? ""
                let fullName = "\(name) \(surname)".trimmingCharacters(in: .whitespaces)
                DispatchQueue.main.async {
                    self?.userName = fullName
                    self?.greetingLabel.text = "Good morning, \(name)"
                    self?.walletsCollectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - CollectionView DataSource & Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // If there's only one wallet, center it
        if wallets.count == 1 {
            let totalWidth = collectionView.bounds.width
            let itemWidth: CGFloat = 240 // Width of a single wallet card
            let padding = (totalWidth - itemWidth) / 2
            return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        }
        // Otherwise use default left alignment
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}



