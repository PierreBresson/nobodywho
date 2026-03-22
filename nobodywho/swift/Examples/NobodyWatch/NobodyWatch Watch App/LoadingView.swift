//
//  LoadingView.swift
//  NobodyWatch Watch App
//

import SwiftUI

struct LoadingView: View {
    @Bindable var session: ChatSession

    var body: some View {
        if session.errorLoadingModel {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(.red)

                Text("Failed to load model. Please try again.")
                    .font(.caption2)
                    .multilineTextAlignment(.center)

                Button {
                    session.loadModel()
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
                session.loadModel()
            }
        }
    }
}

#Preview("Loading") {
    LoadingView(session: ChatSession())
}

#Preview("Error") {
    let session = ChatSession()
    session.errorLoadingModel = true
    return LoadingView(session: session)
}
