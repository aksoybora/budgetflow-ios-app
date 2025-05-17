//
//  TransactionsViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 3.02.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class AddTransactionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var transactionTypeSegment: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    
    let currencyOptions = ["TRY", "USD", "EUR"]
    let categoryOptions = ["Food", "Transportation", "Electricity", "Entertainment", "Accommodation", "Education", "Technology", "Salary", "Other"]
    var selectedCurrency: String?
    var selectedCategory: String?
    var selectedTransactionType: String?
    let titleLabel = UILabel()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currencyPicker.delegate = self
        currencyPicker.dataSource = self
            
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        currencyPicker.selectRow(0, inComponent: 0, animated: false)
        categoryPicker.selectRow(0, inComponent: 0, animated: false)
        
        selectedCurrency = currencyOptions[0]
        selectedCategory = categoryOptions[0]
        
        transactionTypeSegment.selectedSegmentIndex = 0
        selectedTransactionType = "Income"
        
        titleLabel.text = "Add Transaction"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == currencyPicker ? currencyOptions.count : categoryOptions.count
    }

    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == currencyPicker ? currencyOptions[row] : categoryOptions[row]
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == currencyPicker {
            selectedCurrency = currencyOptions[row]
        } else if pickerView == categoryPicker {
            selectedCategory = categoryOptions[row]
        }
    }

    
    
    @IBAction func transactionTypeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
                selectedTransactionType = "Income"
            } else {
                selectedTransactionType = "Expense"
            }
    }
    
    
    
    @IBAction func tapToSelectButton(_ sender: Any) {
        performSegue(withIdentifier: "toSelectPhotoVC", sender: nil)
    }
    
    
    
    @IBAction func saveTheTransactionButton(_ sender: Any) {
        // İşlem bilgilerini al
        guard let title = titleText.text, !title.isEmpty,
              let description = descriptionText.text, !description.isEmpty,
              let amountText = amountText.text, !amountText.isEmpty,
              let amount = Double(amountText),
              let currency = selectedCurrency,
              let transactionType = selectedTransactionType,
              let userID = Auth.auth().currentUser?.uid else {
            print("Eksik bilgi veya kullanıcı girişi yok.")
            return
        }

        // Firestore'a işlemi kaydet
        let transactionData: [String: Any] = [
            "title": title,
            "description": description,
            "amount": amount,
            "currency": currency,
            "type": transactionType,
            "category": selectedCategory ?? "Other",
            "date": Timestamp(date: Date()),
            "userID": userID
        ]

        let db = Firestore.firestore()
        db.collection("transactions").addDocument(data: transactionData) { error in
            if let error = error {
                print("Error saving transaction: \(error)")
            } else {
                // İşlem başarılıysa cüzdanı güncelle
                let balanceChange = (transactionType == "Income") ? amount : -amount
                self.updateWalletBalance(userID: userID, currency: currency, changeAmount: balanceChange)
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: Notification.Name("WalletsDidUpdate"), object: nil)

            }
        }
    }

    
    
    func updateWalletBalance(userID: String, currency: String, changeAmount: Double) {
        let db = Firestore.firestore()
        let walletsRef = db.collection("users").document(userID).collection("wallets")

        // Cüzdanı currency'ye göre ara
        walletsRef.whereField("currency", isEqualTo: currency).getDocuments { snapshot, error in
            if let error = error {
                print("Cüzdan sorgulama hatası: \(error.localizedDescription)")
                return
            }

            if let document = snapshot?.documents.first {
                // Cüzdan bulundu, güncelle
                let docRef = walletsRef.document(document.documentID)
                docRef.updateData([
                    "balance": FieldValue.increment(changeAmount)
                ]) { error in
                    if let error = error {
                        print("Cüzdan güncellenemedi: \(error.localizedDescription)")
                    } else {
                        print("Cüzdan bakiyesi güncellendi.")
                    }
                }
            } else {
                // Cüzdan yoksa oluştur
                walletsRef.addDocument(data: [
                    "currency": currency,
                    "balance": changeAmount,
                    "userID": userID
                ]) { error in
                    if let error = error {
                        print("Yeni cüzdan oluşturulamadı: \(error.localizedDescription)")
                    } else {
                        print("Yeni cüzdan oluşturuldu.")
                    }
                }
            }
        }
    }
    
    /*
    // Cüzdan oluştruma ve kontrol etme
    func createOrUpdateWallet(userID: String, currency: String, initialBalance: Double) {
        let db = Firestore.firestore()
        let walletRef = db.collection("users").document(userID).collection("wallets").document(currency)
        
        db.runTransaction { (transaction, errorPointer) -> Any? in
            let walletDocument: DocumentSnapshot
            do {
                try walletDocument = transaction.getDocument(walletRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
            
            if walletDocument.exists {
                // Cüzdan zaten varsa, bakiyeyi güncelle
                guard let currentBalance = walletDocument.data()?["balance"] as? Double else {
                    return nil
                }
                let newBalance = currentBalance + initialBalance
                transaction.updateData(["balance": newBalance], forDocument: walletRef)
            } else {
                // Cüzdan yoksa, yeni bir cüzdan oluştur
                transaction.setData(["currency": currency, "balance": initialBalance], forDocument: walletRef)
            }
            return nil
        } completion: { (_, error) in
            if let error = error {
                print("Error creating/updating wallet: \(error)")
            } else {
                print("Wallet created/updated successfully")
            }
        }
    } */
    
}
