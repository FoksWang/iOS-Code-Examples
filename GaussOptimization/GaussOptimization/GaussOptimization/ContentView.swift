//
//  ContentView.swift
//  GaussOptimization
//
//  Created by Hui Wang on 2025-03-08.
//

import SwiftUI

struct ContentView: View {
    @State private var totalDurationLoop: Int = 0
    @State private var totalDurationReduce: Int = 0
    @State private var totalDurationGauss: Int = 0
    @State private var executionTimeLoop: Double = 0
    @State private var executionTimeReduce: Double = 0
    @State private var executionTimeGauss: Double = 0
    
    // Simulated podcast durations (each episode duration increases sequentially)
    let podcastDurations = Array(1...100) // Episodes with durations from 1 to 100 minutes
    let episodeCount = 50 // Calculate total duration for the first 50 episodes
    
    var body: some View {
        VStack(spacing: 26) {
            Text("🎧 Podcast Playback Time Calculator")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 10) {
                resultCard(title: "For-In Loop", duration: totalDurationLoop, time: executionTimeLoop)
                resultCard(title: "Reduce Method", duration: totalDurationReduce, time: executionTimeReduce)
                resultCard(title: "Gauss Formula", duration: totalDurationGauss, time: executionTimeGauss)
            }
            .padding()
            
            Button(action: {
                runCalculations()
            }) {
                Text("Calculate Total Duration")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 3)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding()
    }
    
    func resultCard(title: String, duration: Int, time: Double) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Total Duration: \(duration) min")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Execution Time: \(time, specifier: "%.5f") ms")
                .font(.subheadline)
                .foregroundColor(.red)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.8))
        )
        .padding(.horizontal, 20)
    }
    
    // For-In Loop method
    func cumulativeDurationLoop(durations: [Int], upto count: Int) -> Int {
        var total = 0
        for i in 0..<min(count, durations.count) {
            total += durations[i]
        }
        return total
    }
    
    // Reduce Method
    func cumulativeDurationReduce(durations: [Int], upto count: Int) -> Int {
        durations.prefix(count).reduce(0, +)
    }
    
    // Gauss Formula (for arithmetic sequence)
    func cumulativeDurationGaussFormula(upto count: Int) -> Int {
        (count * (count + 1)) / 2
    }
    
    // Run calculations and measure execution time
    func runCalculations() {
        (totalDurationLoop, executionTimeLoop) = measureExecutionTime {
            cumulativeDurationLoop(durations: podcastDurations, upto: episodeCount)
        }
        
        (totalDurationReduce, executionTimeReduce) = measureExecutionTime {
            cumulativeDurationReduce(durations: podcastDurations, upto: episodeCount)
        }
        
        (totalDurationGauss, executionTimeGauss) = measureExecutionTime {
            cumulativeDurationGaussFormula(upto: episodeCount)
        }
    }
    
    // Measure execution time
    func measureExecutionTime<T>(_ function: () -> T) -> (T, Double) {
        let start = DispatchTime.now()
        let result = function()
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000 // Convert to milliseconds
        return (result, timeInterval)
    }
}

#Preview {
    ContentView()
}
