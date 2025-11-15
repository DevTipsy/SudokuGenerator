//
//  PrivacyPolicyView.swift
//  SudokuGenerator
//
//  Created by Thibault on 07/09/2025.
//


import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // En-tête
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Vos données sont en sécurité", systemImage: "lock.shield.fill")
                            .font(.title2.bold())
                            .foregroundStyle(Color.green)
                        
                        Text("Dernière mise à jour : \(currentDate())")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom)
                    
                    // Points principaux
                    PrivacySection(
                        icon: "wifi.slash",
                        iconColor: .blue,
                        title: "100% Hors ligne",
                        description: "Générateur de Sudoku fonctionne entièrement sur votre appareil. Aucune connexion internet n'est requise ou utilisée."
                    )
                    
                    PrivacySection(
                        icon: "icloud.slash",
                        iconColor: .orange,
                        title: "Aucune collecte de données",
                        description: "Nous ne collectons, ne stockons et ne transmettons aucune donnée personnelle. Vos sudokus restent sur votre appareil."
                    )
                    
                    PrivacySection(
                        icon: "person.crop.circle.badge.xmark",
                        iconColor: .purple,
                        title: "Pas de compte utilisateur",
                        description: "Aucune inscription requise. Aucun identifiant. Vous restez complètement anonyme."
                    )
                    
                    PrivacySection(
                        icon: "eye.slash.fill",
                        iconColor: .indigo,
                        title: "Pas de tracking",
                        description: "Aucun analytics, aucun tracker, aucune publicité. Votre activité reste privée."
                    )
                    
                    // Stockage local
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Stockage local uniquement", systemImage: "internaldrive")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Text("Les seules données stockées sont :")
                                .font(.subheadline)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                BulletPoint("Vos préférences d'affichage")
                                BulletPoint("Le compteur de sudokus générés (statistique locale)")
                                BulletPoint("Les PDF temporaires avant partage (supprimés automatiquement)")
                            }
                            .font(.footnote)
                        }
                    }
                    .backgroundStyle(Color(uiColor: .secondarySystemBackground))
                    
                    // Contact
                    GroupBox {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Des questions ?", systemImage: "questionmark.circle")
                                .font(.headline)
                            
                            Text("Si vous avez des questions sur cette politique, contactez-nous :")
                                .font(.footnote)
                            
                            Link(destination: URL(string: "mailto:thibault_sanclemente@icloud.com")!) {
                                Label("thibault_sanclemente@icloud.com", systemImage: "envelope")
                                    .font(.footnote)
                            }
                        }
                    }
                    
                    // Note finale
                    Text("Cette application a été conçue avec le respect de votre vie privée comme priorité absolue. Profitez de vos sudokus en toute tranquillité !")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Confidentialité")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { 
                        dismiss() 
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    private func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: Date())
    }
}

// Composant réutilisable pour les sections
struct PrivacySection: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// Composant pour les bullet points
struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(.secondary)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }
}

// Preview
#Preview("Privacy Policy") {
    PrivacyPolicyView()
}

#Preview("Privacy Dark Mode") {
    PrivacyPolicyView()
        .preferredColorScheme(.dark)
}
