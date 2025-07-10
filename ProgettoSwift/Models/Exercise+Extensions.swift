//
//  Excercise+Extensions.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
import Foundation
import CoreData

extension Exercise {

    enum MuscleGroup: String, CaseIterable{
        case abs = "Abs"
        case biceps = "Biceps"
        case triceps = "Triceps"
        case back = "Back"
        case chest = "Chest"
        case shoulders = "Shoulders"
        case legs = "Legs"
    }
    
    // Costruttore custom
    convenience init(context: NSManagedObjectContext,
                     id: UUID = UUID(),
                     name: String,
                     difficulty: Difficulty,
                     muscle: MuscleGroup,
                     method: String? = nil,
                     pathToImage: String? = "defaultImageName",
                     pathToVideo: String? = "defaultVideoName",
                     isBanned: Bool = false,
                     instructions: String? = nil
                     ) {
        
        self.init(context: context)
        
        self.id = id
        self.name = name
        self.difficulty = difficulty.rawValue
        self.muscle = muscle
        self.method = method
        self.pathToImage = pathToImage
        self.pathToVideo = pathToVideo
        self.isBanned = isBanned
        self.instructions = instructions
    }
    
}
