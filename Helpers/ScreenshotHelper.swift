//
//  ScreenshotHelper.swift
//  SudokuGenerator
//
//  Created by Thibault on 07/09/2025.
//
//  Ajoute ce fichier uniquement en configuration Debug
//  Pour l'utiliser : Product > Scheme > Edit Scheme > Run > Arguments
//  Ajoute "-screenshots" dans Arguments Passed On Launch
//

#if DEBUG
import SwiftUI

extension MainView {
    func setupForScreenshots() {
        // Détecte si on est en mode screenshot
        if ProcessInfo.processInfo.arguments.contains("-screenshots") {
            // Génère automatiquement des sudokus
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec
                
                // Génère 8 sudokus avec difficultés variées
                await viewModel.generateSudokus(
                    count: 8,
                    difficulties: [.beginner, .intermediate, .expert, .hardcore]
                )
                
                // Sauvegarde un état pour le compteur
                UserDefaults.standard.set(142, forKey: "totalGenerated")
            }
        }
    }
}
#endif