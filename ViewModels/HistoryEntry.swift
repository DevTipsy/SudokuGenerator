//
//  HistoryEntry.swift
//  SudokuGenerator
//
//  Created by Thibault on 14/11/2025.
//

import Foundation

struct HistoryEntry: Identifiable, Codable {
    let id: UUID
    let sudokus: [GeneratedSudoku]
    let generationDate: Date
    
    init(sudokus: [GeneratedSudoku], generationDate: Date = Date()) {
        self.id = UUID()
        self.sudokus = sudokus
        self.generationDate = generationDate
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy à HH:mm"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: generationDate)
    }
    
    var gridRange: String {
        let count = sudokus.count
        guard !sudokus.isEmpty else { return "Aucune grille" }
        
        let numbers = sudokus.map { $0.number }.sorted()
        guard let first = numbers.first, let last = numbers.last else {
            return "\(count) grille\(count > 1 ? "s" : "")"
        }
        
        if first == last {
            return "Grille \(first) (1 grille)"
        } else {
            return "Grilles \(first) à \(last) (\(count) grille\(count > 1 ? "s" : ""))"
        }
    }
    
    var uniqueDifficulties: [Difficulty] {
        let difficulties = Set(sudokus.map { $0.difficulty })
        return difficulties.sorted { d1, d2 in
            Difficulty.allCases.firstIndex(of: d1) ?? 0 < Difficulty.allCases.firstIndex(of: d2) ?? 0
        }
    }
    
    var description: String {
        let count = sudokus.count
        let difficulties = Set(sudokus.map { $0.difficulty })
        let difficultyString = difficulties.map { $0.rawValue }.joined(separator: ", ")
        return "\(count) grille\(count > 1 ? "s" : "") - \(difficultyString)"
    }
}

// MARK: - Extension pour la conformité Sendable (Swift 6 ready)

extension HistoryEntry: @unchecked Sendable {}

// MARK: - Codable pour GeneratedSudoku

extension GeneratedSudoku: Codable {
    enum CodingKeys: String, CodingKey {
        case id, puzzle, solution, difficulty, number
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        
        // Encodage du puzzle (avec optionnels)
        let puzzleData = puzzle.map { row in
            row.map { cell in cell ?? -1 }
        }
        try container.encode(puzzleData, forKey: .puzzle)
        
        try container.encode(solution, forKey: .solution)
        try container.encode(difficulty.rawValue, forKey: .difficulty)
        try container.encode(number, forKey: .number)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedId = try container.decode(UUID.self, forKey: .id)
        
        // Décodage du puzzle
        let puzzleData = try container.decode([[Int]].self, forKey: .puzzle)
        let decodedPuzzle = puzzleData.map { row in
            row.map { cell in cell == -1 ? nil : cell }
        }
        
        let decodedSolution = try container.decode([[Int]].self, forKey: .solution)
        let difficultyRawValue = try container.decode(String.self, forKey: .difficulty)
        guard let decodedDifficulty = Difficulty(rawValue: difficultyRawValue) else {
            throw DecodingError.dataCorruptedError(
                forKey: .difficulty,
                in: container,
                debugDescription: "Cannot decode Difficulty from \(difficultyRawValue)"
            )
        }
        let decodedNumber = try container.decode(Int.self, forKey: .number)
        
        // Utilisation du memberwise initializer pour les structs avec des propriétés let
        self.init(
            id: decodedId,
            puzzle: decodedPuzzle,
            solution: decodedSolution,
            difficulty: decodedDifficulty,
            number: decodedNumber
        )
    }
}
