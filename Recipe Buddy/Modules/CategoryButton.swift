//
//  CategoryButton.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

import SwiftUI

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.name)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(.EBA_72_B) : Color(.F_2_F_2_F_7))
                .foregroundStyle(isSelected ? .FFFFFF : ._181818)
                .cornerRadius(8)
        }
    }
}
