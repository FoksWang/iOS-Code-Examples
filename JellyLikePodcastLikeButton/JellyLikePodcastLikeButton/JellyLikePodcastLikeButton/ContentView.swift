//
//  ContentView.swift
//  JellyLikePodcastLikeButton
//
//  Created by Hui Wang on 2025-03-04.
//

import SwiftUI

struct JellyLikePodcastButton: View {
    @State private var isLiked = false
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Button(action: {
            // Triggers haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
            
            // Creates a bouncy, spring-like animation for a "jelly" effect
            withAnimation(.interpolatingSpring(
                mass: 0.5,
                stiffness: 300,
                damping: 5,
                initialVelocity: 10
            )) {
                isLiked.toggle()
                scale = isLiked ? 1.2 : 0.9 // Smooth scaling effect
                rotation = isLiked ? -15 : 0  // Slight rotation for dynamic effect
                opacity = isLiked ? 1.0 : 0.6 // Subtle opacity transition
            }
        }) {
            Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .opacity(opacity)
                .foregroundColor(isLiked ? .blue : .gray)
                .font(.system(size: 40))
        }
    }
}

struct EpisodeDetailView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Episode 001 - Advanced SwiftUI Animations")
                .font(.title)
                .bold()
            
            JellyLikePodcastButton()
        }
        .padding()
    }
}

#Preview {
    EpisodeDetailView()
}
