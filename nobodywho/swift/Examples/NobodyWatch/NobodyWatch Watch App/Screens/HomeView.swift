//
//  HomeView.swift
//  NobodyWatch Watch App
//

import SwiftUI

struct HomeView: View {
    private let endpoint = URL(string: "https://gist.githubusercontent.com/PierreBresson/f3da1a01c39417237fa2883fb11fe376/raw/830650a4700ddb7196fb6697d6c0e940a723a4da/nobody-watchos-app.json")!

    @State private var remoteModels: [RemoteModel] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("Loading remoteModels…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                    Text(errorMessage)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                    Button {
                        fetchModels()
                    } label: {
                        Label("Retry", systemImage: "arrow.clockwise")
                    }
                }
                .padding()
            } else if remoteModels.isEmpty {
                Text("No remote models available.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                List {
                    Section(header: Text("Downloaded").padding(.bottom, 8)) {
                        ForEach(remoteModels) { model in
                            NavigationLink(destination: MainView()) {
                                ModelRow(model: model)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Models")
        .onAppear {
            fetchModels()
        }
    }

    private func fetchModels() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: endpoint)
                let decoded = try JSONDecoder().decode([RemoteModel].self, from: data)
                await MainActor.run {
                    remoteModels = decoded
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

private struct ModelRow: View {
    let model: RemoteModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(model.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
            HStack(spacing: 6) {
                Text(model.developer)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(model.sizeMB) MB")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview("Loaded") {
    NavigationStack {
        HomeView()
    }
}
