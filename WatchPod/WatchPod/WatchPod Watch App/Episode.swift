//
//  Episode.swift
//  WatchPod
//
//  Created by Hui Wang on 2025-03-09.
//

import Foundation
import AVFoundation

final class Episode: ObservableObject {
    let title: String
    let url: URL
    @Published var progress: CGFloat
    @Published var duration: CGFloat
    @Published var isPlaying: Bool
    
    init(title: String, url: URL, progress: CGFloat = 0.0, duration: CGFloat = 0.0, isPlaying: Bool = false) {
        self.title = title
        self.url = url
        self.progress = progress
        self.duration = duration
        self.isPlaying = isPlaying
    }
    
    func updateProgress(_ progress: CGFloat) {
        DispatchQueue.main.async {
            self.progress = progress
        }
    }
    
    func setPlaying(_ playing: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = playing
        }
    }
}
