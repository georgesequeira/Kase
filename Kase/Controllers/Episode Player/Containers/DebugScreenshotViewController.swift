//
//  DebugScreenshotViewController.swift
//  Kase
//
//  Created by George Sequeira on 3/10/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit

class DebugScreenshotViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    weak var trueImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let actualImage = trueImage {
            image.image = actualImage
        }
    }

    @IBAction func buttonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
