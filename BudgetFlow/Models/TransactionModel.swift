//
//  TransactionModel.swift
//  BudgetFlow
//
//  Created by Bora Aksoy on 13.03.2025.
//

import Foundation
import FirebaseFirestore

// Uygulamadaki işlemleri temsil eden model
struct Transaction {
    let title: String // İşlem başlığı
    let description: String // İşlem açıklaması
    let amount: String // İşlem tutarı
    let currency: String // Para birimi
    let category: String // Kategori
    let type: String // İşlem tipi (gelir/gider)
    let date: Timestamp // İşlem tarihi
    let walletID: String // İşlemin ait olduğu cüzdanın ID'si
}
