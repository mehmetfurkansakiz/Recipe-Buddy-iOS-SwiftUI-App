//
//  RecipeCardView.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    let width: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(recipe.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width - 16, height: 150)
                .clipped()
                .cornerRadius(8)
            
            Text(recipe.name)
                .font(.headline)
                .lineLimit(1)
                .foregroundStyle(._181818)
            
            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(.A_3_A_3_A_3)
                Text("\(recipe.cookingTime) dk")
                    .font(.caption)
                    .foregroundStyle(.A_3_A_3_A_3)
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .foregroundStyle(.FFCB_1_F)
                Text(String(format: "%.1f", recipe.rating))
                    .font(.caption)
                    .foregroundStyle(.A_3_A_3_A_3)
            }
        }
        .padding(8)
        .background(Color(.FBFBFB))
        .cornerRadius(8)
        .shadow(radius: 2)
        .frame(width: width)
    }
}
