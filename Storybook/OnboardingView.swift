//
//  OnboardingView.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-30.
//

import SwiftUI
import AVKit

struct OnboardingView: View {
    @State private var bookTitle = "My Storybook"
    @State private var selectedCoverIndex = 0
    @State private var currentStep = 0
    @State private var showContent = false
    @State private var videoPlayer: AVPlayer?
    
    let onComplete: () -> Void
    
    // Onboarding steps with timing
    private let onboardingSteps: [(text: String, duration: Double)] = [
        ("Life is a collection of stories", 3.0),
        ("Welcome to your storybook", 3.0)
    ]
    
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
            LinearGradient(colors: [Color(hex: "#1F1F23"), Color(hex: "#343439")], startPoint: .topLeading, endPoint: .bottomTrailing)
        ]
    }
    
    var body: some View {
        ZStack {
            // Video background
            videoBackground
            
            // Dark overlay for text readability
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Animated text sequence
                if currentStep < onboardingSteps.count {
                    animatedTextSequence
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.8)),
                            removal: .opacity.combined(with: .scale(scale: 1.2))
                        ))
                } else if currentStep == onboardingSteps.count {
                    // Book cover customization (final step)
                    bookCustomizationView
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8)
                                .combined(with: .opacity),
                            removal: .opacity
                        ))
                } else {
                    // Show nothing - onboarding complete
                    EmptyView()
                }
                
                Spacer()
            }
            
            // Tap anywhere to advance (for testing) - only during text steps
            if currentStep < onboardingSteps.count {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        advanceStep()
                    }
            }
        }
        .onAppear {
            startTimers()
            setupVideoPlayer()
        }
        .onDisappear {
            videoPlayer?.pause()
        }
    }
    
    // MARK: - Video Background
    private var videoBackground: some View {
        Group {
            if let player = videoPlayer {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .clipped()
                    .ignoresSafeArea()
            } else {
                // Fallback background while video loads
                Color.black
                    .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Animated Text Sequence
    private var animatedTextSequence: some View {
        VStack(spacing: 20) {
            Text(onboardingSteps[currentStep].text)
                .font(.system(size: currentStep == 0 ? 32 : 28, weight: .light, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)
                .animation(.easeInOut(duration: 0.8), value: showContent)
            
            if currentStep == 0 {
                // Stars animation for first message
                floatingStars
            } else {
                // Subtle pulse animation for welcome message
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .scaleEffect(showContent ? 1.2 : 0.8)
                    .opacity(showContent ? 0.3 : 0.1)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: showContent)
            }
        }
    }
    
    // MARK: - Book Customization View
    private var bookCustomizationView: some View {
        VStack(spacing: 40) {
            VStack(spacing: 8) {
                Text("Customize your storybook")
                    .font(.system(size: 24, weight: .light, design: .serif))
                    .foregroundColor(.white)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .animation(.easeOut(duration: 0.8), value: showContent)
                
                Text("Step 3: Personalize")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.1), value: showContent)
            }
            
            // Customizable book cover
            EditableBookCover(
                title: $bookTitle,
                coverGradient: coverOptions[selectedCoverIndex]
            )
            
            // Cover options
            coverSelectionDots
            
            // Instruction text
            Text("Tap the title to edit • Choose your cover below")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.2), value: showContent)
            
            // Customize button
            Button(action: completeOnboarding) {
                Text("Create my storybook")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            .animation(.easeOut(duration: 0.8).delay(0.3), value: showContent)
        }
    }
    
    // MARK: - Cover Selection
    private var coverSelectionDots: some View {
        VStack(spacing: 16) {
            Text("Choose your cover")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.1), value: showContent)
            
            HStack(spacing: 12) {
                ForEach(0..<coverOptions.count, id: \.self) { index in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCoverIndex = index
                        }
                    } label: {
                        Circle()
                            .fill(Color.white.opacity(selectedCoverIndex == index ? 1.0 : 0.4))
                            .frame(width: selectedCoverIndex == index ? 10 : 8, height: selectedCoverIndex == index ? 10 : 8)
                            .scaleEffect(selectedCoverIndex == index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedCoverIndex)
                    }
                }
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.8).delay(0.1), value: showContent)
    }
    
    // MARK: - Floating Stars Animation
    private var floatingStars: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.system(size: CGFloat.random(in: 8...16)))
                    .foregroundColor(.white.opacity(Double.random(in: 0.4...0.8)))
                    .position(
                        x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                        y: CGFloat.random(in: 100...UIScreen.main.bounds.height * 0.6)
                    )
                    .opacity(showContent ? 1 : 0)
                    .animation(
                        .easeInOut(duration: Double.random(in: 1.5...3.0))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...1.5)),
                        value: showContent
                    )
            }
        }
    }
    
    // MARK: - Actions
    private func advanceStep() {
        guard currentStep <= onboardingSteps.count else { return }
        
        // Show the current step
        withAnimation(.easeOut(duration: 0.8)) {
            showContent = true
        }
        
        // Auto advance after the duration
        let stepDuration = currentStep < onboardingSteps.count ? onboardingSteps[currentStep].duration : 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
            withAnimation(.easeInOut(duration: 0.6)) {
                showContent = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                currentStep += 1
                if currentStep <= onboardingSteps.count {
                    advanceStep()
                }
                // If currentStep > onboardingSteps.count, stop the sequence
            }
        }
    }
    
    private func startTimers() {
        // Start the sequence
        advanceStep()
    }
    
    private func setupVideoPlayer() {
        // For now, create a placeholder video URL
        // You can replace this with your actual video file
        guard let url = Bundle.main.url(forResource: "onboarding_bg", withExtension: "mp4") else {
            // Fallback to a web video or create a solid background
            return
        }
        
        videoPlayer = AVPlayer(url: url)
        videoPlayer?.actionAtItemEnd = .none
        videoPlayer?.volume = 0 // Mute the video
        
        // Loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: videoPlayer?.currentItem,
            queue: .main
        ) { _ in
            videoPlayer?.seek(to: .zero)
            videoPlayer?.play()
        }
        
        videoPlayer?.play()
    }
    
    private func completeOnboarding() {
        // Save user preferences
        UserDefaults.standard.set(bookTitle, forKey: "bookTitle")
        UserDefaults.standard.set(selectedCoverIndex, forKey: "selectedCoverIndex")
        
        // Animate out
        withAnimation(.easeInOut(duration: 0.8)) {
            showContent = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onComplete()
        }
    }
}

// MARK: - Editable Book Cover
struct EditableBookCover: View {
    @Binding var title: String
    let coverGradient: LinearGradient
    @State private var isEditing = false
    @State private var rotationAngle: Double = -15
    
    var body: some View {
        ZStack {
            // Book cover background
            RoundedRectangle(cornerRadius: 8)
                .fill(coverGradient)
                .frame(width: 280, height: 360)
                .shadow(color: .black.opacity(0.4), radius: 20, x: -8, y: 10)
                .rotation3DEffect(
                    .degrees(rotationAngle),
                    axis: (x: 0, y: 1, z: 0)
                )
                .onAppear {
                    withAnimation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.5)) {
                        rotationAngle = 0
                    }
                }
            
            // Cover content
            VStack(spacing: 16) {
                Spacer()
                
                // Title input
                VStack(spacing: 8) {
                    if isEditing {
                        TextField("My Storybook", text: $title)
                            .font(.system(size: 28, weight: .light, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.plain)
                            .accentColor(.white.opacity(0.8))
                    } else {
                        Text(title.isEmpty ? "My Storybook" : title)
                            .font(.system(size: 28, weight: .light, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Author line
                    Text("your personal collection")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Book icon
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 40)
            }
            .padding()
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isEditing.toggle()
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