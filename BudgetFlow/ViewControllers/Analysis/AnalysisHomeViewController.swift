//
//  AnalysisHomeViewController.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 15.06.2025.
//

import UIKit

class AnalysisHomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Analysis"
        
        // Create Graphs button
        let graphsButton = UIButton(type: .system)
        graphsButton.setTitle("Graphs", for: .normal)
        graphsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
        graphsButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        graphsButton.layer.cornerRadius = 20
        graphsButton.translatesAutoresizingMaskIntoConstraints = false
        graphsButton.addTarget(self, action: #selector(graphsButtonTapped), for: .touchUpInside)
        view.addSubview(graphsButton)

        // Add icon as watermark
        let graphsIcon = UIImageView(image: UIImage(systemName: "chart.bar.fill"))
        graphsIcon.contentMode = .scaleAspectFit
        graphsIcon.tintColor = UIColor.systemBlue.withAlphaComponent(0.3)
        graphsIcon.translatesAutoresizingMaskIntoConstraints = false
        graphsButton.addSubview(graphsIcon)

        // Create Predict button
        let predictButton = UIButton(type: .system)
        predictButton.setTitle("Predict", for: .normal)
        predictButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
        predictButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        predictButton.layer.cornerRadius = 20
        predictButton.translatesAutoresizingMaskIntoConstraints = false
        predictButton.addTarget(self, action: #selector(predictButtonTapped), for: .touchUpInside)
        view.addSubview(predictButton)

        // Add icon as watermark
        let predictIcon = UIImageView(image: UIImage(systemName: "chart.line.uptrend.xyaxis"))
        predictIcon.contentMode = .scaleAspectFit
        predictIcon.tintColor = UIColor.systemGreen.withAlphaComponent(0.3)
        predictIcon.translatesAutoresizingMaskIntoConstraints = false
        predictButton.addSubview(predictIcon)

        // Create Export button
        let exportButton = UIButton(type: .system)
        exportButton.setTitle("Export", for: .normal)
        exportButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
        exportButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
        exportButton.layer.cornerRadius = 20
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        exportButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)
        view.addSubview(exportButton)

        // Add icon as watermark
        let exportIcon = UIImageView(image: UIImage(systemName: "square.and.arrow.up"))
        exportIcon.contentMode = .scaleAspectFit
        exportIcon.tintColor = UIColor.systemOrange.withAlphaComponent(0.3)
        exportIcon.translatesAutoresizingMaskIntoConstraints = false
        exportButton.addSubview(exportIcon)

        // Layout buttons vertically centered
        NSLayoutConstraint.activate([
            graphsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            graphsButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
            graphsButton.widthAnchor.constraint(equalToConstant: 280),
            graphsButton.heightAnchor.constraint(equalToConstant: 100),

            graphsIcon.centerXAnchor.constraint(equalTo: graphsButton.centerXAnchor),
            graphsIcon.centerYAnchor.constraint(equalTo: graphsButton.centerYAnchor),
            graphsIcon.widthAnchor.constraint(equalToConstant: 80),
            graphsIcon.heightAnchor.constraint(equalToConstant: 150),

            predictButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            predictButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            predictButton.widthAnchor.constraint(equalToConstant: 280),
            predictButton.heightAnchor.constraint(equalToConstant: 100),

            predictIcon.centerXAnchor.constraint(equalTo: predictButton.centerXAnchor),
            predictIcon.centerYAnchor.constraint(equalTo: predictButton.centerYAnchor),
            predictIcon.widthAnchor.constraint(equalToConstant: 80),
            predictIcon.heightAnchor.constraint(equalToConstant: 150),

            exportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exportButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 150),
            exportButton.widthAnchor.constraint(equalToConstant: 280),
            exportButton.heightAnchor.constraint(equalToConstant: 100),

            exportIcon.centerXAnchor.constraint(equalTo: exportButton.centerXAnchor),
            exportIcon.centerYAnchor.constraint(equalTo: exportButton.centerYAnchor),
            exportIcon.widthAnchor.constraint(equalToConstant: 80),
            exportIcon.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    @objc func graphsButtonTapped() {
        performSegue(withIdentifier: "toGraphs", sender: self)
    }

    @objc func predictButtonTapped() {
        performSegue(withIdentifier: "toPredict", sender: self)
    }

    @objc func exportButtonTapped() {
        performSegue(withIdentifier: "toExport", sender: self)
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
