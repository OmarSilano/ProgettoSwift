import Foundation

enum Method: String, CaseIterable, Codable {
    
    // Chest
    case pushChest = "Push"
    case pullChest = "Pull"
    
    // Back
    case pullUpBack = "Pull-up"
    case rowBack = "Row"
    
    // Abs
    case upperAbs = "Upper Abs"
    case lowerAbs = "Lower Abs"
    case fullPack = "Full Pack"
    
    // Arms
    case bicepsArms = "Biceps"
    case tricepsArms = "Triceps"
    
    // Shoulders
    case pushShoulders = "Shoulder Press"
    case lateralRaiseShoulders = "Lateral Raise"
    case rotationShoulders = "Shoulder Pull"
    
    // Legs
    case hPushLegs = "Horizontal Push"
    case vPushLegs = "Vertical Push"
    case calfLegs = "Calf Raise"
    case hamstringLegs = "Hamstring Curl"
}

