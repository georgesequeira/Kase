//
//  CustomPersistentContainer.swift
//  Kase
//
//  Created by George Sequeira on 3/2/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit
import CoreData

class NSCustomPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.kinlet")
        storeURL = storeURL?.appendingPathComponent("Kinlet.sqlite")
        return storeURL!
    }

}
