import UIKit

class TransactionDetailsViewController: UIViewController {
    
    // MARK: - Özellikler
    var transaction: Transaction?
    
    // MARK: - Arayüz Elemanları
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
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
    
    // İşlem kartı görünümü
    private let transactionCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // İşlem simgesi
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Başlık etiketi
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Tutar etiketi
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Detay kartı görünümü
    private let detailsCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Detaylar için stack view
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Yaşam Döngüsü
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Arayüzü kur
        configureWithTransaction() // İşlem detaylarını göster
    }
    
    // MARK: - Arayüz Kurulumu
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        title = "Transaction Details"
        
        // Görünümleri hiyerarşiye ekle
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(transactionCard)
        transactionCard.addSubview(iconImageView)
        transactionCard.addSubview(titleLabel)
        transactionCard.addSubview(amountLabel)
        
        contentView.addSubview(detailsCard)
        detailsCard.addSubview(stackView)
        
        // Otomatik yerleşim kısıtlamalarını ayarla
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
            
            transactionCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            transactionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transactionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            iconImageView.topAnchor.constraint(equalTo: transactionCard.topAnchor, constant: 24),
            iconImageView.centerXAnchor.constraint(equalTo: transactionCard.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 64),
            iconImageView.heightAnchor.constraint(equalToConstant: 64),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: transactionCard.centerXAnchor),
            
            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            amountLabel.leadingAnchor.constraint(equalTo: transactionCard.leadingAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: transactionCard.trailingAnchor, constant: -16),
            amountLabel.bottomAnchor.constraint(equalTo: transactionCard.bottomAnchor, constant: -24),
            
            detailsCard.topAnchor.constraint(equalTo: transactionCard.bottomAnchor, constant: 16),
            detailsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailsCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: -16)
        ])
    }
    
    // İşlem detaylarını arayüze yerleştirir
    private func configureWithTransaction() {
        guard let transaction = transaction else { return }
        
        // Simgeyi ayarla
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
        let image: UIImage?
        
        switch transaction.title.lowercased() {
        case let title where title.contains("coffee"):
            image = UIImage(systemName: "cup.and.saucer.fill", withConfiguration: imageConfig)
        case let title where title.contains("transport") || title.contains("uber"):
            image = UIImage(systemName: "car.fill", withConfiguration: imageConfig)
        case let title where title.contains("shopping") || title.contains("market"):
            image = UIImage(systemName: "cart.fill", withConfiguration: imageConfig)
        case let title where title.contains("bill") || title.contains("utilities"):
            image = UIImage(systemName: "doc.text.fill", withConfiguration: imageConfig)
        case let title where title.contains("entertainment") || title.contains("movie"):
            image = UIImage(systemName: "tv.fill", withConfiguration: imageConfig)
        case let title where title.contains("health") || title.contains("medical"):
            image = UIImage(systemName: "heart.fill", withConfiguration: imageConfig)
        case let title where title.contains("education") || title.contains("school"):
            image = UIImage(systemName: "book.fill", withConfiguration: imageConfig)
        case let title where title.contains("food") || title.contains("restaurant"):
            image = UIImage(systemName: "fork.knife", withConfiguration: imageConfig)
        case let title where title.contains("tech") || title.contains("technology"):
            image = UIImage(systemName: "laptopcomputer", withConfiguration: imageConfig)
        case let title where title.contains("app") || title.contains("software"):
            image = UIImage(systemName: "app.fill", withConfiguration: imageConfig)
        case let title where title.contains("stay") || title.contains("hotel"):
            image = UIImage(systemName: "house.fill", withConfiguration: imageConfig)
        case let title where title.contains("rent") || title.contains("housing"):
            image = UIImage(systemName: "building.2.fill", withConfiguration: imageConfig)
        case let title where title.contains("groceries"):
            image = UIImage(systemName: "basket.fill", withConfiguration: imageConfig)
        default:
            image = UIImage(systemName: "banknote.fill", withConfiguration: imageConfig)
        }
        
        iconImageView.image = image
        iconImageView.tintColor = transaction.type == "Income" ? UIColor(hex: "#3E7B27") : .systemRed
        
        // Başlık ve tutarı ayarla
        titleLabel.text = transaction.title
        let amount = Double(transaction.amount) ?? 0
        let formattedAmount = String(format: "%.2f", abs(amount))
        amountLabel.text = "\(formattedAmount) \(transaction.currency)"
        amountLabel.textColor = transaction.type == "Income" ? UIColor(hex: "#3E7B27") : .systemRed
        
        // Kart arka plan rengini ayarla
        transactionCard.backgroundColor = transaction.type == "Income" ? 
            UIColor(hex: "#A7D477", alpha: 0.2) : UIColor(hex: "#F44336", alpha: 0.2)
        
        // Detayları ekle
        let details: [(String, String)] = [
            ("Description", transaction.description),
            ("Category", transaction.category),
            ("Type", transaction.type),
            ("Date", formatDate(transaction.date.dateValue())),
            ("Currency", transaction.currency)
        ]
        
        details.forEach { title, value in
            let detailView = createDetailView(title: title, value: value)
            stackView.addArrangedSubview(detailView)
        }
    }
    
    // Detay satırı oluşturan yardımcı fonksiyon
    private func createDetailView(title: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .systemBlue
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .regular)
        valueLabel.textColor = .black
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    // Tarihi formatlayan yardımcı fonksiyon
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: date)
    }
}
