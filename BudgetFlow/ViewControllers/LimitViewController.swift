//
//  LimitViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 15.06.2025.
//

// LimitViewController.swift
// Kullanıcıların harcama limitlerini ve harcamalarını yönetmesini sağlar.
// Her kategori için limit belirlenebilir ve harcamalar anlık olarak güncellenir.

import UIKit
import FirebaseAuth
import FirebaseFirestore

// Limit ekranı ana controller'ı
class LimitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Tabloyu ve ekle butonunu tanımlıyoruz
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let addButton = UIButton(type: .system)
    // Limitleri tutacak model
    private struct LimitModel {
        var limitID: String // Limitin ID'si (kategori adı)
        var category: String // Kategori adı
        var limit: Double // Belirlenen limit
        var spend: Double // O kategori için harcanan miktar
        var userID: String // Kullanıcı ID'si
        var startDate: Date // Limitin başladığı tarih
    }
    // Kategorilere göre limitleri tutan sözlük
    private var limits: [String: LimitModel] = [:]
    // Kategoriler listesi
    private let categories = ["Food", "Transportation", "Electricity", "Entertainment", "Accommodation", "Education", "Technology", "Salary", "Other"]
    // Kullanıcı ID'si
    private var userId: String? { Auth.auth().currentUser?.uid }
    // Firestore bağlantısı
    private let db = Firestore.firestore()
    // Harcama listener'ı (gerçek zamanlı güncelleme için)
    private var spendingListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Arka plan ve başlık ayarları
        view.backgroundColor = .systemGroupedBackground
        title = "Limits & Budgets"
        // Tablo ve buton kurulumları
        setupTableView()
        setupAddButton()
        // Limitleri ve harcamaları çek
        fetchLimits()
        fetchSpending()
    }

    // Tabloyu ekrana yerleştir ve ayarlarını yap
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LimitCell.self, forCellReuseIdentifier: "LimitCell")
        tableView.contentInset.bottom = 90 // Altta buton olduğu için padding
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
        ])
    }

    // Ekle/Güncelle butonunu ekle ve ayarla
    private func setupAddButton() {
        addButton.setTitle("Add/Update Limit", for: .normal)
        addButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        addButton.backgroundColor = .systemBlue
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 16
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addLimitTapped), for: .touchUpInside)
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // Firestore'dan limitleri çek
    private func fetchLimits() {
        guard let userId = userId else { return }
        db.collection("users").document(userId).collection("limits").getDocuments { [weak self] snap, _ in
            guard let self = self else { return }
            var newLimits: [String: LimitModel] = [:]
            for doc in snap?.documents ?? [] {
                let data = doc.data()
                let category = data["category"] as? String ?? "Other"
                let limit = data["limit"] as? Double ?? 0.0
                let spend = data["spend"] as? Double ?? 0.0
                let limitID = doc.documentID
                let userID = data["userID"] as? String ?? ""
                let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date.distantPast
                newLimits[category] = LimitModel(limitID: limitID, category: category, limit: limit, spend: spend, userID: userID, startDate: startDate)
            }
            self.limits = newLimits
            self.tableView.reloadData()
        }
    }

    // Firestore'a yeni limit kaydet
    private func saveLimit(for category: String, limit: Double) {
        guard let userId = userId else { return }
        let docRef = db.collection("users").document(userId).collection("limits").document(category)
        let now = Date()
        let data: [String: Any] = [
            "limitID": category,
            "category": category,
            "limit": limit,
            "spend": 0.0,
            "userID": userId,
            "startDate": Timestamp(date: now)
        ]
        docRef.setData(data)
    }

    // Firestore'dan limiti sil
    private func removeLimit(for category: String) {
        guard let userId = userId else { return }
        db.collection("users").document(userId).collection("limits").document(category).delete()
        limits[category] = nil
        tableView.reloadData()
    }

    // Harcama değerini güncelle (Firestore'da)
    private func updateSpend(for category: String, amount: Double) {
        guard let userId = userId else { return }
        let docRef = db.collection("users").document(userId).collection("limits").document(category)
        docRef.updateData(["spend": FieldValue.increment(amount)])
    }

    // Harcamayı sıfırla (limit kaldırıldığında)
    private func resetSpend(for category: String) {
        guard let userId = userId else { return }
        let docRef = db.collection("users").document(userId).collection("limits").document(category)
        docRef.updateData(["spend": 0.0])
    }

    // Gerçek zamanlı olarak harcamaları takip et ve güncelle
    private func fetchSpending() {
        spendingListener?.remove()
        guard let userId = userId else { return }
        spendingListener = db.collection("transactions")
            .whereField("userID", isEqualTo: userId)
            .whereField("type", isEqualTo: "Expense")
            .addSnapshotListener { [weak self] snap, _ in
                guard let self = self else { return }
                var spendUpdates: [String: Double] = [:]
                for doc in snap?.documents ?? [] {
                    let data = doc.data()
                    let amount = data["amount"] as? Double ?? 0.0
                    let category = data["category"] as? String ?? "Other"
                    if let limitModel = self.limits[category] {
                        if let ts = data["date"] as? Timestamp, ts.dateValue() >= limitModel.startDate {
                            spendUpdates[category, default: 0.0] += amount
                        }
                    }
                }
                // Firestore ve local modelde harcamayı güncelle
                for (category, spend) in spendUpdates {
                    self.limits[category]?.spend = spend
                    self.db.collection("users").document(userId).collection("limits").document(category).updateData(["spend": spend])
                }
                // Hiç harcama yoksa 0 olarak ayarla
                for category in self.limits.keys where spendUpdates[category] == nil {
                    self.limits[category]?.spend = 0.0
                    self.db.collection("users").document(userId).collection("limits").document(category).updateData(["spend": 0.0])
                }
                self.tableView.reloadData()
            }
    }

    // Tablo kaç bölümden oluşacak (tek bölüm)
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    // Her bölümde kaç satır olacak (kategori sayısı kadar)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return categories.count }
    // Her satırda ne gösterilecek
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LimitCell", for: indexPath) as! LimitCell
        let category = categories[indexPath.row]
        let limitModel = limits[category]
        let limit = limitModel?.limit ?? 0.0
        let spentAmount = limitModel?.spend
        cell.configure(category: category, limit: limit, spent: spentAmount)
        cell.onRemove = { [weak self] in
            self?.removeLimit(for: category)
        }
        return cell
    }

    // Limit ekleme/güncelleme butonuna tıklanınca
    @objc private func addLimitTapped() {
        let alert = UIAlertController(title: "Set Limit", message: "Choose category and set a monthly limit.", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Category"
            tf.text = self.categories.first
        }
        alert.addTextField { tf in
            tf.placeholder = "Limit (₺)"
            tf.keyboardType = .decimalPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let category = alert.textFields?[0].text ?? "Other"
            let limit = Double(alert.textFields?[1].text ?? "") ?? 0.0
            if self.categories.contains(category) && limit > 0 {
                self.saveLimit(for: category, limit: limit)
                self.fetchLimits()
            }
        }))
        present(alert, animated: true)
    }

    // Listener'ı kaldır (bellek sızıntısı olmasın diye)
    deinit {
        spendingListener?.remove()
    }
}

// Tablo hücresi: Her kategori için limit ve harcama gösterimi
class LimitCell: UITableViewCell {
    private let categoryLabel = UILabel()
    private let limitLabel = UILabel()
    private let spentLabel = UILabel()
    private let warningLabel = UILabel()
    private let removeButton = UIButton(type: .system)
    var onRemove: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setupUI() }
    // Hücredeki UI elemanlarını ayarla
    private func setupUI() {
        categoryLabel.font = .boldSystemFont(ofSize: 18)
        limitLabel.font = .systemFont(ofSize: 15)
        spentLabel.font = .systemFont(ofSize: 15)
        warningLabel.font = .systemFont(ofSize: 14)
        warningLabel.textColor = .systemRed
        removeButton.setTitle("Remove", for: .normal)
        removeButton.setTitleColor(.systemRed, for: .normal)
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [categoryLabel, limitLabel, spentLabel, warningLabel, removeButton])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    // Hücreyi verilen verilerle doldur
    func configure(category: String, limit: Double, spent: Double?) {
        categoryLabel.text = category
        if limit > 0 {
            limitLabel.text = "Limit: " + String(format: "%.2f ₺", limit)
            if let spent = spent {
                spentLabel.text = "Spent: " + String(format: "%.2f ₺", spent)
                let percent = spent / limit
                if percent >= 1.0 {
                    warningLabel.text = "Limit exceeded!"
                } else if percent >= 0.8 {
                    warningLabel.text = "Warning: 80% of limit used."
                } else {
                    warningLabel.text = ""
                }
            } else {
                spentLabel.text = "Spent: 0.00 ₺"
                warningLabel.text = ""
            }
        } else {
            limitLabel.text = "No limit set"
            spentLabel.text = ""
            warningLabel.text = ""
        }
    }
    // Remove butonuna tıklanınca çağrılır
    @objc private func removeTapped() { onRemove?() }
}
