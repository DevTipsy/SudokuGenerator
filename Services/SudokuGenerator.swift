//
//  SudokuGenerator.swift
//  SudokuGenerator
//
//  Created by Thibault on 04/09/2025.
//


import Foundation

class SudokuGenerator {
    static func generate(difficulty: Difficulty, number: Int) -> GeneratedSudoku {
        let solution = generateCompleteSudoku()
        let puzzle = createPuzzle(from: solution, difficulty: difficulty)
        
        return GeneratedSudoku(
            puzzle: puzzle,
            solution: solution,
            difficulty: difficulty,
            number: number
        )
    }
    
    private static func generateCompleteSudoku() -> [[Int]] {
        var board = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        
        for box in stride(from: 0, to: 9, by: 3) {
            fillBox(&board, startRow: box, startCol: box)
        }
        
        _ = solveSudoku(&board)
        
        return board
    }
    
    private static func fillBox(_ board: inout [[Int]], startRow: Int, startCol: Int) {
        var numbers = Array(1...9).shuffled()
        
        for i in 0..<3 {
            for j in 0..<3 {
                board[startRow + i][startCol + j] = numbers.removeLast()
            }
        }
    }
    
    private static func solveSudoku(_ board: inout [[Int]]) -> Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                if board[row][col] == 0 {
                    for num in (1...9).shuffled() {
                        if isValid(board, row: row, col: col, num: num) {
                            board[row][col] = num
                            
                            if solveSudoku(&board) {
                                return true
                            }
                            
                            board[row][col] = 0
                        }
                    }
                    return false
                }
            }
        }
        return true
    }
    
    private static func isValid(_ board: [[Int]], row: Int, col: Int, num: Int) -> Bool {
        if board[row].contains(num) { return false }
        
        for i in 0..<9 {
            if board[i][col] == num { return false }
        }
        
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        for i in boxRow..<boxRow + 3 {
            for j in boxCol..<boxCol + 3 {
                if board[i][j] == num { return false }
            }
        }
        
        return true
    }
    
    private static func createPuzzle(from solution: [[Int]], difficulty: Difficulty) -> [[Int?]] {
        var puzzle: [[Int?]] = solution.map { row in
            row.map { Int?($0) }
        }
        
        var allPositions: [(row: Int, col: Int)] = []
        for row in 0..<9 {
            for col in 0..<9 {
                allPositions.append((row: row, col: col))
            }
        }
        
        allPositions.shuffle()
        let cellsToRemove = difficulty.cellsToRemove
        
        for i in 0..<cellsToRemove {
            let position = allPositions[i]
            puzzle[position.row][position.col] = nil
        }
        
        return puzzle
    }
}
