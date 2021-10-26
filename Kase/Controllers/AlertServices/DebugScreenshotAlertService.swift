//
//  DebugScreenshotAlertService.swift
//  Kase
//
//  Created by George Sequeira on 3/10/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit

class DebugScreenshotAlertService {
    func alert() -> DebugScreenshotViewController {
        let storyboard = UIStoryboard(name: "DebugScreenshot", bundle: .main)
        let debugVC = storyboard.instantiateViewController(identifier: "debugScreenshotSb") as! DebugScreenshotViewController

        return debugVC
    }
}
