//
//  MainView.swift
//  NobodyWatch Watch App
//
//  Created by pierre on 20/03/2026.
//

import SwiftUI
import NobodyWho

struct MainView: View {
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorLoadingModel: Bool = false
    @State private var errorMessage: String? = nil
    @State private var modelLoaded: Bool = false
    @State private var chat: Chat?

    /// Path to a GGUF model file on the watch.
    /// In a real app you'd bundle this or download it at runtime.
    private var modelPath: String {
        Bundle.main.path(forResource: "model", ofType: "gguf")!
    }

    var body: some View {
        if !modelLoaded {
            loadingView
        } else {
            chatView
        }
    }

    private var loadingView: some View {
        Group {
            if errorLoadingModel {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)

                    Text("Failed to load model. Please try again.")
                        .font(.caption2)
                        .multilineTextAlignment(.center)

                    Button {
                        loadModel()
                    } label: {
                        Label("Retry", systemImage: "arrow.clockwise")
                    }
                }
            } else {
                VStack(spacing: 8) {
                    ProgressView()

                    Text("Loading…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .onAppear {
                    loadModel()
                }
            }
        }
    }

    private var chatView: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                List {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.bottom, message.id == messages.last?.id ? 8 : 0)
                            .id(message.id)
                    }
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.7)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .id("loading")
                    }
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption2)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .onChange(of: messages.count) {
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
                .onChange(of: isLoading) {
                    if isLoading {
                        withAnimation {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 6) {
                TextField("Ask something…", text: $inputText)
                    .font(.caption)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(inputText.isEmpty || isLoading ? .gray : .blue)
                }
                .disabled(inputText.isEmpty || isLoading)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
    }

    private func loadModel() {
        isLoading = true
        errorLoadingModel = false

        let path = modelPath
        Task.detached {
            do {
                initLogging()
                // useGpu: false — Metal is not available on watchOS
                let model = try NobodyWho.loadModel(path: path, useGpu: false)
                let config = ChatConfig(
                    contextSize: 2048,
                    systemPrompt: "You are a helpful assistant running on Apple Watch. Keep answers very short."
                )
                let chatInstance = try Chat(model: model, config: config)

                await MainActor.run {
                    chat = chatInstance
                    modelLoaded = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorLoadingModel = true
                    isLoading = false
                }
            }
        }
    }

    private func sendMessage() {
        guard let chat, !inputText.isEmpty else { return }
        let question = inputText
        inputText = ""
        isLoading = true
        errorMessage = nil

        messages.append(Message(role: .user, content: question))

        Task.detached {
            do {
                let answer = try chat.askBlocking(prompt: question)
                await MainActor.run {
                    messages.append(Message(role: .assistant, content: answer))
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    MainView()
}
