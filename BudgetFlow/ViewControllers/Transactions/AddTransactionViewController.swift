//
//  TransactionsViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 3.02.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - AddTransactionViewController
// Bu sınıf, yeni bir işlem eklemek için kullanılan ekranı yönetir
class AddTransactionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - UI Elemanları
    // Ekrandaki tüm UI bileşenleri burada tanımlanır
    
    // Başlık etiketi ve metin alanı
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Title"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Açıklama etiketi ve metin alanı
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Description"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // İşlem tipi etiketi ve segment kontrolü
    private let transactionTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Transaction Type"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let transactionTypeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Income", "Expense"])
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    // Kategori etiketi ve seçici
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Category"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    // Tutar etiketi ve metin alanı
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "Amount"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Amount"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Para birimi etiketi ve seçici
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "Currency"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let currencyPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    // Tarih etiketi ve seçici
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    // Fotoğraf etiketi ve butonu
    private let photoLabel: UILabel = {
        let label = UILabel()
        label.text = "Photo"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let photoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tap to select", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Özellikler
    // Seçenekler ve seçili değerler
    let currencyOptions = ["TRY", "USD", "EUR"] // Para birimi seçenekleri
    let categoryOptions = ["Food", "Transportation", "Electricity", "Entertainment", "Accommodation", "Education", "Technology", "Salary", "Other"] // Kategori seçenekleri
    var selectedCurrency: String? // Seçili para birimi
    var selectedCategory: String? // Seçili kategori
    var selectedTransactionType: String? // Seçili işlem tipi
    
    // MARK: - Yaşam Döngüsü Metodları
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // UI elemanlarını ayarla
        setupNavigationBar() // Navigasyon çubuğunu ayarla
        setupPickers() // Seçicileri ayarla
    }
    
    // MARK: - Kurulum Metodları
    // UI elemanlarını oluştur ve yerleştir
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Alt görünümleri ekle
        view.addSubview(titleLabel)
        view.addSubview(titleTextField)
        view.addSubview(descriptionLabel)
        view.addSubview(descriptionTextField)
        view.addSubview(transactionTypeLabel)
        view.addSubview(transactionTypeSegment)
        view.addSubview(categoryLabel)
        view.addSubview(categoryPicker)
        view.addSubview(amountLabel)
        view.addSubview(amountTextField)
        view.addSubview(currencyLabel)
        view.addSubview(currencyPicker)
        view.addSubview(dateLabel)
        view.addSubview(datePicker)
        view.addSubview(photoLabel)
        view.addSubview(photoButton)
        
        // Kısıtlamaları ayarla
        NSLayoutConstraint.activate([
            // Başlık etiketi ve metin alanı kısıtlamaları
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Açıklama etiketi ve metin alanı kısıtlamaları
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 15),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            descriptionTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            descriptionTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // İşlem tipi etiketi ve segment kontrolü kısıtlamaları
            transactionTypeLabel.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 15),
            transactionTypeLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            transactionTypeLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            transactionTypeSegment.topAnchor.constraint(equalTo: transactionTypeLabel.bottomAnchor, constant: 8),
            transactionTypeSegment.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            transactionTypeSegment.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            transactionTypeSegment.heightAnchor.constraint(equalToConstant: 40),
            
            // Kategori etiketi ve seçici kısıtlamaları
            categoryLabel.topAnchor.constraint(equalTo: transactionTypeSegment.bottomAnchor, constant: 15),
            categoryLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            categoryLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            categoryPicker.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            categoryPicker.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            categoryPicker.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            categoryPicker.heightAnchor.constraint(equalToConstant: 100),
            
            // Tutar etiketi ve metin alanı kısıtlamaları
            amountLabel.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 15),
            amountLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            amountTextField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            amountTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            amountTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            amountTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Para birimi etiketi ve seçici kısıtlamaları
            currencyLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 15),
            currencyLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            currencyLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            currencyPicker.topAnchor.constraint(equalTo: currencyLabel.bottomAnchor, constant: 8),
            currencyPicker.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            currencyPicker.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            currencyPicker.heightAnchor.constraint(equalToConstant: 100),
            
            // Tarih etiketi ve seçici kısıtlamaları
            dateLabel.topAnchor.constraint(equalTo: currencyPicker.bottomAnchor, constant: 15),
            dateLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            dateLabel.widthAnchor.constraint(equalToConstant: 100),

            datePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            datePicker.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 40),
            datePicker.widthAnchor.constraint(equalToConstant: 200),

            // Fotoğraf etiketi ve butonu kısıtlamaları
            photoLabel.topAnchor.constraint(equalTo: dateLabel.topAnchor),
            photoLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            photoLabel.widthAnchor.constraint(equalToConstant: 100),

            photoButton.topAnchor.constraint(equalTo: photoLabel.bottomAnchor, constant: 5),
            photoButton.trailingAnchor.constraint(equalTo: photoLabel.trailingAnchor),
            photoButton.widthAnchor.constraint(equalToConstant: 100),
            photoButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Aksiyonları ekle
        transactionTypeSegment.addTarget(self, action: #selector(transactionTypeChanged(_:)), for: .valueChanged)
        photoButton.addTarget(self, action: #selector(tapToSelectButton(_:)), for: .touchUpInside)
    }
    
    // Navigasyon çubuğunu ayarla
    private func setupNavigationBar() {
        // Navigasyon çubuğu başlığı
        let titleLabel = UILabel()
        titleLabel.text = "Add Transaction"
        titleLabel.textColor = .black
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
        // Kaydet butonu ekle
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = .systemGreen
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    // Seçicileri ayarla
    private func setupPickers() {
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        // Varsayılan seçimleri ayarla
        currencyPicker.selectRow(0, inComponent: 0, animated: false)
        categoryPicker.selectRow(0, inComponent: 0, animated: false)
        
        selectedCurrency = currencyOptions[0]
        selectedCategory = categoryOptions[0]
        selectedTransactionType = "Income"
    }
    
    // MARK: - Aksiyonlar
    // İşlem tipi değiştiğinde çağrılır
    @objc private func transactionTypeChanged(_ sender: UISegmentedControl) {
        selectedTransactionType = sender.selectedSegmentIndex == 0 ? "Income" : "Expense"
            }
    
    // Fotoğraf seçme butonuna tıklandığında çağrılır
    @objc private func tapToSelectButton(_ sender: Any) {
        performSegue(withIdentifier: "toSelectPhotoVC", sender: nil)
    }
    
    // Kaydet butonuna tıklandığında çağrılır
    @objc private func saveButtonTapped() {
        // İşlem bilgilerini kontrol et
        guard let title = titleTextField.text, !title.isEmpty,
              let description = descriptionTextField.text, !description.isEmpty,
              let amountText = amountTextField.text, !amountText.isEmpty,
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
            }
        }
    }

    // MARK: - PickerView Metodları
    // Seçici sütun sayısı
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Seçici satır sayısı
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == currencyPicker ? currencyOptions.count : categoryOptions.count
    }
    
    // Seçici satır başlıkları
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == currencyPicker ? currencyOptions[row] : categoryOptions[row]
    }
    
    // Seçici değer değiştiğinde çağrılır
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == currencyPicker {
            selectedCurrency = currencyOptions[row]
        } else if pickerView == categoryPicker {
            selectedCategory = categoryOptions[row]
        }
    }
    
    // MARK: - Yardımcı Metodlar
    // Cüzdan bakiyesini güncelle
    func updateWalletBalance(userID: String, currency: String, changeAmount: Double) {
        let db = Firestore.firestore()
        let walletsRef = db.collection("users").document(userID).collection("wallets")

        // First check if wallet exists
        walletsRef.whereField("currency", isEqualTo: currency).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Cüzdan sorgulama hatası: \(error.localizedDescription)")
                return
            }

            if let document = snapshot?.documents.first {
                // Mevcut cüzdanı güncelle
                let docRef = walletsRef.document(document.documentID)
                docRef.updateData([
                    "balance": FieldValue.increment(changeAmount)
                ]) { error in
                    if let error = error {
                        print("Cüzdan güncellenemedi: \(error.localizedDescription)")
                    } else {
                        print("Cüzdan bakiyesi güncellendi.")
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("WalletsDidUpdate"), object: nil)
                        }
                    }
                }
            } else {
                // Yeni cüzdan oluştur
                let newWalletData: [String: Any] = [
                    "currency": currency,
                    "balance": changeAmount,
                    "userID": userID,
                    "createdAt": FieldValue.serverTimestamp()
                ]
                
                walletsRef.addDocument(data: newWalletData) { error in
                    if let error = error {
                        print("Yeni cüzdan oluşturulamadı: \(error.localizedDescription)")
                    } else {
                        print("Yeni cüzdan oluşturuldu.")
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("WalletsDidUpdate"), object: nil)
                        }
                    }
                }
            }
        }
    }
}
