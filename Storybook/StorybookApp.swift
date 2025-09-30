//
//  StorybookApp.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI

@main
struct StorybookApp: App {
    @StateObject private var viewModel = StorybookViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(viewModel: viewModel)
        }
    }
}
