//
//  ShoppingListRow.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

import SwiftUI

struct ShoppingItemRow: View {
    let item: ShoppingItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                    .foregroundStyle(item.isChecked ? ._33_C_759 : .A_3_A_3_A_3)
            }
            
            VStack(alignment: .leading) {
                Text(item.ingredient.name)
                    .strikethrough(item.isChecked)
                    .foregroundStyle(item.isChecked ? .A_3_A_3_A_3 : .primary)
                
                Text("\(String(format: "%.1f", item.amount)) \(item.unit)")
                    .font(.caption)
                    .foregroundStyle(._181818)
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                }) {
                    Image(systemName: "minus.circle")
                        .foregroundStyle(.A_3_A_3_A_3)
                }
                
                Button(action: {
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.A_3_A_3_A_3)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyShoppingListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 80))
                .foregroundStyle(.A_3_A_3_A_3)
            
            Text("Alışveriş Listeniz Boş")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(._181818)
            
            Text("Tarif detaylarından malzemeleri seçerek alışveriş listenize ekleyebilirsiniz.")
                .multilineTextAlignment(.center)
                .foregroundStyle(._303030)
                .padding(.horizontal)
        }
        .padding()
    }
}
