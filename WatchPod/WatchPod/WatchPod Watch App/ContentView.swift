//
//  ContentView.swift
//  WatchPod Watch App
//
//  Created by Hui Wang on 2025-03-08.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var playerManager: PodcastPlayerManager
    @State private var isShowingPlaylist = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 12) {
                Text("🎙️ Podcast")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .padding(.top, 6)
                
                Text(playerManager.currentEpisode?.title ?? "Loading...")
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                HStack(spacing: 16) {
                    CircularButton(icon: "backward.fill", color: .gray, action: playerManager.previousEpisode)
                    
                    if let episode = playerManager.currentEpisode {
                        CircularButton(
                            icon: episode.isPlaying ? "pause.fill" : "play.fill",
                            color: episode.isPlaying ? .blue : .cyan,
                            action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    episode.isPlaying ? playerManager.pause() : playerManager.play()
                                }
                            },
                            progress: Binding(
                                get: { episode.progress },
                                set: { episode.updateProgress($0) }
                            )
                        )
                    } else {
                        CircularButton(icon: "play.fill", color: .cyan, action: {}, progress: nil)
                    }
                    
                    CircularButton(icon: "forward.fill", color: .gray, action: playerManager.nextEpisode)
                }
                
                Button(action: {
                    isShowingPlaylist = true
                }) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderless)
                .padding(.top, 8)
            }
            .padding(16)
        }
        .sheet(isPresented: $isShowingPlaylist) {
            PodcastPlaylistView(isShowingPlaylist: $isShowingPlaylist)
                .environmentObject(playerManager)
        }
    }
}

struct CircularButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    var progress: Binding<CGFloat>? = nil
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color)
                        .overlay(
                            Group {
                                if let progress = progress, progress.wrappedValue > 0 {
                                    Circle()
                                        .trim(from: 0.0, to: max(progress.wrappedValue, 0.01))
                                        .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                        .rotationEffect(.degrees(-90))
                                        .frame(width: 54, height: 54)
                                        .animation(.easeInOut(duration: 0.3), value: progress.wrappedValue)
                                }
                            }
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(PodcastPlayerManager())
}
