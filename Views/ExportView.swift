//
// ExportView.swift
// SudokuGenerator
//
// Created by Thibault on 04/09/2025.
//

import SwiftUI

// Structure pour les données PDF à partager
struct PDFToShare: Identifiable {
    let id = UUID()
    let data: Data
    let filename: String
}

struct ExportView: View {
    @ObservedObject var viewModel: SudokuGeneratorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var pdfToShare: PDFToShare?
    
    var body: some View {
        NavigationStack {
            List {
                puzzleSection
                solutionSection
                summarySection
            }
            .navigationTitle("Export PDF")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(item: $pdfToShare) { pdfData in
                ShareSheet(items: [pdfData.data], filename: pdfData.filename)
            }
        }
    }
}

// MARK: - Propriétés calculées pour découper la complexité

private extension ExportView {
    
    var puzzleSection: some View {
        Section {
            puzzleContent
        } header: {
            Text("Sudokus générés")
        } footer: {
            Text("💡 Fichier nommé automatiquement avec date et heure")
                .font(.caption)
        }
    }
    
    var puzzleContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            puzzleLabel
            puzzleButton
        }
        .padding(.vertical, 8)
    }
    
    var puzzleLabel: some View {
        Label {
            VStack(alignment: .leading) {
                Text("PDF Grilles")
                    .font(.headline)
                Text("\(viewModel.generatedSudokus.count) sudokus")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: "doc.text")
                .font(.title2)
                .foregroundStyle(.blue)
        }
    }
    
    var puzzleButton: some View {
        Button(action: exportPuzzles) {
            Text("Télécharger les grilles")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
    
    var solutionSection: some View {
        Section {
            solutionContent
        } header: {
            Text("Solutions")
        } footer: {
            Text("💡 Fichier séparé pour éviter la triche")
                .font(.caption)
        }
    }
    
    var solutionContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            solutionLabel
            solutionButton
        }
        .padding(.vertical, 8)
    }
    
    var solutionLabel: some View {
        Label {
            VStack(alignment: .leading) {
                Text("PDF Solutions")
                    .font(.headline)
                Text("Solutions complètes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: "doc.text.fill")
                .font(.title2)
                .foregroundStyle(.green)
        }
    }
    
    var solutionButton: some View {
        Button(action: exportSolutions) {
            Text("Télécharger les solutions")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.green)
    }
    
    var summarySection: some View {
        Section("Résumé de la génération") {
            ForEach(Difficulty.allCases) { difficulty in
                summaryRow(for: difficulty)
            }
        }
    }
    
    func summaryRow(for difficulty: Difficulty) -> some View {
        let count = viewModel.generatedSudokus.filter { $0.difficulty == difficulty }.count
        
        return Group {
            if count > 0 {
                HStack {
                    Label(difficulty.rawValue, systemImage: difficulty.icon)
                        .foregroundStyle(difficulty.color)
                    Spacer()
                    Text("\(count) sudoku(s)")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
        }
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Terminé") {
                dismiss()
            }
        }
    }
}

// MARK: - Actions

private extension ExportView {
    func exportPuzzles() {
        let export = viewModel.exportPDF(includeSolutions: false)
        if let data = export.0 {
            pdfToShare = PDFToShare(data: data, filename: export.1)
        }
    }
    
    func exportSolutions() {
        let export = viewModel.exportPDF(includeSolutions: true)
        if let data = export.0 {
            pdfToShare = PDFToShare(data: data, filename: export.1)
        }
    }
}
