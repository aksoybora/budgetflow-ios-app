
import UIKit

// Cüzdan kartı için CollectionView hücresi
class WalletCardCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elemanları
    let cardBackgroundView = UIView() // Kartın arka planı
    let walletNameLabel = UILabel()   // Cüzdan adı
    let balanceLabel = UILabel()      // Bakiye
    let currencyLabel = UILabel()     // Para birimi
    let cardholderNameLabel = UILabel() // Kart sahibi adı
    let detailsButton = UIButton(type: .system) // Detaylar butonu
    let cardLogoImageView = UIImageView() // Kart logosu

    // Kart rengi
    var walletColor: UIColor = UIColor.systemPurple {
        didSet {
            cardBackgroundView.layer.borderColor = walletColor.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews() // Görünümleri ayarla
        setupConstraints() // Kısıtlamaları ayarla
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews() // Görünümleri ayarla
        setupConstraints() // Kısıtlamaları ayarla
    }

    // UI elemanlarını oluştur ve özelleştir
    private func setupViews() {
        // Kart arka planı
        cardBackgroundView.layer.cornerRadius = 16
        cardBackgroundView.layer.borderWidth = 2
        cardBackgroundView.clipsToBounds = true
        addSubview(cardBackgroundView)

        // Cüzdan adı
        walletNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cardBackgroundView.addSubview(walletNameLabel)

        // Bakiye
        balanceLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        cardBackgroundView.addSubview(balanceLabel)

        // Para birimi
        currencyLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        cardBackgroundView.addSubview(currencyLabel)

        // Kart logosu
        cardLogoImageView.contentMode = .scaleAspectFit
        cardBackgroundView.addSubview(cardLogoImageView)

        // Kart sahibi adı
        cardholderNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cardholderNameLabel.textColor = .gray
        cardBackgroundView.addSubview(cardholderNameLabel)

        // Detaylar butonu
        detailsButton.setTitle("Details", for: .normal)
        detailsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        detailsButton.layer.cornerRadius = 12
        detailsButton.layer.borderWidth = 1
        detailsButton.backgroundColor = .white
        cardBackgroundView.addSubview(detailsButton)
    }

    // Otomatik yerleşim (Auto Layout) kuralları
    private func setupConstraints() {
        cardBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        walletNameLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        cardLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        cardholderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Kart arka planı
            cardBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            cardBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Cüzdan adı
            walletNameLabel.topAnchor.constraint(equalTo: cardBackgroundView.topAnchor, constant: 16),
            walletNameLabel.leadingAnchor.constraint(equalTo: cardBackgroundView.leadingAnchor, constant: 16),

            // Bakiye
            balanceLabel.topAnchor.constraint(equalTo: walletNameLabel.bottomAnchor, constant: 8),
            balanceLabel.leadingAnchor.constraint(equalTo: cardBackgroundView.leadingAnchor, constant: 16),

            // Para birimi
            currencyLabel.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            currencyLabel.leadingAnchor.constraint(equalTo: balanceLabel.trailingAnchor, constant: 8),

            // Kart logosu
            cardLogoImageView.topAnchor.constraint(equalTo: cardBackgroundView.topAnchor, constant: 16),
            cardLogoImageView.trailingAnchor.constraint(equalTo: cardBackgroundView.trailingAnchor, constant: -16),
            cardLogoImageView.widthAnchor.constraint(equalToConstant: 32),
            cardLogoImageView.heightAnchor.constraint(equalToConstant: 32),

            // Kart sahibi adı
            cardholderNameLabel.leadingAnchor.constraint(equalTo: cardBackgroundView.leadingAnchor, constant: 16),
            cardholderNameLabel.bottomAnchor.constraint(equalTo: cardBackgroundView.bottomAnchor, constant: -16),

            // Detaylar butonu
            detailsButton.trailingAnchor.constraint(equalTo: cardBackgroundView.trailingAnchor, constant: -16),
            detailsButton.bottomAnchor.constraint(equalTo: cardBackgroundView.bottomAnchor, constant: -16),
            detailsButton.widthAnchor.constraint(equalToConstant: 80),
            detailsButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    // Cüzdan ile hücreyi doldur
    func configure(with wallet: Wallet, userName: String = "") {
        walletNameLabel.text = "\(wallet.currency) Wallet"
        currencyLabel.text = wallet.currency
        cardholderNameLabel.text = userName.uppercased()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        if let formattedBalance = formatter.string(from: NSNumber(value: wallet.balance)) {
            balanceLabel.text = formattedBalance
        }
        
        // Kart logosu ve renkler
        switch wallet.currency {
        case "TRY":
            cardLogoImageView.image = UIImage(systemName: "turkishlirasign.circle.fill")
            cardBackgroundView.backgroundColor = UIColor(red: 0.91, green: 0.97, blue: 0.89, alpha: 1) // Açık yeşil
            walletColor = UIColor(red: 0.22, green: 0.65, blue: 0.32, alpha: 1) // Koyu yeşil
            walletNameLabel.textColor = walletColor
            balanceLabel.textColor = walletColor
            currencyLabel.textColor = walletColor
            detailsButton.layer.borderColor = walletColor.cgColor
            detailsButton.setTitleColor(walletColor, for: .normal)
            cardLogoImageView.tintColor = walletColor
        case "USD":
            cardLogoImageView.image = UIImage(systemName: "dollarsign.circle.fill")
            cardBackgroundView.backgroundColor = UIColor(red: 0.89, green: 0.94, blue: 0.98, alpha: 1) // Açık mavi
            walletColor = UIColor(red: 0.13, green: 0.36, blue: 0.75, alpha: 1) // Koyu mavi
            walletNameLabel.textColor = walletColor
            balanceLabel.textColor = walletColor
            currencyLabel.textColor = walletColor
            detailsButton.layer.borderColor = walletColor.cgColor
            detailsButton.setTitleColor(walletColor, for: .normal)
            cardLogoImageView.tintColor = walletColor
        case "EUR":
            cardLogoImageView.image = UIImage(systemName: "eurosign.circle.fill")
            cardBackgroundView.backgroundColor = UIColor(red: 1.0, green: 0.96, blue: 0.86, alpha: 1) // Açık sarı
            walletColor = UIColor(red: 0.98, green: 0.60, blue: 0.18, alpha: 1) // Koyu turuncu
            walletNameLabel.textColor = walletColor
            balanceLabel.textColor = walletColor
            currencyLabel.textColor = walletColor
            detailsButton.layer.borderColor = walletColor.cgColor
            detailsButton.setTitleColor(walletColor, for: .normal)
            cardLogoImageView.tintColor = walletColor
        default:
            cardLogoImageView.image = UIImage(systemName: "creditcard.fill")
            cardBackgroundView.backgroundColor = UIColor(white: 0.97, alpha: 1)
            walletColor = UIColor.systemPurple
            walletNameLabel.textColor = walletColor
            balanceLabel.textColor = walletColor
            currencyLabel.textColor = walletColor
            detailsButton.layer.borderColor = walletColor.cgColor
            detailsButton.setTitleColor(walletColor, for: .normal)
            cardLogoImageView.tintColor = walletColor
        }
    }
}
