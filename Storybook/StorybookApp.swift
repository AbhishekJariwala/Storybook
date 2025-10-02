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
    @StateObject private var userPrefs = UserPreferencesManager.shared
    @State private var showingOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if userPrefs.hasCompletedOnboarding {
                    StorybookView(viewModel: viewModel)
                        .transition(.opacity)
                } else {
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            userPrefs.hasCompletedOnboarding = true
                        }
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.8), value: userPrefs.hasCompletedOnboarding)
        }
    }
}
