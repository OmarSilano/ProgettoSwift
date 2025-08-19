//
//  Excercise+Extensions.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
import Foundation
import CoreData

extension Typology {
    
    
    // Costruttore custom
    convenience init(context: NSManagedObjectContext,
                     id: UUID = UUID(),
                     name: String,
                     detail: String? = "No Details...",
                     isDefault: Bool = false
                     ) {
        
        self.init(context: context)
        
        self.id = id
        self.name = name
        self.detail = detail
        self.isDefault = isDefault
    }
    
}
