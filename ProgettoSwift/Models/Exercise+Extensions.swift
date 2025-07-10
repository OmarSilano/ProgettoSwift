//
//  Excercise+Extensions.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
import Foundation
import CoreData

extension Exercise {
    
    var difficultyEnum: Difficulty {
        get {
            Difficulty(rawValue: difficulty ?? Difficulty.beginner.rawValue) ?? .beginner
        }
        set {
            difficulty = newValue.rawValue
        }
    }
    
    // Default paths se nil
    var safeImagePath: String {
        pathToImage ?? "default_image"
    }
    
    var safeVideoPath: String {
        pathToVideo ?? "default_video"
    }
    
    // Costruttore custom
    convenience init(context: NSManagedObjectContext,
                     id: UUID = UUID(),
                     name: String,
                     difficulty: Difficulty,
                     muscle: String,
                     method: String? = nil,
                     pathToImage: String? = nil,
                     pathToVideo: String? = nil,
                     isBanned: Bool = false,
                     instructions: String? = nil
                     ) {
        
        self.init(context: context)
        
        self.id = id
        self.name = name
        self.difficulty = difficulty.rawValue
        self.muscle = muscle
        self.method = method
        self.pathToImage = pathToImage ?? "defaultImageName"
        self.pathToVideo = pathToVideo ?? "defaultVideoName"
        self.isBanned = isBanned
        self.instructions = instructions
    }
}
