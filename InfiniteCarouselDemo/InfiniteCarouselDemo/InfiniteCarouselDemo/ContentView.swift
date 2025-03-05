//
//  ContentView.swift
//  InfiniteCarouselDemo
//
//  Created by Hui Wang on 2025-03-05.
//

import SwiftUI

struct ContentView: View {
    let colors: [Color] = [.red, .green, .blue, .yellow, .brown]
    let numberOfCarousels = 6
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<numberOfCarousels, id: \.self) { _ in
                    InfiniteCarousel(colors, duration: 3) { index, color in
                        cell(index, color)
                            .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.7)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.95)
                            }
                    }
                    .padding(.vertical, 10)
                }
            }
            .padding(.vertical, 10)
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    func cell(_ index: Int, _ color: Color) -> some View {
        NavigationLink {
            label(index)
                .background(color.ignoresSafeArea())
        } label: {
            label(index)
                .background(
                    RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                        .foregroundStyle(color)
                        .shadow(radius: 5)
                )
        }
        .buttonStyle(.plain)
    }
    
    func label(_ index: Int) -> some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text("\(index)")
                    .font(.system(size: 120))
                    .foregroundColor(.white)
                Spacer()
            }
            .bold()
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
            .navigationTitle("Infinite Carousel")
            .navigationBarTitleDisplayMode(.inline)
    }
}
