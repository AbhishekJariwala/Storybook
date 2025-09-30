//
//  AddEditStoryView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//


//
//  AddEditStoryView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI
import PhotosUI

struct AddEditStoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StorybookViewModel
    
    // Editing mode
    let storyToEdit: Story?
    
    // Form fields
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var date: Date = Date()
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var imageDataArray: [Data] = []
    
    // UI state
    @State private var isLoadingImages = false
    
    var isEditing: Bool {
        storyToEdit != nil
    }
    
    init(viewModel: StorybookViewModel, storyToEdit: Story? = nil) {
        self.viewModel = viewModel
        self.storyToEdit = storyToEdit
        
        // Initialize with existing story data if editing
        if let story = storyToEdit {
            _title = State(initialValue: story.title)
            _text = State(initialValue: story.text)
            _date = State(initialValue: story.date)
            _imageDataArray = State(initialValue: story.imageData)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Story Details") {
                    TextField("Title", text: $title)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                }
                
                Section("Your Story") {
                    TextEditor(text: $text)
                        .frame(minHeight: 200)
                }
                
                Section("Photos") {
                    // Display existing images
                    if !imageDataArray.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(imageDataArray.enumerated()), id: \.offset) { index, data in
                                    if let uiImage = UIImage(data: data) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            // Delete button
                                            Button {
                                                imageDataArray.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Circle().fill(Color.black.opacity(0.6)))
                                            }
                                            .padding(4)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Photo picker
                    PhotosPicker(
                        selection: $selectedImages,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Label("Add Photos", systemImage: "photo.on.rectangle.angled")
                    }
                    .onChange(of: selectedImages) { oldValue, newValue in
                        Task {
                            await loadImages(from: newValue)
                        }
                    }
                    
                    if isLoadingImages {
                        HStack {
                            ProgressView()
                            Text("Loading images...")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Story" : "New Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveStory()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveStory() {
        if let existingStory = storyToEdit {
            // Update existing story
            let updatedStory = Story(
                id: existingStory.id,
                title: title,
                text: text,
                date: date,
                imageData: imageDataArray
            )
            viewModel.updateStory(updatedStory)
        } else {
            // Create new story
            let newStory = Story(
                title: title,
                text: text,
                date: date,
                imageData: imageDataArray
            )
            viewModel.addStory(newStory)
        }
        
        dismiss()
    }
    
    private func loadImages(from items: [PhotosPickerItem]) async {
        isLoadingImages = true
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                // Compress image to reasonable size
                if let uiImage = UIImage(data: data),
                   let compressedData = uiImage.jpegData(compressionQuality: 0.7) {
                    await MainActor.run {
                        imageDataArray.append(compressedData)
                    }
                }
            }
        }
        
        await MainActor.run {
            isLoadingImages = false
            selectedImages = [] // Clear selection
        }
    }
}

#Preview {
    AddEditStoryView(viewModel: StorybookViewModel())
}

#Preview("Edit Mode") {
    AddEditStoryView(viewModel: StorybookViewModel(), storyToEdit: Story.example)
}