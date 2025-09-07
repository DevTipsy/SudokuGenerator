//
// ActionButtons.swift
// SudokuGenerator
//
// Created by Thibault on 04/09/2025.
//

import SwiftUI

struct ActionButtons: View {
    let onExport: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: onExport) {
                Label("Exporter les PDF", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: -2)
    }
}
