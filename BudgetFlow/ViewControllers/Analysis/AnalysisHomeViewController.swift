import UIKit

class AnalysisHomeViewController: UIViewController {

    // MARK: - Arayüz Elemanları
    // ScrollView ve içerik görünümü
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
    
    // Başlık ve alt başlık
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Analysis Tools"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Track and analyze your financial data"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Kartlar: Grafikler, Tahmin, Dışa Aktar
    private lazy var graphsCard: UIView = createCard(
        title: "Graphs",
        description: "View detailed charts and graphs of your spending patterns",
        icon: "chart.bar.fill",
        color: .systemBlue,
        action: #selector(graphsButtonTapped)
    )
    
    private lazy var predictCard: UIView = createCard(
        title: "Predict",
        description: "Get AI-powered predictions for your future expenses",
        icon: "chart.line.uptrend.xyaxis",
        color: .systemGreen,
        action: #selector(predictButtonTapped)
    )
    
    private lazy var exportCard: UIView = createCard(
        title: "Export",
        description: "Export your transaction history as PDF",
        icon: "square.and.arrow.up",
        color: .systemOrange,
        action: #selector(exportButtonTapped)
    )

    // MARK: - Yaşam Döngüsü
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Arayüzü kur
    }

    // MARK: - Arayüz Kurulumu
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Görünümleri hiyerarşiye ekle
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(graphsCard)
        contentView.addSubview(predictCard)
        contentView.addSubview(exportCard)
        
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            graphsCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            graphsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            graphsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            predictCard.topAnchor.constraint(equalTo: graphsCard.bottomAnchor, constant: 16),
            predictCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            predictCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            exportCard.topAnchor.constraint(equalTo: predictCard.bottomAnchor, constant: 16),
            exportCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            exportCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            exportCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    // Kart oluşturan yardımcı fonksiyon
    private func createCard(title: String, description: String, icon: String, color: UIColor, action: Selector) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Tıklama hareketi ekle
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        card.addGestureRecognizer(tapGesture)
        card.isUserInteractionEnabled = true
        
        // Simge
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Kart başlığı
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Açıklama
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .gray
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Ok simgesi
        let arrowView = UIImageView()
        arrowView.image = UIImage(systemName: "chevron.right")
        arrowView.tintColor = .gray
        arrowView.contentMode = .scaleAspectFit
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(descLabel)
        card.addSubview(arrowView)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 120),
            
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: arrowView.leadingAnchor, constant: -16),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: arrowView.leadingAnchor, constant: -16),
            descLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -20),
            
            arrowView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            arrowView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            arrowView.widthAnchor.constraint(equalToConstant: 16),
            arrowView.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        return card
    }

    // MARK: - Aksiyonlar
    // Grafikler kartına tıklandığında
    @objc private func graphsButtonTapped() {
        performSegue(withIdentifier: "toGraphs", sender: self)
    }

    // Tahmin kartına tıklandığında
    @objc private func predictButtonTapped() {
        performSegue(withIdentifier: "toPredict", sender: self)
    }

    // Dışa aktar kartına tıklandığında
    @objc private func exportButtonTapped() {
        performSegue(withIdentifier: "toExport", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // Storyboard tabanlı uygulamalarda, genellikle gezinmeden önce biraz hazırlık yapmak istersiniz
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Yeni view controller'ı segue.destination ile alın.
        // Seçilen nesneyi yeni view controller'a iletin.
    }
    */

}
