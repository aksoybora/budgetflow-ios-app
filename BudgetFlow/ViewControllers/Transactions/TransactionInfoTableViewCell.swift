import UIKit

class TransactionInfoTableViewCell: UITableViewCell {
    // Hücre başlatıldığında arayüzü ayarla
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // Hücre arka planı ve seçim stilini ayarla
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    // Hücreyi verilen işlem, tarih ve ikon ile yapılandır
    func configure(with transaction: Transaction, dateString: String, icon: UIImage?) {
        // Hücre içeriğini oluştur
        var content = defaultContentConfiguration()
        content.text = transaction.title
        content.secondaryText = "\(transaction.amount) \(transaction.currency) - \(dateString)"
        
        // İkonu ayarla
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        content.image = icon?.withConfiguration(imageConfig)
        content.imageProperties.tintColor = transaction.type == "Income" ? UIColor(hex: "#3E7B27") : .systemRed
        content.imageProperties.maximumSize = CGSize(width: 32, height: 32)
        content.imageToTextPadding = 16
        
        // İşlem tipine göre metin ve arka plan rengini ayarla
        if transaction.type == "Income" {
            content.secondaryTextProperties.color = UIColor(hex: "#3E7B27")
            backgroundColor = UIColor(hex: "#A7D477", alpha: 0.2)
        } else {
            content.secondaryTextProperties.color = .systemRed
            backgroundColor = UIColor(hex: "#F44336", alpha: 0.2)
        }
        
        contentConfiguration = content
    }
}
