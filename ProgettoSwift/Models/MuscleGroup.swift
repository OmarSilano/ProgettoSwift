import Foundation

enum MuscleGroup: String, CaseIterable, Codable{
    case abs = "Abs"
    case arms = "Arms"
    case back = "Back"
    case chest = "Chest"
    case shoulders = "Shoulders"
    case legs = "Legs"
}

extension MuscleGroup {
    var availableMethods: [Method] {
        switch self {
            
        case .chest:
            return [.pushChest, .pullChest]
            
        case .back:
            return [.pullUpBack, .rowBack]
            
        case .abs:
            return [.upperAbs, .lowerAbs, .fullPack]
            
        case .arms:
            return [.bicepsArms, .tricepsArms]
            
        case .shoulders:
            return [.pushShoulders, .lateralRaiseShoulders, .rotationShoulders]
            
        case .legs:
            return [.hPushLegs, .vPushLegs, .calfLegs, .hamstringLegs]
        }
    }
}
