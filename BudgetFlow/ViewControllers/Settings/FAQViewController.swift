
import UIKit

// Sıkça Sorulan Sorular (SSS) ekranını yöneten ViewController
class FAQViewController: UIViewController {
    
    // MARK: - UI Bileşenleri
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Frequently Asked Questions"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let faqStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Özellikler
    private let faqs: [(question: String, answer: String)] = [
        // SSS soruları ve cevapları
        (
            "How do I add a new transaction?",
            "Go to the Home screen and tap the '+' button. Fill in the transaction details and tap 'Save' to add it."
        ),
        (
            "How can I create a new wallet?",
            "On the Home screen, tap the wallet icon and select 'Add New Wallet'. Enter the wallet name and initial balance, then tap 'Create'."
        ),
        (
            "How do I edit my profile information?",
            "Go to Settings > Account Info, then tap the edit button. You can change your name, surname, or password."
        ),
        (
            "How do I view my account information?",
            "Go to Settings and select 'Account Info' to see your profile details."
        ),
        (
            "How do I switch between wallets?",
            "On the Home screen, tap the wallet name at the top and select the wallet you want to use."
        ),
        (
            "How can I delete a transaction?",
            "Swipe left on a transaction in the Home screen and tap the delete button."
        ),
        (
            "How do I change the app theme?",
            "Go to Settings and select 'Theme' to switch between light and dark mode."
        ),
        (
            "How do I manage notification settings?",
            "Go to Settings and select 'Notification Settings' or 'Email Notifications' to customize your preferences."
        ),
        (
            "How do I sign out of my account?",
            "Go to Settings and select 'Sign Out' at the bottom of the menu."
        ),
        (
            "How can I contact support?",
            "Go to Settings and select 'Contact Support' to find the developer's email address and send a message."
        )
    ]
    
    // MARK: - Yaşam Döngüsü Metodları
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // UI kurulumunu yap
        setupFAQs() // SSS'leri ekle
    }
    
    // MARK: - UI Kurulumu
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Görünümleri hiyerarşiye ekle
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(faqStack)
        
        // Otomatik yerleşim kısıtlamaları
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            faqStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            faqStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            faqStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            faqStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func setupFAQs() {
        for faq in faqs {
            let faqView = createFAQView(question: faq.question, answer: faq.answer)
            faqStack.addArrangedSubview(faqView)
        }
    }
    
    // SSS kutusu oluşturan yardımcı fonksiyon
    private func createFAQView(question: String, answer: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        
        let questionLabel = UILabel()
        questionLabel.text = question
        questionLabel.font = .systemFont(ofSize: 16, weight: .bold)
        questionLabel.numberOfLines = 0
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let answerLabel = UILabel()
        answerLabel.text = answer
        answerLabel.font = .systemFont(ofSize: 14)
        answerLabel.textColor = .darkGray
        answerLabel.numberOfLines = 0
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(questionLabel)
        container.addSubview(answerLabel)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            questionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 8),
            answerLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            answerLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            answerLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
}
