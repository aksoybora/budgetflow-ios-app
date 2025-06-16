//
//  AccountInfoVC.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 29.04.2025.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AccountInfoViewController: UIViewController {

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let stackView = UIStackView()
    private let db = Firestore.firestore()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        generateSampleTransactions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        title = "Account Info"
        
        // ScrollView & Container
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        scrollView.addSubview(containerView)
        
        // StackView
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    // Helper to add a section header
    private func addSectionHeader(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor(hex: "#007AFF")
        stackView.addArrangedSubview(label)
    }
    
    // Helper to add a row (title + value)
    private func addInfoRow(title: String, value: String) {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 8
        rowStack.alignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .darkGray
        titleLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        valueLabel.textColor = .black
        valueLabel.numberOfLines = 0
        valueLabel.textAlignment = .right
        
        rowStack.addArrangedSubview(titleLabel)
        rowStack.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(rowStack)
    }
    
    // MARK: - Data Methods
    private func loadUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        db.collection("users").document(userID).collection("info").getDocuments { [weak self] snapshot, error in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            
            guard let self = self else { return }
            self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear old content
            
            if let error = error {
                self.addSectionHeader("Error")
                self.addInfoRow(title: "Message", value: error.localizedDescription)
                return
            }
            
            if let document = snapshot?.documents.first {
                let data = document.data()
                // Personal Info
                self.addSectionHeader("Personal Information")
                self.addInfoRow(title: "Name", value: data["name"] as? String ?? "-")
                self.addInfoRow(title: "Surname", value: data["surname"] as? String ?? "-")
                self.addInfoRow(title: "Email", value: data["email"] as? String ?? "-")
                self.addInfoRow(title: "Birthday", value: data["birthday"] as? String ?? "-")
                // Account Info
                self.addSectionHeader("Account Information")
                if let timestamp = data["createdAt"] as? Timestamp {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .short
                    self.addInfoRow(title: "Created", value: dateFormatter.string(from: timestamp.dateValue()))
                } else {
                    self.addInfoRow(title: "Created", value: "-")
                }
                if let lastSignInDate = Auth.auth().currentUser?.metadata.lastSignInDate {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .short
                    self.addInfoRow(title: "Last Login", value: dateFormatter.string(from: lastSignInDate))
                } else {
                    self.addInfoRow(title: "Last Login", value: "-")
                }
            } else {
                self.addSectionHeader("No Data")
                self.addInfoRow(title: "Info", value: "No user info found.")
            }
        }
    }
    
    // MARK: - SAMPLE DATA GENERATION (REMOVE AFTER USE)
    /// Call this function ONCE to generate 6 months of sample transactions for the current user.
    func generateSampleTransactions() {
        guard let userID = Auth.auth().currentUser?.uid else { print("No userID"); return }
        let db = Firestore.firestore()
        let categories = ["Food", "Transportation", "Electricity", "Entertainment", "Accommodation", "Education", "Technology", "Salary", "Other"]
        let incomeCategories = ["Salary", "Other"]
        let expenseCategories = ["Food", "Transportation", "Electricity", "Entertainment", "Accommodation", "Education", "Technology", "Other"]
        let now = Date()
        let calendar = Calendar.current
        var runningBalance: Double = 0
        let monthsBack = 6
        let transactionsPerMonth = 45
        let expenseRatio = 0.7 // 70% expenses
        let incomeRatio = 0.3  // 30% income
        let currency = "TRY"
        let descriptions = [
            "Market shopping", "Bus ticket", "Electric bill", "Cinema night", "Hotel stay", "Course fee", "New phone", "Monthly salary", "Freelance work", "Gift", "Dinner out", "Taxi ride", "Concert", "Rent payment", "Book purchase", "Software subscription", "Bonus", "Side job", "Utilities", "Coffee shop"
        ]
        let titles = [
            "Groceries", "Transport", "Electricity", "Fun", "Stay", "Education", "Tech", "Salary", "Income", "Gift", "Meal", "Taxi", "Music", "Rent", "Book", "App", "Bonus", "Job", "Bill", "Coffee"
        ]
        var allTransactions: [[String: Any]] = []
        for monthOffset in (0..<monthsBack).reversed() {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) else { continue }
            let range = calendar.range(of: .day, in: .month, for: monthDate)
            let dayRange: ClosedRange<Int> = {
                if let r = range {
                    return r.lowerBound...(r.upperBound - 1)
                } else {
                    return 1...28
                }
            }()
            var monthIncome: Double = 0
            var monthExpense: Double = 0
            for i in 0..<transactionsPerMonth {
                let isIncome = Double.random(in: 0...1) > expenseRatio
                let day = Int.random(in: dayRange)
                var dateComponents = calendar.dateComponents([.year, .month], from: monthDate)
                dateComponents.day = day
                dateComponents.hour = Int.random(in: 8...20)
                dateComponents.minute = Int.random(in: 0...59)
                let txDate = calendar.date(from: dateComponents) ?? monthDate
                let category = isIncome ? incomeCategories.randomElement()! : expenseCategories.randomElement()!
                let amount: Double = isIncome ? Double.random(in: 4000...20000) : Double.random(in: 100...4000)
                let txType = isIncome ? "Income" : "Expense"
                let title = titles.randomElement()!
                let desc = descriptions.randomElement()!
                // Ensure expenses do not exceed income
                if isIncome {
                    monthIncome += amount
                    runningBalance += amount
                } else {
                    if (monthExpense + amount) > monthIncome {
                        continue // skip this expense, would exceed income
                    }
                    monthExpense += amount
                    runningBalance -= amount
                }
                let tx: [String: Any] = [
                    "amount": amount,
                    "category": category,
                    "currency": currency,
                    "date": Timestamp(date: txDate),
                    "description": desc,
                    "title": title,
                    "type": txType,
                    "userID": userID
                ]
                allTransactions.append(tx)
            }
        }
        // Upload all transactions
        let group = DispatchGroup()
        for tx in allTransactions {
            group.enter()
            db.collection("transactions").addDocument(data: tx) { error in
                if let error = error {
                    print("Error adding transaction: \(error)")
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            print("Sample transactions added: \(allTransactions.count)")

            // Calculate final balance for TRY
            let finalBalance = allTransactions.reduce(0.0) { result, tx in
                let amount = tx["amount"] as? Double ?? 0.0
                let type = tx["type"] as? String ?? ""
                return result + (type == "Income" ? amount : -amount)
            }

            // Update or create the wallet for TRY
            let walletsRef = db.collection("users").document(userID).collection("wallets")
            walletsRef.whereField("currency", isEqualTo: "TRY").getDocuments { snapshot, error in
                if let document = snapshot?.documents.first {
                    // Update existing wallet
                    walletsRef.document(document.documentID).setData([
                        "currency": "TRY",
                        "balance": finalBalance,
                        "userID": userID
                    ], merge: true)
                } else {
                    // Create new wallet
                    walletsRef.addDocument(data: [
                        "currency": "TRY",
                        "balance": finalBalance,
                        "userID": userID
                    ])
                }
            }
        }
    }
}
