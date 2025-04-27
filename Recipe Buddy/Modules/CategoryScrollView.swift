//
//  CategoryScrollView.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

import SwiftUI

struct CategoryScrollView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory?.id == category.id,
                        action: {
                            if selectedCategory?.id == category.id {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
}
