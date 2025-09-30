//
//  MainTabView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: StorybookViewModel
    @State private var showingAddStory = false
    
    init(viewModel: StorybookViewModel) {
        self.viewModel = viewModel
        
        // Set tab bar appearance to dark theme
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.darkBackground)
        
        // Tab bar item colors
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.textSecondary)]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.accentGold)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.accentGold)]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            StorybookView(viewModel: viewModel)
                .tabItem {
                    Label("Book", systemImage: "book.closed")
                }
            
            // Placeholder view for the add button
            Color.clear
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .onAppear {
                    showingAddStory = true
                }
            
            LibraryView(viewModel: viewModel)
                .tabItem {
                    Label("Library", systemImage: "list.bullet")
                }
        }
        .accentColor(.accentGold)
        .sheet(isPresented: $showingAddStory) {
            AddEditStoryView(viewModel: viewModel)
        }
    }
}

#Preview {
    MainTabView(viewModel: StorybookViewModel())
}
