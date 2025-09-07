//
// GenerationForm.swift
// SudokuGenerator
//
// Created by Thibault on 04/09/2025.
//

import SwiftUI

struct GenerationForm: View {
    @Binding var numberOfSudokus: Int
    @Binding var selectedDifficulties: Set<Difficulty>  // <- Correction ici
    let onGenerate: () -> Void
    let isGenerating: Bool
    
    var body: some View {
        Form {
            // Section pour le nombre
            Section {
                Stepper(value: $numberOfSudokus, in: 1...20) {
                    HStack {
                        Image(systemName: "number.square")
                            .foregroundColor(.accentColor)
                        Text("Nombre de sudokus")
                        Spacer()
                        Text("\(numberOfSudokus)")
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                            .font(.title3)
                    }
                }
            } header: {
                Text("Quantité à générer (Maximum 20)")
            }
            
            // Section pour les difficultés
            Section("Niveaux de difficulté") {
                ForEach(Difficulty.allCases) { difficulty in
                    HStack {
                        Image(systemName: difficulty.icon)
                            .foregroundColor(difficulty.color)
                        Text(difficulty.rawValue)
                        Spacer()
                        if selectedDifficulties.contains(difficulty) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if selectedDifficulties.contains(difficulty) {
                                if selectedDifficulties.count > 1 {
                                    selectedDifficulties.remove(difficulty)
                                }
                            } else {
                                selectedDifficulties.insert(difficulty)
                            }
                        }
                    }
                }
            }
            
            // Bouton de génération
            Section {
                Button(action: onGenerate) {
                    HStack {
                        Spacer()
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                        } else {
                            Label("Générer", systemImage: "wand.and.stars")
                                .fontWeight(.medium)
                        }
                        Spacer()
                    }
                }
                .disabled(isGenerating || selectedDifficulties.isEmpty)
                .foregroundStyle(isGenerating || selectedDifficulties.isEmpty ? .gray : .white)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isGenerating || selectedDifficulties.isEmpty ?
                              Color.gray.opacity(0.3) : Color.accentColor)
                )
            }
        }
        .scrollDisabled(true)
    }
}
