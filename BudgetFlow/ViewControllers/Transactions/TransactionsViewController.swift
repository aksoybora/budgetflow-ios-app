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
    var filteredTransactions: [Transaction] = []
    let filterSegmentedControl = UISegmentedControl(items: ["All", "Income", "Expense"])
    var datePicker: UIDatePicker?
    var filterButton: UIButton?
    var selectedDateFilter: Date?
    var selectedDateRange: (Date, Date)?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation Bar'a "+" butonu ekle
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        // Başlık ayarları
        titleLabel.text = "Transactions"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.sizeToFit()
        navigationController?.navigationBar.topItem?.titleView = titleLabel
        
        // Filtreleme kontrollerini ayarla
        setupFilterControls()
            
        // TableView ayarları
        transactionsTableView.dataSource = self
        transactionsTableView.delegate = self
        
        // İşlemleri yükle
        loadTransactions()
    }
    
    // MARK: - UI Setup
    
    // Filtreleme kontrollerini ayarla
    private func setupFilterControls() {
        // Tip filtresi ayarları
        filterSegmentedControl.selectedSegmentIndex = 0
        filterSegmentedControl.backgroundColor = .systemBackground
        filterSegmentedControl.selectedSegmentTintColor = .systemBlue
        filterSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .selected)
        filterSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged(_:)), for: .valueChanged)
        
        // Filtre butonu oluştur
        filterButton = UIButton(type: .system)
        filterButton?.setImage(UIImage(systemName: "calendar"), for: .normal)
        filterButton?.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        
        // Navigation Bar'a ekle
        let filterBarButton = UIBarButtonItem(customView: filterButton!)
        navigationController?.navigationBar.topItem?.leftBarButtonItem = filterBarButton
        
        // Date Picker'ı oluştur
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.preferredDatePickerStyle = .wheels
        datePicker?.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    // Date Picker'ı göster
    @objc private func showDatePicker() {
        let alertController = UIAlertController(title: "Select Date Filter", message: nil, preferredStyle: .actionSheet)
        
        // Filtreleme seçenekleri
        let lastWeekAction = UIAlertAction(title: "Last Week", style: .default) { [weak self] _ in
            self?.selectedDateFilter = Calendar.current.date(byAdding: .day, value: -7, to: Date())
            self?.applyFilters()
        }
        
        let lastMonthAction = UIAlertAction(title: "Last Month", style: .default) { [weak self] _ in
            self?.selectedDateFilter = Calendar.current.date(byAdding: .month, value: -1, to: Date())
            self?.applyFilters()
        }
        
        let last3MonthsAction = UIAlertAction(title: "Last 3 Months", style: .default) { [weak self] _ in
            self?.selectedDateFilter = Calendar.current.date(byAdding: .month, value: -3, to: Date())
            self?.applyFilters()
        }
        
        let customDateAction = UIAlertAction(title: "Custom Date", style: .default) { [weak self] _ in
            self?.showCustomDatePicker()
        }
        
        let clearFilterAction = UIAlertAction(title: "Clear Filter", style: .destructive) { [weak self] _ in
            self?.selectedDateFilter = nil
            self?.applyFilters()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(lastWeekAction)
        alertController.addAction(lastMonthAction)
        alertController.addAction(last3MonthsAction)
        alertController.addAction(customDateAction)
        alertController.addAction(clearFilterAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // Özel tarih seçici göster
    private func showCustomDatePicker() {
        let alertController = UIAlertController(title: "Select Date Range", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        // Date Picker'ı alert controller'a ekle
        if let datePicker = datePicker {
            datePicker.frame = CGRect(x: 8, y: 8, width: alertController.view.bounds.width - 16, height: 200)
            alertController.view.addSubview(datePicker)
        }
        
        let fromDateAction = UIAlertAction(title: "From This Date", style: .default) { [weak self] _ in
            if let selectedDate = self?.datePicker?.date {
                self?.selectedDateFilter = selectedDate
                self?.applyFilters()
            }
        }
        
        let onThisDateAction = UIAlertAction(title: "On This Date Only", style: .default) { [weak self] _ in
            if let selectedDate = self?.datePicker?.date {
                // Seçilen tarihin başlangıcı ve sonu
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: selectedDate)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                self?.selectedDateFilter = startOfDay
                self?.selectedDateRange = (startOfDay, endOfDay)
                self?.applyFilters()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(fromDateAction)
        alertController.addAction(onThisDateAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // Date Picker değeri değiştiğinde
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDateFilter = sender.date
        applyFilters()
    }
    
    // Tip filtresi değiştiğinde çağrılır
    @objc private func filterChanged(_ sender: UISegmentedControl) {
        applyFilters()
    }
    
    // Tüm filtreleri uygula
    private func applyFilters() {
        // Önce tarih filtresini uygula
        var dateFilteredTransactions = transactions
        
        if let selectedDate = selectedDateFilter {
            if let dateRange = selectedDateRange {
                // Belirli bir tarih aralığı için filtreleme
                dateFilteredTransactions = transactions.filter { transaction in
                    let transactionDate = transaction.date.dateValue()
                    return transactionDate >= dateRange.0 && transactionDate < dateRange.1
                }
            } else {
                // Seçilen tarihten itibaren filtreleme
                dateFilteredTransactions = transactions.filter { $0.date.dateValue() >= selectedDate }
            }
        }
        
        // Sonra tip filtresini uygula
        switch filterSegmentedControl.selectedSegmentIndex {
        case 1: // Income
            filteredTransactions = dateFilteredTransactions.filter { $0.type == "Income" }
        case 2: // Expense
            filteredTransactions = dateFilteredTransactions.filter { $0.type == "Expense" }
        default:
            filteredTransactions = dateFilteredTransactions
        }
        
        // Filtre butonunun görünümünü güncelle
        updateFilterButtonAppearance()
        
        transactionsTableView.reloadData()
    }
    
    // Filtre butonunun görünümünü güncelle
    private func updateFilterButtonAppearance() {
        if selectedDateFilter != nil {
            filterButton?.tintColor = .systemBlue
        } else {
            filterButton?.tintColor = .systemGray
        }
    }
    
    // View her görünür olduğunda işlemleri yeniden yükle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTransactions()
    }

    // "+" butonuna tıklandığında yeni işlem ekleme ekranına git
    @objc func addButtonClicked(){
        performSegue(withIdentifier: "toAddTransactionVC", sender: nil)
    }
    
    // MARK: - Data Loading
    
    // Firebase'den işlemleri yükle
    func loadTransactions() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let db = Firestore.firestore()
        db.collection("transactions")
            .whereField("userID", isEqualTo: userID)
            .order(by: "date", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    // Firebase'den gelen verileri Transaction modeline dönüştür
                    self.transactions = querySnapshot?.documents.compactMap { document in
                        let data = document.data()
                        let currency = data["currency"] as? String ?? ""
                        let walletID = self.getWalletID(userID: userID, currency: currency)

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
                            currency: currency,
                            category: data["category"] as? String ?? "",
                            type: data["type"] as? String ?? "",
                            date: data["date"] as? Timestamp ?? Timestamp(),
                            walletID: walletID
                        )
                    } ?? []
                    
                    // Filtrelenmiş işlemleri güncelle
                    self.applyFilters()
                }
            }
    }
    
    // MARK: - Wallet Operations
    
    // Para birimine göre cüzdan ID'sini bul
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
    
    // MARK: - Table View Data Source
    
    // Tablo satır sayısını belirle
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions.count
    }
    
    // Tablo hücrelerini yapılandır
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        let transaction = filteredTransactions[indexPath.row]
        
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
        
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Table View Delegate
    
    // Hücre seçildiğinde detay sayfasına git
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTransaction = filteredTransactions[indexPath.row]
        performSegue(withIdentifier: "toTransactionDetailVC", sender: selectedTransaction)
    }
    
    // MARK: - Navigation
    
    // Detay sayfasına geçiş hazırlığı
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTransactionDetailVC",
           let destinationVC = segue.destination as? TransactionDetailsViewController,
           let selectedTransaction = sender as? Transaction {
            destinationVC.transaction = selectedTransaction
        } else {
            print("Segue failed or transaction is nil")
        }
    }
    
    // MARK: - Table View Swipe Actions
    
    // Sağa kaydırma ile silme işlemi
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let transaction = filteredTransactions[indexPath.row]
            deleteTransaction(transaction: transaction) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    DispatchQueue.main.async {
                        // Hem filtrelenmiş hem de ana listeden kaldır
                        if let index = self.transactions.firstIndex(where: { $0.title == transaction.title && $0.amount == transaction.amount && $0.date == transaction.date }) {
                            self.transactions.remove(at: index)
                        }
                        self.filteredTransactions.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    
    // Silme butonunun metnini ayarla
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    // MARK: - Firebase Operations
    
    // Firebase'den işlem silme fonksiyonu
    private func deleteTransaction(transaction: Transaction, completion: @escaping (Bool) -> Void) {
        // Kullanıcı oturum kontrolü
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        
        // String amount'u Double'a çevir
        let amountDouble = Double(transaction.amount) ?? 0.0
        
        // İşlemi bulmak için gerekli sorgu oluştur
        let query = db.collection("transactions")
            .whereField("userID", isEqualTo: userID)
            .whereField("title", isEqualTo: transaction.title)
            .whereField("amount", isEqualTo: amountDouble)
            .whereField("date", isEqualTo: transaction.date)
            .whereField("type", isEqualTo: transaction.type)
            .whereField("category", isEqualTo: transaction.category)
            .whereField("currency", isEqualTo: transaction.currency)
        
        // Sorguyu çalıştır ve sonuçları kontrol et
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error finding transaction: \(error)")
                completion(false)
                return
            }
            
            // İşlem bulundu mu kontrol et
            guard let document = querySnapshot?.documents.first else {
                print("Transaction not found")
                completion(false)
                return
            }
            
            // İşlemi Firebase'den sil
            document.reference.delete { error in
                if let error = error {
                    print("Error deleting transaction: \(error)")
                    completion(false)
                } else {
                    print("Transaction successfully deleted")
                    completion(true)
                }
            }
        }
    }
    
}
