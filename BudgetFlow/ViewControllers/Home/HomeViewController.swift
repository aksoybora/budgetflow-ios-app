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
    let bellButton = UIButton(type: .system)
    let balanceCardView = UIView()
    let balanceTitleLabel = UILabel()
    let balanceLabel = UILabel()
    let eyeButton = UIButton(type: .system)
    let addTransactionButton = UIButton(type: .system)
    let walletsTitleLabel = UILabel()
    let newCardButton = UIButton(type: .system)
    var walletsCollectionView: UICollectionView!
    let transactionsTitleLabel = UILabel()
    let seeAllButton = UIButton(type: .system)
    let transactionsTableView = UITableView()
    
    // MARK: - Veriler
    var wallets: [Wallet] = []
    var selectedWalletIndex: Int = 0
    var transactions: [Transaction] = []
    var isBalanceHidden = false
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupUI()
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
        
        // Bell button
        bellButton.setImage(UIImage(systemName: "bell"), for: .normal)
        bellButton.tintColor = UIColor.gray
        bellButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bellButton)
        
        // Balance Card
        balanceCardView.backgroundColor = UIColor.white
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
        
        balanceLabel.text = "$0.00"
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 36)
        balanceLabel.textColor = .black
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceCardView.addSubview(balanceLabel)
        
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
        
        newCardButton.setTitle("+ New card", for: .normal)
        newCardButton.setTitleColor(UIColor.systemPurple, for: .normal)
        newCardButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        newCardButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(newCardButton)
        
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
            bellButton.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor),
            bellButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            bellButton.widthAnchor.constraint(equalToConstant: 36),
            bellButton.heightAnchor.constraint(equalToConstant: 36),
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
            
            eyeButton.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            eyeButton.leadingAnchor.constraint(equalTo: balanceLabel.trailingAnchor, constant: 12),
            eyeButton.widthAnchor.constraint(equalToConstant: 28),
            eyeButton.heightAnchor.constraint(equalToConstant: 28),
            
            addTransactionButton.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 16),
            addTransactionButton.leadingAnchor.constraint(equalTo: balanceCardView.leadingAnchor, constant: 20),
            addTransactionButton.trailingAnchor.constraint(equalTo: balanceCardView.trailingAnchor, constant: -20),
            addTransactionButton.heightAnchor.constraint(equalToConstant: 48),
            
            walletsTitleLabel.topAnchor.constraint(equalTo: balanceCardView.bottomAnchor, constant: 32),
            walletsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            newCardButton.centerYAnchor.constraint(equalTo: walletsTitleLabel.centerYAnchor),
            newCardButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            walletsCollectionView.topAnchor.constraint(equalTo: walletsTitleLabel.bottomAnchor, constant: 12),
            walletsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            walletsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            walletsCollectionView.heightAnchor.constraint(equalToConstant: 140),
            
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
    }
    
    // MARK: - Wallets CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletCardCell", for: indexPath) as! WalletCardCollectionViewCell
        let wallet = wallets[indexPath.item]
        let last4 = "4568" // Örnek, Firestore'dan son 4 hane alınabilir
        cell.configure(with: wallet, last4: last4)
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
        return CGSize(width: 240, height: 140)
    }
    
    // MARK: - Transactions TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(transactions.count, 5) // Sadece son 5 işlem
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
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
    
    // MARK: - Balance Card Güncelleme
    func updateBalanceCard() {
        guard wallets.indices.contains(selectedWalletIndex) else { return }
        let wallet = wallets[selectedWalletIndex]
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        if isBalanceHidden {
            balanceLabel.text = "••••••"
            eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else if let formattedBalance = formatter.string(from: NSNumber(value: wallet.balance)) {
            balanceLabel.text = formattedBalance
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
    @objc func seeAllButtonTapped() {
        performSegue(withIdentifier: "toTransactionsVC", sender: nil)
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
            self?.wallets = documents.compactMap { Wallet(document: $0) }
            DispatchQueue.main.async {
                self?.walletsCollectionView.reloadData()
                self?.updateBalanceCard()
                self?.loadTransactionsForSelectedWallet()
            }
        }
    }
    
    // MARK: - Firestore'dan İşlemleri Yükle
    func loadTransactionsForSelectedWallet() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("transactions")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("İşlemler çekilirken hata:", error.localizedDescription)
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self?.transactions = documents.compactMap { doc in
                    let data = doc.data()
                    guard let title = data["title"] as? String,
                          let description = data["description"] as? String,
                          let amount = data["amount"] as? String,
                          let currency = data["currency"] as? String,
                          let category = data["category"] as? String,
                          let type = data["type"] as? String,
                          let date = data["date"] as? Timestamp,
                          let walletID = data["walletID"] as? String else { return nil }
                    
                    return Transaction(
                        title: title,
                        description: description,
                        amount: amount,
                        currency: currency,
                        category: category,
                        type: type,
                        date: date,
                        walletID: walletID
                    )
                }.sorted(by: { $0.date.dateValue() > $1.date.dateValue() })
                
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
}


