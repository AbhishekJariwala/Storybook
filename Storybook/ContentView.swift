//
//  ContentView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "book")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Storybook")
                .font(.largeTitle)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
