//
//  BookOpeningAnimation.swift
//  Storybook
//
//  Created by Abhishek Jariwala on 2025-09-29.
//

import SwiftUI

struct BookOpeningAnimation: View {
    let story: Story?
    @State private var isOpen = false
    @State private var showContent = false
    let onAnimationComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Date and title
                VStack(spacing: 8) {
                    Text(Date(), style: .date)
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.textSecondary)
                    
                    Text("Here, your stories\ncome to life")
                        .font(.system(size: 22, weight: .light, design: .serif))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Book animation
                ZStack {
                    // Pages (revealed when book opens)
                    if let story = story {
                        BookPagesView(story: story)
                            .opacity(showContent ? 1 : 0)
                            .scaleEffect(showContent ? 1 : 0.95)
                    } else {
                        // Show cover contents if no story (opening to cover)
                        BookPagesView(story: Story(
                            title: "My Storybook",
                            text: "Your stories will appear here.\n\nTap the + button to add your first story.",
                            date: Date(),
                            imageData: []
                        ))
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.95)
                    }
                    
                    // Front cover (animates open)
                    BookCoverView(
                        title: story?.title ?? "My Storybook",
                        subtitle: "by You"
                    )
                    .rotation3DEffect(
                        .degrees(isOpen ? -180 : 0),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .leading,
                        anchorZ: 0,
                        perspective: 0.3
                    )
                    .opacity(isOpen ? 0 : 1)
                }
                .frame(maxWidth: 350) // MATCH THE BOOK SIZE
                
                Spacer()
            }
        }
        .onAppear {
            // Start opening animation after brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 1.2, dampingFraction: 0.75)) {
                    isOpen = true
                }
                
                // Show content slightly after cover starts opening
                withAnimation(.easeIn(duration: 0.6).delay(0.4)) {
                    showContent = true
                }
                
                // Complete animation and transition to story view
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    onAnimationComplete()
                }
            }
        }
    }
}

#Preview {
    BookOpeningAnimation(story: Story.example) {
        print("Animation complete")
    }
}
