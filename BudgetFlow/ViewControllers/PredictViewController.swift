//
//  PredictViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 15.06.2025.
//

import UIKit
import CoreML
import FirebaseAuth
import FirebaseFirestore

class PredictViewController: UIViewController {
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let predictionLabel = UILabel()
    private let explanationLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        setupUI()
        fetchAndPredictExpense()
    }

    private func setupUI() {
        // Card View
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 18
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)

        // Title Label
        titleLabel.text = "AI Expense Estimate"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = .systemBlue
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        // Prediction Label
        predictionLabel.text = "-- ₺"
        predictionLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        predictionLabel.textColor = .systemGreen
        predictionLabel.textAlignment = .center
        predictionLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(predictionLabel)

        // Explanation Label
        explanationLabel.text = "This is your estimated expense for next month based on your previous spending."
        explanationLabel.font = UIFont.systemFont(ofSize: 15)
        explanationLabel.textColor = .darkGray
        explanationLabel.textAlignment = .center
        explanationLabel.numberOfLines = 0
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(explanationLabel)

        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        // Layout
        NSLayoutConstraint.activate([
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            cardView.heightAnchor.constraint(equalToConstant: 240),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 28),

            predictionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            predictionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            predictionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            predictionLabel.heightAnchor.constraint(equalToConstant: 48),

            explanationLabel.topAnchor.constraint(equalTo: predictionLabel.bottomAnchor, constant: 18),
            explanationLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            explanationLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            explanationLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetchAndPredictExpense() {
        activityIndicator.startAnimating()
        predictionLabel.text = "-- ₺"
        guard let userId = Auth.auth().currentUser?.uid else {
            predictionLabel.text = "Login required"
            activityIndicator.stopAnimating()
            return
        }
        let db = Firestore.firestore()
        db.collection("transactions")
            .whereField("userID", isEqualTo: userId)
            .whereField("type", isEqualTo: "Expense")
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    self.predictionLabel.text = "Error"
                    self.explanationLabel.text = error.localizedDescription
                    self.activityIndicator.stopAnimating()
                    return
                }
                let docs = snapshot?.documents ?? []
                // Sort docs by date ascending
                let sortedDocs = docs.sorted { (doc1, doc2) -> Bool in
                    let ts1 = (doc1.data()["date"] as? Timestamp)?.dateValue() ?? Date.distantPast
                    let ts2 = (doc2.data()["date"] as? Timestamp)?.dateValue() ?? Date.distantPast
                    return ts1 < ts2
                }
                // Group by month, sum expenses
                var monthlyTotals: [String: Double] = [:]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM"
                for doc in sortedDocs {
                    let data = doc.data()
                    let amount = data["amount"] as? Double ?? 0.0
                    if let timestamp = data["date"] as? Timestamp {
                        let date = timestamp.dateValue()
                        let key = dateFormatter.string(from: date)
                        monthlyTotals[key, default: 0.0] += amount
                    }
                }
                // Sort months
                let sortedMonths = monthlyTotals.keys.sorted()
                let sortedTotals = sortedMonths.map { monthlyTotals[$0] ?? 0.0 }
                // Prepare input for model: use last N months (e.g., 3)
                let N = 3
                let inputArray = Array(sortedTotals.suffix(N))
                // If not enough data, show info
                if inputArray.count < N {
                    self.predictionLabel.text = "Not enough data"
                    self.explanationLabel.text = "You need at least \(N) months of expense data."
                    self.activityIndicator.stopAnimating()
                    return
                }
                // Prepare MLMultiArray for model input
                guard let categoryArray = try? MLMultiArray(shape: [NSNumber(value: N)], dataType: .double),
                      let transactionTypeArray = try? MLMultiArray(shape: [NSNumber(value: 1)], dataType: .double) else {
                    self.predictionLabel.text = "Model error"
                    self.activityIndicator.stopAnimating()
                    return
                }
                // Fill categoryArray with last N months' expenses
                for (i, value) in inputArray.enumerated() {
                    categoryArray[i] = NSNumber(value: value)
                }
                // transaction_type: 1 for Expense
                transactionTypeArray[0] = 1.0
                // Run model
                do {
                    let model = try BudgetFlowModel(configuration: MLModelConfiguration())
                    let output = try model.prediction(category: categoryArray, transaction_type: transactionTypeArray)
                    let predictedAmount = output.amount
                    self.predictionLabel.text = String(format: "%.2f ₺", predictedAmount)
                    self.explanationLabel.text = "This is your estimated expense for next month based on your last \(N) months."
                } catch {
                    self.predictionLabel.text = "Prediction error"
                    self.explanationLabel.text = error.localizedDescription
                }
                self.activityIndicator.stopAnimating()
            }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
