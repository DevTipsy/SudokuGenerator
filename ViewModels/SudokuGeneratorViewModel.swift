//
//  SudokuGeneratorViewModel.swift
//  SudokuGenerator
//
//  Created by Thibault on 04/09/2025.
//

import Foundation

@MainActor
class SudokuGeneratorViewModel: ObservableObject {
    @Published var generatedSudokus: [GeneratedSudoku] = []
    @Published var isGenerating = false
    @Published var history: [HistoryEntry] = []
    
    private let historyKey = "sudokuHistory"
    
    init() {
        loadHistory()
    }
    
    // MARK: - Génération avec Swift Concurrency moderne
    
    func generateSudokus(count: Int, difficulties: [Difficulty]) async {
        isGenerating = true
        
        // Option 1: Task concurrent avec actors (Recommandé pour Swift 6)
        let newSudokus = await withTaskGroup(of: GeneratedSudoku.self) { group in
            for i in 1...count {
                group.addTask {
                    let difficulty = difficulties.randomElement() ?? .beginner
                    return SudokuGenerator.generate(difficulty: difficulty, number: i)
                }
            }
            
            var sudokus: [GeneratedSudoku] = []
            for await sudoku in group {
                sudokus.append(sudoku)
            }
            
            // Trier par numéro pour maintenir l'ordre
            return sudokus.sorted { $0.number < $1.number }
        }
        
        // Mise à jour sur MainActor (déjà garanti car la classe est @MainActor)
        generatedSudokus = newSudokus
        isGenerating = false
        
        // Ajouter à l'historique
        if !newSudokus.isEmpty {
            addToHistory(sudokus: newSudokus)
        }
    }
    
    // Alternative pour Swift 5.5+ (plus simple mais moins performante)
    func generateSudokusAlternative(count: Int, difficulties: [Difficulty]) async {
        isGenerating = true
        
        // Génération séquentielle mais dans un contexte async
        var sudokus: [GeneratedSudoku] = []
        
        for i in 1...count {
            // Yield pour ne pas bloquer le main thread
            await Task.yield()
            
            let difficulty = difficulties.randomElement() ?? .beginner
            let sudoku = SudokuGenerator.generate(difficulty: difficulty, number: i)
            sudokus.append(sudoku)
        }
        
        generatedSudokus = sudokus
        isGenerating = false
    }
    
    // MARK: - Export PDF
    
    func exportPDF(includeSolutions: Bool) -> (Data?, filename: String) {
        let data = PDFGenerator.generatePDF(
            sudokus: generatedSudokus,
            includeSolutions: includeSolutions
        )
        
        let filename = PDFGenerator.generateFileName(
            for: includeSolutions ? "Solutions" : "Grilles"
        )
        
        return (data, filename)
    }
    
    // MARK: - Actions supplémentaires
    
    func clearSudokus() {
        generatedSudokus = []
    }
    
    func regenerate(count: Int, difficulties: [Difficulty]) async {
        // Efface et régénère
        generatedSudokus = []
        await generateSudokus(count: count, difficulties: difficulties)
    }
    
    // MARK: - Gestion de l'historique
    
    private func addToHistory(sudokus: [GeneratedSudoku]) {
        let entry = HistoryEntry(sudokus: sudokus)
        history.insert(entry, at: 0)
        saveHistory()
    }
    
    private func saveHistory() {
        guard let encoded = try? JSONEncoder().encode(history) else { return }
        UserDefaults.standard.set(encoded, forKey: historyKey)
    }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) else {
            return
        }
        history = decoded
    }
    
    func deleteHistoryEntry(_ entry: HistoryEntry) {
        history.removeAll { $0.id == entry.id }
        saveHistory()
    }
    
    func clearHistory() {
        history = []
        saveHistory()
    }
}

// MARK: - Extension pour la conformité Sendable (Swift 6 ready)

extension GeneratedSudoku: @unchecked Sendable {
    // GeneratedSudoku est déjà Sendable car tous ses membres sont immutables
}

// Note pour Swift 6:
// Si SudokuGenerator.generate n'est pas isolé sur un actor,
// considérez l'ajout de @Sendable ou la migration vers un actor
