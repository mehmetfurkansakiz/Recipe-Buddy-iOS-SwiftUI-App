//
//  SearchBarView.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.A_3_A_3_A_3)
            
            TextField("Tarif Ara...", text: $searchText)
                .padding(8)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.A_3_A_3_A_3)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color(.F_2_F_2_F_7))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.vertical, 0)
    }
}

#Preview {
    SearchBarView(searchText: .constant(""))
}
