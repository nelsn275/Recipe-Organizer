import SwiftUI
import UIKit

// Recipe Class
class Recipe: Identifiable {
    let id = UUID()
    let RecipeName: String
    let RecipeType: String
    let RecipeContents: UIImage?
    
    init(RecipeName: String, RecipeType: String, RecipeContents: UIImage?) {
        self.RecipeName = RecipeName
        self.RecipeType = RecipeType
        self.RecipeContents = RecipeContents
    }
}

// Enum for Recipe Types
enum RecipeType: String, CaseIterable, Identifiable {
    case appetizer = "Appetizer"
    case entree = "Entree"
    case dessert = "Dessert"
    
    var id: String { self.rawValue }
}

// ImagePicker to select image from photo library
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// RecipeDetailView to display recipe image in full screen
struct RecipeDetailView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack {
            if let image = recipe.RecipeContents {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("No image available")
                    .font(.headline)
            }
        }
        .navigationTitle(recipe.RecipeName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// RecipeListView to display recipes grouped by type
struct RecipeListView: View {
    @Binding var recipes: [Recipe]
    
    var body: some View {
        List {
            ForEach(RecipeType.allCases) { type in
                Section(header: Text(type.rawValue)) {
                    ForEach(recipes.filter { $0.RecipeType == type.rawValue }) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            HStack {
                                if let image = recipe.RecipeContents {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                }
                                VStack(alignment: .leading) {
                                    Text(recipe.RecipeName)
                                        .font(.headline)
                                    Text(recipe.RecipeType)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Recipes")
    }
}

// ContentView for adding new recipes and navigating to RecipeListView
struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var recipeName = ""
    @State private var selectedRecipeType: RecipeType = .appetizer
    @State private var recipes = [Recipe]()
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Recipe Name", text: $recipeName)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                
                Picker("Select Recipe Type", selection: $selectedRecipeType) {
                    ForEach(RecipeType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Button to pick image
                Button(action: {
                    showingImagePicker = true
                }) {
                    Text("Pick Image")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // Display selected image
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
                
                Button(action: {
                    // Add new recipe with selected image
                    let newRecipe = Recipe(RecipeName: recipeName, RecipeType: selectedRecipeType.rawValue, RecipeContents: selectedImage)
                    recipes.append(newRecipe)
                    
                    // Reset fields
                    recipeName = ""
                    selectedRecipeType = .appetizer
                    selectedImage = nil
                }) {
                    Text("Add Recipe")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                NavigationLink(destination: RecipeListView(recipes: $recipes)) {
                    Text("View Recipes")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
