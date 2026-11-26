//
//  Theme.swift
//  SecureNest
//

import SwiftUI

public struct Theme {
    public static let primaryDark = Color(red: 0.06, green: 0.08, blue: 0.12)
    public static let surfaceDark = Color(red: 0.10, green: 0.13, blue: 0.18)
    public static let cardBackground = Color(red: 0.13, green: 0.17, blue: 0.23)
    public static let cyberBlue = Color(red: 0.20, green: 0.65, blue: 1.00)
    public static let secureGreen = Color(red: 0.18, green: 0.80, blue: 0.44)
    public static let alertRed = Color(red: 0.95, green: 0.26, blue: 0.26)
    public static let warningAmber = Color(red: 1.00, green: 0.70, blue: 0.20)
    public static let nightIndigo = Color(red: 0.40, green: 0.45, blue: 0.95)
}

public struct SecurityCardModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Theme.cardBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

public extension View {
    func securityCard() -> some View {
        self.modifier(SecurityCardModifier())
    }
}
