//
//  StorybookView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI
import UIKit

struct StorybookView: View {
    @ObservedObject var viewModel: StorybookViewModel
    @State private var currentIndex = -1 // Start at -1 to show cover
    @State private var showBookAnimation = false
    @State private var hasShownInitialAnimation = false
    @State private var showLibrary = false
    @State private var showAddStory = false
    
    var body: some View {
        ZStack {
            // Dark background
            Color.darkBackground
                .ignoresSafeArea()
            
            // Main book view
            VStack(spacing: 16) {
                // Header with controls
                HStack {
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Button {
                            showLibrary = true
                        } label: {
                            Text(Date(), style: .date)
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1)
                        }
                        
                        Text("My Storybook")
                            .font(.system(size: 20, weight: .light, design: .serif))
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    // Top right controls
                    HStack(spacing: 16) {
                        Button {
                            showLibrary = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18))
                                .foregroundColor(.textSecondary)
                        }
                        
                        Button {
                            showAddStory = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.accentGold)
                        }
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 20)
                
                if !viewModel.stories.isEmpty && currentIndex >= 0 {
                    Text("Story \(currentIndex + 1) of \(viewModel.stories.count)")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.textSecondary)
                        .tracking(1)
                } else if currentIndex == -1 {
                    Text("Table of Contents")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.textSecondary)
                        .tracking(1)
                }
                
                // Page curl storybook
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
                        currentIndex: $currentIndex
                    )
                    .opacity(showBookAnimation ? 0 : 1)
                }
            }
            .opacity(showBookAnimation ? 0 : 1)
            
            // Book opening animation overlay (only on app launch)
            if showBookAnimation {
                BookOpeningAnimation(
                    story: viewModel.stories.first
                ) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showBookAnimation = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
            
            // Library overlay
            if showLibrary {
                LibraryOverlay(
                    viewModel: viewModel,
                    isPresented: $showLibrary,
                    onStorySelected: { index in
                        // Jump to selected story in the book
                        currentIndex = index
                        showLibrary = false
                    }
                )
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
        .sheet(isPresented: $showAddStory) {
            AddEditStoryView(viewModel: viewModel)
        }
        .onAppear {
            // Show book animation ONLY on first app launch
            if !viewModel.stories.isEmpty && !hasShownInitialAnimation {
                hasShownInitialAnimation = true
                showBookAnimation = true
            }
        }
    }
}

// UIPageViewController that includes cover as page 0
struct PageCurlWithCoverViewController: UIViewControllerRepresentable {
    let stories: [Story]
    @Binding var currentIndex: Int
    
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
        
        // Handle programmatic page changes (from library selection)
        if context.coordinator.parent.currentIndex != context.coordinator.lastKnownIndex {
            context.coordinator.navigateToIndex(context.coordinator.parent.currentIndex, pageVC: pageVC)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        let parent: PageCurlWithCoverViewController
        private var currentStories: [Story]
        var lastKnownIndex: Int = -1
        
        init(_ parent: PageCurlWithCoverViewController) {
            self.parent = parent
            self.currentStories = parent.stories
            self.lastKnownIndex = parent.currentIndex
        }
        
        func updateStories(_ stories: [Story]) {
            self.currentStories = stories
        }
        
        func navigateToIndex(_ index: Int, pageVC: UIPageViewController) {
            guard index >= -1 && index < currentStories.count else { return }
            
            let targetVC: UIViewController
            if index == -1 {
                targetVC = BookCoverHostingController()
            } else {
                targetVC = StoryHostingController(story: currentStories[index], index: index)
            }
            
            let direction: UIPageViewController.NavigationDirection = index > lastKnownIndex ? .forward : .reverse
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
            } else {
                return nil
            }
            
            if currentIndex == 0 {
                return BookCoverHostingController()
            } else if currentIndex > 0 {
                return StoryHostingController(
                    story: currentStories[currentIndex - 1],
                    index: currentIndex - 1
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
            } else {
                return nil
            }
            
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
            }
            
            return nil
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed else { return }
            
            if let visibleVC = pageViewController.viewControllers?.first {
                if visibleVC is BookCoverHostingController {
                    parent.currentIndex = -1
                    lastKnownIndex = -1
                } else if let storyVC = visibleVC as? StoryHostingController {
                    parent.currentIndex = storyVC.index
                    lastKnownIndex = storyVC.index
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

#Preview {
    StorybookView(viewModel: StorybookViewModel())
}
