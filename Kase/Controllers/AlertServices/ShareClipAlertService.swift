//
//  ShareClipAlertService.swift
//  Kase
//
//  Created by George Sequeira on 3/9/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//


import AVKit
import UIKit

class ShareClipAlertService {
    func alert(mark: Mark, id: String, totalDuration: Int, avPlayer: AVPlayer) -> ShareClipViewController {
        let storyboard = UIStoryboard(name: "ShareClipStoryboard", bundle: .main)
        let shareclipVC = storyboard.instantiateViewController(identifier: "shareclipSb") as! ShareClipViewController
        shareclipVC.mark = mark
        shareclipVC.totalDuration = totalDuration
        shareclipVC.avPlayer = avPlayer
        shareclipVC.episodeId = id

        return shareclipVC
    }
}
