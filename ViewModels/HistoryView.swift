//
//  HistoryView.swift
//  SudokuGenerator
//
//  Created by Thibault on 14/11/2025.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: SudokuGeneratorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var exportingEntry: HistoryEntry?
    @State private var showingShareSheet = false
    @State private var pdfDataToShare: [(Data, String)] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.history.isEmpty {
                    emptyHistoryView
                } else {
                    historyList
                }
            }
            .navigationTitle("Historique")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
                
                if !viewModel.history.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.clearHistory()
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if !pdfDataToShare.isEmpty {
                    MultiFileShareSheet(items: pdfDataToShare)
                }
            }
        }
    }
    
    private var emptyHistoryView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Aucun historique")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Les grilles que vous générez apparaîtront ici")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var historyList: some View {
        List {
            ForEach(viewModel.history) { entry in
                HistoryRow(entry: entry) {
                    exportEntry(entry)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation {
                            viewModel.deleteHistoryEntry(entry)
                        }
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func exportEntry(_ entry: HistoryEntry) {
        // Génération des deux PDFs
        let puzzleData = PDFGenerator.generatePDF(
            sudokus: entry.sudokus,
            includeSolutions: false
        )
        
        let solutionData = PDFGenerator.generatePDF(
            sudokus: entry.sudokus,
            includeSolutions: true
        )
        
        var pdfsToShare: [(Data, String)] = []
        
        if let puzzleData = puzzleData {
            let puzzleFilename = PDFGenerator.generateFileName(for: "Grilles")
            pdfsToShare.append((puzzleData, puzzleFilename))
        }
        
        if let solutionData = solutionData {
            let solutionFilename = PDFGenerator.generateFileName(for: "Solutions")
            pdfsToShare.append((solutionData, solutionFilename))
        }
        
        pdfDataToShare = pdfsToShare
        showingShareSheet = true
    }
}

// MARK: - History Row

struct HistoryRow: View {
    let entry: HistoryEntry
    let onExport: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                    // Affichage du range de grilles
                Text(entry.gridRange)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                    // Affichage des niveaux avec leurs logos
                HStack(spacing: 4) {
                    Text("Niveaux :")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(entry.uniqueDifficulties, id: \.id) { difficulty in
                        HStack(spacing: 2) {
                            Image(systemName: difficulty.icon)
                                .font(.caption)
                                .foregroundColor(difficulty.color)
                        }
                    }
                }
            }
            
            Spacer()
            
            Button(action: onExport) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.down")
                    Text("Exporter")
                }
                .font(.callout)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Multi-File Share Sheet

struct MultiFileShareSheet: UIViewControllerRepresentable {
    let items: [(Data, String)]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Création des URLs temporaires pour les PDFs
        let tempURLs = items.map { data, filename -> URL in
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try? data.write(to: tempURL)
            return tempURL
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: tempURLs,
            applicationActivities: nil
        )
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    HistoryView(viewModel: SudokuGeneratorViewModel())
}
