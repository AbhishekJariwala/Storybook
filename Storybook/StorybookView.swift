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
    @State private var currentIndex = -1 // Start at -1 to show cover on launch
    @State private var showBookAnimation = false
    @State private var animationTrigger: AnimationTrigger = .appLaunch
    
    enum AnimationTrigger {
        case appLaunch
        case pageFlip
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color.darkBackground
                .ignoresSafeArea()
            
            // Main book view
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 4) {
                    Text(Date(), style: .date)
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.textSecondary)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    Text("My Storybook")
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundColor(.textPrimary)
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
                        currentIndex: $currentIndex,
                        onAnimationTrigger: { trigger in
                            animationTrigger = trigger
                            showBookAnimation = true
                        }
                    )
                }
            }
            
            // Book opening animation overlay
            if showBookAnimation {
                BookOpeningAnimation(
                    story: currentIndex >= 0 && currentIndex < viewModel.stories.count
                        ? viewModel.stories[currentIndex]
                        : nil
                ) {
                    showBookAnimation = false
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onAppear {
            // Show book animation on app launch
            if !viewModel.stories.isEmpty {
                showBookAnimation = true
            }
        }
    }
}

// New UIPageViewController that includes cover as page 0
struct PageCurlWithCoverViewController: UIViewControllerRepresentable {
    let stories: [Story]
    @Binding var currentIndex: Int
    let onAnimationTrigger: (StorybookView.AnimationTrigger) -> Void
    
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
        context.coordinator.onAnimationTrigger = onAnimationTrigger
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        let parent: PageCurlWithCoverViewController
        private var currentStories: [Story]
        var onAnimationTrigger: (StorybookView.AnimationTrigger) -> Void
        private var previousIndex: Int = -1
        
        init(_ parent: PageCurlWithCoverViewController) {
            self.parent = parent
            self.currentStories = parent.stories
            self.onAnimationTrigger = parent.onAnimationTrigger
        }
        
        func updateStories(_ stories: [Story]) {
            self.currentStories = stories
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            // Get current index
            let currentIndex: Int
            if viewController is BookCoverHostingController {
                currentIndex = -1
            } else if let storyVC = viewController as? StoryHostingController {
                currentIndex = storyVC.index
            } else {
                return nil
            }
            
            // Navigate backwards
            if currentIndex == 0 {
                // Go back to cover
                return BookCoverHostingController()
            } else if currentIndex > 0 {
                // Go to previous story
                return StoryHostingController(
                    story: currentStories[currentIndex - 1],
                    index: currentIndex - 1
                )
            }
            
            return nil // Can't go back from cover
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            // Get current index
            let currentIndex: Int
            if viewController is BookCoverHostingController {
                currentIndex = -1
            } else if let storyVC = viewController as? StoryHostingController {
                currentIndex = storyVC.index
            } else {
                return nil
            }
            
            // Navigate forwards
            if currentIndex == -1 && !currentStories.isEmpty {
                // Go from cover to first story
                return StoryHostingController(
                    story: currentStories[0],
                    index: 0
                )
            } else if currentIndex >= 0 && currentIndex < currentStories.count - 1 {
                // Go to next story
                return StoryHostingController(
                    story: currentStories[currentIndex + 1],
                    index: currentIndex + 1
                )
            }
            
            return nil // No more stories
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed else { return }
            
            // Determine current index
            if let visibleVC = pageViewController.viewControllers?.first {
                let newIndex: Int
                if visibleVC is BookCoverHostingController {
                    newIndex = -1
                } else if let storyVC = visibleVC as? StoryHostingController {
                    newIndex = storyVC.index
                } else {
                    return
                }
                
                // Check if we should trigger animation
                // Trigger when: going from cover (index -1) to first story (index 0)
                // OR going from first story (index 0) back to cover (index -1)
                if (previousIndex == -1 && newIndex == 0) || (previousIndex == 0 && newIndex == -1) {
                    onAnimationTrigger(.pageFlip)
                }
                
                previousIndex = newIndex
                parent.currentIndex = newIndex
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
