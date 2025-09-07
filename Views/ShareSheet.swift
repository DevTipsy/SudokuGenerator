//
// ShareSheet.swift
// SudokuGenerator
//
// Created by Thibault on 04/09/2025.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let filename: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        var activityItems = items
        
        if let data = items.first as? Data {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try? data.write(to: tempURL)
            activityItems = [tempURL]
        }
        
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIView()
            popover.sourceRect = .zero
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
