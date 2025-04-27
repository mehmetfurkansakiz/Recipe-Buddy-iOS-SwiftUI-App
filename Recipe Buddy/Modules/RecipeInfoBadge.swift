//
//  RecipeInfoBadge.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

import SwiftUI

struct RecipeInfoBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.EBA_72_B)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(.F_2_F_2_F_7))
        .cornerRadius(8)
    }
}

#Preview {
    RecipeInfoBadge(icon: "star.fill", text: "4.9")
}
