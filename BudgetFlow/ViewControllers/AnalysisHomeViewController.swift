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
        
        // Create Graphs button
        let graphsButton = UIButton(type: .system)
        graphsButton.setTitle("Graphs", for: .normal)
        graphsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        graphsButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        graphsButton.layer.cornerRadius = 12
        graphsButton.translatesAutoresizingMaskIntoConstraints = false
        graphsButton.addTarget(self, action: #selector(graphsButtonTapped), for: .touchUpInside)
        view.addSubview(graphsButton)

        // Create Predict button
        let predictButton = UIButton(type: .system)
        predictButton.setTitle("Predict", for: .normal)
        predictButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        predictButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        predictButton.layer.cornerRadius = 12
        predictButton.translatesAutoresizingMaskIntoConstraints = false
        predictButton.addTarget(self, action: #selector(predictButtonTapped), for: .touchUpInside)
        view.addSubview(predictButton)

        // Layout buttons vertically centered
        NSLayoutConstraint.activate([
            graphsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            graphsButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            graphsButton.widthAnchor.constraint(equalToConstant: 200),
            graphsButton.heightAnchor.constraint(equalToConstant: 60),

            predictButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            predictButton.topAnchor.constraint(equalTo: graphsButton.bottomAnchor, constant: 32),
            predictButton.widthAnchor.constraint(equalToConstant: 200),
            predictButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc func graphsButtonTapped() {
        performSegue(withIdentifier: "toGraphs", sender: self)
    }

    @objc func predictButtonTapped() {
        performSegue(withIdentifier: "toPredict", sender: self)
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
