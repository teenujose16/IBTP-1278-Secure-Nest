//
//  LoginView.swift
//  SecureNest
//
//  Created by Teenu on 09/11/26.
//

import SwiftUI

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var pinCode = "4829"
    @State private var errorText: String?
    @State private var isPinVisible = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.primaryDark
                    .ignoresSafeArea()

                // Ambient Background Glow Spheres
                VStack {
                    Circle()
                        .fill(Theme.cyberBlue.opacity(0.12))
                        .frame(width: 320, height: 320)
                        .blur(radius: 80)
                        .offset(x: -100, y: -160)
                    Spacer()
                    Circle()
                        .fill(Theme.secureGreen.opacity(0.10))
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .offset(x: 120, y: 100)
                }
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        headerSection
                        loginCardSection
                        demoShortcutSection
                        terminalSecurityFooter
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.cardBackground)
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle().stroke(Theme.cyberBlue.opacity(0.4), lineWidth: 2)
                    )
                    .shadow(color: Theme.cyberBlue.opacity(0.25), radius: 16)

                Image(systemName: "shield.checkered")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.cyberBlue, Theme.secureGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("SecureNest")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Security Monitoring Companion")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    private var loginCardSection: some View {
        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("OPERATOR SECURITY PIN")
                    .font(.caption2.bold())
                    .foregroundColor(.gray)

                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Theme.cyberBlue)
                        .frame(width: 20)

                    if isPinVisible {
                        TextField("Enter Security PIN", text: $pinCode)
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                            .foregroundColor(.white)
                    } else {
                        SecureField("Enter Security PIN", text: $pinCode)
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                            .foregroundColor(.white)
                    }

                    Button {
                        isPinVisible.toggle()
                    } label: {
                        Image(systemName: isPinVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Theme.surfaceDark)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
            }

            if let errorText {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text(errorText)
                }
                .font(.caption)
                .foregroundColor(Theme.alertRed)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                authorizeTerminal()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Authorize Terminal Gateway")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Theme.cyberBlue, Theme.cyberBlue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(14)
                .shadow(color: Theme.cyberBlue.opacity(0.3), radius: 8, y: 4)
            }
        }
        .securityCard()
    }

    private var demoShortcutSection: some View {
        VStack(spacing: 8) {
            Text("Reviewer & Evaluation Mode")
                .font(.caption2)
                .foregroundColor(.gray)

            Button {
                pinCode = "4829"
                authorizeTerminal()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                    Text("Auto-fill Default PIN (4829)")
                }
                .font(.footnote.bold())
                .foregroundColor(Theme.secureGreen)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Theme.secureGreen.opacity(0.12))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.secureGreen.opacity(0.3), lineWidth: 1))
            }
        }
    }

    private var terminalSecurityFooter: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Theme.secureGreen)
                .frame(width: 6, height: 6)
            Text("GATEWAY ONLINE")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Theme.secureGreen)
            Text("•")
                .foregroundColor(.gray)
            Text("AES-256")
                .font(.system(size: 10))
                .foregroundColor(.gray)
            Text("•")
                .foregroundColor(.gray)
            Text("SWIFTDATA PERSISTED")
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .padding(.top, 4)
    }

    private func authorizeTerminal() {
        if pinCode == "4829" {
            errorText = nil
            isAuthenticated = true
        } else {
            errorText = "Invalid security PIN. Default is 4829."
        }
    }
}
