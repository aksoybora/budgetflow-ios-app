//
//  AnalysisViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 3.02.2025.
//

import UIKit
import DGCharts
import Charts
import FirebaseAuth
import FirebaseFirestore

class AnalysisViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = true
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
        label.text = "Financial Analysis"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Track your spending patterns and financial health"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pieChartCard: UIView = {
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
    
    private let barChartCard: UIView = {
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
    
    private let walletChartCard: UIView = {
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCharts()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        
        // Add views to hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(pieChartCard)
        contentView.addSubview(barChartCard)
        contentView.addSubview(walletChartCard)
        
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
            
            pieChartCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            pieChartCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            pieChartCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pieChartCard.heightAnchor.constraint(equalToConstant: 480),
            
            barChartCard.topAnchor.constraint(equalTo: pieChartCard.bottomAnchor, constant: 24),
            barChartCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            barChartCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            barChartCard.heightAnchor.constraint(equalToConstant: 400),
            
            walletChartCard.topAnchor.constraint(equalTo: barChartCard.bottomAnchor, constant: 24),
            walletChartCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            walletChartCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            walletChartCard.heightAnchor.constraint(equalToConstant: 400),
            walletChartCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupCharts() {
        setupPieChart()
        setupBarChart()
        setupBarChartt()
    }
    
    // MARK: - Chart Setup
    private func setupPieChart() {
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Expense Breakdown by Category"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pieChartCard.addSubview(titleLabel)
        
        // Pie Chart
        let pieChart = PieChartView()
        pieChart.translatesAutoresizingMaskIntoConstraints = false
        pieChartCard.addSubview(pieChart)
        
        // Legend View
        let legendView = UIView()
        legendView.translatesAutoresizingMaskIntoConstraints = false
        pieChartCard.addSubview(legendView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: pieChartCard.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: pieChartCard.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: pieChartCard.trailingAnchor, constant: -16),
            
            pieChart.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            pieChart.leadingAnchor.constraint(equalTo: pieChartCard.leadingAnchor, constant: 16),
            pieChart.trailingAnchor.constraint(equalTo: pieChartCard.trailingAnchor, constant: -16),
            pieChart.heightAnchor.constraint(equalToConstant: 280),
            
            legendView.topAnchor.constraint(equalTo: pieChart.bottomAnchor, constant: 16),
            legendView.leadingAnchor.constraint(equalTo: pieChartCard.leadingAnchor, constant: 16),
            legendView.trailingAnchor.constraint(equalTo: pieChartCard.trailingAnchor, constant: -16),
            legendView.bottomAnchor.constraint(equalTo: pieChartCard.bottomAnchor, constant: -16)
        ])
        
        // Fetch and setup data
        fetchExpensesGroupedByCategory { [weak self] categoryTotals in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let total = categoryTotals.values.reduce(0, +)
                guard total > 0 else { return }
                
                let minDisplayPercentage = 10.0
                var entries: [PieChartDataEntry] = []
                var colors: [UIColor] = []
                var legendItems: [(color: UIColor, category: String, percentage: Double, amount: Double)] = []
                
                let customColors: [UIColor] = [
                    .systemBlue, .systemGreen, .systemOrange,
                    .systemRed, .systemPurple, .systemTeal,
                    .systemYellow, .brown, .systemIndigo
                ]
                
                var colorIndex = 0
                
                for (category, amount) in categoryTotals {
                    let percentage = (amount / total) * 100
                    let color = customColors[colorIndex % customColors.count]
                    
                    entries.append(PieChartDataEntry(value: amount, label: percentage >= minDisplayPercentage ? category : ""))
                    colors.append(color)
                    legendItems.append((color: color, category: category, percentage: percentage, amount: amount))
                    
                    colorIndex += 1
                }
                
                let dataSet = PieChartDataSet(entries: entries, label: "")
                dataSet.colors = colors
                dataSet.valueFont = .systemFont(ofSize: 14)
                dataSet.entryLabelFont = .systemFont(ofSize: 14)
                
                let data = PieChartData(dataSet: dataSet)
                pieChart.data = data
                pieChart.legend.enabled = false
                pieChart.animate(xAxisDuration: 1.0)
                
                // Update legend
                legendView.subviews.forEach { $0.removeFromSuperview() }
                var previousRow: UIView? = nil
                
                for item in legendItems {
                    let rowStack = UIStackView()
                    rowStack.axis = .horizontal
                    rowStack.spacing = 8
                    rowStack.alignment = .center
                    rowStack.translatesAutoresizingMaskIntoConstraints = false
                    
                    let colorBox = UIView()
                    colorBox.backgroundColor = item.color
                    colorBox.layer.cornerRadius = 4
                    colorBox.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        colorBox.widthAnchor.constraint(equalToConstant: 16),
                        colorBox.heightAnchor.constraint(equalToConstant: 16)
                    ])
                    
                    let textStack = UIStackView()
                    textStack.axis = .horizontal
                    textStack.spacing = 4
                    textStack.distribution = .equalSpacing
                    
                    let categoryLabel = UILabel()
                    categoryLabel.text = item.category
                    categoryLabel.font = .systemFont(ofSize: 14, weight: .medium)
                    
                    let detailsLabel = UILabel()
                    detailsLabel.text = String(format: "%.1f%% (%.2f ₺)", item.percentage, item.amount)
                    detailsLabel.font = .systemFont(ofSize: 14)
                    detailsLabel.textColor = .secondaryLabel
                    
                    textStack.addArrangedSubview(categoryLabel)
                    textStack.addArrangedSubview(detailsLabel)
                    
                    rowStack.addArrangedSubview(colorBox)
                    rowStack.addArrangedSubview(textStack)
                    
                    legendView.addSubview(rowStack)
                    
                    if let previous = previousRow {
                        rowStack.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 8).isActive = true
                    } else {
                        rowStack.topAnchor.constraint(equalTo: legendView.topAnchor).isActive = true
                    }
                    
                    rowStack.leadingAnchor.constraint(equalTo: legendView.leadingAnchor).isActive = true
                    rowStack.trailingAnchor.constraint(equalTo: legendView.trailingAnchor).isActive = true
                    
                    previousRow = rowStack
                }
                
                if let last = previousRow {
                    last.bottomAnchor.constraint(equalTo: legendView.bottomAnchor).isActive = true
                }
            }
        }
    }
    
    private func setupBarChart() {
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Monthly Income-Expense Breakdown"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        barChartCard.addSubview(titleLabel)
        
        // Bar Chart
        let barChart = BarChartView()
        barChart.translatesAutoresizingMaskIntoConstraints = false
        barChartCard.addSubview(barChart)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: barChartCard.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: barChartCard.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: barChartCard.trailingAnchor, constant: -16),
            
            barChart.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            barChart.leadingAnchor.constraint(equalTo: barChartCard.leadingAnchor, constant: 16),
            barChart.trailingAnchor.constraint(equalTo: barChartCard.trailingAnchor, constant: -16),
            barChart.bottomAnchor.constraint(equalTo: barChartCard.bottomAnchor, constant: -16)
        ])
        
        // Fetch and setup data
        fetchMonthlyIncomeAndExpense { [weak self] monthlyData in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let months = monthlyData.map { $0.month }
                
                let incomeEntries = monthlyData.enumerated().map { (i, data) in
                    BarChartDataEntry(x: Double(i), y: data.income)
                }
                
                let expenseEntries = monthlyData.enumerated().map { (i, data) in
                    BarChartDataEntry(x: Double(i), y: data.expense)
                }
                
                let incomeDataSet = BarChartDataSet(entries: incomeEntries, label: "Income")
                incomeDataSet.setColor(.systemGreen)
                
                let expenseDataSet = BarChartDataSet(entries: expenseEntries, label: "Expense")
                expenseDataSet.setColor(.systemRed)
                
                let data = BarChartData(dataSets: [incomeDataSet, expenseDataSet])
                
                let groupSpace = 0.3
                let barSpace = 0.05
                let barWidth = 0.3
                
                data.barWidth = barWidth
                let startX = 0.0
                data.groupBars(fromX: startX, groupSpace: groupSpace, barSpace: barSpace)
                
                barChart.data = data
                barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
                barChart.xAxis.granularity = 1
                barChart.xAxis.labelPosition = .bottom
                barChart.xAxis.centerAxisLabelsEnabled = true
                barChart.rightAxis.enabled = false
                barChart.animate(yAxisDuration: 1.0)
                barChart.legend.enabled = true
                barChart.chartDescription.enabled = false
            }
        }
    }
    
    private func setupBarChartt() {
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Wallet Balances"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        walletChartCard.addSubview(titleLabel)
        
        // Bar Chart
        let barChart = BarChartView()
        barChart.translatesAutoresizingMaskIntoConstraints = false
        walletChartCard.addSubview(barChart)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: walletChartCard.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: walletChartCard.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: walletChartCard.trailingAnchor, constant: -16),
            
            barChart.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            barChart.leadingAnchor.constraint(equalTo: walletChartCard.leadingAnchor, constant: 16),
            barChart.trailingAnchor.constraint(equalTo: walletChartCard.trailingAnchor, constant: -16),
            barChart.bottomAnchor.constraint(equalTo: walletChartCard.bottomAnchor, constant: -16)
        ])
        
        let wallets = ["Main Account", "Cash", "Savings"]
        let balances: [Double] = [3500, 1500, 8000]
        
        var dataEntries: [BarChartDataEntry] = []
        for (i, value) in balances.enumerated() {
            dataEntries.append(BarChartDataEntry(x: Double(i), y: value))
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Balance")
        chartDataSet.colors = [UIColor.systemBlue]
        let chartData = BarChartData(dataSet: chartDataSet)
        
        barChart.data = chartData
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: wallets)
        barChart.xAxis.labelPosition = .bottom
        barChart.legend.enabled = false
        barChart.rightAxis.enabled = false
        barChart.chartDescription.enabled = false
        barChart.animate(yAxisDuration: 1.0)
    }
    
    // MARK: - Data Fetching
    private func fetchExpensesGroupedByCategory(completion: @escaping ([String: Double]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("transactions")
            .whereField("userID", isEqualTo: userID)
            .whereField("type", isEqualTo: "Expense")
            .getDocuments { (snapshot, error) in
                var categoryTotals: [String: Double] = [:]
                
                if let error = error {
                    print("Error fetching expenses: \(error)")
                    completion([:])
                    return
                }
                
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    if let category = data["category"] as? String,
                       let amount = data["amount"] as? Double {
                        categoryTotals[category, default: 0] += amount
                    }
                }
                
                completion(categoryTotals)
            }
    }
    
    private func fetchMonthlyIncomeAndExpense(completion: @escaping ([(month: String, income: Double, expense: Double)]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("transactions")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching transactions: \(error)")
                    completion([])
                    return
                }
                
                var monthlyData: [String: (income: Double, expense: Double)] = [:]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM yyyy"
                
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    if let timestamp = data["date"] as? Timestamp,
                       let type = data["type"] as? String,
                       let amount = data["amount"] as? Double {
                        let date = timestamp.dateValue()
                        let monthKey = dateFormatter.string(from: date)
                        
                        var currentData = monthlyData[monthKey] ?? (income: 0, expense: 0)
                        if type == "Income" {
                            currentData.income += amount
                        } else if type == "Expense" {
                            currentData.expense += amount
                        }
                        monthlyData[monthKey] = currentData
                    }
                }
                
                let sortedMonthlyData = monthlyData.sorted { (lhs, rhs) -> Bool in
                    dateFormatter.date(from: lhs.key)! < dateFormatter.date(from: rhs.key)!
                }
                .map { (month: $0.key, income: $0.value.income, expense: $0.value.expense) }
                
                completion(sortedMonthlyData)
            }
    }
}
