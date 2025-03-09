//
//  WatchPodApp.swift
//  WatchPod Watch App
//
//  Created by Hui Wang on 2025-03-08.
//

import SwiftUI

@main
struct WatchPodApp: App {
    @StateObject private var playerManager = PodcastPlayerManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playerManager)
        }
    }
}
