//
//  MiniSudokuView.swift
//  SudokuGenerator
//
//  Created by Thibault on 04/09/2025.
//

import SwiftUI

struct MiniSudokuView: View {
    let sudoku: GeneratedSudoku
    @State private var showingDetail = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 4) {
            // En-tête avec numéro et difficulté
            HStack {
                Text("N°\(sudoku.number)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.primary) // ✅ S'adapte au Dark/Light mode
                
                Spacer()
                
                Image(systemName: sudoku.difficulty.icon)
                    .font(.caption)
                    .foregroundStyle(sudoku.difficulty.color)
            }
            .padding(.horizontal, 2)
            
            // Grille de Sudoku
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let cellSize = size / 9
                
                ZStack {
                    // Fond adaptatif pour la grille
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(uiColor: .systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(uiColor: .separator), lineWidth: 0.5)
                        )
                    
                    // Lignes de la grille
                    ForEach(0..<10) { i in
                        // Lignes horizontales
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: CGFloat(i) * cellSize))
                            path.addLine(to: CGPoint(x: size, y: CGFloat(i) * cellSize))
                        }
                        .stroke(
                            i % 3 == 0 ? Color(uiColor: .label) : Color(uiColor: .separator),
                            lineWidth: i % 3 == 0 ? 1.5 : 0.5
                        )
                        
                        // Lignes verticales
                        Path { path in
                            path.move(to: CGPoint(x: CGFloat(i) * cellSize, y: 0))
                            path.addLine(to: CGPoint(x: CGFloat(i) * cellSize, y: size))
                        }
                        .stroke(
                            i % 3 == 0 ? Color(uiColor: .label) : Color(uiColor: .separator),
                            lineWidth: i % 3 == 0 ? 1.5 : 0.5
                        )
                    }
                    
                    // Nombres du sudoku
                    ForEach(0..<9, id: \.self) { row in
                        ForEach(0..<9, id: \.self) { col in
                            if let value = sudoku.puzzle[row][col] {
                                Text("\(value)")
                                    .font(.system(size: cellSize * 0.55, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color(uiColor: .label)) // ✅ Adaptatif
                                    .frame(width: cellSize, height: cellSize)
                                    .position(
                                        x: CGFloat(col) * cellSize + cellSize / 2,
                                        y: CGFloat(row) * cellSize + cellSize / 2
                                    )
                            }
                        }
                    }
                }
                .frame(width: size, height: size)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .padding(8)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(uiColor: .separator), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                radius: 3, x: 0, y: 2)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            SudokuDetailView(sudoku: sudoku)
        }
    }
}

// Preview pour tester les deux modes
#Preview("Light Mode") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
            ForEach(0..<4) { i in
                MiniSudokuView(
                    sudoku: GeneratedSudoku(
                        puzzle: generateSamplePuzzle(),
                        solution: [[Int]](),
                        difficulty: Difficulty.allCases[i % 4],
                        number: i + 1
                    )
                )
                .frame(width: 150, height: 150)
            }
        }
        .padding()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
            ForEach(0..<4) { i in
                MiniSudokuView(
                    sudoku: GeneratedSudoku(
                        puzzle: generateSamplePuzzle(),
                        solution: [[Int]](),
                        difficulty: Difficulty.allCases[i % 4],
                        number: i + 1
                    )
                )
                .frame(width: 150, height: 150)
            }
        }
        .padding()
    }
    .preferredColorScheme(.dark)
    .background(Color.black)
}

// Helper pour les previews
private func generateSamplePuzzle() -> [[Int?]] {
    var puzzle: [[Int?]] = Array(repeating: Array(repeating: nil, count: 9), count: 9)
    // Ajouter quelques chiffres pour l'exemple
    for _ in 0..<30 {
        let row = Int.random(in: 0..<9)
        let col = Int.random(in: 0..<9)
        puzzle[row][col] = Int.random(in: 1...9)
    }
    return puzzle
}
