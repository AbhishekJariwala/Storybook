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
        .sheet(isPresented: $showingAddStory) {
            AddEditStoryView(viewModel: viewModel)
        }
    }
}

#Preview {
    MainTabView(viewModel: StorybookViewModel())
}
