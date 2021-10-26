//
//  MarkAlertService.swift
//  Kase
//
//  Created by George Sequeira on 2/18/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import Foundation
import UIKit

class MarkAlertService {
    func alert(doneEditing: @escaping (Int, String) -> ()) -> MarkViewController {
        let storyboard = UIStoryboard(name: "MarkEditorStoryboard", bundle: .main)
        let markVC = storyboard.instantiateViewController(identifier: "markEditorSb") as! MarkViewController
        markVC.doneEditing = doneEditing
        return markVC
    }
}
