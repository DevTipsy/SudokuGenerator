//
//  GeneratedSudoku.swift
//  SudokuGenerator
//
//  Created by Thibault on 04/09/2025.
//


import Foundation

struct GeneratedSudoku: Identifiable, Equatable {
    let id: UUID
    let puzzle: [[Int?]]
    let solution: [[Int]]
    let difficulty: Difficulty
    let number: Int
    
    init(id: UUID = UUID(), puzzle: [[Int?]], solution: [[Int]], difficulty: Difficulty, number: Int) {
        self.id = id
        self.puzzle = puzzle
        self.solution = solution
        self.difficulty = difficulty
        self.number = number
    }
}
