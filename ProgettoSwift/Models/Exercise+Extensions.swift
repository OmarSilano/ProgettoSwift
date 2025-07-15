//
//  Excercise+Extensions.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
import Foundation
import CoreData

extension Exercise {


    
    // Costruttore custom
    convenience init(context: NSManagedObjectContext,
                     id: UUID = UUID(),
                     name: String,
                     difficulty: Difficulty,
                     muscle: MuscleGroup,
                     method: Method,
                     pathToImage: String? = "defaultImageName",
                     pathToVideo: String? = "defaultVideoName",
                     isBanned: Bool = false,
                     instructions: String? = nil
                     ) {
        
        self.init(context: context)
        
        self.id = id
        self.name = name
        self.difficulty = difficulty.rawValue
        self.muscle = muscle.rawValue
        self.method = method.rawValue
        self.pathToImage = pathToImage
        self.pathToVideo = pathToVideo
        self.isBanned = isBanned
        self.instructions = instructions
    }
    
}
