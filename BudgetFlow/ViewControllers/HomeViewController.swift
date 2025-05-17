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



class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var walletsTableView: UITableView!
    
    var wallets: [Wallet] = []  // Cüzdanları tutacak dizi
    let titleLabel = UILabel() // Navigation bardaki başlık

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView ayarları
        walletsTableView.delegate = self
        walletsTableView.dataSource = self
        
        titleLabel.text = "Home"
        //titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        loadWallets()  // 🔥 Verileri yükle
        NotificationCenter.default.addObserver(self, selector: #selector(walletsDidUpdate), name: Notification.Name("WalletsDidUpdate"), object: nil)
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = titleLabel
    }

    
    
    
    // MARK: - UITableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }
    
    

    
    func loadWallets() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Kullanıcı giriş yapmamış")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("wallets").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Cüzdanlar çekilirken hata:", error.localizedDescription)
                return
            }

            // Veriler geldiğinde log'la
            if let documents = snapshot?.documents {
                for document in documents {
                    print("Document data: \(document.data())") // Her bir dökümanın verilerini yazdırıyoruz
                }
            }
            
            // Veriyi işle
            guard let documents = snapshot?.documents else {
                print("Cüzdan bulunamadı")
                return
            }
            
            // Wallet modelini oluştur ve diziyi güncelle
            self?.wallets = documents.compactMap { Wallet(document: $0) }
            print("Çekilen cüzdanlar:", self?.wallets ?? [])
            
            DispatchQueue.main.async {
                self?.walletsTableView.reloadData()
            }
        }
    }

    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as! WalletTableViewCell  // Storyboard'daki Cell Identifier'ı "WalletCell" yapın
        
        let wallet = wallets[indexPath.row]
        //cell.backgroundColor = UIColor(hex: "#1B56FD", alpha: 0.2)
        cell.backgroundColor = .white
        //cell.layer.cornerRadius
        cell.layer.shadowColor = UIColor.black.cgColor
        //cell.layer.shadowOpacity = 0.1
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        //cell.layer.shadowRadius = 4
        cell.layer.masksToBounds = false
        tableView.rowHeight = 100
        cell.currencyLabel.text = wallet.currency
        cell.balanceLabel.text = "\(wallet.balance)"  // Formatlı gösterim için String(format: "%.2f", wallet.balance) de kullanabilirsiniz
        
        let backgroundColors: [UIColor] = [
            UIColor(hex: "#ecf6e2", alpha: 1),
            UIColor(hex: "#e1effa", alpha: 1),
            UIColor(hex: "#fef0d8", alpha: 1),
        ]
        
        cell.contentView.backgroundColor = backgroundColors[indexPath.row % backgroundColors.count]
        let textColors: [UIColor] = [
            UIColor(hex: "#245320"), // Mavi ton
            UIColor(hex: "#194385"), // Yeşil ton
            UIColor(hex: "#e37701")  // Turuncu ton
        ]

        let textColor = textColors[indexPath.row % textColors.count]
        cell.currencyLabel.textColor = textColor
        cell.balanceLabel.textColor = textColor
        cell.currencyLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        cell.balanceLabel.font = UIFont.boldSystemFont(ofSize: 24)

        
        return cell
    }
    
    
    
    @objc func walletsDidUpdate() {
        loadWallets()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}


