//
//  PodcastPlayerManager.swift
//  WatchPod
//
//  Created by Hui Wang on 2025-03-08.
//

import Foundation
import AVFoundation
import Combine

final class PodcastPlayerManager: ObservableObject {
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    @Published var episodes: [Episode] = [
        Episode(title: "Episode 1", url: URL(string: "https://media.pod.space/tuttobalutto/tutto-pa-tio-5-3-25.mp3")!),
        Episode(title: "Episode 2", url: URL(string: "https://media.pod.space/tuttobalutto/sveputto-3-mars-2025.mp3")!),
        Episode(title: "Episode 3", url: URL(string: "https://media.pod.space/tuttobalutto/tutto915.mp3")!)
    ]
    
    @Published var currentEpisode: Episode?
    
    private var currentIndex: Int = 0
    private var episodeProgress: [Int: CGFloat] = [:]
    private var episodeDuration: [Int: CGFloat] = [:]
    
    init() {
        setupAudioSession()
        setupPlayer()
        loadPodcast()
    }
    
    deinit {
        removeTimeObserver()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
        }
    }
    
    private func setupPlayer() {
        player = AVPlayer()
    }
    
    func loadPodcast() {
        guard let player, episodes.indices.contains(currentIndex) else { return }
        
        let episode = episodes[currentIndex]
        currentEpisode = episode
        
        let newItem = AVPlayerItem(url: episode.url)
        player.replaceCurrentItem(with: newItem)
        addTimeObserver()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleEpisodeEnd), name: .AVPlayerItemDidPlayToEndTime, object: newItem)
        
        restorePlaybackProgress()
    }
    
    func play() {
        player?.play()
        currentEpisode?.setPlaying(true)
        objectWillChange.send()
    }
    
    func pause() {
        player?.pause()
        currentEpisode?.setPlaying(false)
        objectWillChange.send()
    }
    
    func nextEpisode() {
        saveCurrentProgress()
        currentIndex = (currentIndex + 1) % episodes.count
        loadPodcast()
        play()
    }
    
    func previousEpisode() {
        saveCurrentProgress()
        currentIndex = (currentIndex - 1 + episodes.count) % episodes.count
        loadPodcast()
        play()
    }
    
    func playEpisode(at index: Int) {
        saveCurrentProgress()
        guard episodes.indices.contains(index) else { return }
        currentIndex = index
        loadPodcast()
        play()
    }
    
    private func saveCurrentProgress(reset: Bool = false) {
        guard let currentEpisode else { return }
        let newProgress = reset ? 0.0 : currentEpisode.progress
        episodeProgress[currentIndex] = newProgress
        episodeDuration[currentIndex] = currentEpisode.duration
        currentEpisode.updateProgress(newProgress)
    }
    
    private func restorePlaybackProgress() {
        guard let player, let currentEpisode else { return }
        
        let savedProgress = episodeProgress[currentIndex] ?? 0.0
        let savedDuration = episodeDuration[currentIndex] ?? 0.0
        
        currentEpisode.updateProgress(savedProgress)
        currentEpisode.duration = savedDuration
        
        if savedDuration > 0 {
            let seekTime = CMTime(seconds: Double(savedProgress) * savedDuration, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            player.seek(to: seekTime) { [weak self] _ in
                self?.player?.play()
            }
        }
    }
    
    private func addTimeObserver() {
        guard let player else { return }
        
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self,
                  let duration = player.currentItem?.duration.seconds,
                  duration > 0,
                  let episode = currentEpisode else {
                return
            }
            
            let progressValue = CGFloat(time.seconds / duration)
            DispatchQueue.main.async {
                episode.updateProgress(progressValue)
                episode.duration = CGFloat(duration)
                self.objectWillChange.send()
            }
        }
    }
    
    private func removeTimeObserver() {
        guard let player, let observer = timeObserver else { return }
        player.removeTimeObserver(observer)
        timeObserver = nil
    }
    
    @objc private func handleEpisodeEnd() {
        saveCurrentProgress(reset: true)
        player?.seek(to: .zero) { [weak self] _ in
            guard let self else { return }
            currentEpisode?.updateProgress(0.0)
            player?.play()
        }
    }
}
