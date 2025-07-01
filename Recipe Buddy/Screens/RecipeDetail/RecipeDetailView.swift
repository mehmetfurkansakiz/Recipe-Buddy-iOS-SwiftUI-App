import SwiftUI

struct RecipeDetailView: View {
    @StateObject var viewModel: RecipeDetailViewModel
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    init(viewModel: RecipeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    recipeImageHeader
                    
                    VStack(alignment: .leading, spacing: 16) {
                        recipeInfoSection
                        Divider()
                        ingredientsSection
                        Divider()
                        preparationSection
                        Divider()
                        addToShoppingListButton
                        Spacer(minLength: 64)
                    }
                    .padding()
                }
            }
            .navigationBarBackButtonHidden()
            .ignoresSafeArea(edges: .top)
        }
    }
    
    // MARK: - View Components
    private var recipeImageHeader: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                AsyncImage(url: viewModel.recipe.imagePublicURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.1)
                        ProgressView()
                    }
                }
                .frame(width: geo.size.width, height: max(geo.size.height, geo.frame(in: .global).minY > 0 ? geo.size.height + geo.frame(in: .global).minY : geo.size.height))
                .clipped()
                .offset(y: geo.frame(in: .global).minY > 0 ? -geo.frame(in: .global).minY : 0)
                
                // BackButton
                Button(action: {
                    dismiss()
                }) {
                    ZStack(alignment: .center) {
                        Circle()
                            .fill(Color("000000").opacity(0.5))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(Color("FFFFFF"))
                            
                    }
                }
                .padding(.leading, 16)
                .padding(.top, 48)
            }
        }
        .frame(minHeight: 300)
    }
    
    private var recipeInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(viewModel.recipe.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("181818"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if viewModel.isOwnedByCurrentUser {
                    Button(action: {
                        // TODO: added navigation to edit recipe view
                        print("Düzenle butonuna basıldı!")
                    }) {
                        Image("pencil.icon")
                            .resizable()
                            .foregroundStyle(Color("A3A3A3"))
                            .frame(width: 32, height: 32)
                    }
                }
                
                Button(action: {
                    viewModel.toggleFavorite()
                }) {
                    Image(viewModel.isFavorite ? "heart.fill.icon" : "heart.icon")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(viewModel.isFavorite ? Color("FF2A1F") : Color("A3A3A3"))
                }
            }
            
            Text(viewModel.recipe.description)
                .font(.subheadline)
                .foregroundStyle(Color("303030"))
            
            if let recipeAuthor = viewModel.recipe.user?.fullName {
                HStack {
                    Image("user.icon")
                        .font(.caption)
                    Text("\(recipeAuthor)")
                        .font(.caption)
                }
                .foregroundStyle(Color("A3A3A3"))
                .padding(.top, 4)
            }
            
            HStack {
                RecipeInfoBadge(icon: "alarm.icon", text: "\(viewModel.recipe.cookingTime) dk", color: Color("181818"))
                RecipeInfoBadge(icon: "people.icon", text: "\(viewModel.recipe.servings)", color: Color("181818"))
                if let rating = viewModel.recipe.rating {
                    RecipeInfoBadge(icon: "star.fill.icon", text: String(format: "%.1f", rating), color: Color("FFCB1F"))
                } else {
                    RecipeInfoBadge(icon: "star.icon", text: "0(0)", color: Color("C2C2C2"))
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.recipe.categories) { recipeCategory in
                        Text(recipeCategory.category.name)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color("EBA72B").opacity(0.2))
                            .foregroundStyle(Color("EBA72B"))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Malzemeler")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color("181818"))
            
            ForEach(viewModel.recipe.ingredients) { recipeIngredient in
                HStack {
                    Image("circle.fill.icon")
                        .resizable()
                        .foregroundStyle(Color("EBA72B"))
                        .frame(width: 12, height: 12)
                    
                    Text("\(recipeIngredient.formattedAmount) \(recipeIngredient.unit) \(recipeIngredient.ingredient.name)")
                                .foregroundStyle(Color("303030"))
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.toggleIngredientSelection(recipeIngredient)
                    }) {
                        Image(viewModel.isIngredientSelected(recipeIngredient.ingredient) ? "checkbox.check.icon" : "checkbox.unchecked.icon")
                            .resizable()
                            .foregroundStyle(viewModel.isIngredientSelected(recipeIngredient.ingredient) ? Color("33C759") : Color("A3A3A3"))
                            .frame(width: 18, height: 18)
                    }
                }
                .padding(.vertical, 4)
            }
            
            Button(action: {
                viewModel.toggleAllIngredients()
            }) {
                Text(viewModel.areAllIngredientsSelected ? "Tüm Seçimleri Kaldır" : "Tümünü Seç")
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color("EBA72B").opacity(0.8))
            }
            .padding(.top, 8)
        }
    }
    
    private var preparationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hazırlanışı")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color("181818"))
            
            ForEach(Array(viewModel.recipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top) {
                    Text("\(index + 1).")
                        .font(.headline)
                        .foregroundStyle(Color("A3A3A3"))
                    
                    Text(step)
                        .foregroundStyle(Color("303030"))
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private var addToShoppingListButton: some View {
        Button(action: {
            viewModel.addSelectedIngredientsToShoppingList()
            viewModel.showingShoppingListAlert = true
        }) {
            VStack {
                HStack(spacing: 8) {
                    Image("cart.icon")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(Color("FFFFFF"))
                    
                    Text("Seçili Malzemeleri Alışveriş Listesine Ekle")
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("EBA72B"))
            .foregroundStyle(Color("FFFFFF"))
            .cornerRadius(8)
        }
        .disabled(viewModel.selectedIngredients.isEmpty)
        .opacity(viewModel.selectedIngredients.isEmpty ? 0.6 : 1)
        .alert(isPresented: $viewModel.showingShoppingListAlert) {
            Alert(
                title: Text("Başarılı"),
                message: Text("Seçili malzemeler alışveriş listenize eklendi."),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
}

#Preview("Kullanıcının Kendi Tarifi (Düzenle Butonu Görünür)") {
    NavigationStack {
        let viewModel = RecipeDetailViewModel(
            recipe: Recipe.mockOwnedByCurrentUser,
            isOwnedForPreview: true
        )
        
        RecipeDetailView(viewModel: viewModel)
    }
}
