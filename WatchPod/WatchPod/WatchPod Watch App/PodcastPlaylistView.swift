//
//  PodcastPlaylistView.swift
//  WatchPod
//
//  Created by Hui Wang on 2025-03-08.
//

import SwiftUI

struct PodcastPlaylistView: View {
    @EnvironmentObject var playerManager: PodcastPlayerManager
    @Binding var isShowingPlaylist: Bool
    
    var body: some View {
        VStack {
            Text("Select an Episode")
                .font(.title3.bold())
                .foregroundColor(.white)
                .padding()
            
            List {
                ForEach(playerManager.episodes.indices, id: \.self) { index in
                    let episode = playerManager.episodes[index]
                    Button(action: {
                        playerManager.playEpisode(at: index)
                        isShowingPlaylist = false
                    }) {
                        HStack {
                            Text(episode.title)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Spacer()
                            
                            if playerManager.currentEpisode === episode {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                    }
                }
            }
            .listStyle(.carousel)
        }
        .background(Color.black)
    }
}

#Preview {
    PodcastPlaylistView(isShowingPlaylist: .constant(true))
        .environmentObject(PodcastPlayerManager())
}
