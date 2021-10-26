//
//  ShareViewController.swift
//  KinletExt
//
//  Created by George Sequeira on 2/19/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit
import Social


class ShareViewController: UIViewController {
    private var minString: String?
    private var secString: String?
    private var notes: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        /* This could've been done from the Object Library but for some reason
           the blurred view kept being deallocated. Doing it programmatically
           resulted in the same behaviour, but after a couple retries it seems
           that it is ok. Weird.
        */
        // https://stackoverflow.com/questions/17041669/creating-a-blurring-overlay-view/25706250
        // only apply the blur if the user hasn't disabled transparency effects
        if UIAccessibility.isReduceTransparencyEnabled == false {
            view.backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            view.insertSubview(blurEffectView, at: 0)
        } else {
            view.backgroundColor = .black
        }
    }

}
