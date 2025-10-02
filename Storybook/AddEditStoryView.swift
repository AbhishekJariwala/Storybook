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
        ZStack {
            backgroundView
            mainContentView
        }
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        Color.darkBackground
            .ignoresSafeArea()
    }
    
    // MARK: - Main Content View
    private var mainContentView: some View {
        VStack(spacing: 0) {
            headerView
            contentScrollView
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            cancelButton
            Spacer()
            titleText
            Spacer()
            saveButton
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 32)
    }
    
    // MARK: - Header Components
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
        .font(.system(size: 16, weight: .light))
        .foregroundColor(.textSecondary)
    }
    
    private var titleText: some View {
        Text(isEditing ? "Edit Story" : "New Story")
            .font(.system(size: 20, weight: .light, design: .serif))
            .foregroundColor(.textPrimary)
    }
    
    private var saveButton: some View {
        Button("Save") {
            saveStory()
        }
        .font(.system(size: 16, weight: .light))
        .foregroundColor(title.isEmpty ? .textSecondary : .accentGold)
        .disabled(title.isEmpty)
    }
    
    // MARK: - Content Scroll View
    private var contentScrollView: some View {
        ScrollView {
            VStack(spacing: 32) {
                titleFieldSection
                datePickerSection
                textEditorSection
                photoSection
                Spacer(minLength: 50)
            }
        }
    }
    
    // MARK: - Form Sections
    private var titleFieldSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Title")
            
            TextField("What is this story about?", text: $title)
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundColor(.textPrimary)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(paperBackground)
        }
        .padding(.horizontal, 24)
    }
    
    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Date")
            
            DatePicker("", selection: $date, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(.accentGold)
        }
        .padding(.horizontal, 24)
    }
    
    private var textEditorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Story")
            
            textEditorView
        }
        .padding(.horizontal, 24)
    }
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Photos")
            
            existingImagesView
            photoPickerView
            loadingIndicator
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Helper Views
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .light))
            .foregroundColor(.textSecondary)
            .textCase(.uppercase)
            .tracking(1)
    }
    
    private var paperBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.bookCover)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var textEditorView: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.system(size: 18, weight: .light, design: .serif))
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(paperBackground)
            
            if text.isEmpty {
                Text("Begin writing your story...")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundColor(.textSecondary.opacity(0.6))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .allowsHitTesting(false)
            }
        }
        .frame(minHeight: 300)
    }
    
    private var existingImagesView: some View {
        Group {
            if !imageDataArray.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(imageDataArray.enumerated()), id: \.offset) { index, data in
                            imageThumbnailView(for: data, at: index)
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
        }
    }
    
    private func imageThumbnailView(for data: Data, at index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            
            imageDeleteButton(for: index)
        }
    }
    
    private func imageDeleteButton(for index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                guard index >= 0 && index < imageDataArray.count else { return }
                imageDataArray.remove(atOffsets: IndexSet(integer: index))
            }
        } label: {
            Image(systemName: "minus.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.textSecondary)
                .background(
                    Circle()
                        .fill(Color.darkBackground)
                        .scaleEffect(1.2)
                )
        }
        .padding(4)
    }
    
    private var photoPickerView: some View {
        PhotosPicker(
            selection: $selectedImages,
            maxSelectionCount: 10,
            matching: .images
        ) {
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .light))
                Text("Add Photos")
                    .font(.system(size: 16, weight: .light))
            }
            .foregroundColor(.textSecondary)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.textSecondary.opacity(0.3), lineWidth: 1)
            )
        }
        .onChange(of: selectedImages) { oldValue, newValue in
            Task {
                await loadImages(from: newValue)
            }
        }
    }
    
    private var loadingIndicator: some View {
        Group {
            if isLoadingImages {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.textSecondary)
                    Text("Loading images...")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 8)
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
