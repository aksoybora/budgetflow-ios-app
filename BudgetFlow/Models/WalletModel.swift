//
//  WalletModel.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 21.03.2025.
//

import FirebaseFirestore

struct Wallet {
    let currency: String  // "TRY", "USD", "EUR"
    let balance: Double   // Bakiye (0.00 ile başlar)
    let userID: String    // Hangi kullanıcıya ait olduğu

    // Firestore belgesinden Wallet oluşturmak için
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let currency = data["currency"] as? String,
              let balance = data["balance"] as? Double,
              let userID = data["userID"] as? String else {
            return nil
        }
        self.currency = currency
        self.balance = balance
        self.userID = userID
    }
}
