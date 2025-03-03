//
//  ContentView.swift
//  MLXSwiftChat
//
//  Created by Hui Wang on 2025-03-03.
//

import MLXLLM
import MLXLMCommon
import SwiftUI

struct ContentView: View {
    @State private var prompt = "Can you recommend some good podcasts?"
    @State private var response = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("MLX Swift Chat")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("Enter your prompt...", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16))
                    .padding(.horizontal)
                
                Button(action: generateResponse) {
                    Text("Generate")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(prompt.isEmpty ? .gray : .blue)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
                .disabled(prompt.isEmpty || isLoading)
                .padding(.leading, 16)
            }
            
            Divider().background(.gray.opacity(0.3))
            
            if !response.isEmpty {
                ScrollView {
                    ResponseBubble(text: response)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            if isLoading {
                ProgressView("Generating response...")
                    .progressViewStyle(.circular)
                    .padding()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isLoading)
        .padding()
    }
}

// MARK: - Actions
extension ContentView {
    func generateResponse() {
        response = ""
        Task {
            do {
                try await generate()
            } catch {
                debugPrint(error)
            }
        }
    }
    
    func generate() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Load model (first time use will download it)
        let modelConfiguration = ModelRegistry.llama3_2_1B_4bit
        let modelContainer = try await LLMModelFactory.shared.loadContainer(configuration: modelConfiguration) { progress in
            debugPrint("Downloading \(modelConfiguration.name): \(Int(progress.fractionCompleted * 100))%")
        }
        
        // Perform inference
        let _ = try await modelContainer.perform { [prompt] context in
            let input = try await context.processor.prepare(input: .init(prompt: prompt))
            let result = try MLXLMCommon.generate(input: input, parameters: .init(), context: context) { tokens in
                let text = context.tokenizer.decode(tokens: tokens)
                Task { @MainActor in
                    self.response = text
                }
                return .more
            }
            return result
        }
    }
}

// MARK: - Response Bubble UI
struct ResponseBubble: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI Response")
                .font(.headline)
                .foregroundColor(.blue)
            
            Text(text)
                .font(.system(size: 16))
                .padding()
                .background(.blue.opacity(0.1))
                .cornerRadius(12)
                .shadow(radius: 2)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
