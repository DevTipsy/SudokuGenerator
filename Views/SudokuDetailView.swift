//
//  SudokuDetailView.swift
//  SudokuGenerator
//
//  Created by Thibault on 04/09/2025.
//

import SwiftUI

struct SudokuDetailView: View {
    let sudoku: GeneratedSudoku
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSolution = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Info header avec couleurs adaptatives
                HStack {
                    Label {
                        Text("N°\(sudoku.number)")
                            .foregroundStyle(Color.primary)
                    } icon: {
                        Image(systemName: "number.circle")
                            .foregroundStyle(Color.accentColor)
                    }
                    
                    Spacer()
                    
                    Label {
                        Text(sudoku.difficulty.rawValue)
                            .foregroundStyle(sudoku.difficulty.color)
                    } icon: {
                        Image(systemName: sudoku.difficulty.icon)
                            .foregroundStyle(sudoku.difficulty.color)
                    }
                }
                .font(.headline)
                .padding(.horizontal)
                
                // Grille agrandie
                GeometryReader { geometry in
                    let size = min(geometry.size.width * 0.9, 350)
                    
                    VStack {
                        Spacer()
                        
                        // Utilisation de la vue grille corrigée
                        SudokuGridViewAdaptive(
                            puzzle: showingSolution ?
                                sudoku.solution.map { $0.map { Int?($0) }} :
                                sudoku.puzzle,
                            size: size
                        )
                        .frame(width: size, height: size)
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                }
                
                // Boutons d'action
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingSolution.toggle()
                        }
                    }) {
                        Label(
                            showingSolution ? "Masquer solution" : "Voir solution",
                            systemImage: showingSolution ? "eye.slash" : "eye"
                        )
                    }
                    .buttonStyle(.bordered)
                    .tint(showingSolution ? .orange : .blue)
                    
                    ShareLink(
                        item: exportSinglePDF(),
                        preview: SharePreview(
                            "Sudoku N°\(sudoku.number)",
                            icon: Image(systemName: "square.grid.3x3")
                        )
                    ) {
                        Label("Partager", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Détail du Sudoku")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
    
    private func exportSinglePDF() -> URL {
        let data = PDFGenerator.generatePDF(
            sudokus: [sudoku],
            includeSolutions: false
        )
        
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Sudoku_\(sudoku.number).pdf")
        try? data?.write(to: url)
        
        return url
    }
}

// Vue grille adaptative aux deux modes
struct SudokuGridViewAdaptive: View {
    let puzzle: [[Int?]]
    let size: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Fond avec couleur système
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: .systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(uiColor: .separator), lineWidth: 1)
                )
            
            // Grille complète
            let cellSize = size / 9
            
            // Lignes de grille
            ForEach(0...9, id: \.self) { i in
                let isMainLine = i % 3 == 0
                let lineColor = isMainLine ?
                    Color(uiColor: .label) :
                    Color(uiColor: .separator)
                let lineWidth: CGFloat = isMainLine ? 2 : 0.5
                
                // Ligne horizontale
                Path { path in
                    path.move(to: CGPoint(x: 0, y: CGFloat(i) * cellSize))
                    path.addLine(to: CGPoint(x: size, y: CGFloat(i) * cellSize))
                }
                .stroke(lineColor, lineWidth: lineWidth)
                
                // Ligne verticale
                Path { path in
                    path.move(to: CGPoint(x: CGFloat(i) * cellSize, y: 0))
                    path.addLine(to: CGPoint(x: CGFloat(i) * cellSize, y: size))
                }
                .stroke(lineColor, lineWidth: lineWidth)
            }
            
            // Nombres
            ForEach(0..<9, id: \.self) { row in
                ForEach(0..<9, id: \.self) { col in
                    if let value = puzzle[row][col] {
                        Text("\(value)")
                            .font(.system(size: cellSize * 0.6, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(uiColor: .label))
                            .position(
                                x: CGFloat(col) * cellSize + cellSize / 2,
                                y: CGFloat(row) * cellSize + cellSize / 2
                            )
                    }
                }
            }
        }
        .frame(width: size, height: size)
        // Ombre adaptative selon le mode
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.5 : 0.1),
            radius: 5,
            x: 0,
            y: 2
        )
    }
}

// Preview Helper
#Preview("Detail View") {
    SudokuDetailView(
        sudoku: GeneratedSudoku(
            puzzle: createSamplePuzzle(),
            solution: createCompleteSudoku(),
            difficulty: .intermediate,
            number: 42
        )
    )
}

// Helpers pour les previews
private func createSamplePuzzle() -> [[Int?]] {
    var puzzle: [[Int?]] = Array(repeating: Array(repeating: nil, count: 9), count: 9)
    let values: [(Int, Int, Int)] = [
        (0, 0, 5), (0, 1, 3), (0, 4, 7),
        (1, 0, 6), (1, 3, 1), (1, 4, 9), (1, 5, 5),
        (2, 1, 9), (2, 2, 8), (2, 7, 6),
        (3, 0, 8), (3, 4, 6), (3, 8, 3),
        (4, 0, 4), (4, 3, 8), (4, 5, 3), (4, 8, 1),
        (5, 0, 7), (5, 4, 2), (5, 8, 6),
        (6, 1, 6), (6, 6, 2), (6, 7, 8),
        (7, 3, 4), (7, 4, 1), (7, 5, 9), (7, 8, 5),
        (8, 4, 8), (8, 7, 7), (8, 8, 9)
    ]
    for (row, col, value) in values {
        puzzle[row][col] = value
    }
    return puzzle
}

private func createCompleteSudoku() -> [[Int]] {
    return [
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9]
    ]
}
