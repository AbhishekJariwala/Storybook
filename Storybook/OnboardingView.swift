//
//  OnboardingView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-30.
//

import SwiftUI

struct OnboardingView: View {
    @State private var bookTitle = "Dreams"
    @State private var selectedCoverIndex = 0
    @State private var isAnimating = false
    @State private var showContent = false
    
    let onComplete: () -> Void
    
    // Predefined cover gradients
    private var coverOptions: [LinearGradient] {
        [
            // Default purple/dreamy
            LinearGradient(colors: [Color(hex: "#1A1628"), Color(hex: "#2C2445")], startPoint: .topLeading, endPoint: .bottomTrailing),
            
            // Midnight blue
            LinearGradient(colors: [Color(hex: "#0D1421"), Color(hex: "#1E3A8A")], startPoint: .topLeading, endPoint: .bottomTrailing),
            
            // Deep forest
            LinearGradient(colors: [Color(hex: "#0F2B0F"), Color(hex: "#1B4332")], startPoint: .topLeading, endPoint: .bottomTrailing),
            
            // Wine red
            LinearGradient(colors: [Color(hex: "#2D0A0A"), Color(hex: "#7F1D1D")], startPoint: .topLeading, endPoint: .bottomTrailing),
            
            // Charcoal
            LinearGradient(colors: [Color(hex: "#1F1F23"), Color(hex: "#343439")], startPoint: .topLeading, endPoint: .bottomTrailing),
            
            // Indigo
            LinearGradient(colors: [Color(hex: "#1E1B4B"), Color(hex: "#4C1D95")], startPoint: .topLeading, endPoint: .bottomTrailing)
        ]
    }
    
    var body: some View {
        ZStack {
            // Starry background
            starryBackground
            
            // Main content
            if showContent {
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Welcome text
                    VStack(spacing: 8) {
                        Text("Oh hi there..")
                            .font(.system(size: 28, weight: .light, design: .serif))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Stumbled into a dream, have you?")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 50)
                    
                    // Interactive book cover
                    EditableBookCover(
                        title: $bookTitle,
                        coverGradient: coverOptions[selectedCoverIndex],
                        isAnimating: $isAnimating
                    )
                    .padding(.horizontal, 40)
                    
                    // Cover options (swipeable dots)
                    coverSelectionDots
                        .padding(.top, 30)
                    
                    Spacer()
                    
                    // Get started button
                    Button(action: completeOnboarding) {
                        Text("Let's get started")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.bottom, 50)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
        }
    }
    
    // MARK: - Background
    private var starryBackground: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // Animated stars
            ForEach(0..<50, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...1.0)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(showContent ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: showContent
                    )
            }
        }
    }
    
    // MARK: - Cover Selection
    private var coverSelectionDots: some View {
        HStack(spacing: 12) {
            ForEach(0..<coverOptions.count, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedCoverIndex = index
                        isAnimating = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isAnimating = false
                        }
                    }
                } label: {
                    Circle()
                        .fill(Color.white.opacity(selectedCoverIndex == index ? 1.0 : 0.4))
                        .frame(width: selectedCoverIndex == index ? 8 : 6, height: selectedCoverIndex == index ? 8 : 6)
                        .scaleEffect(selectedCoverIndex == index ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedCoverIndex)
                }
            }
        }
    }
    
    // MARK: - Actions
    private func completeOnboarding() {
        // Save user preferences
        UserDefaults.standard.set(bookTitle, forKey: "bookTitle")
        UserDefaults.standard.set(selectedCoverIndex, forKey: "selectedCoverIndex")
        
        // Animate out and complete
        withAnimation(.easeInOut(duration: 0.6)) {
            showContent = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            onComplete()
        }
    }
}

// MARK: - Editable Book Cover
struct EditableBookCover: View {
    @Binding var title: String
    let coverGradient: LinearGradient
    @Binding var isAnimating: Bool
    @State private var isEditing = false
    
    var body: some View {
        ZStack {
            // Book cover background
            RoundedRectangle(cornerRadius: 8)
                .fill(coverGradient)
                .frame(width: 280, height: 360)
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isAnimating)
            
            // Cover content
            VStack(spacing: 16) {
                Spacer()
                
                // Title input
                VStack(spacing: 8) {
                    if isEditing {
                        TextField("Dreams", text: $title)
                            .font(.system(size: 28, weight: .light, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.plain)
                            .accentColor(.white.opacity(0.8))
                            .onTapGesture {
                                // Bring up keyboard
                            }
                    } else {
                        Text(title.isEmpty ? "Dreams" : title)
                            .font(.system(size: 28, weight: .light, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Author line
                    HStack(spacing: 0) {
                        Text("written by ")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(".....................")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Spacer()
                
                // Moon icon
                Image(systemName: "moonphase.first.quarter")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 40)
            }
            .padding()
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isEditing.toggle()
                }
                
                if isEditing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // Focus could be handled here
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(onComplete: {
        // Preview completion
    })
}
