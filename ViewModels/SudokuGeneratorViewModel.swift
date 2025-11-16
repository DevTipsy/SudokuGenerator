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
    private let counterKey = "sudokuCounter"
    
    // Compteur global pour la numérotation des grilles
    private var globalCounter: Int {
        get {
            UserDefaults.standard.integer(forKey: counterKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: counterKey)
        }
    }
    
    init() {
        loadHistory()
    }
    
    // MARK: - Génération avec Swift Concurrency moderne
    
    func generateSudokus(count: Int, difficulties: [Difficulty]) async {
        isGenerating = true
        
        // Récupérer le compteur actuel et l'incrémenter
        let startNumber = globalCounter + 1
        
        // Option 1: Task concurrent avec actors (Recommandé pour Swift 6)
        let newSudokus = await withTaskGroup(of: (GeneratedSudoku, Int).self) { group in
            for i in 0..<count {
                let sudokuNumber = startNumber + i
                group.addTask {
                    let difficulty = difficulties.randomElement() ?? .beginner
                    let sudoku = SudokuGenerator.generate(difficulty: difficulty, number: sudokuNumber)
                    return (sudoku, sudokuNumber)
                }
            }
            
            var sudokus: [(GeneratedSudoku, Int)] = []
            for await result in group {
                sudokus.append(result)
            }
            
            // Trier par numéro pour maintenir l'ordre
            return sudokus.sorted { $0.1 < $1.1 }.map { $0.0 }
        }
        
        // Mettre à jour le compteur global
        globalCounter = startNumber + count - 1
        
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
        
        // Récupérer le compteur actuel et l'incrémenter
        let startNumber = globalCounter + 1
        
        // Génération séquentielle mais dans un contexte async
        var sudokus: [GeneratedSudoku] = []
        
        for i in 0..<count {
            // Yield pour ne pas bloquer le main thread
            await Task.yield()
            
            let sudokuNumber = startNumber + i
            let difficulty = difficulties.randomElement() ?? .beginner
            let sudoku = SudokuGenerator.generate(difficulty: difficulty, number: sudokuNumber)
            sudokus.append(sudoku)
        }
        
        // Mettre à jour le compteur global
        globalCounter = startNumber + count - 1
        
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
