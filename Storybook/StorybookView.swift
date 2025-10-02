//
//  StorybookView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI
import UIKit

// Custom book opening animations
extension AnyTransition {
    static var bookOpeningAnimation: AnyTransition {
        .asymmetric(
            insertion: AnyTransition.scale(scale: 0.8)
                .combined(with: AnyTransition.opacity)
                .combined(with: AnyTransition.move(edge: .trailing)),
            removal: AnyTransition.opacity
        )
    }
    
    static var bookClosingAnimation: AnyTransition {
        .asymmetric(
            insertion: AnyTransition.opacity,
            removal: AnyTransition.scale(scale: 0.8)
                .combined(with: AnyTransition.opacity)
                .combined(with: AnyTransition.move(edge: .trailing))
        )
    }
}

struct StorybookView: View {
    @ObservedObject var viewModel: StorybookViewModel
    @State private var currentIndex = -1 // Start at -1 to show cover
    
    // Library interface state
    @State private var libraryMode: LibraryMode = .hidden
    @State private var librarySearchText = ""
    @State private var libraryShowingCalendar = false
    @State private var librarySelectedDate: Date?
    
    enum LibraryMode {
        case hidden
        case search
        case calendar
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color.darkBackground
                .ignoresSafeArea()
            
            // Main layout with slideDOWN animation for library only
            ZStack(alignment: .top) {
                // Book slides down from top to bottom
                bottomBookArea
                    .offset(y: libraryMode == .hidden ? 0 : UIScreen.main.bounds.height * 0.5)
                
                // Interface slides in from top
                if libraryMode != .hidden {
                    topInterfaceArea
                        .offset(y: libraryMode == .hidden ? -UIScreen.main.bounds.height * 0.5 : 0)
                }
            }
        }
    }
    
    
    // MARK: - Top Interface Area
    private var topInterfaceArea: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Interface header
                topInterfaceHeader
                
                // Interface content
                topInterfaceContent
                
                Spacer()
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.5)
        .background(Color.darkBackground)
        .onTapGesture {
            dismissLibraryInterface()
        }
    }
    
    // MARK: - Top Interface Header
    private var topInterfaceHeader: some View {
        HStack {
            // Close button
            Button {
                dismissLibraryInterface()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Mode toggle
            HStack(spacing: 20) {
                Button {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        libraryMode = .search
                        librarySearchText = ""
                        librarySelectedDate = nil
                    }
                } label: {
                    Text("Search")
                        .font(.system(size: 16, weight: libraryMode == .search ? .medium : .light))
                        .foregroundColor(libraryMode == .search ? .textPrimary : .textSecondary)
                }
                
                Button {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        libraryMode = .calendar
                        librarySearchText = ""
                        librarySelectedDate = nil
                    }
                } label: {
                    Text("Calendar")
                        .font(.system(size: 16, weight: libraryMode == .calendar ? .medium : .light))
                        .foregroundColor(libraryMode == .calendar ? .textPrimary : .textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .padding(.bottom, 20)
    }
    
    // MARK: - Top Interface Content
    private var topInterfaceContent: some View {
        Group {
            if libraryMode == .search {
                searchInterface
            } else if libraryMode == .calendar {
                calendarInterface
            }
        }
    }
    
    // MARK: - Search Interface
    private var searchInterface: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Search field
            HStack {
                TextField("Search stories...", text: $librarySearchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(.textPrimary)
                
                if !librarySearchText.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            librarySearchText = ""
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.bookCover)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            .padding(.horizontal, 24)
            
            // Search results
            searchResultsView
        }
    }
    
    // MARK: - Calendar Interface
    private var calendarInterface: some View {
        VStack {
            CalendarView(
                viewModel: viewModel,
                selectedDate: $librarySelectedDate,
                onStorySelected: { index in
                    // Navigate to story and dismiss interface
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentIndex = index
                        dismissLibraryInterface()
                    }
                }
            )
            .background(Color.bookCover)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // MARK: - Search Results
    private var searchResultsView: some View {
        let filteredStories = viewModel.stories.filter { story in
            story.title.localizedCaseInsensitiveContains(librarySearchText) ||
            story.text.localizedCaseInsensitiveContains(librarySearchText)
        }
        
        return ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredStories) { story in
                    if let index = viewModel.stories.firstIndex(where: { $0.id == story.id }) {
                        storyResultCard(story: story, index: index)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Story Result Card
    private func storyResultCard(story: Story, index: Int) -> some View {
        Button {
            // Navigate to story and dismiss interface
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentIndex = index
                dismissLibraryInterface()
            }
        } label: {
            HStack(spacing: 16) {
                // Story thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.bookCover)
                        .frame(width: 50, height: 70)
                    
                    if let firstImageData = story.imageData.first,
                       let uiImage = UIImage(data: firstImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "book.pages")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.textSecondary)
                    }
                }
                
                // Story details
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.title)
                        .font(.system(size: 16, weight: .light, design: .serif))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Text(story.text)
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                    
                    Text(story.date, style: .date)
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    
    
    // MARK: - Bottom Book Area
    private var bottomBookArea: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Header with controls
                VStack(spacing: 8) {
                    // Date
                    HStack{
                        Button {
                            animateToggleLibrary(.search)
                        } label: {
                            Text(Date(), style: .date)
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1)
                        }
                        Spacer()
                        Group {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.accentGold)
                            
                            Text("\(viewModel.currentStreak)")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.accentGold)
                            
                            Text("day\(viewModel.currentStreak == 1 ? "" : "s")")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .padding()
                    
                    // Title and controls on same line
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Text("My Storybook")
                            .font(.system(size: 20, weight: .light, design: .serif))
                            .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // Top right controls
                    HStack(spacing: 16) {
                        Button {
                                animateToggleLibrary(.search)
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18))
                                .foregroundColor(.textSecondary)
                        }
                        
                        Button {
                            // Navigate to blank writing page (always at stories.count)
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentIndex = viewModel.stories.count
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.accentGold)
                        }
                    }
                    .padding(.trailing, 20)
                }
                }
                .padding(.top, libraryMode == .hidden ? 20 : 10)
                .padding(.bottom, libraryMode == .hidden ? 32 : 16)
                
                if currentIndex == -1 {
                    Text("Table of Contents")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.textSecondary)
                        .tracking(1)
                } else if !viewModel.stories.isEmpty && currentIndex >= 0 && currentIndex < viewModel.stories.count {
                    Text("Story \(currentIndex + 1) of \(viewModel.stories.count)")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.textSecondary)
                        .tracking(1)
                } else if currentIndex == viewModel.stories.count {
                    Text("New Story")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.textSecondary)
                        .tracking(1)
                }
                
                // Page curl storybook
                bookContentView
            }
            .onTapGesture {
                if libraryMode != .hidden {
                    dismissLibraryInterface()
                }
            }
        }
    }
    
    // MARK: - Book Content View
    private var bookContentView: some View {
        Group {
                if viewModel.stories.isEmpty {
                    // Empty state
                    VStack(spacing: 24) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 70, weight: .thin))
                            .foregroundColor(.textSecondary)
                        
                        VStack(spacing: 8) {
                            Text("No stories yet")
                                .font(.system(size: 24, weight: .light, design: .serif))
                                .foregroundColor(.textPrimary)
                            
                            Text("Tap + to write your first story")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    PageCurlWithCoverViewController(
                        stories: viewModel.stories,
                        currentIndex: $currentIndex,
                        viewModel: viewModel
                    )
            }
        }
    }
    
    // MARK: - Animation Functions
    private func animateToggleLibrary(_ mode: LibraryMode) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if libraryMode == mode {
                libraryMode = .hidden
            } else {
                libraryMode = mode
            }
        }
    }
    
    private func dismissLibraryInterface() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            libraryMode = .hidden
        }
    }
    
}

// UIPageViewController that includes cover as page 0
struct PageCurlWithCoverViewController: UIViewControllerRepresentable {
    let stories: [Story]
    @Binding var currentIndex: Int
    let viewModel: StorybookViewModel
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageVC = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        pageVC.dataSource = context.coordinator
        pageVC.delegate = context.coordinator
        
        // Set dark background
        pageVC.view.backgroundColor = UIColor(Color.darkBackground)
        
        // Start with book cover (index -1)
        let coverVC = BookCoverHostingController()
        pageVC.setViewControllers([coverVC], direction: .forward, animated: false)
        
        return pageVC
    }
    
    func updateUIViewController(_ pageVC: UIPageViewController, context: Context) {
        context.coordinator.updateStories(stories)
        
        // Handle programmatic page changes (from library selection only)
        // Don't navigate if the change came from user swiping
        if !context.coordinator.isUserGesture && context.coordinator.parent.currentIndex != context.coordinator.lastKnownIndex {
            context.coordinator.navigateToIndex(context.coordinator.parent.currentIndex, pageVC: pageVC)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        let parent: PageCurlWithCoverViewController
        private var currentStories: [Story]
        private let viewModel: StorybookViewModel
        var lastKnownIndex: Int = -1
        var isUserGesture: Bool = false
        
        init(_ parent: PageCurlWithCoverViewController) {
            self.parent = parent
            self.currentStories = parent.stories
            self.viewModel = parent.viewModel
            self.lastKnownIndex = parent.currentIndex
        }
        
        func updateStories(_ stories: [Story]) {
            self.currentStories = stories
        }
        
        func navigateToIndex(_ index: Int, pageVC: UIPageViewController) {
            guard index >= -1 && index <= currentStories.count else { return }
            
            // Mark this as a programmatic navigation (not user gesture)
            isUserGesture = false
            
            let targetVC: UIViewController
            if index == -1 {
                targetVC = BookCoverHostingController()
            } else if index == currentStories.count {
                // Blank writing page - always available after last story
                targetVC = BlankPageHostingController(
                    index: index,
                    onSave: { [weak self] newStory in
                        self?.viewModel.addStory(newStory)
                        // Navigate back to the newly created story
                        if let storyIndex = self?.viewModel.stories.firstIndex(where: { $0.id == newStory.id }) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self?.parent.currentIndex = storyIndex
                            }
                        }
                    }
                )
            } else {
                targetVC = StoryHostingController(story: currentStories[index], index: index)
            }
            
            // Improve direction calculation to prevent awkward animations
            let direction: UIPageViewController.NavigationDirection
            if lastKnownIndex == -1 {
                // Always go forward from cover
                direction = .forward
            } else if index == -1 {
                // Always go backward to cover
                direction = .reverse
            } else {
                // Normal forward/reverse based on index
                direction = index > lastKnownIndex ? .forward : .reverse
            }
            pageVC.setViewControllers([targetVC], direction: direction, animated: true)
            lastKnownIndex = index
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            let currentIndex: Int
            if viewController is BookCoverHostingController {
                currentIndex = -1
            } else if let storyVC = viewController as? StoryHostingController {
                currentIndex = storyVC.index
            } else if let blankVC = viewController as? BlankPageHostingController {
                currentIndex = blankVC.index
            } else {
                return nil
            }
            
            // Only allow going back to cover from the first story (index 0)
            // For all other stories, go to the previous story
            // From blank page, go back to the last story
            // Never go back from the cover (-1) as it's the starting point
            if currentIndex == 0 && !currentStories.isEmpty {
                return BookCoverHostingController()
            } else if currentIndex > 0 && currentIndex < currentStories.count {
                return StoryHostingController(
                    story: currentStories[currentIndex - 1],
                    index: currentIndex - 1
                )
            } else if currentIndex == currentStories.count && !currentStories.isEmpty {
                // From blank page, go back to last story
                return StoryHostingController(
                    story: currentStories[currentStories.count - 1],
                    index: currentStories.count - 1
                )
            }
            
            return nil
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            let currentIndex: Int
            if viewController is BookCoverHostingController {
                currentIndex = -1
            } else if let storyVC = viewController as? StoryHostingController {
                currentIndex = storyVC.index
            } else if let blankVC = viewController as? BlankPageHostingController {
                currentIndex = blankVC.index
            } else {
                return nil
            }
            
            // From cover (-1), go to first story if stories exist
            // From any story, go to next story if it exists, or blank page if it's the last
            if currentIndex == -1 && !currentStories.isEmpty {
                return StoryHostingController(
                    story: currentStories[0],
                    index: 0
                )
            } else if currentIndex >= 0 && currentIndex < currentStories.count - 1 {
                return StoryHostingController(
                    story: currentStories[currentIndex + 1],
                    index: currentIndex + 1
                )
            } else if currentIndex == currentStories.count - 1 {
                // From last story, go to blank writing page
                return BlankPageHostingController(
                    index: currentIndex + 1,
                    onSave: { [weak self] newStory in
                        self?.viewModel.addStory(newStory)
                        // Navigate back to the newly created story
                        if let storyIndex = self?.viewModel.stories.firstIndex(where: { $0.id == newStory.id }) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self?.parent.currentIndex = storyIndex
                            }
                        }
                    }
                )
            }
            
            // No more pages after blank page
            return nil
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed else { return }
            
            // Mark this as a user gesture (swipe) to prevent feedback loop
            isUserGesture = true
            
            if let visibleVC = pageViewController.viewControllers?.first {
                if visibleVC is BookCoverHostingController {
                    parent.currentIndex = -1
                    lastKnownIndex = -1
                } else if let storyVC = visibleVC as? StoryHostingController {
                    parent.currentIndex = storyVC.index
                    lastKnownIndex = storyVC.index
                } else if let blankVC = visibleVC as? BlankPageHostingController {
                    parent.currentIndex = blankVC.index
                    lastKnownIndex = blankVC.index
                }
            }
        }
    }
}

// Hosting controller for book cover
class BookCoverHostingController: UIHostingController<BookCoverPageView> {
    init() {
        super.init(rootView: BookCoverPageView())
        view.backgroundColor = UIColor(Color.darkBackground)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Book cover as a page in the book
struct BookCoverPageView: View {
    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()
            
            BookCoverView(
                title: "My Storybook",
                subtitle: "by You"
            )
        }
    }
}

// Hosting controller for stories
class StoryHostingController: UIHostingController<ThemedStoryView> {
    let index: Int
    
    init(story: Story, index: Int) {
        self.index = index
        super.init(rootView: ThemedStoryView(story: story))
        view.backgroundColor = UIColor(Color.darkBackground)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Hosting controller for blank writing page
class BlankPageHostingController: UIHostingController<BlankWritingPageView> {
    let index: Int
    
    var onSave: ((Story) -> Void)?
    
    init(index: Int, onSave: @escaping (Story) -> Void) {
        self.index = index
        self.onSave = onSave
        super.init(rootView: BlankWritingPageView(onSave: onSave))
        view.backgroundColor = UIColor(Color.darkBackground)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Blank writing page view - looks like story page but editable
struct BlankWritingPageView: View {
    @State var title: String = ""
    @State var text: String = ""
    @State var date: Date = Date()
    let onSave: ((Story) -> Void)?
    
    var body: some View {
        // Exact replica of ThemedStoryView design but editable
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.pageWhite)
            .frame(maxWidth: 350)
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
            .overlay(
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Editable Title - same style as story
                        TextField("Untitled", text: $title)
                            .font(.system(size: 28, weight: .regular, design: .serif))
                            .foregroundColor(.black)
                        
                        // Editable Date - same style as story
                        DatePicker("", selection: $date, displayedComponents: [.date])
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                            .tracking(1)
                            .labelsHidden()
                        
                        Divider()
                            .background(Color.black.opacity(0.2))
                            .padding(.vertical, 4)
                        
                        // Editable Story text - same style as story
                        TextEditor(text: $text)
                            .font(.system(size: 17, design: .serif))
                            .foregroundColor(.black.opacity(0.85))
                            .lineSpacing(10)
                            .frame(minHeight: 300)
                            .overlay(
                                Group {
                                    if text.isEmpty {
                                        VStack {
                                            HStack {
                                                Text("Begin writing your story...")
                                                    .font(.system(size: 17, design: .serif))
                                                    .foregroundColor(.gray.opacity(0.7))
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                },
                                alignment: .topLeading
                            )
                        
                        Spacer(minLength: 40)
                        
                        // Save button
                        HStack {
                            Spacer()
                            Button {
                                guard !title.isEmpty else { return }
                                
                                let newStory = Story(
                                    title: title,
                                    text: text,
                                    date: date,
                                    imageData: []
                                )
                                
                                onSave?(newStory)
                                
                                // Clear the form after saving
                                title = ""
                                text = ""
                                date = Date()
                            } label: {
                                Text("Save Story")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                            .background(Color.accentGold)
                            .cornerRadius(8)
                            }
                            .disabled(title.isEmpty)
                            Spacer()
                        }
                        .padding(.vertical, 20)
                    }
                    .padding(32)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 20)
    }
}

#Preview {
    StorybookView(viewModel: StorybookViewModel())
}

