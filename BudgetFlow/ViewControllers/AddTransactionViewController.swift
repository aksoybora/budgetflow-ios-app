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
    
    
    let currencyOptions = ["TRY ₺", "USD ＄", "EUR €"]
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
        
        // Initially make the first pickers & selector selected
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
        guard let title = titleText.text, !title.isEmpty,
              let description = descriptionText.text, !description.isEmpty,
              let amount = amountText.text, !amount.isEmpty else {
            
            let alert = UIAlertController(title: "Error!", message: "Please fill in the blank spaces.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let selectedDate = datePicker.date
        let timestamp = Timestamp(date: selectedDate) // Tarihi Timestamp olarak kaydet
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        let transactionData: [String: Any] = [
            "title": title,
            "description": description,
            "amount": amount,
            "currency": selectedCurrency ?? "TRY ₺",
            "category": selectedCategory ?? "Other",
            "type": selectedTransactionType ?? "Expense",
            "date": timestamp, // Timestamp olarak kaydet
            "userID": userID // Kullanıcı kimliğini ekle
        ]
        
        let db = Firestore.firestore()
        db.collection("transactions").addDocument(data: transactionData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                let alert = UIAlertController(title: "Error", message: "Failed to save transaction.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Transaction saved successfully")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
