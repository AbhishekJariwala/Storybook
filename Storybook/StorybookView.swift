//
//  StorybookView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI
import UIKit

struct StorybookView: View {
    let stories: [Story]
    @State private var currentIndex = 0
    
    var body: some View {
        VStack {
            // Page indicator
            Text("Book Title")
                .font(.caption)
                .foregroundColor(.primary)
            if !stories.isEmpty {
                Text("Story \(currentIndex + 1) of \(stories.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Page curl storybook
            PageCurlViewController(stories: stories, currentIndex: $currentIndex)
            Button("+") {
                
            }
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
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        let parent: PageCurlViewController
        
        init(_ parent: PageCurlViewController) {
            self.parent = parent
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
                story: parent.stories[previousIndex],
                index: previousIndex
            )
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let storyVC = viewController as? StoryHostingController,
                  storyVC.index < parent.stories.count - 1 else {
                return nil
            }
            
            let nextIndex = storyVC.index + 1
            return StoryHostingController(
                story: parent.stories[nextIndex],
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
    StorybookView(stories: Story.examples)
}

#Preview("Single Story") {
    StorybookView(stories: [Story.example])
}

#Preview("Empty") {
    StorybookView(stories: [])
}
