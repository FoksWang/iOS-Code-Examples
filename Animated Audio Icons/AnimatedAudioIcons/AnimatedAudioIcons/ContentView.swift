//
//  ContentView.swift
//  AnimatedAudioIcons
//
//  Created by Hui Wang on 2025-03-02.
//

import SwiftUI

struct ContentView: View {
    @State private var animationsRunning = false

    var body: some View {
        VStack {
            Button("Start Animations") {
                withAnimation {
                    animationsRunning.toggle()
                }
            }
            .padding()
            
            VStack {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .symbolEffect(.variableColor.iterative, value: animationsRunning)
                    
                    Image(systemName: "waveform")
                        .symbolEffect(.variableColor.cumulative, value: animationsRunning)
                    
                    Image(systemName: "headphones")
                        .symbolEffect(.variableColor.reversing.iterative, value: animationsRunning)
                    
                    Image(systemName: "mic.fill")
                        .symbolEffect(.variableColor.reversing.cumulative, value: animationsRunning)
                }
                .padding()

                HStack {
                    Image(systemName: "speaker.wave.3.fill")
                        .symbolEffect(.variableColor.iterative, options: .repeating, value: animationsRunning)
                    
                    Image(systemName: "music.note")
                        .symbolEffect(.variableColor.cumulative, options: .repeat(3), value: animationsRunning)
                    
                    Image(systemName: "airpodspro")
                        .symbolEffect(.variableColor.reversing.iterative, options: .speed(3), value: animationsRunning)
                    
                    Image(systemName: "radio")
                        .symbolEffect(.variableColor.reversing.cumulative, options: .repeat(3).speed(3), value: animationsRunning)
                }
                .padding()
            }
            .font(.largeTitle)
        }
    }
}

#Preview {
    ContentView()
}
