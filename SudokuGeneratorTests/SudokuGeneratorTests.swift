//
//  SudokuGeneratorTests.swift
//  SudokuGeneratorTests
//
//  Created by Thibault on 03/09/2025.
//

import XCTest
@testable import SudokuGenerator

final class SudokuGeneratorTests: XCTestCase {
    
    // Test basique pour vérifier que la génération fonctionne
    func testSudokuGeneration() {
        let sudoku = SudokuGenerator.generate(difficulty: .beginner, number: 1)
        
        // Vérifier que le puzzle est généré
        XCTAssertEqual(sudoku.puzzle.count, 9, "Le sudoku doit avoir 9 lignes")
        XCTAssertEqual(sudoku.puzzle[0].count, 9, "Chaque ligne doit avoir 9 colonnes")
        
        // Vérifier que la solution est complète
        XCTAssertEqual(sudoku.solution.count, 9, "La solution doit avoir 9 lignes")
        
        // Vérifier qu'il y a le bon nombre de cases vides pour débutant (40)
        let emptyCells = sudoku.puzzle.flatMap { $0 }.compactMap { $0 == nil ? 1 : nil }.count
        XCTAssertEqual(emptyCells, 40, "Difficulty.beginner doit avoir 40 cases vides")
    }
    
    // Test de performance
    func testGenerationPerformance() {
        measure {
            // Générer 10 sudokus devrait prendre moins de 1 seconde
            for i in 1...10 {
                _ = SudokuGenerator.generate(difficulty: .intermediate, number: i)
            }
        }
    }
    
    // Test pour vérifier que chaque difficulté a le bon nombre de cases vides
    func testDifficultyLevels() {
        let difficulties: [(Difficulty, Int)] = [
            (.beginner, 40),
            (.intermediate, 48),
            (.expert, 54),
            (.hardcore, 60)
        ]
        
        for (difficulty, expectedEmpty) in difficulties {
            let sudoku = SudokuGenerator.generate(difficulty: difficulty, number: 1)
            let emptyCells = sudoku.puzzle.flatMap { $0 }.compactMap { $0 == nil ? 1 : nil }.count
            XCTAssertEqual(emptyCells, expectedEmpty, "\(difficulty.rawValue) devrait avoir \(expectedEmpty) cases vides")
        }
    }
    
    // Test pour vérifier que la solution est valide
    func testSolutionValidity() {
        let sudoku = SudokuGenerator.generate(difficulty: .intermediate, number: 1)
        
        // Vérifier que chaque ligne contient 1-9
        for row in sudoku.solution {
            let sortedRow = row.sorted()
            XCTAssertEqual(sortedRow, [1, 2, 3, 4, 5, 6, 7, 8, 9], "Chaque ligne doit contenir tous les chiffres de 1 à 9")
        }
        
        // Vérifier que chaque colonne contient 1-9
        for col in 0..<9 {
            let column = (0..<9).map { sudoku.solution[$0][col] }.sorted()
            XCTAssertEqual(column, [1, 2, 3, 4, 5, 6, 7, 8, 9], "Chaque colonne doit contenir tous les chiffres de 1 à 9")
        }
    }
}
