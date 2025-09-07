//
//  PreviewSection.swift
//  SudokuGenerator
//
//  Created by Thibault on 04/09/2025.
//

import SwiftUI

struct PreviewSection: View {
    @ObservedObject var viewModel: SudokuGeneratorViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.generatedSudokus.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.grid.3x3")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary.opacity(0.5))
                    
                    VStack(spacing: 4) {
                        Text("Générateur de sudokus")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Configurez et générez")
                            .font(.caption)
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Label("\(viewModel.generatedSudokus.count) sudoku(s) générés",
                              systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption2)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(viewModel.generatedSudokus) { sudoku in
                                MiniSudokuView(sudoku: sudoku)
                                    .frame(width: 150, height: 150)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
        }
        .background(Color(UIColor.systemGray6))
    }
}

#Preview {
    PreviewSection(viewModel: SudokuGeneratorViewModel())
}
