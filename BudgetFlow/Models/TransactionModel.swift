//
//  TransactionModel.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 13.03.2025.
//

import Foundation
import FirebaseFirestore

struct Transaction {
    let title: String
    let description: String
    let amount: String
    let currency: String
    let category: String
    let type: String
    let date: Timestamp
    let walletID: String
}
