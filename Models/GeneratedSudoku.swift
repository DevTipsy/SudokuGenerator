//
//  GeneratedSudoku.swift
//  SudokuGenerator
//
//  Created by Thibault on 04/09/2025.
//


import Foundation

struct GeneratedSudoku: Identifiable, Equatable {
    let id = UUID()
    let puzzle: [[Int?]]
    let solution: [[Int]]
    let difficulty: Difficulty
    let number: Int
}
