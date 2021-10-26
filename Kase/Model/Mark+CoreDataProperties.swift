//
//  Mark+CoreDataProperties.swift
//  
//
//  Created by George Sequeira on 3/24/20.
//
//

import Foundation
import CoreData


extension Mark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mark> {
        return NSFetchRequest<Mark>(entityName: "Mark")
    }

    @NSManaged public var created: Date?
    @NSManaged public var notes: String?
    @NSManaged public var screenshotId: String?
    @NSManaged public var seconds: Int16
    @NSManaged public var hadError: Bool
    @NSManaged public var errorMsg: String?
    @NSManaged public var source: String
    @NSManaged public var episode: Episode?

}
