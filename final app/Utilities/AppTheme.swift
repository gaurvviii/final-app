import SwiftUI

public enum AppTheme {
    public static let primaryPurple = Color(red: 147/255, green: 112/255, blue: 219/255)
    public static let deepBlue = Color(red: 25/255, green: 25/255, blue: 112/255)
    public static let nightBlack = Color(red: 13/255, green: 13/255, blue: 13/255)
    public static let darkGray = Color(red: 28/255, green: 28/255, blue: 30/255)
    public static let safetyRed = Color(red: 255/255, green: 69/255, blue: 58/255)
    
    // Secondary Colors
    public static let accentPurple = Color(red: 187/255, green: 134/255, blue: 252/255)
    public static let surfaceGray = Color(red: 18/255, green: 18/255, blue: 18/255)
    public static let textPrimary = Color.white
    public static let textSecondary = Color(white: 0.7)
    
    // Status Colors
    public static let success = Color(red: 48/255, green: 209/255, blue: 88/255)
    public static let warning = Color(red: 255/255, green: 214/255, blue: 10/255)
    public static let error = Color(red: 255/255, green: 69/255, blue: 58/255)
    
    // Gradients
    public static let primaryGradient = LinearGradient(
        colors: [primaryPurple, deepBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let darkGradient = LinearGradient(
        colors: [nightBlack, darkGray],
        startPoint: .top,
        endPoint: .bottom
    )
} 