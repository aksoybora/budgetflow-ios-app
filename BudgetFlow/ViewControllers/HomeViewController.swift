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
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as! WalletTableViewCell
        
        let wallet = wallets[indexPath.row]
        
        // Configure cell with wallet data
        cell.configure(with: wallet)
        
        // Set background gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = cell.contentView.bounds
        gradientLayer.cornerRadius = 16
        
        let colors: [CGColor]
        switch wallet.currency {
        case "TRY":
            colors = [
                UIColor(hex: "#ecf6e2", alpha: 1).cgColor,
                UIColor(hex: "#d4e9c5", alpha: 1).cgColor
            ]
        case "USD":
            colors = [
                UIColor(hex: "#e1effa", alpha: 1).cgColor,
                UIColor(hex: "#c5dff0", alpha: 1).cgColor
            ]
        case "EUR":
            colors = [
                UIColor(hex: "#fef0d8", alpha: 1).cgColor,
                UIColor(hex: "#f5d9b0", alpha: 1).cgColor
            ]
        default:
            colors = [
                UIColor(hex: "#f5f5f5", alpha: 1).cgColor,
                UIColor(hex: "#e5e5e5", alpha: 1).cgColor
            ]
        }
        
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        // Remove any existing gradient layers
        cell.contentView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        cell.contentView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Set text colors based on currency
        let textColor: UIColor
        switch wallet.currency {
        case "TRY":
            textColor = UIColor(hex: "#245320")
        case "USD":
            textColor = UIColor(hex: "#194385")
        case "EUR":
            textColor = UIColor(hex: "#e37701")
        default:
            textColor = .darkGray
        }
        
        cell.currencyLabel.textColor = textColor
        cell.balanceLabel.textColor = textColor
        cell.walletIconImageView.tintColor = textColor
        
        return cell
    }
    
    
    
    @objc func walletsDidUpdate() {
        loadWallets()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}


