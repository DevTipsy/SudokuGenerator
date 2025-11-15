//
// PDFGenerator.swift
// SudokuGenerator
//
// Created by Thibault on 04/09/2025.
//

import PDFKit
import UIKit
import Foundation

class PDFGenerator {
    private static let fixedFontSize: CGFloat = 20
    
    static func generatePDF(sudokus: [GeneratedSudoku], includeSolutions: Bool) -> Data? {
        let pdfDocument = PDFDocument()
        let sudokusPerPage = 4
        
        // Implémentation directe du chunking sans extension
        let chunkedSudokus = stride(from: 0, to: sudokus.count, by: sudokusPerPage).map { i in
            let endIndex = min(i + sudokusPerPage, sudokus.count)
            return Array(sudokus[i..<endIndex])
        }
        
        for (pageIndex, pageSudokus) in chunkedSudokus.enumerated() {
            if let page = createPDFPage(
                sudokus: pageSudokus,
                pageNumber: pageIndex + 1,
                includeSolutions: includeSolutions
            ) {
                pdfDocument.insert(page, at: pdfDocument.pageCount)
            }
        }
        
        return pdfDocument.dataRepresentation()
    }
    
    static func generateFileName(for type: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = formatter.string(from: Date())
        return "Sudoku_\(type)_\(timestamp).pdf"
    }
    
    private static func createPDFPage(sudokus: [GeneratedSudoku], pageNumber: Int, includeSolutions: Bool) -> PDFPage? {
        let includeDate = UserDefaults.standard.bool(forKey: "includeDate")  // ✅ Déclaré ici
        let pageSize = CGSize(width: 595, height: 842)
        let renderer = UIGraphicsImageRenderer(size: pageSize)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fill(CGRect(origin: .zero, size: pageSize))
            
            let title = includeSolutions ? "Solutions - Page \(pageNumber)" : "Sudokus - Page \(pageNumber)"
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            
            let titleSize = title.size(withAttributes: titleAttrs)
            title.draw(at: CGPoint(x: (pageSize.width - titleSize.width) / 2, y: 30), withAttributes: titleAttrs)
            
            let gridSize: CGFloat = 250
            let spacing: CGFloat = 30
            let startX = (pageSize.width - (gridSize * 2 + spacing)) / 2
            let startY: CGFloat = 80
            
            let positions: [(x: CGFloat, y: CGFloat)] = [
                (startX, startY),
                (startX + gridSize + spacing, startY),
                (startX, startY + gridSize + spacing + 40),
                (startX + gridSize + spacing, startY + gridSize + spacing + 40)
            ]
            
            for (index, sudoku) in sudokus.enumerated() {
                guard index < positions.count else { break }
                
                let position = positions[index]
                drawSudoku(sudoku: sudoku, at: position, size: gridSize, includeSolution: includeSolutions, in: ctx)
            }
            
            if includeDate {
                let footer = "Généré avec Générateur de Sudoku - \(formattedDate())"
                let footerAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                
                let footerSize = footer.size(withAttributes: footerAttrs)
                footer.draw(at: CGPoint(x: (pageSize.width - footerSize.width) / 2, y: pageSize.height - 40), withAttributes: footerAttrs)
            }
        }
        
        return PDFPage(image: image)
    }
    
    private static func drawSudoku(sudoku: GeneratedSudoku, at position: (x: CGFloat, y: CGFloat), size: CGFloat, includeSolution: Bool, in context: CGContext) {
        let title = "N°\(sudoku.number) - \(sudoku.difficulty.rawValue)"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ]
        
        title.draw(at: CGPoint(x: position.x, y: position.y - 20), withAttributes: titleAttrs)
        
        let cellSize = size / 9
        context.setStrokeColor(UIColor.black.cgColor)
        
        for i in 0...9 {
            let lineWidth: CGFloat = i % 3 == 0 ? 2.0 : 0.5
            context.setLineWidth(lineWidth)
            
            context.move(to: CGPoint(x: position.x, y: position.y + CGFloat(i) * cellSize))
            context.addLine(to: CGPoint(x: position.x + size, y: position.y + CGFloat(i) * cellSize))
            context.strokePath()
            
            context.move(to: CGPoint(x: position.x + CGFloat(i) * cellSize, y: position.y))
            context.addLine(to: CGPoint(x: position.x + CGFloat(i) * cellSize, y: position.y + size))
            context.strokePath()
        }
        
        let numberAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fixedFontSize, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        
        for row in 0..<9 {
            for col in 0..<9 {
                let value = includeSolution ? sudoku.solution[row][col] : sudoku.puzzle[row][col]
                
                if let value = value {
                    let text = "\(value)"
                    let textSize = text.size(withAttributes: numberAttrs)
                    
                    let x = position.x + CGFloat(col) * cellSize + (cellSize - textSize.width) / 2
                    let y = position.y + CGFloat(row) * cellSize + (cellSize - textSize.height) / 2
                    
                    text.draw(at: CGPoint(x: x, y: y), withAttributes: numberAttrs)
                }
            }
        }
    }
    
    private static func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: Date())
    }
}
