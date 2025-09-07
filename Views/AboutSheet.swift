//
//  AboutSheet.swift
//  SudokuGenerator
//
//  Created by Thibault on 04/09/2025.
//

import SwiftUI
import MessageUI
import StoreKit

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview // iOS 16+
    @AppStorage("includeDate") private var includeDate = true
    @AppStorage("totalGenerated") private var totalGenerated = 0
    @State private var showingPrivacyPolicy = false
    @State private var showingMailComposer = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    // ID de ton app sur l'App Store (à remplacer après publication)
    private let appStoreID = "6738950456" // Remplace par ton vrai ID après publication
    
    var body: some View {
        NavigationStack {
            List {
                // Section principale
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Sudoku Master")
                            .font(.title.bold())
                        
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Générez des sudokus instantanément")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                
                // Fonctionnalités
                Section("Pourquoi Sudoku Master ?") {
                    FeatureRow(
                        icon: "wifi.slash",
                        iconColor: .green,
                        title: "100% Hors ligne",
                        subtitle: "Aucune connexion requise"
                    )
                    
                    FeatureRow(
                        icon: "bolt.fill",
                        iconColor: .orange,
                        title: "Génération instantanée",
                        subtitle: "Jusqu'à 20 sudokus en quelques secondes"
                    )
                    
                    FeatureRow(
                        icon: "printer.fill",
                        iconColor: .blue,
                        title: "Export PDF optimisé",
                        subtitle: "4 sudokus par page pour l'impression"
                    )
                    
                    FeatureRow(
                        icon: "lock.shield.fill",
                        iconColor: .purple,
                        title: "Respect de la vie privée",
                        subtitle: "Aucune donnée collectée"
                    )
                }
                
                // Statistiques
                Section("Statistiques") {
                    HStack {
                        Label("Total généré", systemImage: "chart.bar.fill")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("\(totalGenerated)")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                }
                
                // Développeur - Version améliorée
                Section("Développeur") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.indigo, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Créé par Thibault alias DevTipsy")
                                .font(.subheadline.weight(.medium))
                            Link(destination: URL(string: "https://github.com/DevTipsy")!) {
                                HStack(spacing: 4) {
                                    Text("github.com/DevTipsy")
                                        .font(.caption)
                                    Image(systemName: "arrow.up.forward.square")
                                        .font(.caption2)
                                }
                                .foregroundColor(.accentColor)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                // Support & Informations
                Section {
                    // Contact support - Ouvre Mail directement
                    Button(action: openMail) {
                        Label("Contacter le support", systemImage: "envelope.fill")
                            .foregroundColor(.primary)
                    }
                    
                    // Politique de confidentialité
                    Button(action: { showingPrivacyPolicy = true }) {
                        Label("Politique de confidentialité", systemImage: "lock.shield")
                            .foregroundColor(.primary)
                    }
                    
                    // Noter l'app - Utilise la nouvelle API iOS 16+
                    Button(action: rateApp) {
                        Label("Noter l'application", systemImage: "star.fill")
                            .foregroundColor(.accentColor)
                    }
                } header: {
                    Text("Support & Informations")
                }
            }
            .navigationTitle("À propos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingMailComposer) {
                MailComposerView(
                    recipient: "thibault_sanclemente@icloud.com",
                    subject: "Support Sudoku Master",
                    body: generateSupportEmailBody(),
                    result: $mailResult
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private func openMail() {
        // Vérifie si Mail est disponible
        if MFMailComposeViewController.canSendMail() {
            showingMailComposer = true
        } else {
            // Fallback : ouvre l'app Mail avec mailto
            if let url = URL(string: "mailto:thibault_sanclemente@icloud.com?subject=Support%20Sudoku%20Master") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func rateApp() {
        // iOS 16+ : Utilise la nouvelle API RequestReview
        if #available(iOS 16.0, *) {
            requestReview()
        } else {
            // iOS 15 et moins : Ouvre directement l'App Store
            if let url = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func generateSupportEmailBody() -> String {
        let device = UIDevice.current
        return """
        
        ----
        Informations de debug :
        App Version: 1.0
        iOS: \(device.systemVersion)
        Appareil: \(device.model)
        Total généré: \(totalGenerated)
        """
    }
}

// MARK: - Mail Composer

struct MailComposerView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let body: String
    @Binding var result: Result<MFMailComposeResult, Error>?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients([recipient])
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerView
        
        init(_ parent: MailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                  didFinishWith result: MFMailComposeResult,
                                  error: Error?) {
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
            parent.dismiss()
        }
    }
}

// Composant réutilisable pour les fonctionnalités
struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } icon: {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
        }
    }
}

#Preview {
    AboutSheet()
}
