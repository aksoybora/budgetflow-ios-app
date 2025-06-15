//
//  ExportViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 15.06.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import PDFKit

// Bu ekran, kullanıcıya filtreli işlemlerini PDF olarak dışa aktarma imkanı sunar.
class ExportViewController: UIViewController {
    // UI elemanları
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let categoryPicker = UIPickerView()
    private let typeSegment = UISegmentedControl(items: ["All", "Income", "Expense"])
    private let exportButton = UIButton(type: .system)
    private let infoLabel = UILabel()
    private let categories = ["All", "Food", "Transportation", "Electricity", "Entertainment", "Accommodation", "Education", "Technology", "Salary", "Other"]
    private var selectedCategory: String = "All"
    private var selectedType: String = "All"
    private var transactions: [[String: Any]] = []
    private var userId: String? { Auth.auth().currentUser?.uid }
    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Export Transactions"
        setupUI()
    }

    // UI elemanlarını ekrana yerleştir
    private func setupUI() {
        // Bilgi etiketi
        infoLabel.text = "Select filters and export your transactions as a PDF."
        infoLabel.font = UIFont.systemFont(ofSize: 15)
        infoLabel.textColor = .darkGray
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)

        // Yeni başlık etiketi
        let filterLabel = UILabel()
        filterLabel.text = "Filtering Options"
        filterLabel.font = UIFont.boldSystemFont(ofSize: 18)
        filterLabel.textColor = .black
        filterLabel.textAlignment = .center
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterLabel)

        // Başlangıç tarihi seçici
        let startDateLabel = UILabel()
        startDateLabel.text = "Start Date"
        startDateLabel.font = UIFont.boldSystemFont(ofSize: 16)
        startDateLabel.textColor = .black
        startDateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startDateLabel)

        startDatePicker.datePickerMode = .date
        startDatePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startDatePicker)

        // Bitiş tarihi seçici
        let endDateLabel = UILabel()
        endDateLabel.text = "End Date"
        endDateLabel.font = UIFont.boldSystemFont(ofSize: 16)
        endDateLabel.textColor = .black
        endDateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(endDateLabel)

        endDatePicker.datePickerMode = .date
        endDatePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(endDatePicker)

        // Kategori seçici
        let categoryLabel = UILabel()
        categoryLabel.text = "Category"
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 16)
        categoryLabel.textColor = .black
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryLabel)

        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryPicker)

        // Tip segmenti
        let typeLabel = UILabel()
        typeLabel.text = "Type"
        typeLabel.font = UIFont.boldSystemFont(ofSize: 16)
        typeLabel.textColor = .black
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typeLabel)

        typeSegment.selectedSegmentIndex = 0
        typeSegment.translatesAutoresizingMaskIntoConstraints = false
        typeSegment.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
        view.addSubview(typeSegment)

        // Export butonu
        exportButton.setTitle("Export as PDF", for: .normal)
        exportButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        exportButton.backgroundColor = .systemBlue
        exportButton.setTitleColor(.white, for: .normal)
        exportButton.layer.cornerRadius = 14
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        exportButton.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
        view.addSubview(exportButton)

        // Layout
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            infoLabel.heightAnchor.constraint(equalToConstant: 40),

            filterLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 12),
            filterLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterLabel.heightAnchor.constraint(equalToConstant: 24),

            startDateLabel.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 12),
            startDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            startDateLabel.heightAnchor.constraint(equalToConstant: 20),

            startDatePicker.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 4),
            startDatePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            endDateLabel.topAnchor.constraint(equalTo: startDatePicker.bottomAnchor, constant: 8),
            endDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            endDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            endDateLabel.heightAnchor.constraint(equalToConstant: 20),

            endDatePicker.topAnchor.constraint(equalTo: endDateLabel.bottomAnchor, constant: 4),
            endDatePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            endDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            categoryLabel.topAnchor.constraint(equalTo: endDatePicker.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryLabel.heightAnchor.constraint(equalToConstant: 20),

            categoryPicker.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            categoryPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryPicker.heightAnchor.constraint(equalToConstant: 180),

            typeLabel.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 8),
            typeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            typeLabel.heightAnchor.constraint(equalToConstant: 20),

            typeSegment.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            typeSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            typeSegment.widthAnchor.constraint(equalToConstant: 260),

            exportButton.topAnchor.constraint(equalTo: typeSegment.bottomAnchor, constant: 140),
            exportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exportButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            exportButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    // Tip segmenti değişince
    @objc private func typeChanged() {
        let idx = typeSegment.selectedSegmentIndex
        if idx == 0 { selectedType = "All" }
        else if idx == 1 { selectedType = "Income" }
        else { selectedType = "Expense" }
    }

    // Export butonuna tıklanınca
    @objc private func exportTapped() {
        // Filtreye göre işlemleri çek
        fetchFilteredTransactions { [weak self] in
            guard let self = self else { return }
            if self.transactions.isEmpty {
                let alert = UIAlertController(title: "Uyarı", message: "Seçilen filtrelere uygun işlem bulunamadı.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                self.present(alert, animated: true)
                return
            }
            // PDF oluştur ve paylaş
            let pdfData = self.createPDF()
            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("transactions.pdf")
            try? pdfData.write(to: tmpURL)
            let activityVC = UIActivityViewController(activityItems: [tmpURL], applicationActivities: nil)
            self.present(activityVC, animated: true)
        }
    }

    // Filtreye göre işlemleri Firestore'dan çek
    private func fetchFilteredTransactions(completion: @escaping () -> Void) {
        guard let userId = userId else { completion(); return }
        var query: Query = db.collection("transactions").whereField("userID", isEqualTo: userId)
        if selectedType != "All" {
            query = query.whereField("type", isEqualTo: selectedType)
        }
        query.getDocuments { [weak self] snap, _ in
            guard let self = self else { completion(); return }
            var results: [[String: Any]] = []
            for doc in snap?.documents ?? [] {
                let data = doc.data()
                // Tarih aralığı kontrolü
                if let ts = data["date"] as? Timestamp {
                    let date = ts.dateValue()
                    if date < self.startDatePicker.date || date > self.endDatePicker.date { continue }
                }
                // Kategori kontrolü
                if self.selectedCategory != "All" {
                    if let cat = data["category"] as? String, cat != self.selectedCategory { continue }
                }
                results.append(data)
            }
            self.transactions = results
            completion()
        }
    }

    // PDF dosyası oluştur
    private func createPDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "BudgetFlow",
            kCGPDFContextAuthor: "Bora Aksoy"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageWidth = 595.2
        let pageHeight = 841.8
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let title = "İşlem Raporu"
            let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22)]
            title.draw(at: CGPoint(x: 40, y: 40), withAttributes: attrs)
            var y: CGFloat = 80
            let header = "Tarih        | Kategori | Tip | Tutar | Açıklama"
            header.draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
            y += 24
            // Tarihe göre sıralama (azalan)
            let sortedTransactions = transactions.sorted { (tx1, tx2) -> Bool in
                let date1 = (tx1["date"] as? Timestamp)?.dateValue() ?? Date.distantPast
                let date2 = (tx2["date"] as? Timestamp)?.dateValue() ?? Date.distantPast
                return date1 > date2
            }
            for tx in sortedTransactions {
                if y > pageHeight - 60 {
                    ctx.beginPage()
                    y = 40
                }
                let dateStr: String = {
                    if let ts = tx["date"] as? Timestamp {
                        let df = DateFormatter()
                        df.dateFormat = "dd.MM.yyyy"
                        return df.string(from: ts.dateValue())
                    }
                    return "-"
                }()
                let cat = tx["category"] as? String ?? "-"
                let type = tx["type"] as? String ?? "-"
                let amount = (tx["amount"] as? Double).map { String(format: "%.2f", $0) } ?? "-"
                let desc = tx["description"] as? String ?? "-"
                let line = "\(dateStr) | \(cat) | \(type) | \(amount) | \(desc)"
                line.draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: UIFont.systemFont(ofSize: 13)])
                y += 20
            }
        }
        return data
    }
}

// Kategori seçici için picker view delegate ve data source
extension ExportViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return categories.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return categories[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }
}
