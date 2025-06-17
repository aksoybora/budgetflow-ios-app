//
//  ReportsViewController.swift
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

    let titleLabel = UILabel() // Navigation bardaki başlık

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var chartView1: UIView!
    @IBOutlet weak var chartView2: UIView!
    @IBOutlet weak var chartView3: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Analysis"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        scrollView.backgroundColor = .lightGray
        contentView.backgroundColor = .systemCyan
        
        // ScrollView ve ContentView'in translateAutoresizingMaskIntoConstraints'ı false yapalım
        // Bu, Auto Layout constraint’lerinin düzgün çalışabilmesi için gerekli.
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.isPagingEnabled = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        chartView1.translatesAutoresizingMaskIntoConstraints = false
        chartView2.translatesAutoresizingMaskIntoConstraints = false
        chartView3.translatesAutoresizingMaskIntoConstraints = false

        // 1. ScrollView'un ana view ile ilişkisini kuruyoruz
        NSLayoutConstraint.activate([
            // ScrollView'un üst, sol, sağ ve alt kenarlarını ana view ile bağlıyoruz
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        // 2. ContentView'i ScrollView'e bağlıyoruz
        NSLayoutConstraint.activate([
            // ContentView'un tüm kenarlarını ScrollView'e bağlıyoruz
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            // ContentView'in genişliğini, ScrollView'in genişliği ile orantılı yapıyoruz
            // Yani yatayda 3 ekran genişliği olacak (3 grafik var)
            contentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            contentView.widthAnchor.constraint(equalToConstant: view.frame.width * 3) // 3 grafik olacak
        ])

        // 3. İlk grafik View'ini (chartView1) ContentView'e ekliyoruz
        NSLayoutConstraint.activate([
            chartView1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            chartView1.topAnchor.constraint(equalTo: contentView.topAnchor),
            chartView1.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            chartView1.widthAnchor.constraint(equalTo: view.widthAnchor) // İlk grafik için genişlik, ekranın genişliği kadar olacak
        ])

        // 4. İkinci grafik View'ini (chartView2) ContentView'e ekliyoruz
        NSLayoutConstraint.activate([
            chartView2.leadingAnchor.constraint(equalTo: chartView1.trailingAnchor), // chartView1'in sağından başlar
            chartView2.topAnchor.constraint(equalTo: contentView.topAnchor),
            chartView2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            chartView2.widthAnchor.constraint(equalTo: view.widthAnchor) // İkinci grafik de aynı genişlikte olacak
        ])

        // 5. Üçüncü grafik View'ini (chartView3) ContentView'e ekliyoruz
        NSLayoutConstraint.activate([
            chartView3.leadingAnchor.constraint(equalTo: chartView2.trailingAnchor), // chartView2'nin sağından başlar
            chartView3.topAnchor.constraint(equalTo: contentView.topAnchor),
            chartView3.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            chartView3.widthAnchor.constraint(equalTo: view.widthAnchor), // Üçüncü grafik de aynı genişlikte olacak
            chartView3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor) // En son grafik, ContentView'in sağ kenarına bağlanır
        ])
        
        chartView1.backgroundColor = UIColor(hex: "#F7F7F7")
        chartView2.backgroundColor = UIColor(hex: "#F7F7F7")
        chartView3.backgroundColor = UIColor(hex: "#FBFBFB")
        
        setupPieChart()
        setupBarChart()
        setupBarChartt()

        }
        
        
    
    // Firestore'dan sadece kullanıcıya ait olan "Expense" (gider) verilerini alıp,
    // kategoriye göre gruplandırarak her kategori için toplam gider tutarını döndürür.
    func fetchExpensesGroupedByCategory(completion: @escaping ([String: Double]) -> Void) {
        // Şu anda oturum açmış olan kullanıcının UID'sini al
        guard let userId = Auth.auth().currentUser?.uid else {
            // Kullanıcı giriş yapmamışsa boş dictionary döndür
            completion([:])
            return
        }

        let db = Firestore.firestore() // Firestore bağlantısını oluştur

        // "transactions" koleksiyonunda, sadece bu kullanıcıya ve "Expense" tipine ait verileri filtrele
        db.collection("transactions")
            .whereField("userID", isEqualTo: userId)         // Kullanıcıya ait kayıtlar
            .whereField("type", isEqualTo: "Expense")         // Yalnızca gider kayıtları
            .getDocuments { (snapshot, error) in
                if let error = error {
                    // Hata varsa konsola yazdır ve boş veri döndür
                    print("Error fetching documents: \(error)")
                    completion([:])
                    return
                }

                var categoryTotals: [String: Double] = [:] // Kategori ismi -> toplam tutar sözlüğü

                // Tüm dökümanları gez
                for document in snapshot?.documents ?? [] {
                    let data = document.data() // Her belge verisini al

                    // "category" alanı yoksa varsayılan olarak "Other" ata
                    let category = data["category"] as? String ?? "Other"

                    // "amount" alanı yoksa 0.0 ata
                    let amount = data["amount"] as? Double ?? 0.0

                    // Aynı kategori varsa mevcut tutara ekle, yoksa sıfırdan başlat
                    categoryTotals[category, default: 0.0] += amount
                }

                // Elde edilen toplamları konsola yaz (geliştirme sürecinde kontrol amaçlı)
                print("Kategoriye göre toplamlar: \(categoryTotals)")

                // Closure aracılığıyla verileri dışarıya gönder
                completion(categoryTotals)
            }
    }


    
    
    
    // Pie chart'ı ve altındaki kategori açıklamalarını (legend) dinamik olarak oluşturur
    func setupPieChart() {
        // --- 1. Başlık Etiketi (Label) Oluşturuluyor ---
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Expense Breakdown by Category" // Başlık metni
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold) // Font ayarı
        titleLabel.textAlignment = .left // Yazıyı sola hizala
        chartView1.addSubview(titleLabel)

        // Başlığın konumlandırılması
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: chartView1.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: chartView1.leadingAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 28)
        ])

        // --- 2. Pie Chart Görseli Oluşturuluyor ---
        let pieChart = PieChartView()
        pieChart.translatesAutoresizingMaskIntoConstraints = false
        chartView1.addSubview(pieChart)

        // Pie Chart'ın konumu ve boyutlandırılması
        NSLayoutConstraint.activate([
            pieChart.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            pieChart.leadingAnchor.constraint(equalTo: chartView1.leadingAnchor, constant: 8),
            pieChart.trailingAnchor.constraint(equalTo: chartView1.trailingAnchor, constant: -8),
            pieChart.heightAnchor.constraint(equalToConstant: 360)
        ])

        // --- 3. Grafik Altına Özel Legend (Açıklamalar) Alanı ---
        let legendView = UIView()
        legendView.translatesAutoresizingMaskIntoConstraints = false
        chartView1.addSubview(legendView)

        NSLayoutConstraint.activate([
            legendView.topAnchor.constraint(equalTo: pieChart.bottomAnchor, constant: 8),
            legendView.leadingAnchor.constraint(equalTo: chartView1.leadingAnchor, constant: 16),
            legendView.trailingAnchor.constraint(equalTo: chartView1.trailingAnchor, constant: -16),
            legendView.bottomAnchor.constraint(equalTo: chartView1.bottomAnchor, constant: -8)
        ])

        // --- 4. Firestore'dan Verileri Çek ve Grafiği Oluştur ---
        fetchExpensesGroupedByCategory { categoryTotals in
            DispatchQueue.main.async {
                let total = categoryTotals.values.reduce(0, +) // Tüm kategorilerin toplamı

                // Eğer toplam gider 0 ise grafik oluşturulmaz
                guard total > 0 else {
                    print("Toplam 0, grafik çizilmeyecek.")
                    return
                }

                let minDisplayPercentage = 10.0 // %10'dan küçük olan kategorilere etiket (label) gösterilmez

                var entries: [PieChartDataEntry] = [] // Pie chart için veri girişleri
                var colors: [UIColor] = [] // Dilim renkleri
                var legendItems: [(color: UIColor, category: String, percentage: Double, amount: Double)] = []

                // Dilim renkleri için özel bir renk dizisi
                let customColors: [UIColor] = [
                    .systemBlue, .systemGreen, .systemOrange,
                    .systemRed, .systemPurple, .systemTeal,
                    .systemYellow, .brown, .systemIndigo
                ]

                var colorIndex = 0 // Renk dizisini sırasıyla kullanmak için indeks

                // Her kategori için Pie dilimi oluşturuluyor
                for (category, amount) in categoryTotals {
                    let percentage = (amount / total) * 100 // Yüzdelik oran

                    // Eğer oran %10'dan fazlaysa, etikette kategori + yüzde göster
                    let label: String? = percentage >= minDisplayPercentage
                        ? "\(category) \(String(format: "%.1f", percentage))%"
                        : nil

                    // PieChartDataEntry oluştur
                    let entry = PieChartDataEntry(value: amount, label: label, data: amount as AnyObject)
                    entries.append(entry)

                    // Renk ata
                    let color = customColors[colorIndex % customColors.count]
                    colors.append(color)
                    colorIndex += 1

                    // Legend listesine bu öğeyi ekle
                    legendItems.append((color: color, category: category, percentage: percentage, amount: amount))
                }

                // Veri seti oluşturuluyor
                let dataSet = PieChartDataSet(entries: entries, label: "Data")
                dataSet.colors = colors // Dilim renkleri
                dataSet.sliceSpace = 4  // Dilimler arası boşluk

                dataSet.drawValuesEnabled = false // Dilim üstünde değer göstermeyi kapat

                let data = PieChartData(dataSet: dataSet)
                data.setValueTextColor(.black)

                // Pie chart konfigürasyonu
                pieChart.data = data
                pieChart.chartDescription.enabled = false // Açıklama metni kapatıldı
                pieChart.legend.enabled = false // Kendi legend'imizi kullanıyoruz
                pieChart.highlightPerTapEnabled = true // Dilime tıklanınca vurgulansın
                pieChart.notifyDataSetChanged()

                // --- 5. Legend (Alt Açıklamalar) Oluşturuluyor ---
                // Eski legend alt elemanlarını temizle
                legendView.subviews.forEach { $0.removeFromSuperview() }

                var previousRow: UIView? = nil // İlk satır için başlangıç referansı

                for item in legendItems {
                    // --- Renk Kutusu ---
                    let colorBox = UIView()
                    colorBox.backgroundColor = item.color
                    colorBox.translatesAutoresizingMaskIntoConstraints = false
                    colorBox.layer.cornerRadius = 4
                    colorBox.layer.masksToBounds = true

                    // --- Kategori İsmi ---
                    let categoryLabel = UILabel()
                    categoryLabel.translatesAutoresizingMaskIntoConstraints = false
                    categoryLabel.text = item.category
                    categoryLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)

                    // --- Yüzde Bilgisi ---
                    let percentageLabel = UILabel()
                    percentageLabel.translatesAutoresizingMaskIntoConstraints = false
                    percentageLabel.text = String(format: "%.1f%%", item.percentage)
                    percentageLabel.font = UIFont.systemFont(ofSize: 14)
                    percentageLabel.textColor = .darkGray

                    // --- Tutar Bilgisi ---
                    let amountLabel = UILabel()
                    amountLabel.translatesAutoresizingMaskIntoConstraints = false
                    amountLabel.text = String(format: "%.2f ₺", item.amount)
                    amountLabel.font = UIFont.systemFont(ofSize: 14)
                    amountLabel.textColor = .darkGray

                    // --- Satır Container View ---
                    let rowView = UIView()
                    rowView.translatesAutoresizingMaskIntoConstraints = false
                    rowView.addSubview(colorBox)
                    rowView.addSubview(categoryLabel)
                    rowView.addSubview(percentageLabel)
                    rowView.addSubview(amountLabel)
                    legendView.addSubview(rowView)

                    // Renk ve label'ların satır içindeki konumları
                    NSLayoutConstraint.activate([
                        colorBox.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
                        colorBox.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
                        colorBox.widthAnchor.constraint(equalToConstant: 16),
                        colorBox.heightAnchor.constraint(equalToConstant: 16),

                        categoryLabel.leadingAnchor.constraint(equalTo: colorBox.trailingAnchor, constant: 8),
                        categoryLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),

                        percentageLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 12),
                        percentageLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),

                        amountLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
                        amountLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
                    ])

                    // Bu satırın legendView içindeki konumu
                    NSLayoutConstraint.activate([
                        rowView.leadingAnchor.constraint(equalTo: legendView.leadingAnchor),
                        rowView.trailingAnchor.constraint(equalTo: legendView.trailingAnchor),
                        previousRow == nil
                            ? rowView.topAnchor.constraint(equalTo: legendView.topAnchor)
                            : rowView.topAnchor.constraint(equalTo: previousRow!.bottomAnchor, constant: 8),
                        rowView.heightAnchor.constraint(equalToConstant: 24)
                    ])

                    // Bir sonraki satır için referansı güncelle
                    previousRow = rowView
                }
            }
        }
    }





    
    func fetchMonthlyIncomeExpense(completion: @escaping ([(month: String, income: Double, expense: Double)]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        let db = Firestore.firestore()
        db.collection("transactions")
            .whereField("userID", isEqualTo: userId)
            // İstersen burada tarih filtresi eklenebilir, şimdilik tümü çekiliyor
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching transactions: \(error)")
                    completion([])
                    return
                }
                
                var monthlyData: [String: (income: Double, expense: Double)] = [:]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM yyyy" // Örneğin "May 2025"
                
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    let amount = data["amount"] as? Double ?? 0.0
                    let type = data["type"] as? String ?? ""
                    
                    if let timestamp = data["date"] as? Timestamp {
                        let date = timestamp.dateValue()
                        let monthString = dateFormatter.string(from: date)
                        
                        if monthlyData[monthString] == nil {
                            monthlyData[monthString] = (income: 0, expense: 0)
                        }
                        
                        if type == "Income" {
                            monthlyData[monthString]?.income += amount
                        } else if type == "Expense" {
                            monthlyData[monthString]?.expense += amount
                        }
                    }
                }
                
                // Ayların sıralı gelmesi için sort edelim
                let sortedMonthlyData = monthlyData.sorted { (lhs, rhs) -> Bool in
                    dateFormatter.date(from: lhs.key)! < dateFormatter.date(from: rhs.key)!
                }
                .map { (month: $0.key, income: $0.value.income, expense: $0.value.expense) }
                
                completion(sortedMonthlyData)
            }
    }



    
    
    
    func setupBarChart() {
        // Başlık label'ı oluştur
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Monthly Income-Expense Breakdown" // Başlık metni
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold) // Yazı tipi ve kalınlık
        titleLabel.textAlignment = .left // Sola hizala
        chartView2.addSubview(titleLabel) // Başlığı chartView2'ye ekle

        // Başlık için Auto Layout kısıtlamaları
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: chartView2.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: chartView2.leadingAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 28)
        ])

        // Bar chart view oluştur
        let barChart = BarChartView()
        barChart.translatesAutoresizingMaskIntoConstraints = false
        chartView2.addSubview(barChart)

        // Bar chart için Auto Layout kısıtlamaları (başlığın altına konumlandır)
        NSLayoutConstraint.activate([
            barChart.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            barChart.leadingAnchor.constraint(equalTo: chartView2.leadingAnchor, constant: 8),
            barChart.trailingAnchor.constraint(equalTo: chartView2.trailingAnchor, constant: -8),
            barChart.bottomAnchor.constraint(equalTo: chartView2.bottomAnchor, constant: -8)
        ])

        // Verileri Firestore'dan çek
        fetchMonthlyIncomeExpense { monthlyData in
            DispatchQueue.main.async {
                guard monthlyData.count > 0 else {
                    print("Aylık veri yok, grafik çizilmeyecek.")
                    return
                }

                let months = monthlyData.map { $0.month } // X ekseni etiketleri

                var incomeEntries: [BarChartDataEntry] = [] // Gelir çubukları
                var expenseEntries: [BarChartDataEntry] = [] // Gider çubukları

                for (index, data) in monthlyData.enumerated() {
                    incomeEntries.append(BarChartDataEntry(x: Double(index), y: data.income))
                    expenseEntries.append(BarChartDataEntry(x: Double(index), y: data.expense))
                }

                // Gelir için veri seti
                let incomeDataSet = BarChartDataSet(entries: incomeEntries, label: "Gelir")
                incomeDataSet.colors = [.systemGreen] // Renk

                // Gider için veri seti
                let expenseDataSet = BarChartDataSet(entries: expenseEntries, label: "Gider")
                expenseDataSet.colors = [.systemRed] // Renk

                // Bar chart veri setlerini oluştur
                let data = BarChartData(dataSets: [incomeDataSet, expenseDataSet])

                // Bar boyutları ve boşluklar (gruplanmış yapı için gerekli)
                let groupSpace = 0.2
                let barSpace = 0.05
                let barWidth = 0.35

                data.barWidth = barWidth

                let groupCount = months.count
                let startX = 0.0
                let groupWidth = data.groupWidth(groupSpace: groupSpace, barSpace: barSpace)

                // X ekseni minimum ve maksimum değerleri
                barChart.xAxis.axisMinimum = startX
                barChart.xAxis.axisMaximum = startX + groupWidth * Double(groupCount)

                // Gruplamayı uygula
                data.groupBars(fromX: startX, groupSpace: groupSpace, barSpace: barSpace)

                barChart.data = data // Veriyi grafiğe ata

                // X ekseni ayarları
                barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: months) // Ay isimleri
                barChart.xAxis.granularity = 1
                barChart.xAxis.labelPosition = .bottom
                barChart.xAxis.centerAxisLabelsEnabled = true // Grupların ortasına yazı gelsin

                // Y ekseni ve diğer görsel ayarlar
                barChart.rightAxis.enabled = false // Sağ ekseni kaldır
                barChart.animate(yAxisDuration: 1.0) // Animasyon
                barChart.legend.enabled = true // Legend açık
                barChart.chartDescription.enabled = false // Açıklama yok
            }
        }
    }



    
    
    
    func setupBarChartt() {
        let barChart = BarChartView()
        barChart.translatesAutoresizingMaskIntoConstraints = false
        barChart.isUserInteractionEnabled = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Cüzdan Bakiyeleri"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .left
        chartView3.addSubview(titleLabel)
        chartView3.addSubview(barChart)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: chartView3.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: chartView3.leadingAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 28),

            barChart.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            barChart.leadingAnchor.constraint(equalTo: chartView3.leadingAnchor, constant: 16),
            barChart.trailingAnchor.constraint(equalTo: chartView3.trailingAnchor, constant: -16),
            barChart.bottomAnchor.constraint(equalTo: chartView3.bottomAnchor, constant: -16)
        ])

        let wallets = ["Ana Hesap", "Nakit", "Birikim"]
        let balances: [Double] = [3500, 1500, 8000]

        var dataEntries: [BarChartDataEntry] = []
        for (i, value) in balances.enumerated() {
            dataEntries.append(BarChartDataEntry(x: Double(i), y: value))
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bakiye")
        chartDataSet.colors = [UIColor.systemBlue]
        let chartData = BarChartData(dataSet: chartDataSet)

        barChart.data = chartData
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: wallets)
        barChart.xAxis.labelPosition = .bottom
        barChart.legend.enabled = false
        barChart.rightAxis.enabled = false
        barChart.chartDescription.enabled = false
    }
    
}
