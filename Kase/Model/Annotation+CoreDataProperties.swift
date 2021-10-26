//
//  Annotation+CoreDataProperties.swift
//  
//
//  Created by George Sequeira on 3/12/20.
//
//

import Foundation
import CoreData


extension Annotation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Annotation> {
        return NSFetchRequest<Annotation>(entityName: "Annotation")
    }

    @NSManaged public var created: Date
    @NSManaged public var episodeName: String
    @NSManaged public var errorMsg: String
    @NSManaged public var hadError: Bool
    @NSManaged public var podcastName: String
    @NSManaged public var screenshotId: String
    @NSManaged public var timestamp: Int16
}
