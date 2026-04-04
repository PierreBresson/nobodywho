//
//  ModelItem.swift
//  NobodyWatch Watch App
//
//  Created by pierre on 22/03/2026.
//

import SwiftUI

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
