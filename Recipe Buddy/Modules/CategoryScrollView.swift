import SwiftUI

struct CategoryScrollView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
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
                        })
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.name)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color("EBA72B") : Color("F2F2F7"))
                .foregroundStyle(isSelected ? Color("FFFFFF") : Color("181818"))
                .cornerRadius(8)
        }
    }
}

