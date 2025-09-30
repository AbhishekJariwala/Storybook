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
    @State private var showingAddStory = false
    
    var body: some View {
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
                PageCurlViewController(stories: viewModel.stories, currentIndex: $currentIndex)
            }
            
        }
        .sheet(isPresented: $showingAddStory) {
            AddEditStoryView(viewModel: viewModel)
        }
    }
}

struct PageCurlViewController: UIViewControllerRepresentable {
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
        
        // Set initial view controller
        if !stories.isEmpty {
            let initialVC = StoryHostingController(story: stories[0], index: 0)
            pageVC.setViewControllers([initialVC], direction: .forward, animated: false)
        }
        
        return pageVC
    }
    
    func updateUIViewController(_ pageVC: UIPageViewController, context: Context) {
        // Update if needed when stories change
        context.coordinator.updateStories(stories)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        let parent: PageCurlViewController
        private var currentStories: [Story]
        
        init(_ parent: PageCurlViewController) {
            self.parent = parent
            self.currentStories = parent.stories
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
                index: previousIndex
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
                index: nextIndex
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
class StoryHostingController: UIHostingController<StoryView> {
    let index: Int
    
    init(story: Story, index: Int) {
        self.index = index
        super.init(rootView: StoryView(story: story))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    StorybookView(viewModel: StorybookViewModel())
}
