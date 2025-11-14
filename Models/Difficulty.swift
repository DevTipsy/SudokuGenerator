//
//  Difficulty.swift
//  SudokuGenerator
//
//  Created by Thibault on 04/09/2025.
//


import SwiftUI

enum Difficulty: String, CaseIterable, Identifiable {
    case beginner = "Débutant"
    case intermediate = "Intermédiaire"
    case expert = "Expert"
    case hardcore = "Hardcore"
    
    var id: String { rawValue }
    
    var cellsToRemove: Int {
        switch self {
        case .beginner: return 35       // Réduit de 40 à 35 pour plus de cohérence
        case .intermediate: return 45   // Réduit de 48 à 45
        case .expert: return 52         // Réduit de 54 à 52
        case .hardcore: return 58       // Réduit de 60 à 58
        }
    }
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .blue
        case .expert: return .orange
        case .hardcore: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "1.circle"
        case .intermediate: return "2.circle"
        case .expert: return "3.circle"
        case .hardcore: return "4.circle"
        }
    }
}
