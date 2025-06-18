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
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(hex: "#F5F5F5")
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Export Transactions"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Export your filtered transactions as PDF"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let filterCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .systemBlue
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .systemBlue
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let categoryPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let typeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["All", "Income", "Expense"])
        segment.selectedSegmentIndex = 0
        segment.backgroundColor = .systemBackground
        segment.selectedSegmentTintColor = .systemBlue
        segment.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()

    private let exportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Export as PDF", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let infoLabel = UILabel()
    private let categories = ["All", "Food", "Transportation", "Electricity", "Entertainment", "Accommodation", "Education", "Technology", "Salary", "Other"]
    private var selectedCategory: String = "All"
    private var selectedType: String = "All"
    private var transactions: [[String: Any]] = []
    private var userId: String? { Auth.auth().currentUser?.uid }
    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        setupUI()
        setupActions()
    }

    private func setupUI() {
        // Add views to hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(filterCard)
        
        // Add filter card content
        let dateStack = createLabeledStack(title: "Date Range", spacing: 16)
        dateStack.addArrangedSubview(createLabeledComponent(label: "From", component: startDatePicker))
        dateStack.addArrangedSubview(createLabeledComponent(label: "To", component: endDatePicker))
        
        let categoryStack = createLabeledStack(title: "Category", spacing: 8)
        categoryStack.addArrangedSubview(categoryPicker)
        
        let typeStack = createLabeledStack(title: "Transaction Type", spacing: 8)
        typeStack.addArrangedSubview(typeSegment)
        
        let filterStack = UIStackView(arrangedSubviews: [dateStack, categoryStack, typeStack])
        filterStack.axis = .vertical
        filterStack.spacing = 24
        filterStack.translatesAutoresizingMaskIntoConstraints = false
        filterCard.addSubview(filterStack)
        
        contentView.addSubview(exportButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            filterCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            filterCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            filterCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            filterStack.topAnchor.constraint(equalTo: filterCard.topAnchor, constant: 24),
            filterStack.leadingAnchor.constraint(equalTo: filterCard.leadingAnchor, constant: 24),
            filterStack.trailingAnchor.constraint(equalTo: filterCard.trailingAnchor, constant: -24),
            filterStack.bottomAnchor.constraint(equalTo: filterCard.bottomAnchor, constant: -24),
            
            categoryPicker.heightAnchor.constraint(equalToConstant: 120),
            
            exportButton.topAnchor.constraint(equalTo: filterCard.bottomAnchor, constant: 32),
            exportButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            exportButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            exportButton.heightAnchor.constraint(equalToConstant: 56),
            exportButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        // Setup delegates
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    }
    
    private func setupActions() {
        typeSegment.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
        exportButton.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
    }
    
    private func createLabeledStack(title: String, spacing: CGFloat) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .systemBlue
        
        let stack = UIStackView(arrangedSubviews: [titleLabel])
        stack.axis = .vertical
        stack.spacing = spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    private func createLabeledComponent(label: String, component: UIView) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, component])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
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
