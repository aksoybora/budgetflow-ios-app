//
//  TransactionsViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 21.02.2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var transactionsTableView: UITableView!
    let titleLabel = UILabel()
    var transactions: [Transaction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation Bar'a "+" butonu ekle
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        titleLabel.text = "Transactions"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.sizeToFit()
        navigationController?.navigationBar.topItem?.titleView = titleLabel
            
        // TableView ayarları
        transactionsTableView.dataSource = self
        transactionsTableView.delegate = self
        
        // Transaction'ları yükle
        loadTransactions()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTransactions() // Transaction'ları yeniden yükle
    }

    
    
    @objc func addButtonClicked(){
        performSegue(withIdentifier: "toAddTransactionVC", sender: nil)
    }
    
    
    
    func loadTransactions() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("transactions")
            .whereField("userID", isEqualTo: userID) // Sadece mevcut kullanıcının transaction'larını çek
            .order(by: "date", descending: true) // En yeni işlem en üstte
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.transactions = querySnapshot?.documents.compactMap { document in
                        let data = document.data()
                        return Transaction(
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            amount: data["amount"] as? String ?? "",
                            currency: data["currency"] as? String ?? "",
                            category: data["category"] as? String ?? "",
                            type: data["type"] as? String ?? "",
                            date: data["date"] as? Timestamp ?? Timestamp()
                        )
                    } ?? []
                    self.transactionsTableView.reloadData()
                }
            }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let transaction = transactions[indexPath.row]
        
        // Timestamp'i String'e dönüştür
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: transaction.date.dateValue())
        
        // Hücre içeriğini oluştur
        var content = cell.defaultContentConfiguration()
        content.text = transaction.title
        content.secondaryText = "\(transaction.amount) \(transaction.currency) - \(dateString)"
        
        // Gelir (Income) veya Gider (Expense) durumuna göre renk ayarla
        if transaction.type == "Income" {
            //content.textProperties.color = .systemGreen // Başlık yeşil
            content.secondaryTextProperties.color = UIColor(hex: "#3E7B27") // Alt metin yeşil
            cell.backgroundColor = UIColor(hex: "#A7D477", alpha: 0.1) // Açık yeşil arka plan
        } else if transaction.type == "Expense" {
            //content.textProperties.color = .systemRed // Başlık kırmızı
            content.secondaryTextProperties.color = .systemRed // Alt metin kırmızı
            cell.backgroundColor = UIColor(hex: "#F44336", alpha: 0.1) // Açık kırmızı arka plan
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
}
