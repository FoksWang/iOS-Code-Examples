//
//  ContentView.swift
//  ContentTransitionDemo
//
//  Created by Hui Wang on 2025-03-02.
//

import SwiftUI

struct ContentView: View {
    @State private var isPlaying = false
    
    var body: some View {
        VStack {
            Button {
                withAnimation {
                    isPlaying.toggle()
                }
            } label: {
                Label("Play/Pause", systemImage: isPlaying ? "pause.fill" : "play.fill")
            }
            .contentTransition(.symbolEffect(.replace))
        }
        .padding()
        .font(.title)
    }
}

#Preview {
    ContentView()
}
