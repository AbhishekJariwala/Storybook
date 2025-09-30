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
    @State private var currentIndex = 0
    @State private var showBookAnimation = false
    @State private var selectedStory: Story?
    
    var body: some View {
        ZStack {
            // Main book view
            VStack {
                // Page indicator
                Text("My Storybook")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !viewModel.stories.isEmpty {
                    Text("Story \(currentIndex + 1) of \(viewModel.stories.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Page curl storybook
                if viewModel.stories.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No stories yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Tap + to write your first story")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    PageCurlViewController(
                        stories: viewModel.stories,
                        currentIndex: $currentIndex,
                        onStoryTap: { story in
                            selectedStory = story
                            showBookAnimation = true
                        }
                    )
                }
            }
            
            // Book opening animation overlay
            if showBookAnimation, let story = selectedStory {
                BookOpeningAnimation(story: story) {
                    showBookAnimation = false
                    selectedStory = nil
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

struct PageCurlViewController: UIViewControllerRepresentable {
    let stories: [Story]
    @Binding var currentIndex: Int
    let onStoryTap: (Story) -> Void
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageVC = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        pageVC.dataSource = context.coordinator
        pageVC.delegate = context.coordinator
        
        // Set initial view controller
        if !stories.isEmpty {
            let initialVC = StoryHostingController(
                story: stories[0],
                index: 0,
                onTap: onStoryTap
            )
            pageVC.setViewControllers([initialVC], direction: .forward, animated: false)
        }
        
        return pageVC
    }
    
    func updateUIViewController(_ pageVC: UIPageViewController, context: Context) {
        context.coordinator.updateStories(stories)
        context.coordinator.onStoryTap = onStoryTap
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        let parent: PageCurlViewController
        private var currentStories: [Story]
        var onStoryTap: (Story) -> Void
        
        init(_ parent: PageCurlViewController) {
            self.parent = parent
            self.currentStories = parent.stories
            self.onStoryTap = parent.onStoryTap
        }
        
        func updateStories(_ stories: [Story]) {
            self.currentStories = stories
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let storyVC = viewController as? StoryHostingController,
                  storyVC.index > 0 else {
                return nil
            }
            
            let previousIndex = storyVC.index - 1
            return StoryHostingController(
                story: currentStories[previousIndex],
                index: previousIndex,
                onTap: onStoryTap
            )
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let storyVC = viewController as? StoryHostingController,
                  storyVC.index < currentStories.count - 1 else {
                return nil
            }
            
            let nextIndex = storyVC.index + 1
            return StoryHostingController(
                story: currentStories[nextIndex],
                index: nextIndex,
                onTap: onStoryTap
            )
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            if completed,
               let visibleVC = pageViewController.viewControllers?.first as? StoryHostingController {
                parent.currentIndex = visibleVC.index
            }
        }
    }
}

// Hosting controller to wrap SwiftUI StoryView in UIKit
class StoryHostingController: UIHostingController<TappableStoryView> {
    let index: Int
    
    init(story: Story, index: Int, onTap: @escaping (Story) -> Void) {
        self.index = index
        super.init(rootView: TappableStoryView(story: story, onTap: onTap))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Wrapper to make StoryView tappable
struct TappableStoryView: View {
    let story: Story
    let onTap: (Story) -> Void
    
    var body: some View {
        StoryView(story: story)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap(story)
            }
    }
}

#Preview {
    StorybookView(viewModel: StorybookViewModel())
}
