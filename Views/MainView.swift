//
//  MainView.swift
//  SudokuGenerator
//
//  Created by Thibault on 04/09/2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = SudokuGeneratorViewModel()
    @State private var numberOfSudokus = 4
    @State private var selectedDifficulties = Set<Difficulty>([.beginner])
    @State private var showingExportSheet = false
    @State private var showingAbout = false
    @AppStorage("totalGenerated") private var totalGenerated = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                PreviewSection(viewModel: viewModel)
                
                VStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("QUANTITÉ À GÉNÉRER (MAXIMUM 20)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack {
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
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NIVEAUX DE DIFFICULTÉ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(Difficulty.allCases.enumerated()), id: \.element.id) { index, difficulty in
                                VStack(spacing: 0) {
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
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)  // Réduit de padding()
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
                                    
                                    if index < Difficulty.allCases.count - 1 {
                                        Divider()
                                            .padding(.leading, 44)
                                    }
                                }
                            }
                        }
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 8)
                }
                .padding(.top, 10)
                .background(Color(UIColor.systemGroupedBackground))
                
                VStack(spacing: 5) {
                    Button(action: {
                        Task {
                            await viewModel.generateSudokus(
                                count: numberOfSudokus,
                                difficulties: Array(selectedDifficulties)
                            )
                        }
                    }) {
                        HStack {
                            if viewModel.isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.7)
                                    .tint(.white)
                            } else {
                                Label("Générer", systemImage: "wand.and.stars")
                                    .font(.body.weight(.medium))
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 42)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isGenerating || selectedDifficulties.isEmpty)
                    
                    if !viewModel.generatedSudokus.isEmpty {
                        Button(action: { showingExportSheet = true }) {
                            Label("Exporter PDF", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity, minHeight: 38)
                                .font(.callout)
                        }
                        .buttonStyle(.bordered)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .navigationTitle("Sudoku Master")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAbout) {
                AboutSheet()
            }
            .onChange(of: viewModel.generatedSudokus) { _, newValue in
                if !newValue.isEmpty {
                    totalGenerated += newValue.count
                }
            }
        }
    }
}

#Preview {
    MainView()
}
